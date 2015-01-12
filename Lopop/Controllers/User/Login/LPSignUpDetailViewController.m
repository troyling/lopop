//
//  LPSignUpDetailViewController.m
//  Lopop
//
//  Created by Troy Ling on 1/10/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "LPSignUpDetailViewController.h"
#import "LPSignUpTableViewController.h"

@interface LPSignUpDetailViewController ()

@property LPSignUpTableViewController *signUpTableViewController;

@end

@implementation LPSignUpDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (IBAction)cancelSignUp:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"signUpViewEmbedSegue"] &&
        [[segue destinationViewController] isKindOfClass:[LPSignUpTableViewController class]]) {
        _signUpTableViewController = [segue destinationViewController];
    }
}

@end
