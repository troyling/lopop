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
NSMutableArray* activeChatArray = nil;

NSString* userId;
NSNumber* activeChat;
Firebase* userRef;
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

- (void) messageViewUpdateNotifyWithMessage:(LPMessageModel*) message{
    [[NSNotificationCenter defaultCenter]
     postNotificationName: ChatManagerMessageViewUpdateNotification
     object:message];
}

- (void)initalChatArray {
    if ([PFUser currentUser]) {
        userId =[[PFUser currentUser] objectId];
        
        allChatArray = [[NSMutableArray alloc] init];
        activeChatArray = [[NSMutableArray alloc] init];
        userRef = [[Firebase alloc] initWithUrl:
                   [NSString stringWithFormat:@"%@%@%@", firebaseUrl, @"users/", userId]];
        
        [userRef observeEventType: FEventTypeChildAdded withBlock:^(FDataSnapshot *userSnapshot) {
            NSString* chatId = [LPChatManager composeChatIdWithContac1: userId withContact2:userSnapshot.key];
            Firebase* chatRef = [[Firebase alloc]initWithUrl:[NSString stringWithFormat:@"%@%@%@", firebaseUrl, @"chats/", chatId
                                                              ]];
            Firebase* chatInfoRef = [chatRef childByAppendingPath:@"info"];
            //Firebase* chatMessageRef = [chatRef childByAppendingPath:@"messages"];
            NSString* contactId = userSnapshot.key;
            [chatInfoRef observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *chatInfoSnapShot) {
                [chatInfoRef removeAllObservers];
                NSDictionary *chatInfoDict = chatInfoSnapShot.value;
                LPChatModel* chatModel = [LPChatModel alloc];
                
                chatModel.chatInfoRef = chatInfoRef;
                //Set up observer for chat info (trigger when chat status changed)
                [chatModel.chatInfoRef observeEventType: FEventTypeChildChanged withBlock:^(FDataSnapshot *snapshot) {
                    if([snapshot.key isEqualToString:userId]){
                        chatModel.userStatus = snapshot.value[@"status"];
                    }else{
                        chatModel.contactStatus = snapshot.value[@"status"];
                    }
                }];
                
                chatModel.messageArray = [[NSMutableArray alloc] init];
                [chatRef childByAppendingPath:[@"messages" stringByAppendingString: contactId]];
                chatModel.sendRef = [[chatRef childByAppendingPath:@"messages"] childByAppendingPath:contactId];
                chatModel.receiveRef = [[chatRef childByAppendingPath:@"messages"] childByAppendingPath:userId];
                
                //Set up observer for chat messages (trigger when new message came)
                [chatModel.receiveRef observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
                    LPMessageModel* messageModel = [LPMessageModel fromDict:snapshot.value];
                    messageModel.messageId = snapshot.key;
                    
                    [self saveMessageFrom:messageModel];
                    [self messageViewUpdateNotifyWithMessage: messageModel];
                    
                    [chatModel.receiveRef authWithCustomToken:AUTH_TOKEN withCompletionBlock:^(NSError *error, FAuthData *authData) {
                        [[chatModel.receiveRef childByAppendingPath:snapshot.key] removeValue];
                    }];
                    //[chatModel.messageArray addObject:messageModel];
                }];
                
                chatModel.contactId = contactId;
                chatModel.userStatus = chatInfoDict[userId][@"status"];
                chatModel.contactStatus = chatInfoDict[contactId][@"status"];

                if([chatModel.userStatus isEqualToNumber: @1]){
                    NSLog(@"One active chat starts");
                    NSLog(@"%@", chatModel.contactId);
                    [activeChatArray addObject:chatModel];
                    [self chatViewUpdateNotify];
                }
                
                [allChatArray addObject:chatModel];
            }];
            
        }];
        
        [userRef observeEventType:FEventTypeChildRemoved withBlock:^(FDataSnapshot *userSnapshot) {
            NSString* contactId = userSnapshot.key;
            
            for(LPChatModel *chatModel in allChatArray){
                if([chatModel.contactId isEqualToString:contactId]){
                    [allChatArray removeObject:chatModel];
                    if([activeChatArray containsObject:chatModel]){
                        NSLog(@"One active chat ends");
                        [chatModel.chatInfoRef removeAllObservers];
                        [activeChatArray removeObject:chatModel];
                        [self chatViewUpdateNotify];
                    }
                }
            }
        }];
        
    }
}

- (NSMutableArray *) getAllChatArray{
    return allChatArray;
}

- (NSMutableArray *) getActiveChatArray{
    return activeChatArray;
}

+ (NSString*) composeChatIdWithContac1:(NSString*) id1 withContact2:(NSString *) id2{
    if([id1 compare:id2] == NSOrderedAscending){
        return [NSString stringWithFormat:@"%@%@%@", @"chat", id1, id2];
    }else{
        return [NSString stringWithFormat:@"%@%@%@", @"chat", id2, id1];
    }
}

- (NSArray *) decomposeChat:(NSString*) chatId{
    NSString* userId1, *userId2;
    if(![chatId hasPrefix:@"chat"]){
        return nil;
    }
    userId1 = [chatId substringWithRange:NSMakeRange(4, 13)];
    userId1 = [chatId substringWithRange:NSMakeRange(14, 23)];
    return [NSArray arrayWithObjects:userId1, userId2, nil];
}


