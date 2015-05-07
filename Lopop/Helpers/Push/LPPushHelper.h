//
//  LPPushHelper.h
//  Lopop
//
//  Created by Troy Ling on 5/5/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LPPop.h"

@interface LPPushHelper : NSObject

+ (void)setPushChannelForPop:(LPPop *)pop;
+ (void)setPushChannelForCurrentUser;

+ (void)sendPushWithOffer:(LPPop *)pop;
+ (void)sendPushWithMeetup:(LPPop *)pop;
+ (void)sendPushWithFollowing:(PFUser *)followed;

@end
