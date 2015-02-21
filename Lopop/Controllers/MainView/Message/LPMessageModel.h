//
//  ChatMessage.h
//  Lopop
//
//  Created by Ruofan Ding on 1/31/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LPMessageModel : NSObject

@property NSString *content;
@property NSTimeInterval timeStamp;
@property NSString *senderId;

- (NSDictionary *) toDict;
+ (LPMessageModel *) fromDict:(NSDictionary *) dict;

@end
