//
//  LPChatManager.m
//  Lopop
//
//  Created by Ruofan Ding on 2/20/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "LPChatManager.h"
#import <Parse/Parse.h>
#import <Firebase/Firebase.h>
#import "LPChatModel.h"
#import <Foundation/NSObject.h>
#import "LPMessageModel.h"
#import "AppDelegate.h"
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>



@implementation LPChatManager
static LPChatManager * instance = nil;
NSMutableArray* allChatArray = nil;
NSMutableArray* visibleChatArray = nil;
NSMutableArray* pendingMessageArray = nil;

NSString* userId;
Firebase* userMessageRef;
NSString* AUTH_TOKEN = @"pVNcW9P2yNe90ycNe2DN8sNysdaR12Q2TS8Jm9fn";

const NSInteger  PASSIVE = 0;
const NSInteger ACTIVE = 1;
const NSInteger DELETED = 2;
const NSInteger CONTACTDELETED = 3;

+ (LPChatManager *)getInstance{
    if(instance == nil){
        instance = [[LPChatManager alloc] init];
    }
    return instance;
}

- (id)init {
    if(instance != nil){
        NSLog(@"init for Chat Manager should only be called once.");
    }else{
        [self initalChatArray];
    }
    return self;
}

- (void) chatViewUpdateNotify{
    [[NSNotificationCenter defaultCenter]
     postNotificationName: ChatManagerChatViewUpdateNotification
     object:nil];
}

- (void) messageViewUpdateNotifyWithMessage{
    [[NSNotificationCenter defaultCenter]
     postNotificationName: ChatManagerMessageViewUpdateNotification
     object:nil];
}

- (void) initalChatArray{
    if (![PFUser currentUser]) {
        NSLog(@"get user fails");
        return;
    }
    userId =[[PFUser currentUser] objectId];
        
    allChatArray = [[NSMutableArray alloc] init];
    visibleChatArray = [[NSMutableArray alloc] init];
    pendingMessageArray = [[NSMutableArray alloc] init];
    
    //Retrieve from db
    NSMutableArray* storedChatArray = [self loadChatsFromDB];

    [allChatArray addObjectsFromArray:storedChatArray];
    
    //Retrieve from firebase
    userMessageRef = [[Firebase alloc] initWithUrl:
               [NSString stringWithFormat:@"%@%@%@%@", firebaseUrl, @"users/", userId, @"/pendingMessages"]];
    
    [userMessageRef observeEventType: FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
        NSDictionary* messageDict = snapshot.value;
        LPMessageModel* messageInstance = [LPMessageModel fromDict:messageDict];
        messageInstance.messageId = snapshot.key;
        
        [pendingMessageArray addObject:messageInstance];
        [self messageViewUpdateNotifyWithMessage]; //TODO
    }];
}


- (void) saveChatToDB: (LPChatModel*) chatModel{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSManagedObject *newContact;
    newContact = [NSEntityDescription insertNewObjectForEntityForName:@"Chat" inManagedObjectContext:context];
    [newContact setValue: chatModel.contactId forKey:@"contactId"];
    NSError *error;
    [context save:&error];
    if(error){
        NSLog(@"%@", error);
    }
}

- (NSMutableArray*) loadChatsFromDB{
     AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
     NSManagedObjectContext *context = [appDelegate managedObjectContext];
     NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Chat" inManagedObjectContext:context];
     NSFetchRequest *request = [[NSFetchRequest alloc] init];
     [request setEntity:entityDesc];
     
     NSError *error;
     NSArray *objects = [context executeFetchRequest:request
                                               error:&error];
     
     NSMutableArray* chatArray = [[NSMutableArray alloc] init];
     if ([objects count] == 0)
     {
         NSLog(@"No matches");
     }
     else
     {
         LPChatModel* chatModel;
         for (int i = 0; i < [objects count]; i++)
         {
             chatModel = [[LPChatModel alloc] init];
             chatModel.contactId = [objects[i] valueForKey:@"contactId"];
             [chatArray addObject:chatModel];
         }
     }
    return chatArray;
}

/*
- (void) updateChatFromDB: (LPChatModel*) chatModel{
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Chat" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    
    NSPredicate *pred =[NSPredicate predicateWithFormat:@"(contactId == %@)", chatModel.contactId];
    [request setPredicate:pred];

    
    NSError *error;
    NSArray *objects = [context executeFetchRequest:request
                                              error:&error];
    if ([objects count] != 1)
    {
        NSLog(@"Error in updateChatFromDB in chatManager");
    }
    else
    {
        NSManagedObject* obj = [objects objectAtIndex:0];
        [obj setValue:[NSNumber numberWithBool:chatModel.visible] forKey:@"visible"];
    }
    [context save:&error];
}*/



- (NSMutableArray*) getMessagesWithUserId: (NSString *)contactId{
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Message" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    
    NSPredicate *pred =[NSPredicate predicateWithFormat:@"(fromUserId == %@) OR (toUserId == %@)", contactId, contactId];
   [request setPredicate:pred];
    
    NSError *error;
    NSArray *objects = [context executeFetchRequest:request
                                              error:&error];
    
    NSMutableArray* messageArray = [[NSMutableArray alloc] init];
    
    if ([objects count] == 0)
    {
        NSLog(@"No matches");
    }
    else
    {
        LPMessageModel* messageModel;
        for (int i = 0; i < [objects count]; i++)
        {
            messageModel = [[LPMessageModel alloc] init];
            messageModel.content = [objects[i] valueForKey:@"content"];
            messageModel.toUserId = [objects[i] valueForKey:@"toUserId"];
            messageModel.fromUserId = [objects[i] valueForKey:@"fromUserId"];
            messageModel.messageId = [objects[i] valueForKey:@"messageId"];
            [messageArray addObject:messageModel];
        }
    }
    return messageArray;
}

- (void) saveMessage: (LPMessageModel*) messageModel{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSManagedObject *newContact;
    newContact = [NSEntityDescription insertNewObjectForEntityForName:@"Message" inManagedObjectContext:context];
    [newContact setValue: messageModel.content forKey:@"content"];
    [newContact setValue: messageModel.toUserId forKey:@"toUserId"];
    [newContact setValue: messageModel.fromUserId forKey:@"fromUserId"];
    [newContact setValue: messageModel.messageId forKey:@"messageId"];
    NSError *error;
    [context save:&error];
    if(error){
        NSLog(@"%@", error);
    }
}

- (void) sendMessage:(NSString *) content to:(LPChatModel*) chatModel{
    LPMessageModel* messageInstance = [[LPMessageModel alloc]init];
    messageInstance.content = content;
    messageInstance.toUserId = userId;
    messageInstance.fromUserId = chatModel.contactId;
    
    Firebase* messageRef = [chatModel.sendRef childByAutoId];
    [messageRef setValue:[messageInstance toDict]];
    messageInstance.messageId = messageRef.key;
    [self saveMessage:messageInstance];
}

- (NSArray*) getChatMessagesWithUser: (NSString *) contactId{
    NSMutableArray * messageArray;
    messageArray = [self getMessagesWithUserId:contactId];

    return [messageArray sortedArrayUsingSelector:@selector(compare:)];
}

- (NSMutableArray *) getChatArray{
    return allChatArray;
}

-(LPChatModel*) getChatModel: (NSString *) contactId{
    for(LPChatModel* chat in allChatArray){
        if([chat.contactId isEqualToString:contactId]){
            return chat;
        }
    }
    return nil;
}

@end
