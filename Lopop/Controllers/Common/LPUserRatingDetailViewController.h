//
//  LPUserRatingDetailViewController.h
//  Lopop
//
//  Created by Troy Ling on 3/15/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface LPUserRatingDetailViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (retain, nonatomic) PFUser *user;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *numCommentLabel;

- (IBAction)dismiss:(id)sender;

@end
