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

NSString* userId;
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

- (void) initalChatArray{
    if (![PFUser currentUser]) {
        NSLog(@"get user fails");
        return;
    }
    userId =[[PFUser currentUser] objectId];
        
    allChatArray = [[NSMutableArray alloc] init];
    visibleChatArray = [[NSMutableArray alloc] init];
    
    //Retrieve from db
    NSMutableArray* storedChatArray = [self loadChatsFromDB];
    for(LPChatModel* chatModel in storedChatArray){
        [self setUpChatModel:chatModel];
        if(chatModel.visible){
            [visibleChatArray addObject:chatModel];
        }
    }
    [allChatArray addObjectsFromArray:storedChatArray];
    
    //Retrieve from firebase
    userRef = [[Firebase alloc] initWithUrl:
               [NSString stringWithFormat:@"%@%@%@%@", firebaseUrl, @"users/", userId, @"/newChats"]];
    [userRef observeEventType: FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
        LPChatModel* chatModel = [LPChatModel alloc];
        chatModel.contactId = snapshot.value;
        chatModel.visible = NO;
        
        bool exist = false;
        for(LPChatModel* existingChatModel in allChatArray){
            if([existingChatModel.contactId isEqualToString:chatModel.contactId]){
                exist = true;
                break;
            }
        }
        
        NSLog(@"%@",snapshot.key);
        if(!exist){
            [self setUpChatModel:chatModel];
            [self saveChatToDB:chatModel];
            [allChatArray addObject:chatModel];
        }
        
        [[userRef childByAppendingPath:snapshot.key] removeValue];
    }];
}

- (void) setUpChatModel: (LPChatModel *) chatModel{
    Firebase* chatRef = [[Firebase alloc]initWithUrl:[NSString stringWithFormat:@"%@%@%@", firebaseUrl, @"chats/",
                                                      [LPChatManager composeChatIdWithContact1: userId withContact2:chatModel.contactId]]];
    chatModel.sendRef = [[chatRef childByAppendingPath:@"messages"] childByAppendingPath: chatModel.contactId];
    
    //Initalize chat Status
    [chatModel.chatInfoRef observeEventType: FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        if(snapshot.value == [NSNull null]){
            //removeChatModel from DB.
        }else{
            chatModel.userStatus = snapshot.value[userId][@"status"];
            chatModel.contactStatus = snapshot.value[chatModel.contactId][@"status"];
        }
    }];
    
    //Set up observer for chat info (trigger when chat status changed)
    chatModel.chatInfoRef = [chatRef childByAppendingPath:@"info"];
    [chatModel.chatInfoRef observeEventType: FEventTypeChildChanged withBlock:^(FDataSnapshot *snapshot) {
        if([snapshot.key isEqualToString:chatModel.contactId]){
            chatModel.contactStatus = snapshot.value[@"status"];
        }else{
            NSLog(@"something goes wrong in setUpChatModel/chatInfoRef listener.");
        }
    }];
    
    //Set up observer for chat messages (trigger when new message came)
    chatModel.receiveRef = [[chatRef childByAppendingPath:@"messages"] childByAppendingPath: userId];
    [chatModel.receiveRef observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
        LPMessageModel* messageModel = [LPMessageModel fromDict:snapshot.value];
        messageModel.messageId = snapshot.key;
        
        [self saveMessageFrom:messageModel];
        [self messageViewUpdateNotifyWithMessage: messageModel];
        
        if(!chatModel.visible){ //make it visible.
            chatModel.visible = YES;
            [self updateChatFromDB:chatModel];
            [visibleChatArray addObject: chatModel];
            [self chatViewUpdateNotify];
        }
        [chatModel.receiveRef authWithCustomToken:AUTH_TOKEN withCompletionBlock:^(NSError *error, FAuthData *authData){
            [[chatModel.receiveRef childByAppendingPath:snapshot.key] removeValue];
        }];
    }];
}

- (NSMutableArray *) getAllChatArray{
    return allChatArray;
}

- (NSMutableArray *) getVisibleChatArray{
    return visibleChatArray;
}

+ (NSString*) composeChatIdWithContact1:(NSString*) id1 withContact2:(NSString *) id2{
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
 0 the chat does not exist on user[id] side,
 1 the chat exists on user[id] side
 **/
- (LPChatModel*) startChatWithContactId:(NSString*) contactId {
    NSLog(@"%@", userId);
    for(LPChatModel* existingChat in allChatArray){
        if([existingChat.contactId isEqualToString:contactId]){
            if(existingChat.contactStatus == 0){ // Contact doesn't have the listener
                Firebase* pendingAddRef = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@%@", firebaseUrl, @"pending/add"]];
                [pendingAddRef authWithCustomToken:AUTH_TOKEN withCompletionBlock:^(NSError *error, FAuthData *authData) {
                    [[pendingAddRef childByAutoId] setValue:@{@"fromUser": userId, @"toUser": contactId}];
                }];
            }
            return existingChat;
        }
    }
    
    
    Firebase* pendingAddRef = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@%@", firebaseUrl, @"pending/add"]];
    [pendingAddRef authWithCustomToken:AUTH_TOKEN withCompletionBlock:^(NSError *error, FAuthData *authData) {
        [[pendingAddRef childByAutoId] setValue:@{@"fromUser": userId, @"toUser": contactId}];
    }];
    
    LPChatModel* chatModel = [[LPChatModel alloc] init];
    chatModel.contactId = contactId;
    chatModel.visible = YES;
    [self setUpChatModel:chatModel];
    [self saveChatToDB: chatModel];
    [allChatArray addObject:chatModel];
    [visibleChatArray addObject:chatModel];
    [self chatViewUpdateNotify];
    return chatModel;
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

- (void) saveChatToDB: (LPChatModel*) chatModel{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSManagedObject *newContact;
    newContact = [NSEntityDescription insertNewObjectForEntityForName:@"Chat" inManagedObjectContext:context];
    [newContact setValue: chatModel.contactId forKey:@"contactId"];
    [newContact setValue: [NSNumber numberWithBool: chatModel.visible] forKey:@"visible"];
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
             chatModel.visible = [objects[i] valueForKey:@"visible"];
             [chatArray addObject:chatModel];
         }
     }
    return chatArray;
}

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
}



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
