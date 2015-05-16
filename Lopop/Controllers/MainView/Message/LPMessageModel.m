//
//  ChatMessage.m
//  Lopop
//
//  Created by Ruofan Ding on 1/31/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "LPMessageModel.h"
#import "Firebase/Firebase.h"

@implementation LPMessageModel




- (NSDictionary *)toDict{
    return @{@"content":self.content,
             @"fromUserId":self.fromUserId,
             @"toUserId":self.toUserId,
             @"timestamp": kFirebaseServerValueTimestamp};
}

+ (LPMessageModel *)fromDict: (NSDictionary *) dict{
    LPMessageModel * msg = [[LPMessageModel alloc] init];
    msg.content = [dict objectForKey:@"content"];
    msg.toUserId = [dict objectForKey:@"toUserId"];
    msg.fromUserId = [dict objectForKey:@"fromUserId"];
    msg.timestamp = [[NSDate alloc] initWithTimeIntervalSince1970:[[dict objectForKey:@"timestamp"] doubleValue] /1000];
    
    NSLog(@"time: %@", msg.timestamp);
    return msg;
}

- (NSComparisonResult)compare:(LPMessageModel *)other {
    return [self.timestamp compare:other.timestamp];
}

@end
