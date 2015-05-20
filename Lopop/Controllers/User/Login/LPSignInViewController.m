//
//  LPSignInViewController.m
//  Lopop
//
//  Created by Hongbo Fang on 1/28/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "LPSignInViewController.h"
#import "LPMainViewTabBarController.h"
#import <Parse/Parse.h>

@interface LPSignInViewController ()

@end

@implementation LPSignInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)signIn:(id)sender {
    NSString *username = _nameTextField.text;
    NSString *pwd = _pwdTextField.text;
    
    [PFUser logInWithUsernameInBackground:username password:pwd
        block:^(PFUser *user, NSError *error) {
            if (user) {
                LPMainViewTabBarController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"LPMainViewTabBarController"];
                [self presentViewController:vc animated:YES completion:nil];
            } else {
                NSString *errorString = [error userInfo][@"error"];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable to sign in" message:errorString delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil];
                [alert show];
            }
        }];
}

- (IBAction)dismiss:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
