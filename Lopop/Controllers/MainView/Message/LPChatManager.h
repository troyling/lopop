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

@interface LPChatManager : NSObject
+ (LPChatManager *) getInstance;
- (NSMutableArray *) getActiveChatArray;
- (NSMutableArray *) getAllChatArray;
- (void) newChatWithContactId:(NSString*) contactId withMessage: (NSString *) content;
- (void) newChatWithContactId:(NSString*) contactId;
- (void) deleteChatWithContactId:(NSString *) contactId;
- (NSArray*) getChatMessagesWith: (NSString *) contactId;
- (void) sendMessage:(NSString *) content to:(LPChatModel*) chatModel;
- (LPChatModel*) getChatModel: (NSString *) contactId;

//- (void) sendMessageWithContent:(NSString*) content withChatModel: (LPChatModel *) chatInstance;

/*
 typedef NS_ENUM(NSInteger, CHAT_STATUS) {
 PASSIVE = 0,
 ACTIVE = 1,
 DELETED = 2
 };*/



@end

static NSString* const ChatManagerChatViewUpdateNotification = @"ChatManagerChatViewUpdateNotification";
static NSString* const ChatManagerMessageViewUpdateNotification = @"ChatManagerMessageViewUpdateNotification";
static NSString* firebaseUrl = @"https://lopop.firebaseio.com/";
