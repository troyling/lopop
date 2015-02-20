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
             @"timeStamp":[NSNumber numberWithDouble: self.timeStamp],
             @"userNumber":[NSNumber numberWithInt:self.userNumber]};
}

+ (LPMessageModel *)fromDict: (NSDictionary *) dict{
    LPMessageModel * msg = [[LPMessageModel alloc] init];
    msg.content = [dict objectForKey:@"content"];
    msg.userNumber = [(NSNumber *)[dict objectForKey:@"userNumber"] intValue];
    msg.timeStamp = [(NSNumber *)[dict objectForKey:@"timeStamp"] doubleValue];
    return msg;
}


@end
