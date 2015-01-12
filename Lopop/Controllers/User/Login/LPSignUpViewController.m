//
//  LPSignUpViewController.m
//  Lopop
//
//  Created by Troy Ling on 1/10/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "LPSignUpViewController.h"
#import "LPUserProfileViewController.h"
#import <ParseFacebookUtils/PFFacebookUtils.h>

@implementation LPSignUpViewController

#pragma mark UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Bypass login view if the user is already logged in
    if  ([PFUser currentUser] &&
         [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        [self _presentUserProfileViewControllerAnimated:NO];
    }
    
    self.activityIndicator.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (IBAction)connectWithFacebook:(id)sender {
    NSLog(@"hi");
    NSLog(@"%@", [PFUser currentUser]);
    NSArray *permissions = @[@"public_profile",
                             @"user_birthday",
                             @"user_friends",
                             @"email",
                             @"user_interests",
                             @"user_location"];
    
    [PFFacebookUtils logInWithPermissions:permissions block:^(PFUser *user, NSError *error) {
        [_activityIndicator stopAnimating];
        if (!user) {
            NSString *errMsg = @"Error occurred when connecting with Facebook. Please try again.";
            NSLog(@"%@", errMsg);
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:errMsg delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil];
            [alert show];
        } else {
            if (user.isNew) {
                NSLog(@"New user signed up and logged in via Facebook");
                // show tutorial maybe?
            } else {
                NSLog(@"User logged in through FB");
            }
            [self _presentUserProfileViewControllerAnimated:NO];
        }
        self.activityIndicator.hidden = YES;
    }];
    
    self.activityIndicator.hidden = NO;
    [_activityIndicator startAnimating];
}

#pragma mark - Navigation


- (void)_presentUserProfileViewControllerAnimated:(BOOL)animated {
    LPUserProfileViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"LPUserProfileViewController"];
    [self presentViewController:vc animated:animated completion:nil];
}

@end


