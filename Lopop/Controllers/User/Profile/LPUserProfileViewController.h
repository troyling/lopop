//
//  LPUserProfileViewController.h
//  Lopop
//
//  Created by Troy Ling on 1/10/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LPUserProfileViewController : UIViewController <UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UIImageView *bkgImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

- (IBAction)logout:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *descriptionTextField;

- (IBAction)profileFinishedEdit:(id)sender;

@end