/**
 
 chatId/info/id/status
 0 the chat exists on user[id] side, but it's not active
 1 the chat exists on user[id] side, and it's active
 2 the chat has been deleted from user[id] side
 
 **/
- (void)newChatWithContactId:(NSString*) contactId {
    Firebase* pendingAddRef = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@%@", firebaseUrl, @"pending/add"]];
    [pendingAddRef authWithCustomToken:AUTH_TOKEN withCompletionBlock:^(NSError *error, FAuthData *authData) {
        [[pendingAddRef childByAutoId] setValue:@{@"fromeUser": userId, @"toUser": contactId}];
    }];
}


- (void) deleteChatWithContactId:(NSString *) contactId{
    Firebase* pendingDeleteRef = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@%@", firebaseUrl, @"pending/delete"]];
    [pendingDeleteRef authWithCustomToken:AUTH_TOKEN withCompletionBlock:^(NSError *error, FAuthData *authData) {
        [[pendingDeleteRef childByAutoId] setValue:@{@"fromUser": userId, @"toUser": contactId}];
    }];
}

- (void) sendMessage:(NSString *) content to:(LPChatModel*) chatModel{
    LPMessageModel* messageModel = [[LPMessageModel alloc]init];
    messageModel.content = content;
    messageModel.senderId = userId;

    [chatModel.sendRef authWithCustomToken:AUTH_TOKEN withCompletionBlock:^(NSError *error, FAuthData *authData) {
        Firebase* messageRef = [chatModel.sendRef childByAutoId];
        [messageRef setValue:[messageModel toDict]];
        messageModel.messageId = messageRef.key;
        [self saveMessageTo:messageModel toUser:chatModel.contactId];
        [self messageViewUpdateNotifyWithMessage:messageModel];
    }];
}
/*
- (void) sendMessage:(NSString *) content to:(NSString*) contactId{
    LPMessageModel* messageModel = [[LPMessageModel alloc]init];
    messageModel.content = content;
    messageModel.senderId = userId;
    

    for(LPChatModel* chatModel in allChatArray){
        if([chatModel.contactId isEqualToString: contactId]){
            [chatModel.sendRef authWithCustomToken:AUTH_TOKEN withCompletionBlock:^(NSError *error, FAuthData *authData) {
                Firebase* messageRef = [[chatModel.sendRef childByAppendingPath:contactId]childByAutoId];
                [messageRef setValue:[messageModel toDict]];
                messageModel.messageId = messageRef.key;
                [self saveMessageTo:messageModel];
            }];
        }
    }
    [self newChatWithContactId: contactId];
}*/


- (NSMutableArray*) getMessageReceivedFrom: (NSString *)contactId{
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"MessageReceived" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    
    NSPredicate *pred =[NSPredicate predicateWithFormat:@"(fromUser == %@)", contactId];
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
            messageModel.senderId = [objects[i] valueForKey:@"fromUser"];
            messageModel.messageId = [objects[i] valueForKey:@"messageId"];
            [messageArray addObject:messageModel];
            NSLog(@"%@", messageModel);
        }
    }
    return messageArray;
}

- (NSMutableArray*) getMessageSentTo: (NSString *)contactId{
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"MessageSent" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    NSPredicate *pred =[NSPredicate predicateWithFormat:@"(toUser = %@)", contactId];
    //NSPredicate *pred =[NSPredicate predicateWithFormat:@"ALL"];

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
            messageModel.senderId = userId;
            messageModel.messageId = [objects[i] valueForKey:@"messageId"];
            [messageArray addObject:messageModel];
            NSLog(@"%@", messageModel);
        }
    }
    return messageArray;
}

- (void) saveMessageTo: (LPMessageModel*) messageModel toUser: (NSString*) contacId{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSManagedObject *newContact;
    newContact = [NSEntityDescription insertNewObjectForEntityForName:@"MessageSent" inManagedObjectContext:context];
    [newContact setValue: messageModel.content forKey:@"content"];
    [newContact setValue: contacId forKey:@"toUser"];
    [newContact setValue: messageModel.messageId forKey:@"messageId"];
    NSError *error;
    [context save:&error];
    if(error){
        NSLog(@"%@", error);
    }
}

- (void) saveMessageFrom: (LPMessageModel *) messageModel{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSManagedObject *newContact;
    newContact = [NSEntityDescription insertNewObjectForEntityForName:@"MessageReceived" inManagedObjectContext:context];
    [newContact setValue: messageModel.content forKey:@"content"];
    [newContact setValue: messageModel.senderId forKey:@"fromUser"];
    [newContact setValue: messageModel.messageId forKey:@"messageId"];
    NSError *error;
    [context save:&error];
    if(error){
        NSLog(@"%@", error);
    }
}



- (NSArray*) getChatMessagesWith: (NSString *) contactId{
    NSMutableArray * array1, *array2;
    NSMutableArray * array = [[NSMutableArray alloc] init];
    array1 = [self getMessageReceivedFrom:contactId];
    array2 = [self getMessageSentTo:contactId];
    [array addObjectsFromArray:array2];
    [array addObjectsFromArray:array1];
    
    return [array sortedArrayUsingSelector:@selector(compare:)];
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
