//
//  LPSignUpViewController.m
//  Lopop
//
//  Created by Troy Ling on 1/10/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "LPSignUpViewController.h"
#import "LPSignUpDetailViewController.h"
#import "LPUserProfileViewController.h"
#import "UIImage+ImageEffects.h"
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "LPUserHelper.h"
#import "LPPushHelper.h"
#import "LPAlertViewHelper.h"
#import "LPUIHelper.h"

@implementation LPSignUpViewController

#pragma mark UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    // Bypass login view if the user is already logged in
    if ([PFUser currentUser] &&
        [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        [self presentUserProfileViewControllerAnimated:NO];
    }

    self.activityIndicator.hidden = YES;
}

#pragma mark FB SDK

- (IBAction)connectWithFacebook:(id)sender {
    NSArray *permissions = @[@"public_profile",
                             @"user_friends",
                             @"email"];

    [PFFacebookUtils logInWithPermissions:permissions block: ^(PFUser *user, NSError *error) {
        [self dismissActivityIndicator];
        if (!user) {
            [LPAlertViewHelper fatalErrorAlert:@"Error occurred when connecting with Facebook. Please try again."];
        }
        else {
            if (user.isNew) {
                [LPUserHelper mapCurrentUserFBData];
            }
            [self presentUserProfileViewControllerAnimated:NO];
        }
        [LPPushHelper setPushChannelForCurrentUser];
    }];

    [self showActivityIndicator];
}

#pragma mark activityIndicator
- (void)showActivityIndicator {
    self.activityIndicator.hidden = NO;
    [self.activityIndicator startAnimating];
}

- (void)dismissActivityIndicator {
    [self.activityIndicator stopAnimating];
    self.activityIndicator.hidden = YES;
}

#pragma mark - Navigation
- (void)presentUserProfileViewControllerAnimated:(BOOL)animated {
    LPUserProfileViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"LPMainViewTabBarController"];
    [self presentViewController:vc animated:animated completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"signUpDetailViewControllerSegue"] &&
        [[segue destinationViewController] isKindOfClass:[LPSignUpDetailViewController class]]) {
        LPSignUpDetailViewController *vc = [segue destinationViewController];
        UIImage *img = [LPUIHelper convertViewToImage:self.view];
        img = [img applyBlurWithRadius:20
                             tintColor:[UIColor colorWithWhite:1.0 alpha:0.2]
                 saturationDeltaFactor:1.3
                             maskImage:nil];
        vc.bgImg = img;
    }
}

@end
