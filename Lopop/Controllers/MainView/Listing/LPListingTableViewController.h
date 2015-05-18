//
//  LPListingTableViewController.h
//  Lopop
//
//  Created by Troy Ling on 2/10/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LPListingTableViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

- (IBAction)viewSelected:(id)sender;

@end
