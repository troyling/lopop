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

- (void) viewUpdateNotify{
    [[NSNotificationCenter defaultCenter]
     postNotificationName: ChatManagerChatViewUpdateNotification
     object:nil];
}

- (void)initalChatArray {
    if ([PFUser currentUser]) {
        userId =[[PFUser currentUser] objectId];
        
        allChatArray = [[NSMutableArray alloc] init];
        activeChatArray = [[NSMutableArray alloc] init];
        userRef = [[Firebase alloc] initWithUrl:
                   [NSString stringWithFormat:@"%@%@%@", firebaseUrl, @"users/", userId]];
        
        [userRef observeEventType: FEventTypeChildAdded withBlock:^(FDataSnapshot *userSnapshot) {
            Firebase* chatRef = [[Firebase alloc]initWithUrl:[NSString stringWithFormat:@"%@%@%@", firebaseUrl, @"chats/", [LPChatManager composeChatIdWithContac1: userId withContact2:userSnapshot.key]]];
            Firebase* chatInfoRef = [chatRef childByAppendingPath:@"info"];
            //Firebase* chatMessageRef = [chatRef childByAppendingPath:@"messages"];
            NSString* contactId = userSnapshot.key;
            [chatInfoRef observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *chatInfoSnapShot) {
                [chatInfoRef removeAllObservers];
                NSDictionary *chatInfoDict = chatInfoSnapShot.value;
                LPChatModel* chatModel = [LPChatModel alloc];
                
                chatModel.chatInfoRef = chatInfoRef;
                
                [chatModel.chatInfoRef observeEventType: FEventTypeChildChanged withBlock:^(FDataSnapshot *snapshot) {
                    if([snapshot.key isEqualToString:userId]){
                        chatModel.userStatus = snapshot.value[@"status"];
                    }else{
                        chatModel.contactStatus = snapshot.value[@"status"];
                    }
                }];
                
                chatModel.contactId = contactId;
                chatModel.userStatus = chatInfoDict[userId][@"status"];
                chatModel.contactStatus = chatInfoDict[contactId][@"status"];
                
                if([chatModel.userStatus isEqualToNumber: @1]){
                    NSLog(@"One active chat starts");
                    NSLog(@"%@", chatModel.contactId);
                    [activeChatArray addObject:chatModel];
                    [self viewUpdateNotify];
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
                        [self viewUpdateNotify];
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

@end
