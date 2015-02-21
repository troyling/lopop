//
//  ChatModel.h
//  Lopop
//
//  Created by Ruofan Ding on 2/3/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Firebase/Firebase.h>
@interface LPChatModel : NSObject

@property NSString *contactId;
@property NSNumber *contactStatus;
@property Firebase *chatMessagesRef;
@property NSNumber *userStatus;
@property Firebase *chatInfoRef;
@property NSMutableArray *messageArray;

//@property NSTimeInterval timeStamp;

//- (NSDictionary *) toDict;
//+ (LPChatModel *) fromDict:(NSDictionary *) dict;



@end
