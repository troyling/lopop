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

@interface LPListingTableViewController ()

@property (strong, nonatomic) NSMutableArray *listings;
@property (strong, nonatomic) NSMutableArray *offerredPops;
@property (strong, nonatomic) NSMutableDictionary *incomingOffers;
@property (strong, nonatomic) NSMutableArray *myOffers;

@property (assign) LPDisplayState displayState;

@end

@implementation LPListingTableViewController

CGFloat const LISTING_CELL_HEIGHT = 275.0f;
CGFloat const OFFER_CELL_HEIGHT = 90.0f;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self followScrollView:self.tableView];

    // configure table view
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.displayState = LPListingDisplay;

    // cache the offer
    self.incomingOffers = [[NSMutableDictionary alloc] init];

    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
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
    // populate data for user
    PFQuery *listingQuery = [LPPop query];
    [listingQuery whereKey:@"seller" equalTo:[PFUser currentUser]];
    [listingQuery orderByDescending:@"createdAt"];
    [listingQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            self.listings = [[NSMutableArray alloc] initWithArray:objects];

            // reload table if necessary
            if (self.displayState == LPListingDisplay) {
                [self.tableView reloadData];
            }
        }
    }];

    self.offerredPops = [[NSMutableArray alloc] init];
    PFQuery *offerQuery = [LPOffer query];
    [offerQuery whereKey:@"fromUser" equalTo:[PFUser currentUser]];
    [offerQuery includeKey:@"pop"];
    [offerQuery orderByDescending:@"createdAt"];
    [offerQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            self.myOffers = [[NSMutableArray alloc] initWithArray:objects];
            for(id o in objects) {
                if ([o isKindOfClass:[LPOffer class]]) {
                    LPOffer *offer = o;
                    [self.offerredPops addObject:offer.pop];

                    // reload table if necessary
                    if (self.displayState == LPOfferDisplay) {
                        [self.tableView reloadData];
                    }
                }
            }
        }
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rows;

    switch (self.displayState) {
        case LPListingDisplay:
            rows = self.listings == nil ? 0 : self.listings.count;
            break;
        case LPOfferDisplay:
            rows = self.offerredPops == nil ? 0 : self.offerredPops.count;
            break;
        default:
            rows = 0;
            break;
    }

    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = self.displayState == LPListingDisplay? @"listingCell" : @"offerCell";

    LPPopListingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];

    if (!cell) {
        cell = [[LPPopListingTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }

    LPPop *pop;

    if (self.displayState == LPListingDisplay) {
        pop = [self.listings objectAtIndex:indexPath.row];
        // asynchronously load number of offers, if needed
        id item = [self.incomingOffers objectForKey:pop.objectId];

        if (item != nil) {
            int count = 0;

            if ([item isKindOfClass:[NSNumber class]]) {
                count = [(NSNumber *)item intValue];
            }

            cell.numOfferLabel.text = [NSString stringWithFormat:@"%d offers", count];
            cell.numOfferLabel.hidden = NO;
        } else {
            [LPPopHelper countOffersToPop:pop inBackgroundWithBlock:^(int count, NSError *error) {
                if (!error) {
                    [self.incomingOffers setObject:[NSNumber numberWithInt:count] forKey:pop.objectId];
                    cell.numOfferLabel.text = [NSString stringWithFormat:@"%d offers", count];
                    cell.numOfferLabel.hidden = NO;
                }
            }];
        }
    } else {
        pop = [self.offerredPops objectAtIndex:indexPath.row];
    }

    cell.titleLabel.text = pop.title;
    cell.priceLabel.text = [pop publicPriceStr];

    // query number of views
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

    PFFile *file = pop.images.firstObject;
    [cell.imgView sd_setImageWithURL:[NSURL URLWithString:file.url]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.displayState == LPListingDisplay) {
        LPIncomingOfferTableViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"incomingOfferTableView"];
        LPPop *pop = [self.listings objectAtIndex:indexPath.row];
        vc.pop = pop;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.displayState == LPListingDisplay ? LISTING_CELL_HEIGHT : OFFER_CELL_HEIGHT;
}

#pragma mark SegmentedControl

- (IBAction)viewSelected:(id)sender {
    switch(self.segmentedControl.selectedSegmentIndex) {
        case 0:
            // Listing view
            if (self.displayState == LPOfferDisplay) {
                self.displayState = LPListingDisplay;
                [self.tableView reloadData];
            } else {
                self.displayState = LPListingDisplay;
            }

            break;
        case 1:
            // offer view
            if (self.displayState == LPListingDisplay) {
                self.displayState = LPOfferDisplay;
                [self.tableView reloadData];
            } else {
                self.displayState = LPOfferDisplay;
            }

            break;
        default:
            break;
    }
}

# pragma mark Navigation Control

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[LPMeetUpMapViewController class]]) {
        LPMeetUpMapViewController *vc = segue.destinationViewController;

        if ([sender isKindOfClass:[LPPopListingTableViewCell class]]) {
            LPPopListingTableViewCell *cell = sender;
            NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
            LPOffer *offer = [self.myOffers objectAtIndex:indexPath.row];
            NSLog(@"%@", offer);
            vc.offer = offer;
        }

        // engage user by hiding tabbar
        if ([self.tabBarController isKindOfClass:[LPMainViewTabBarController class]]) {
            LPMainViewTabBarController *tb = (LPMainViewTabBarController *) self.tabBarController;
            [tb setTabBarVisible:NO animated:YES];
        }
    }
}

- (IBAction)prepareForUnwind:(UIStoryboardSegue *)unwindSegue {
    // FIXME set enable will pop to the vc that hides the tab bar, instead of where it supoose to be
    if ([self.tabBarController isKindOfClass:[LPMainViewTabBarController class]]) {
        [(LPMainViewTabBarController *)self.tabBarController setTabBarVisible:YES animated:YES];
    }
}

@end

