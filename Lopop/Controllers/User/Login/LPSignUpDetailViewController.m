//
//  LPSignUpDetailViewController.m
//  Lopop
//
//  Created by Troy Ling on 1/10/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "LPSignUpDetailViewController.h"
#import "LPSignUpTableViewController.h"
#import "LPUserProfileViewController.h"
#import <Parse/Parse.h>

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
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)signup:(id)sender {
    if (_signUpTableViewController) {
        PFUser *newUser = [PFUser user];
        newUser.username = [_signUpTableViewController.nameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        newUser.email = [_signUpTableViewController.emailField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        newUser.password = [_signUpTableViewController.passwordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                NSLog(@"Thank you for signing up");
                LPUserProfileViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"LPUserProfileViewController"];
                [self presentViewController:vc animated:YES completion:nil];
            } else {
                NSString *errorString = [error userInfo][@"error"];
                NSLog(@"%@", errorString);
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable to sign up" message:errorString delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil];
                [alert show];
            }
        }];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"signUpViewEmbedSegue"] &&
        [[segue destinationViewController] isKindOfClass:[LPSignUpTableViewController class]]) {
        // TODO add this to global text
        CGColorRef lopopGreen = [[UIColor colorWithRed:0.33 green:0.87 blue:0.75 alpha:1] CGColor];
        // setup container view
        _signUpTableViewController = [segue destinationViewController];
        _signUpTableViewController.view.layer.cornerRadius = 8.0f;
        _signUpTableViewController.view.layer.borderWidth = 2.0f;
        _signUpTableViewController.view.layer.borderColor = lopopGreen;
        _signUpTableViewController.detailViewController = self;
    }
}

- (void)enableSignUpBtn:(BOOL)enabled {
    [self.signupBtn setEnabled:enabled];
    self.signupBtn.alpha = enabled ? 1.0f : 0.4f;
}

@end
