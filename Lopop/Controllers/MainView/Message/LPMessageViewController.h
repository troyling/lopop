//
//  MessageViewController.h
//  Lopop
//
//  Created by Ruofan Ding on 1/31/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "JSQMessages.h"
#import "Firebase/firebase.h"
#import "LPMessageModel.h"
#import "LPChatModel.h"
#import "LPPop.h"

@interface LPMessageViewController : JSQMessagesViewController

@property (retain, nonatomic) LPPop *pop;
@property (retain, nonatomic) PFUser *offerUser;

@property LPChatModel* chatModel;
@property Firebase *firebase;
@property (nonatomic, strong) NSMutableArray* messageArray;

// chat view componenets
@property (strong, nonatomic) JSQMessagesBubbleImage *outgoinBubble;
@property (strong, nonatomic) JSQMessagesBubbleImage *incomingBubble;

@end
