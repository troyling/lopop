//
//  LPSignUpDetailViewController.m
//  Lopop
//
//  Created by Troy Ling on 1/10/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "LPSignUpDetailViewController.h"

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

@end
