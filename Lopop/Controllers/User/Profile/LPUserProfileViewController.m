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
#import <ParseFacebookUtils/PFFacebookUtils.h>

@implementation LPUserProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadFollowers];
    [self presentProfileData];
//    [self loadData];
}

- (void)loadData {
    // present what's been previsouly cached and display the update from Facebook
    if (self.targetUser) {
        [self presentProfileData];
    }
    
    // request data from Facebook
    FBRequest *request = [FBRequest requestForMe];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            // process the data
            NSDictionary *userData = (NSDictionary *)result;
            NSString *facebookID = userData[@"id"];
            NSString *name = userData[@"name"];
            NSString *location = userData[@"location"][@"name"];
            NSString *gender = userData[@"gender"];
            NSString *birthday = userData[@"birthday"];
            BOOL isFBUser = YES;
            NSMutableDictionary *profile = [[NSMutableDictionary alloc] init];
    
            if (facebookID) {
                profile[@"facebookID"] = facebookID;
            }
            
            if (name) {
                profile[@"name"] = name;
            }
            
            if (location) {
                profile[@"locaton"] = location;
            }
            
            if (gender) {
                profile[@"gender"] = gender;
            }
            
            if (birthday) {
                profile[@"birthday"] = birthday;
            }
            
            profile[@"pictureURL"] = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=square&return_ssl_resources=1&height=150&width=150", facebookID];
            
            // save data to parse
            [[PFUser currentUser] setObject:profile forKey:@"profile"];
            [[PFUser currentUser] saveInBackground];
            
            [self presentProfileData];
        
        } else if ([[[[error userInfo] objectForKey:@"error"] objectForKey:@"type"] isEqualToString:@"OAuthException"]) {
            NSLog(@"Session error");
            // TODO should log user out
        } else {
            NSLog(@"Other error");
        }
    }];
}

- (void)presentProfileData {
    NSLog(@"presenting profile data");
    NSDictionary *profile = self.targetUser[@"profile"];
    
    if (profile) {
        NSString *name = profile[@"name"];
        NSString *profilePicURLStr = profile[@"pictureURL"];
        NSString *email = profile[@"email"];
        NSString *gender = profile[@"gender"];
        NSString *birthday = profile[@"birthday"];

        NSLog(@"email: %@", email);
        NSLog(@"gender: %@", gender);
        NSLog(@"birthday: %@", birthday);
        
        if (name) {
            self.nameLabel.text = name;
        }
        
        if (profilePicURLStr) {
            // download the user's facebook profile picture
            NSURL *pictureURL = [NSURL URLWithString:profilePicURLStr];
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
                    NSLog(@"Failed to load profile photo.");
                }
            }];
        }
    } else {
        NSString *name = self.targetUser[@"username"];
        if (name) {
            self.nameLabel.text = name;
        }
    }
    
    // populate user description
    NSString *description = self.targetUser[@"description"];
    if (description) {
        self.descriptionTextField.text = description;
    }
}

- (IBAction)logout:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Are you sure you want to log out?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
    [alert show];
}

#pragma mark follower/following system
- (void)loadFollowers {
    PFQuery *followedQuery = [PFQuery queryWithClassName:[LPUserRelationship parseClassName]];
    
    // being followed by other users
    [followedQuery whereKey:@"followedUser" equalTo:self.targetUser];
    [followedQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (!error) {
            self.followerBtn.titleLabel.text = [NSString stringWithFormat:@"Follower %d", number];
        }
    }];
    
    // following other users
    PFQuery *followerQuery = [PFQuery queryWithClassName:[LPUserRelationship parseClassName]];
    [followerQuery whereKey:@"follower" equalTo:self.targetUser];
    [followerQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (!error) {
            self.followingBtn.titleLabel.text = [NSString stringWithFormat:@"Following %d", number];
        }
    }];
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

- (IBAction)followUser:(id)sender {
    LPUserRelationship *follow = [LPUserRelationship object];
    follow.follower = [PFUser currentUser];
    follow.followedUser = self.targetUser;
    [follow saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            NSLog(@"Successfully following this user");
        }
    }];
}

- (IBAction)profileFinishedEdit:(id)sender {
    // FIXME this is broken. Current user shoudn't save the user in view
    [self.descriptionTextField resignFirstResponder];
    self.targetUser[@"description"] = self.descriptionTextField.text;
    [self.targetUser saveInBackground];
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
