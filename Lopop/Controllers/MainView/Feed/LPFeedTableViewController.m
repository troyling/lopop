//
//  LPFeedViewController.m
//  Lopop
//
//  Created by Troy Ling on 1/14/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "LPFeedTableViewController.h"
#import "LPNewPopTableViewController.h"
#import "LPPopFeedTableViewCell.h"
#import "LPPop.h"
#import <Parse/Parse.h>

@interface LPFeedTableViewController ()

@property (strong, nonatomic) NSArray *pops;

@end

@implementation LPFeedTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // delegate
    self.feedTableView.delegate = self;
    self.feedTableView.dataSource = self;
    
    // query data
    [self queryForPops];
    
    // add pull to refresh
    [self initRefreshControl];
}

- (void)queryForPops {
    // start query
    PFQuery *popQuery = [LPPop query];
    
    popQuery.cachePolicy = kPFCachePolicyCacheThenNetwork;
    
    [popQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            self.pops = [[NSArray alloc] initWithArray:objects];
            [self.feedTableView reloadData];
            // TODO stop the loading indicator
        }
    }];
}

- (void)initRefreshControl {
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshPops) forControlEvents:UIControlEventValueChanged];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
}

- (void)refreshPops {
    [self queryForPops];
    
    // add last update
    if (self.refreshControl) {
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMM d, h:mm a"];
        NSString *title = [NSString stringWithFormat:@"Last update: %@", [formatter stringFromDate:[NSDate date]]];
        NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:[UIColor blackColor]
                                                                    forKey:NSForegroundColorAttributeName];
        NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attrsDictionary];
        self.refreshControl.attributedTitle = attributedTitle;

        [self.refreshControl endRefreshing];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSUInteger rows = 0;
    if (self.pops) {
        rows = self.pops.count;
    }
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"LPPopFeedTableViewCell";
    LPPopFeedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    // load the data onto the cutom cell
    if (!cell) {
        cell = [[LPPopFeedTableViewCell alloc] init];
    }

    if (self.pops) {
        LPPop *pop = [self.pops objectAtIndex:indexPath.row];
        cell.titleLabel.text = pop.title;
        cell.descriptionLabel.text = pop.popDescription;
        cell.priceLabel.text = [NSString stringWithFormat:@"$%@", pop.price];
        
        // TODO load image
        //        PFFile *popImageFile = pop.images.firstObject;
//        [popImageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
//            if (!error) {
//                UIImage *origin = [UIImage imageWithData:data];
//                UIImage *resized = [self resizeImage:origin scale:0.8f];
//                cell.imageView.image = resized;
//            }
//        }];
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.pops) {
        if (indexPath.row == (self.pops.count - 1)) {
            // TODO load more item from Parse
            NSLog(@"Time to load more item from server");
        }
    }
}

@end
