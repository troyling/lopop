//
//  LPFeedViewController.h
//  Lopop
//
//  Created by Troy Ling on 1/14/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface LPFeedTableViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *feedTableView;

@end
