//
//  LPUserProfileTableViewController.h
//  Lopop
//
//  Created by Troy Ling on 3/7/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface LPUserProfileTableViewController : UITableViewController

@property (retain, nonatomic) PFUser *user;

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UIImageView *profBkgImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end