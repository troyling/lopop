//
//  LPSignUpTableViewController.h
//  Lopop
//
//  Created by Troy Ling on 1/12/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LPSignUpDetailViewController.h"

@interface LPSignUpTableViewController : UITableViewController

@property LPSignUpDetailViewController *detailViewController;

@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

@end
