//
//  LPUserHelper.m
//  Lopop
//
//  Created by Troy Ling on 1/31/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "LPUserHelper.h"
#import "LPUserRelationship.h"
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
    PFQuery *query = [PFQuery queryWithClassName:[LPUserRelationship parseClassName]];
    [query whereKey:@"follower" equalTo:[PFUser currentUser]];
    [query whereKey:@"followedUser" equalTo:targetUser];
    BOOL result = NO;
    NSInteger count = [query countObjects];
    if (count != 0) {
        result = YES;
    }
    return result;
}

@end
