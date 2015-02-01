//
//  ChatMessage.m
//  Lopop
//
//  Created by Ruofan Ding on 1/31/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "ChatMessage.h"

@implementation ChatMessage




- (NSDictionary *)toDict{
    return @{@"content":self.content, @"timeStamp":[NSNumber numberWithDouble: self.timeStamp]};
}

+ (ChatMessage *)fromDict: (NSDictionary *) dict{
    ChatMessage * msg = [[ChatMessage alloc] init];
    msg.content = [dict objectForKey:@"content"];
    msg.timeStamp = [(NSNumber *)[dict objectForKey:@"timeStamp"] doubleValue];
    return msg;
}


@end
