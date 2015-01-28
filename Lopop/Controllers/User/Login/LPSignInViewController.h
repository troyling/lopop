//
//  LPSignInViewController.h
//  Lopop
//
//  Created by Hongbo Fang on 1/28/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LPSignInViewController : UIViewController
- (IBAction)signIn:(id)sender;
- (IBAction)dismiss:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;

@property (weak, nonatomic) IBOutlet UITextField *pwdTextField;

@end
