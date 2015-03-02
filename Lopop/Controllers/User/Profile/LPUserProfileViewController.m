//
//  LPUserProfileViewController.m
//  Lopop
//
//  Created by Troy Ling on 1/10/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "LPUserProfileViewController.h"
#import "LPUIHelper.h"
#import "UIImage+ImageEffects.h"
#import "LPUserRelationship.h"
#import "LPFollowerTableViewController.h"
#import "LPAlertViewHelper.h"
#import "LPUserHelper.h"
#import "UIImageView+WebCache.h"
#import <ParseFacebookUtils/PFFacebookUtils.h>

@interface LPUserProfileViewController ()

@property BOOL isFollowingTargetUser;
@property NSUInteger numFollower;

@end

@implementation LPUserProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadUserStats];
    [self presentProfileData];
}

- (void)presentProfileData {
    if (self.targetUser) {
        [self.targetUser fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            if (!error) {
                NSString *name = self.targetUser[@"name"];
                NSString *description = self.targetUser[@"description"];
                NSString *profilePictureUrl = self.targetUser[@"profilePictureUrl"];

                if (name) {
                    self.nameLabel.text = name;
                }

                if (description) {
                    self.descriptionTextField.text = description;
                }

                if (profilePictureUrl) {
                    [self.profileImageView sd_setImageWithURL:[NSURL URLWithString:profilePictureUrl]];
                    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 2;
                    self.profileImageView.clipsToBounds = YES;

                    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
                        //Background Thread
                        dispatch_async(dispatch_get_main_queue(), ^(void){
                            UIImage *bkgImg = [self.profileImageView.image applyBlurWithRadius:20
                                                                   tintColor:[UIColor colorWithWhite:1.0 alpha:0.2]
                                                       saturationDeltaFactor:1.3
                                                                   maskImage:nil];
                            self.bkgImageView.image = bkgImg;
                        });
                    });
                }
            }
        }];
    } else {
        [LPAlertViewHelper fatalErrorAlert:@"Unable to load the user's profile"];
    }
}

- (IBAction)followUser:(id)sender {
    if (self.isFollowingTargetUser) {
        [LPUserHelper unfollowUserInBackground:self.targetUser withBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [self toggleFollowBtn];
            }
        }];
    } else {
        [LPUserHelper followUserInBackground:self.targetUser withBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [self toggleFollowBtn];
            }
        }];
    }
}

- (IBAction)profileFinishedEdit:(id)sender {
    // FIXME this is broken. Current user shoudn't save the user in view
    [self.descriptionTextField resignFirstResponder];
    self.targetUser[@"description"] = self.descriptionTextField.text;
    [self.targetUser saveInBackground];
}

#pragma mark Controller UI
- (void)toggleFollowBtn {
    self.isFollowingTargetUser ^= YES; // toggle BOOL
    
    if (self.isFollowingTargetUser) {
        [self.followBtn setTitle:@"Unfollow" forState:UIControlStateNormal];
        [self.followBtn setBackgroundColor:[UIColor grayColor]];
        self.numFollower++;
    } else {
        [self.followBtn setTitle:@"Follow" forState:UIControlStateNormal];
        [self.followBtn setBackgroundColor:[LPUIHelper lopopColor]];
        self.numFollower--;
    }
    
    [self updateFollowerBtn];
}

- (void)updateFollowerBtn {
    [self.followerBtn setTitle:[NSString stringWithFormat:@"Follower %lu", (unsigned long)self.numFollower] forState:UIControlStateNormal];
}

#pragma mark follower/following system

- (void)loadUserStats {
    PFQuery *followedQuery = [PFQuery queryWithClassName:[LPUserRelationship parseClassName]];
    
    // number of followers
    [followedQuery whereKey:@"followedUser" equalTo:self.targetUser];
    [followedQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (!error) {
            self.numFollower = number;
            [self updateFollowerBtn];
        }
    }];
    
    // following other users
    PFQuery *followerQuery = [PFQuery queryWithClassName:[LPUserRelationship parseClassName]];
    [followerQuery whereKey:@"follower" equalTo:self.targetUser];
    [followerQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (!error) {
            [self.followingBtn setTitle:[NSString stringWithFormat:@"Following %d", number] forState:UIControlStateNormal];
        }
    }];
    
    // check if current user is following the target user
    self.isFollowingTargetUser = [LPUserHelper isCurrentUserFollowingUser:self.targetUser];
    if (self.isFollowingTargetUser) {
        [self.followBtn setTitle:@"Unfollow" forState:UIControlStateNormal];
        [self.followBtn setBackgroundColor:[UIColor grayColor]];
    }
}

#pragma mark segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[LPFollowerTableViewController class]]) {
        
        LPFollowerTableViewController *vc = segue.destinationViewController;
        
        // setup query
        PFQuery *query = [PFQuery queryWithClassName:[LPUserRelationship parseClassName]];
        [query orderByDescending:@"createdAt"];
        
        if ([segue.identifier isEqualToString:@"viewFollowingUsers"]) {
            [query whereKey:@"follower" equalTo:self.targetUser];
            vc.contentType = FOLLOWING_USER;
        } else if ([segue.identifier isEqualToString:@"viewFollowers"]) {
            [query whereKey:@"followedUser" equalTo:self.targetUser];
            vc.contentType = FOLLOWER;
        }
        vc.query = query;
    }
}

@end
