//
//  LPUserHelper.m
//  Lopop
//
//  Created by Troy Ling on 1/31/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "LPUserHelper.h"
#import "LPCache.h"
#import "LPUserRelationship.h"
#import "LPAlertViewHelper.h"
#import "LPPushHelper.h"
#import <FacebookSDK/FacebookSDK.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import <Firebase/Firebase.h>

@implementation LPUserHelper

+ (void) mapCurrentUserFBData {
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        // start reading data from Facebook
        FBRequest *request = [FBRequest requestForMe];
        [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            if (!error) {
                // map the data
                NSDictionary *userData = (NSDictionary *)result;
                
                NSString *facebookID = userData[@"id"];
                NSString *email = userData[@"email"];
                NSString *name = userData[@"name"];
                
                if (facebookID) {
                    currentUser[@"facebookID"] = facebookID;
                }
                
                if (email) {
                    currentUser[@"email"] = email;
                }
                
                if (name) {
                    currentUser[@"name"] = name;
                }

                // image urls
                currentUser[@"thumbnailUrl"] = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=square&return_ssl_resources=1&height=50&width=50", facebookID];
                currentUser[@"profilePictureUrl"] = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=square&return_ssl_resources=1&height=150&width=150", facebookID];

                // init user info for current user
                [self initUserInfoWithGender:userData[@"gender"] Locale:userData[@"locale"]];
                
                //Register firebase
                Firebase *ref = [[Firebase alloc] initWithUrl:@"https://lopop.firebaseio.com"];
                [ref createUser:[currentUser.objectId stringByAppendingString:@"@lopop.com"]
                       password:currentUser.objectId
                        withValueCompletionBlock:^(NSError *error, NSDictionary *result) {
                            if (error) {
                                NSLog(@"%@", error);
                            } else {
                                NSString *uid = [result objectForKey:@"uid"];
                                NSLog(@"Successfully created user account with uid: %@", uid);
                                currentUser[@"firebaseId"] = uid;
                                [currentUser saveEventually];
                            }
                        }
                 ];

                [currentUser saveEventually];
            } else if ([[[[error userInfo] objectForKey:@"error"] objectForKey:@"type"] isEqualToString:@"OAuthException"]) {
                NSLog(@"Session error");
            } else {
                NSLog(@"Other error");
            }
        }];
    }
}


+ (BOOL)isCurrentUserFollowingUser:(PFUser *)targetUser {
    if ([targetUser.objectId isEqualToString:[[PFUser currentUser] objectId]]) return NO;
    
    PFQuery *query = [PFQuery queryWithClassName:[LPUserRelationship parseClassName]];
    [query whereKey:@"follower" equalTo:[PFUser currentUser]];
    [query whereKey:@"followedUser" equalTo:targetUser];
    
    NSInteger count = [query countObjects];
    
    return count != 0 ? YES : NO;
}

+ (void)isCurrentUserFollowingUserInBackground:(PFUser *)user withBlock:(void (^)(BOOL isFollowing, NSError *error))completionBlock {
    if ([user.objectId isEqualToString:[[PFUser currentUser] objectId]]) {
        completionBlock(NO, nil);
        return;
    }

    PFQuery *query = [LPUserRelationship query];
    query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    [query whereKey:@"follower" equalTo:[PFUser currentUser]];
    [query whereKey:@"followedUser" equalTo:user];
    [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (!error) {
            if (number != 0) {
                completionBlock(YES, nil);
            } else {
                completionBlock(NO, nil);
            }
        } else {
            completionBlock(NO, error);
        }
    }];
}

+ (void)initUserInfoWithGender:(NSString *)gender Locale:(NSString *)locale {
    LPUserInfo *userInfo = [LPUserInfo object];
    userInfo.user = [PFUser currentUser];
    userInfo.gender = gender;
    userInfo.locale = locale;
    userInfo.numRating = 0;
    userInfo.totalRating = 0;
    [userInfo saveEventually];
}

+ (void)updateUserInfoWithLocationEventually:(CLLocation *)location {
    PFQuery *query = [LPUserInfo query];
    query.cachePolicy = kPFCachePolicyCacheElseNetwork;
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error && objects.count == 1) {
            LPUserInfo *info = objects.firstObject;
            info.location = [PFGeoPoint geoPointWithLocation:location];
            [info saveEventually];
        }
    }];
}

+ (void)followUserInBackground:(PFUser *)targetUser withBlock:(void (^)(BOOL succeeded, NSError *error))completionBlock {
    if ([targetUser.objectId isEqualToString:[[PFUser currentUser] objectId]]) {
        NSMutableDictionary* details = [NSMutableDictionary dictionary];
        [details setValue:@"Can't follow yourself" forKey: NSLocalizedDescriptionKey];
        NSError *error = [[NSError alloc] initWithDomain:[LPUserRelationship parseClassName] code:200 userInfo:details];
        completionBlock(NO, error);
        return;
    }
    
    LPUserRelationship *follow = [LPUserRelationship object];
    follow.follower = [PFUser currentUser];
    follow.followedUser = targetUser;
    [follow saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            // update cache
            [[LPCache getInstance] followUser:targetUser];

            // send notification
            [LPPushHelper sendPushWithFollowing:targetUser];

            if (completionBlock) {
                completionBlock(YES, nil);
            }
        } else {
            completionBlock(NO, error);
        }
    }];
}

+ (void)unfollowUserInBackground:(PFUser *)targetUser withBlock:(void (^)(BOOL succeeded, NSError *error))completionBlock {
    PFQuery *unfollowQuery = [PFQuery queryWithClassName:[LPUserRelationship parseClassName]];
    [unfollowQuery whereKey:@"followedUser" equalTo:targetUser];
    [unfollowQuery whereKey:@"follower" equalTo:[PFUser currentUser]];
    [unfollowQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // remove following activity
            if (objects.count > 0) {
                for (id obj in objects) {
                    if ([obj isKindOfClass:[LPUserRelationship class]]) {
                        LPUserRelationship *follow = obj;
                        [follow deleteEventually];
                    }
                }
            }

            // remove from cache
            [[LPCache getInstance] unfollowUser:targetUser];
            
            // execute callback
            if (completionBlock) {
                completionBlock(YES, nil);
            }
        } else {
            completionBlock(NO, error);
        }
    }];
}

+ (void)findUserInfoInBackground:(PFUser *)targetUser withBlock:(void (^)(LPUserInfo *userInfo, BOOL succeeded, NSError *error))completionBlock {
    PFQuery *query = [LPUserInfo query];
    [query whereKey:@"user" equalTo:targetUser];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            completionBlock(nil, NO, error);
        } else {
            if (objects.count == 1) {
                completionBlock(objects.firstObject, YES, nil);
            } else {
                NSMutableDictionary* details = [NSMutableDictionary dictionary];
                [details setValue:@"Couldn't find user info" forKey: NSLocalizedDescriptionKey];
                NSError *customError = [[NSError alloc] initWithDomain:[LPUserRelationship parseClassName] code:200 userInfo:details];
                completionBlock(nil, NO, customError);
            }
        }
    }];
}

@end
