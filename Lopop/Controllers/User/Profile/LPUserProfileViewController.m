//
//  LPUserProfileViewController.m
//  Lopop
//
//  Created by Troy Ling on 1/10/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "LPUserProfileViewController.h"
#import "UIImage+ImageEffects.h"
#import "LPUserRelationship.h"
#import "LPFollowerTableViewController.h"
#import "LPAlertViewHelper.h"
#import "LPUserHelper.h"
#import <ParseFacebookUtils/PFFacebookUtils.h>

@interface LPUserProfileViewController ()

@property (strong, nonatomic) NSString *followingBtnStr;
@property (strong, nonatomic) NSString *followerBtnStr;
@property BOOL isFollowingTargetUser;

@end

@implementation LPUserProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadUserStats];
    [self presentProfileData];
}

- (void)presentProfileData {
    if (self.targetUser) {
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
            [self loadProfilePictureWithURL:profilePictureUrl];
        }
    } else {
        [LPAlertViewHelper fatalErrorAlert:@"Unable to load the user's profile"];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.followerBtn.titleLabel.text = self.followerBtnStr;
    self.followingBtn.titleLabel.text = self.followingBtnStr;
}

- (void)loadProfilePictureWithURL:(NSString *)UrlString {
    // download the user's facebook profile picture
    NSURL *pictureURL = [NSURL URLWithString:UrlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:pictureURL];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError == nil && data != nil) {
            UIImage *userImage = [UIImage imageWithData:data];
            self.profileImageView.image = userImage;
            self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 2;
            self.profileImageView.clipsToBounds = YES;
            
            // background image
            userImage = [userImage applyBlurWithRadius:20
                                             tintColor:[UIColor colorWithWhite:1.0 alpha:0.2]
                                 saturationDeltaFactor:1.3
                                             maskImage:nil];
            self.bkgImageView.image = userImage;
        } else {
            [LPAlertViewHelper fatalErrorAlert:@"Unable to load the user's profile picture"];
        }
    }];
}

- (IBAction)logout:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Are you sure you want to log out?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
    [alert show];
}

- (IBAction)followUser:(id)sender {
    if (self.isFollowingTargetUser) {
        [LPUserHelper unfollowUserEventually:self.targetUser];
    } else {
        [LPUserHelper followUserEventually:self.targetUser];
    }
}

- (IBAction)profileFinishedEdit:(id)sender {
    // FIXME this is broken. Current user shoudn't save the user in view
    [self.descriptionTextField resignFirstResponder];
    self.targetUser[@"description"] = self.descriptionTextField.text;
    [self.targetUser saveInBackground];
}

#pragma mark follower/following system
- (void)loadUserStats {
    PFQuery *followedQuery = [PFQuery queryWithClassName:[LPUserRelationship parseClassName]];
    
    // being followed by other users
    [followedQuery whereKey:@"followedUser" equalTo:self.targetUser];
    [followedQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (!error) {
            [self.followerBtn setTitle:[NSString stringWithFormat:@"Follower %d", number] forState:UIControlStateNormal];
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

#pragma mark alertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if ([title isEqualToString:@"Yes"]) {
        [PFUser logOut];
        UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"LPSignUpViewController"];
        [self presentViewController:vc animated:NO completion:nil];
    }
}

#pragma mark segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[LPFollowerTableViewController class]]) {
        
        LPFollowerTableViewController *vc = segue.destinationViewController;
        
        // setup query
        PFQuery *query = [PFQuery queryWithClassName:@"UserRelationship"];
        [query orderByDescending:@"createdAt"];
        
        if ([segue.identifier isEqualToString:@"viewFollowingUsers"]) {
            [query whereKey:@"follower" equalTo:self.targetUser];
            vc.type = FOLLOWING_USER;
        } else if ([segue.identifier isEqualToString:@"viewFollowers"]) {
            [query whereKey:@"followedUser" equalTo:self.targetUser];
            vc.type = FOLLOWER;
        }
        vc.query = query;
    }
}

@end
