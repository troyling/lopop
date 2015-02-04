//
//  ChatMessage.h
//  Lopop
//
//  Created by Ruofan Ding on 1/31/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MessageModel : NSObject

@property NSString *content;
@property NSTimeInterval timeStamp;

- (NSDictionary *) toDict;
+ (MessageModel *) fromDict:(NSDictionary *) dict;

@end
