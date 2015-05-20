//
//  LPSignUpDetailViewController.m
//  Lopop
//
//  Created by Troy Ling on 1/10/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "LPSignUpDetailViewController.h"
#import "LPSignUpTableViewController.h"
#import "LPMainViewTabBarController.h"
#import "LPUIHelper.h"
#import "LPPushHelper.h"
#import "LPUserHelper.h"
#import "LPAlertViewHelper.h"
#import <Parse/Parse.h>
#import <Firebase/firebase.h>

@interface LPSignUpDetailViewController ()

@property (weak, nonatomic) LPSignUpTableViewController *signUpTableViewController;

@end

@implementation LPSignUpDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithPatternImage:self.bgImg];
    [self enableSignUpBtn:NO];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (IBAction)cancelSignUp:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)signup:(id)sender {
    if (self.signUpTableViewController) {
        PFUser *newUser = [PFUser user];
        newUser[@"name"] = [self.signUpTableViewController.nameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        newUser.email = [self.signUpTableViewController.emailField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        newUser.username = newUser.email;
        newUser.password = [self.signUpTableViewController.passwordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

        [newUser signUpInBackgroundWithBlock: ^(BOOL succeeded, NSError *error) {
            if (!error) {
                // init user info
                [LPUserHelper initUserInfoWithGender:nil Locale:nil];

                // set up channel for follower notification
                [LPPushHelper setPushChannelForCurrentUser];

                LPMainViewTabBarController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"LPMainViewTabBarController"];
                [self presentViewController:vc animated:YES completion:nil];
                
                
                //Register firebase
                Firebase *rootRef = [[Firebase alloc] initWithUrl:@"https://lopop.firebaseio.com"];
                [rootRef createUser:[newUser.objectId stringByAppendingString:@"@lopop.com"]
                       password:newUser.objectId
                        withValueCompletionBlock:^(NSError *error, NSDictionary *result) {
           
                            if (error) {
                                NSLog(@"%@", error);
                            } else {
                                NSString *uid = [result objectForKey:@"uid"];
                                NSLog(@"Successfully created user account with uid: %@", uid);
                                newUser[@"firebaseId"] = uid;
                                [newUser saveEventually];
                                [[[rootRef childByAppendingPath:@"users"] childByAppendingPath:uid] setValue:
                                 @{@"objectId": newUser.objectId,
                                   @"name": newUser[@"name"]}];
                            }
                        }
                 ];
                

                
            }
            else {
                NSString *errorString = [error userInfo][@"error"];
                [LPAlertViewHelper fatalErrorAlert:errorString];
            }
        }];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"signUpViewEmbedSegue"] &&
        [[segue destinationViewController] isKindOfClass:[LPSignUpTableViewController class]]) {
        // setup container view
        self.signUpTableViewController = [segue destinationViewController];
        self.signUpTableViewController.view.layer.cornerRadius = 8.0f;
        self.signUpTableViewController.view.layer.borderWidth = 2.0f;
        self.signUpTableViewController.view.layer.borderColor = [LPUIHelper lopopColor].CGColor;
        self.signUpTableViewController.detailViewController = self;
    }
}

- (void)enableSignUpBtn:(BOOL)enabled {
    [self.signupBtn setEnabled:enabled];
    self.signupBtn.alpha = enabled ? 1.0f : 0.4f;
}

@end
