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
             @"fromUserId":self.fromUserId,
             @"toUserId":self.toUserId};
}

+ (LPMessageModel *)fromDict: (NSDictionary *) dict{
    LPMessageModel * msg = [[LPMessageModel alloc] init];
    msg.content = [dict objectForKey:@"content"];
    msg.toUserId = [dict objectForKey:@"toUserId"];
    msg.fromUserId = [dict objectForKey:@"fromUserId"];
    return msg;
}

- (NSComparisonResult)compare:(LPMessageModel *)other {
    return [self.messageId compare:other.messageId];
}

@end
