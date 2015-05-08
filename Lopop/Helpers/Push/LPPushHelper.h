//
//  LPPushHelper.h
//  Lopop
//
//  Created by Troy Ling on 5/5/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LPPop.h"
#import "LPOffer.h"

@interface LPPushHelper : NSObject

+ (void)setPushChannelForPop:(LPPop *)pop;
+ (void)setPushChannelForCurrentUser;
+ (void)setPushChannelForOffer:(LPOffer *)offer;

+ (void)sendPushWithPop:(LPPop *)pop withMsg:(NSString *)msg;
+ (void)sendPushWithOffer:(LPOffer *)offer;

+ (void)sendPushWithFollowing:(PFUser *)followed;

@end
