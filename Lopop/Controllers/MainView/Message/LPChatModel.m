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

@property LPMessageModel* lastUnreadMessage;

@end

@implementation LPChatModel





- (id) initWithContactId:(NSString *) contactId{
    self.contactId = contactId;
    self.numberOfUnread = 0;
    self.lastUnreadMessage = nil;
    
    PFQuery *query = [PFUser query];
    [query whereKey:@"objectId" equalTo: contactId];
    NSArray *objects = [query findObjects];
    if (objects.count == 1) {
        self.contactName = objects.firstObject[@"name"];
        self.contactFirebaseId = objects.firstObject[@"firebaseId"];


        NSLog(@"%@, %@", self.contactFirebaseId, self.contactName);

        self.sendRef = [[Firebase alloc] initWithUrl:
                        [NSString stringWithFormat:@"%@%@%@%@", firebaseUrl, @"messages/", self.contactFirebaseId, @"/pendingMessages"]];
    }
    self.stored = YES;

    self.lastMessage = [[LPChatManager getInstance]getLastMessageFromDBWithUserId:contactId];
    
    return self;
}

- (void) sendMessage:(LPMessageModel *) message{
    Firebase* path = [self.sendRef childByAutoId];
    [path setValue: message.toDict];
    message.messageId = path.key;
    message.timestamp = [[NSDate alloc ]initWithTimeIntervalSince1970:[[LPChatManager getInstance] getTime]/1000];
    LPChatManager * LPCM = [LPChatManager getInstance];
    [LPCM saveMessage:message];
    
    
    if(!self.stored){
        [LPCM saveChatToDB:self];
        self.stored = YES;
    }
}

- (NSString *) getLastMessage{
    NSString *lastMsg = @"...";
    
    if (self.lastMessage != nil) {
        lastMsg = self.lastMessage;
    }
    return lastMsg;
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
