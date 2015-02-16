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
#import "LPPopHelper.h"

@interface LPListingTableViewController ()

@property (strong, nonatomic) NSMutableArray *listings;
@property (strong, nonatomic) NSMutableArray *offerredPops;
@property (strong, nonatomic) NSMutableDictionary *incomingOffers;

@property (assign) LPDisplayState displayState;

@end

@implementation LPListingTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // configure table view
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.rowHeight = 90.0f;

    // cache the offer
    self.incomingOffers = [[NSMutableDictionary alloc] init];

    self.displayState = LPListingDisplay;
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
        id count = [self.incomingOffers objectForKey:pop.objectId];

        if (count != nil) {
            cell.numOfferLabel.text = [NSString stringWithFormat:@"%@ offers!", count];
        } else {
            [LPPopHelper countOffersToPop:pop inBackgroundWithBlock:^(int count, NSError *error) {
                if (!error) {
                    [self.incomingOffers setObject:[NSNumber numberWithInt:count] forKey:pop.objectId];
                    cell.numOfferLabel.text = count == 0 ? @"No offer yet" : [NSString stringWithFormat:@"%d offers!", count];
                }
            }];
        }
    } else {
        pop = [self.offerredPops objectAtIndex:indexPath.row];
    }

    cell.titleLabel.text = pop.title;
    cell.priceLabel.text = [pop publicPriceStr];

    PFFile *file = pop.images.firstObject;
    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
            UIImage *img = [UIImage imageWithData:data];
            cell.imgView.contentMode = UIViewContentModeScaleAspectFill;
            cell.imgView.image = img;
            cell.imgView.clipsToBounds = YES;
        }
    }];

    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

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

@end

