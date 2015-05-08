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

+ (void)setPushChannelForOffer:(LPOffer *)offer {
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser != nil) {
        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
        [currentInstallation addUniqueObject:[self channelKeyForOffer:offer] forKey:KEY_CHANNEL];
        [currentInstallation saveInBackground];
    }
}

+ (void)sendPushWithPop:(LPPop *)pop withMsg:(NSString *)msg {
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser != nil) {
//        NSString *msg = [NSString stringWithFormat:@"%@ sent you an offer", currentUser[@"name"]];
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

+ (void)sendPushWithOffer:(LPOffer *)offer {
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser != nil) {
        NSString *msg = [NSString stringWithFormat:@"%@ propose a meet up", currentUser[@"name"]];
        NSDictionary *data = @{
                               @"alert" : msg,
                               @"badge" : @"Increment"
                               };
        PFPush *push = [[PFPush alloc] init];
        [push setChannel:[self channelKeyForOffer:offer]];
        [push setData:data];
        [push sendPushInBackground];
    }
}

+ (void)sendPushWithFollowing:(PFUser *)followed {
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser != nil) {
        NSString *msg = [NSString stringWithFormat:@"%@ started following you", currentUser[@"name"]];
        NSDictionary *data = @{
                               @"alert" : msg,
                               @"badge" : @"Increment"
                               };
        PFPush *push = [[PFPush alloc] init];
        [push setChannel:[self channelKeyForUser:followed]];
        [push setData:data];
        [push sendPushInBackground];
    }
}

+ (NSString *)channelKeyForPop:(LPPop *)pop {
    return [NSString stringWithFormat:@"pop_%@", pop.objectId];
}

+ (NSString *)channelKeyForUser:(PFUser *)user {
    return [NSString stringWithFormat:@"user_%@", user.objectId];
}

+ (NSString *)channelKeyForOffer:(LPOffer *)offer {
    return [NSString stringWithFormat:@"offer_%@", offer.objectId];
}

@end
