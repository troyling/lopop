//
//  LPUserProfileViewController.h
//  Lopop
//
//  Created by Troy Ling on 1/10/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface LPUserProfileViewController : UIViewController <UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UIImageView *bkgImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UITextField *descriptionTextField;
@property (retain, nonatomic) PFUser *targetUser;
@property (strong, nonatomic) IBOutlet UIButton *followingBtn;
@property (strong, nonatomic) IBOutlet UIButton *followerBtn;

- (IBAction)followUser:(id)sender;
- (IBAction)profileFinishedEdit:(id)sender;
- (IBAction)logout:(id)sender;

@end
