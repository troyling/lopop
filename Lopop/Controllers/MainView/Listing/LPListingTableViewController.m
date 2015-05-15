//
//  LPListingTableViewController.m
//  Lopop
//
//  Created by Troy Ling on 2/10/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "LPListingTableViewController.h"
#import "LPPopListingTableViewCell.h"
#import "LPMainViewTabBarController.h"
#import "LPPop.h"
#import "LPOffer.h"
#import "LPPopInfo.h"
#import "LPUIHelper.h"
#import "LPPopHelper.h"
#import "UIImageView+WebCache.h"
#import "LPIncomingOfferTableViewController.h"
#import "LPMeetUpMapViewController.h"
#import "UIViewController+ScrollingNavbar.h"
#import "LPNewMeetupViewController.h"

@interface LPListingTableViewController ()

@property (strong, nonatomic) NSMutableArray *listings;
@property (strong, nonatomic) NSMutableArray *offerReceivedListings;
@property (strong, nonatomic) NSMutableDictionary *incomingOffers;

@end

@implementation LPListingTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self followScrollView:self.tableView];

    // configure table view
    self.tableView.rowHeight = 275.0f;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    [self loadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if ([self.tabBarController isKindOfClass:[LPMainViewTabBarController class]]) {
        [(LPMainViewTabBarController *)self.tabBarController setTabBarVisible:YES animated:YES];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self showNavBarAnimated:NO];
}

- (void)loadData {
    self.incomingOffers = [[NSMutableDictionary alloc] init];
    self.offerReceivedListings = [[NSMutableArray alloc] init];
    
    // populate data for user
    PFQuery *listingQuery = [LPPop query];
    [listingQuery whereKey:@"seller" equalTo:[PFUser currentUser]];
    [listingQuery orderByDescending:@"createdAt"];
    [listingQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            self.listings = [[NSMutableArray alloc] initWithArray:objects];

            PFQuery *incommingOfferQuery = [LPOffer query];
            [incommingOfferQuery whereKey:@"pop" matchesQuery:listingQuery];
            [incommingOfferQuery includeKey:@"pop"];
            [incommingOfferQuery findObjectsInBackgroundWithBlock:^(NSArray *offers, NSError *error) {
                if (!error) {
                    for (LPOffer *o in offers) {
                        NSString *key = o.pop.objectId;
                        if ([self.incomingOffers.allKeys containsObject:key]) {
                            NSNumber *count = [self.incomingOffers objectForKey:key];
                            NSNumber *newVal = [NSNumber numberWithInt:count.intValue + 1];
                            [self.incomingOffers setObject:newVal forKey:key];
                        } else {
                            [self.incomingOffers setObject:[NSNumber numberWithInt:1] forKey:key];

                            // add to array for offer received (avoid duplicate)
                            [self.offerReceivedListings addObject:o.pop];
                        }
                    }
                    [self.tableView reloadData];
                }
            }];
        }
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger row;
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        row = self.listings == nil ? 0 : self.listings.count;
    } else {
        row = self.offerReceivedListings == nil ? 0 : self.offerReceivedListings.count;
    }
    return row;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"listingCell";
    LPPopListingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];

    if (!cell) {
        cell = [[LPPopListingTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }

    LPPop *pop;

    // listing view
    pop = self.segmentedControl.selectedSegmentIndex == 0 ? [self.listings objectAtIndex:indexPath.row] : [self.offerReceivedListings objectAtIndex:indexPath.row];
    NSNumber *count = [self.incomingOffers objectForKey:pop.objectId];
    cell.numOfferLabel.text = [NSString stringWithFormat:@"%d offers", count.intValue];
    cell.numOfferLabel.hidden = NO;

    // count number of views for the pop
    PFQuery *query = [LPPopInfo query];
    [query whereKey:@"pop" equalTo:pop];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (objects.count == 1) {
            LPPopInfo *popInfo = objects.firstObject;
            cell.numViewLabel.text = [NSString stringWithFormat:@"%@ views", popInfo.numViews];
        } else {
            cell.numViewLabel.text = @"0 view";
        }
    }];

    cell.offerStatusLabel.hidden = YES;
    cell.numViewLabel.hidden = NO;
    cell.numOfferLabel.hidden = NO;
    cell.contentView.backgroundColor = [UIColor whiteColor];

    cell.titleLabel.text = pop.title;

    // load image
    PFFile *file = pop.images.firstObject;
    [cell.imgView sd_setImageWithURL:[NSURL URLWithString:file.url]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    LPIncomingOfferTableViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"incomingOfferTableView"];
    LPPop *pop;

    if (self.segmentedControl.selectedSegmentIndex == 0) {
        pop = [self.listings objectAtIndex:indexPath.row];
    } else {
        pop = [self.offerReceivedListings objectAtIndex:indexPath.row];
    }

    vc.pop = pop;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark SegmentedControl

- (IBAction)viewSelected:(id)sender {
    [self.tableView reloadData];
}

# pragma mark Navigation Control

- (IBAction)prepareForUnwind:(UIStoryboardSegue *)unwindSegue {
    // FIXME set enable will pop to the vc that hides the tab bar, instead of where it supoose to be
    if ([self.tabBarController isKindOfClass:[LPMainViewTabBarController class]]) {
        [(LPMainViewTabBarController *)self.tabBarController setTabBarVisible:YES animated:YES];
    }
}

@end

