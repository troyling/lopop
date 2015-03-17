//
//  LPFeedViewController.h
//  Lopop
//
//  Created by Troy Ling on 1/14/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface LPFeedTableViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate, UIScrollViewDelegate, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UITableView *feedTableView;
@property (weak, nonatomic) IBOutlet UILabel *noContentLabel;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;

@end
