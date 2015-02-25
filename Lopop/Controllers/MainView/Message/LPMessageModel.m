//
//  ChatMessage.m
//  Lopop
//
//  Created by Ruofan Ding on 1/31/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "LPMessageModel.h"

@implementation LPMessageModel




- (NSDictionary *)toDict{
    return @{@"content":self.content,
             @"senderId":self.senderId};
}

+ (LPMessageModel *)fromDict: (NSDictionary *) dict{
    LPMessageModel * msg = [[LPMessageModel alloc] init];
    msg.content = [dict objectForKey:@"content"];
    msg.senderId = [dict objectForKey:@"senderId"];
    return msg;
}

- (NSComparisonResult)compare:(LPMessageModel *)other {
    return [self.messageId compare:other.messageId];
}

@end
