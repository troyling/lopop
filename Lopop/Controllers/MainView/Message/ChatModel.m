//
//  ChatModel.m
//  Lopop
//
//  Created by Ruofan Ding on 2/3/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "ChatModel.h"

@implementation ChatModel

- (NSDictionary *)toDict{
    return @{@"contactId":self.contactId, @"chatId":self.chatId};
}

+ (ChatModel *)fromDict: (NSDictionary *) dict{
    ChatModel * chat = [ChatModel alloc];
    chat.contactId = [dict objectForKey:@"contactId"];
    chat.chatId = [dict objectForKey:@"chatId"];
    return chat;
}

@end
