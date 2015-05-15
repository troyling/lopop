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


@interface LPChatManager()

@property NSMutableArray* allChatArray;
@property NSMutableArray* pendingMessageArray;
@property NSString* firebaseId;
@property Firebase* userMessageRef;

@end


@implementation LPChatManager
static LPChatManager * instance = nil;


NSString* firebaseId;
Firebase* userMessageRef;



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
        if (![PFUser currentUser]) {
            NSLog(@"get user fails");
        }
        NSLog(@"%@", [[PFUser currentUser] objectId]);
        userId = [[PFUser currentUser] objectId];
        firebaseId = [PFUser currentUser][@"firebaseId"];
        [self loginFirebase];
        [self initalChatArray];
    }
    return self;
}

- (void) chatViewUpdateNotify{
    [[NSNotificationCenter defaultCenter]
     postNotificationName: ChatManagerChatViewUpdateNotification
     object:nil];
}

- (void) messageViewUpdateNotifyWithMessage:(LPMessageModel*) message{
    [[NSNotificationCenter defaultCenter]
     postNotificationName: ChatManagerMessageViewUpdateNotification
     object:message];
}

- (void) loginFirebase{
    NSLog(@"Here");
    //Receiver for firebase
    Firebase* ref = [[Firebase alloc] initWithUrl:firebaseUrl];

    [ref authUser:[userId stringByAppendingString:@"@lopop.com"] password:userId
         withCompletionBlock:^(NSError *error, FAuthData *authData) {
             if (error) {
                 // an error occurred while attempting login
                 NSLog(@"%@", error);
             } else {
                 // user is logged in, check authData for data
                 NSLog(@"%@", authData);
             }
         }
     ];
}

- (void) initalChatArray{
    
        
    self.allChatArray = [[NSMutableArray alloc] init];
    self.pendingMessageArray = [[NSMutableArray alloc] init];
    
    //Retrieve from db
    [self.allChatArray addObjectsFromArray:[self loadChatsFromDB]];
    
    
    userMessageRef = [[Firebase alloc] initWithUrl:
                      [NSString stringWithFormat:@"%@%@%@%@", firebaseUrl, @"users/", firebaseId, @"/pendingMessages"]];
    
    //Set up message listener
    [userMessageRef observeEventType: FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
        NSDictionary* messageDict = snapshot.value;
        LPMessageModel* messageInstance = [LPMessageModel fromDict:messageDict];
        messageInstance.messageId = snapshot.key;
        
        [self.pendingMessageArray addObject:messageInstance];
        
        
        LPChatModel* chatModel = nil;
        for(LPChatModel* a_chat in self.allChatArray){
            if([messageInstance.fromUserId isEqualToString:a_chat.contactId]){
                chatModel = a_chat;
                break;
            }
        }
        
        if(chatModel != nil){
            
            [self messageViewUpdateNotifyWithMessage: messageInstance]; //TODO
            chatModel.numberOfUnread += 1;
            
        }else{
            LPChatModel* newChat = [[LPChatModel alloc] initWithContactId:messageInstance.fromUserId];
            newChat.numberOfUnread += 1;
            
            [self.allChatArray addObject:newChat];
            [self saveChatToDB:newChat];
            [self chatViewUpdateNotify];
        }
        [self chatViewUpdateNotify];
        
    }withCancelBlock:^(NSError* error){
        
        NSLog(@"%@", error);
    
    }];
    
    [userMessageRef observeEventType: FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        NSLog(@"%@", snapshot.value);
    }];
}


- (void) saveChatToDB: (LPChatModel*) chatModel{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [self chatViewUpdateNotify];
    
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
             
             NSString *contactId = [objects[i] valueForKey:@"contactId"];
             chatModel = [[LPChatModel alloc] initWithContactId: contactId];
             [chatArray addObject:chatModel];
         }
     }
    return chatArray;
}

- (void) removePendingMessage: (LPMessageModel*) message{
    [self saveMessage:message];
    [[userMessageRef childByAppendingPath:message.messageId] removeValue];
    
    [self.pendingMessageArray removeObject:message];
}

- (void) deleteChat: (LPChatModel*) chatModel{
    [self deleteChatFromDB: chatModel];
    [self deleteConversationFromDB:chatModel];
    [self.allChatArray removeObject:chatModel];
}

- (void) deleteChatFromDB: (LPChatModel*) chatModel{
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
        [context deleteObject:obj];
    }
    [context save:&error];
}

- (void) deleteConversationFromDB: (LPChatModel*) chatModel{
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Message" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    
    NSPredicate *pred =[NSPredicate predicateWithFormat:@"(fromUserId == %@) OR (toUserId == %@)", chatModel.contactId, chatModel.contactId];
    [request setPredicate:pred];
    
    NSError *error;
    NSArray *objects = [context executeFetchRequest:request
                                              error:&error];
    
    for(NSManagedObject* obj in objects){
        [context deleteObject:obj];
    }
    NSLog(@"%lu messages got removed!", (unsigned long)objects.count);
    [context save:&error];
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


- (NSArray*) getChatMessagesWithUser: (NSString *) contactId{
    NSMutableArray * messageArray;
    
    //get messages from DB
    messageArray = [self getMessagesWithUserId:contactId];

    //get pending messages that have not been saved to DB
    [messageArray addObjectsFromArray:[self getPendingMessagesWithUser:contactId]];
    
    return [messageArray sortedArrayUsingSelector:@selector(compare:)];
}

- (NSArray*) getPendingMessagesWithUser: (NSString *) contactId{
    NSMutableArray * messageArray = [[NSMutableArray alloc] init];
    for(LPMessageModel* message in self.pendingMessageArray){
        if([message.fromUserId isEqualToString:contactId]){
            [messageArray addObject:message];
            [self saveMessage:message];
            [[userMessageRef childByAppendingPath:message.messageId] removeValue];
        }
    }
    
    for(LPMessageModel * message in messageArray){
        [self.pendingMessageArray removeObject:message];
    }
    
    return [messageArray sortedArrayUsingSelector:@selector(compare:)];
}

- (NSMutableArray *) getChatArray{
    return self.allChatArray;
}

- (LPChatModel *) getChatModel: (NSString *) contactId{
    for(LPChatModel* chat in self.allChatArray){
        if([chat.contactId isEqualToString:contactId]){
            return chat;
        }
    }
    
    LPChatModel* newChat = [[LPChatModel alloc] initWithContactId:contactId];
    newChat.stored = NO;
    [self.allChatArray addObject:newChat];
    return newChat;
}

@end
