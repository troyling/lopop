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
typedef NS_ENUM(NSInteger, USER1OR2) {
    USER1,
    USER2
};
@property USER1OR2 userNumber;

- (NSDictionary *) toDict;
+ (MessageModel *) fromDict:(NSDictionary *) dict;

@end
