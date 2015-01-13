//
//  LPSignUpTableViewController.m
//  Lopop
//
//  Created by Troy Ling on 1/12/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "LPSignUpTableViewController.h"
#import "LPFormValidator.h"

@interface LPSignUpTableViewController ()

@property NSArray *textFields;

@end

@implementation LPSignUpTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _textFields = @[self.nameField, self.emailField, self.passwordField];
    [self _setupForm];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)_setupForm {
    for (UITextField *tf in _textFields) {
        // disable/enable sign-up button
        [tf addTarget:self action:@selector(_textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        // add "clear" button
        tf.clearButtonMode = UITextFieldViewModeWhileEditing;
        // TODO dismiss keyboard
    }
}

- (void)_textFieldDidChange:(UITextField *)textField {
    // enable/disable button
    if ([LPFormValidator isTextfieldsFilled:_textFields]) {
        [self.detailViewController enableSignUpBtn:YES];
    } else {
        [self.detailViewController enableSignUpBtn:YES];
    }
}



@end
