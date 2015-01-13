//
//  LPSignUpDetailViewController.h
//  Lopop
//
//  Created by Troy Ling on 1/10/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LPSignUpDetailViewController : UIViewController

@property UIImage *bgImg;
@property (weak, nonatomic) IBOutlet UIButton *signupBtn;

- (IBAction)cancelSignUp:(id)sender;
- (IBAction)signup:(id)sender;
- (void)enableSignUpBtn:(BOOL)enabled;

@end
