//
//  ChatModel.m
//  Lopop
//
//  Created by Ruofan Ding on 2/3/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "LPChatModel.h"
#import "LPMessageModel.h"
#import "LPChatManager.h"
#import <Parse/Parse.h>

@implementation LPChatModel
NSString* userId;
Firebase *sendRef;

- (id) initWithContactId:(NSString *) contactId{
    userId = [[PFUser currentUser] objectId];
    self.contactId = contactId;
    sendRef = [[Firebase alloc] initWithUrl:
                    [NSString stringWithFormat:@"%@%@%@%@", firebaseUrl, @"users/", self.contactId, @"/pendingMessages"]];
    return self;
}

- (void) sendMessage:(LPMessageModel *) message{
    Firebase* path = [sendRef childByAutoId];
    [path setValue: message.toDict];
    message.messageId = path.key;
    [[LPChatManager getInstance] saveMessage:message];
}


/*
- (NSDictionary *)toDict{
    return @{@"contactId":self.contactId, @"chatId":self.chatId};
}*/

/*
+ (LPChatModel *)fromChatInfo: (NSDictionary *) dict{
    LPChatModel * chat = [LPChatModel alloc];
    chat.contactId = [dict objectForKey:@"contactId"];
}*/



@end
