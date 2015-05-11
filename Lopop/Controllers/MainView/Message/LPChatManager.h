//
//  LPChatManager.h
//  Lopop
//
//  Created by Ruofan Ding on 2/20/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Firebase/Firebase.h>
#import "LPChatModel.h"
#import "LPMessageModel.h"


static NSString* const ChatManagerChatViewUpdateNotification = @"ChatManagerChatViewUpdateNotification";
static NSString* const ChatManagerMessageViewUpdateNotification = @"ChatManagerMessageViewUpdateNotification";
static NSString* firebaseUrl = @"https://lopop.firebaseio.com/";



@interface LPChatManager : NSObject
+ (LPChatManager *) getInstance;

- (NSMutableArray *) getChatArray;

- (NSArray*) getChatMessagesWithUser: (NSString *) contactId;

- (LPChatModel*) getChatModel: (NSString *) contactId;

- (void) removePendingMessage: (LPMessageModel *) message;

- (void) saveMessage: (LPMessageModel*) messageModel;



//- (void) sendMessageWithContent:(NSString*) content withChatModel: (LPChatModel *) chatInstance;

/*
 typedef NS_ENUM(NSInteger, CHAT_STATUS) {
 PASSIVE = 0,
 ACTIVE = 1,
 DELETED = 2
 };*/



@end

