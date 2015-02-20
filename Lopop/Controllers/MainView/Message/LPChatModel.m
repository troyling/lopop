//
//  ChatModel.m
//  Lopop
//
//  Created by Ruofan Ding on 2/3/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "LPChatModel.h"

@implementation LPChatModel

- (NSDictionary *)toDict{
    return @{@"contactId":self.contactId, @"chatId":self.chatId};
}

+ (LPChatModel *)fromDict: (NSDictionary *) dict{
    LPChatModel * chat = [LPChatModel alloc];
    chat.contactId = [dict objectForKey:@"contactId"];
    chat.chatId = [dict objectForKey:@"chatId"];
    return chat;
}

@end
