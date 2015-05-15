//
//  ChatModel.h
//  Lopop
//
//  Created by Ruofan Ding on 2/3/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Firebase/Firebase.h>
#import "LPMessageModel.h"

@interface LPChatModel : NSObject

@property NSString* contactId;

@property NSString* contactName;

@property int numberOfUnread;




@property BOOL stored;

//Use initWithContactId instead of init.
- (id) initWithContactId:(NSString *) contactId;

//Send the message to the contact, and save it to DB.
- (void) sendMessage:(LPMessageModel *) message;


- (LPMessageModel *) getLastMessage;

@end
