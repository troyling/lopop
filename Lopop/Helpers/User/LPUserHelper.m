//
//  LPUserHelper.m
//  Lopop
//
//  Created by Troy Ling on 1/31/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "LPUserHelper.h"
#import "LPUserRelationship.h"
#import "LPAlertViewHelper.h"
#import <FacebookSDK/FacebookSDK.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>

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
                NSString *gender = userData[@"gender"];
                
                if (facebookID) {
                    currentUser[@"facebookID"] = facebookID;
                }
                
                if (email) {
                    currentUser[@"email"] = email;
                }
                
                if (name) {
                    currentUser[@"name"] = name;
                }
                
                if (gender) {
                    currentUser[@"gender"] = gender;
                }
                
                // image urls
                currentUser[@"thumbnailUrl"] = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=square&return_ssl_resources=1&height=50&width=50", facebookID];
                currentUser[@"profilePictureUrl"] = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=square&return_ssl_resources=1&height=150&width=150", facebookID];
                NSLog(@"DONE");
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
    if ([targetUser isEqual:[PFUser currentUser]]) return NO;
    
    PFQuery *query = [PFQuery queryWithClassName:[LPUserRelationship parseClassName]];
    [query whereKey:@"follower" equalTo:[PFUser currentUser]];
    [query whereKey:@"followedUser" equalTo:targetUser];
    
    NSInteger count = [query countObjects];
    
    return count != 0 ? YES : NO;
}

+ (void)followUserEventually:(PFUser *)targetUser {
    LPUserRelationship *follow = [LPUserRelationship object];
    follow.follower = [PFUser currentUser];
    follow.followedUser = targetUser;
    [follow saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            NSLog(@"Successfully following this user");
        } else {
            [LPAlertViewHelper fatalErrorAlert:error.userInfo[@"error"]];
        }
    }];
}

+ (void)unfollowUserEventually:(PFUser *)targetUser {
    PFQuery *unfollowQuery = [PFQuery queryWithClassName:[LPUserRelationship parseClassName]];
    [unfollowQuery whereKey:@"followedUser" equalTo:targetUser];
    [unfollowQuery whereKey:@"follower" equalTo:[PFUser currentUser]];
    [unfollowQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error && objects.count > 0) {
            for (id obj in objects) {
                if ([obj isKindOfClass:[LPUserRelationship class]]) {
                    LPUserRelationship *follow = obj;
                    [follow deleteEventually];
                }
            }
        }
    }];
}


@end
