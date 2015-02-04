//
//  ChatModel.h
//  Lopop
//
//  Created by Ruofan Ding on 2/3/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChatModel : NSObject

@property NSString *contactId;
@property NSString *chatId;
//@property NSTimeInterval timeStamp;

- (NSDictionary *) toDict;
+ (ChatModel *) fromDict:(NSDictionary *) dict;



@end
