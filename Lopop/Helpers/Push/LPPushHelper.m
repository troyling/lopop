//
//  LPPushHelper.m
//  Lopop
//
//  Created by Troy Ling on 5/5/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "LPPushHelper.h"

@implementation LPPushHelper
static NSString *const KEY_CHANNEL = @"channels";

+ (void)setPushChannelForPop:(LPPop *)pop {
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation addUniqueObject:[self channelKeyForPop:pop] forKey:KEY_CHANNEL];
    [currentInstallation saveInBackground];
}

+ (void)setPushChannelForCurrentUser {
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser != nil) {
        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
        [currentInstallation addUniqueObject:[self channelKeyForUser:currentUser] forKey:KEY_CHANNEL];
        [currentInstallation saveInBackground];
    }
}

+ (void)sendPushWithOffer:(LPPop *)pop {
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser != nil) {
        NSString *msg = [NSString stringWithFormat:@"%@ sent you an offer", currentUser[@"name"]];
        NSDictionary *data = @{
                               @"alert" : msg,
                               @"badge" : @"Increment"
                               };
        PFPush *push = [[PFPush alloc] init];
        [push setChannel:[self channelKeyForPop:pop]];
        [push setData:data];
        [push sendPushInBackground];
    }
}

+ (void)sendPushWithMeetup:(LPPop *)pop {
}

+ (void)sendPushFollowing:(PFUser *)followed {
}

+ (NSString *)channelKeyForPop:(LPPop *)pop {
    return [NSString stringWithFormat:@"pop_%@", pop.objectId];
}

+ (NSString *)channelKeyForUser:(PFUser *)user {
    return [NSString stringWithFormat:@"user_%@", user.objectId];
}

@end
