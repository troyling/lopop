//
//  ChatMessage.h
//  Lopop
//
//  Created by Ruofan Ding on 1/31/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChatMessage : NSObject

@property NSString *content;
@property NSTimeInterval timeStamp;

- (NSDictionary *) toDict;
+ (ChatMessage *) fromDict:(NSDictionary *) dict;

@end
