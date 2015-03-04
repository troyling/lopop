//
//  LPUserHelper.h
//  Lopop
//
//  Created by Troy Ling on 1/31/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface LPUserHelper : NSObject

+ (void)mapCurrentUserFBData;

+ (void)initUserInfoWithGender:(NSString *)gender Locale:(NSString *)locale;

+ (BOOL)isCurrentUserFollowingUser:(PFUser *)targetUser;

+ (void)followUserInBackground:(PFUser *)targetUser
                     withBlock:(void (^)(BOOL succeeded, NSError *error))completionBlock;

+ (void)unfollowUserInBackground:(PFUser *)targetUser
                       withBlock:(void (^)(BOOL succeeded, NSError *error))completionBlock;

@end
