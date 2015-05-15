//
//  ChatModel.m
//  Lopop
//
//  Created by Ruofan Ding on 2/3/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "LPChatModel.h"
#import "LPMessageModel.h"
#import "LPChatManager.h"
#import <Parse/Parse.h>

@interface LPChatModel()

@property NSString* contactFirebaseId;

@property Firebase *sendRef;

@end

@implementation LPChatModel





- (id) initWithContactId:(NSString *) contactId{
    self.contactId = contactId;
    self.numberOfUnread = 0;
    PFQuery *query = [PFUser query];
    query.cachePolicy = kPFCachePolicyCacheElseNetwork;
    [query whereKey:@"objectId" equalTo: contactId];
    [query findObjectsInBackgroundWithBlock: ^(NSArray *objects, NSError *error) {
        if (!error && objects.count == 1) {
            self.contactName = objects.firstObject[@"name"];
            self.contactFirebaseId = objects.firstObject[@"firebaseId"];

            
            NSLog(@"%@, %@", self.contactFirebaseId, self.contactName);
            
            self.sendRef = [[Firebase alloc] initWithUrl:
                       [NSString stringWithFormat:@"%@%@%@%@", firebaseUrl, @"users/", self.contactFirebaseId, @"/pendingMessages"]];
        }
    }];
    
    self.stored = YES;

    return self;
}

- (void) sendMessage:(LPMessageModel *) message{
    NSLog(@"%@, %@", self.contactFirebaseId, self.contactName);
    Firebase* path = [self.sendRef childByAutoId];
    [path setValue: message.toDict];
    message.messageId = path.key;
    LPChatManager * LPCM = [LPChatManager getInstance];
    [LPCM saveMessage:message];
    
    if(!self.stored){
        [LPCM saveChatToDB:self];
        self.stored = YES;
    }
}


/*
- (NSDictionary *)toDict{
    return @{@"contactId":self.contactId, @"chatId":self.chatId};
}*/

/*
+ (LPChatModel *)fromChatInfo: (NSDictionary *) dict{
    LPChatModel * chat = [LPChatModel alloc];
    chat.contactId = [dict objectForKey:@"contactId"];
}*/



@end
