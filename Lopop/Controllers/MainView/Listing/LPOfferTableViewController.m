//
//  LPOfferTableViewController.m
//  Lopop
//
//  Created by Troy Ling on 5/12/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "LPOfferTableViewController.h"
#import "LPPopListingTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "LPOffer.h"

@interface LPOfferTableViewController ()

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@property (strong, nonatomic) NSMutableArray *offerredPops;
@property (strong, nonatomic) NSMutableArray *pendingOfferredPops;
@property (strong, nonatomic) NSMutableArray *meetupProposedPops;

@property (strong, nonatomic) NSMutableArray *myOffers;
@property (strong, nonatomic) NSMutableArray *myPendingOffers;
@property (strong, nonatomic) NSMutableArray *meetupProposedOffers;

@end

@implementation LPOfferTableViewController

CGFloat const CELL_HEIGHT = 275.0f;

- (void)viewDidLoad {
    [super viewDidLoad];

    // configure table view
    self.tableView.rowHeight = CELL_HEIGHT;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];

    [self loadData];
}

- (void)loadData {
    self.offerredPops = [[NSMutableArray alloc] init];
    self.meetupProposedPops = [[NSMutableArray alloc] init];
    self.pendingOfferredPops = [[NSMutableArray alloc] init];
    self.meetupProposedOffers = [[NSMutableArray alloc] init];
    self.myPendingOffers = [[NSMutableArray alloc] init];

    PFQuery *offerQuery = [LPOffer query];
    [offerQuery whereKey:@"fromUser" equalTo:[PFUser currentUser]];
    [offerQuery includeKey:@"pop"];
    [offerQuery orderByDescending:@"status"];
    [offerQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            self.myOffers = [[NSMutableArray alloc] initWithArray:objects];
            for(id o in objects) {
                if ([o isKindOfClass:[LPOffer class]]) {
                    LPOffer *offer = o;
                    [self.offerredPops addObject:offer.pop];

                    // query used for sorting
                    if (offer.status == kOfferPending) {
                        [self.myPendingOffers addObject:offer];
                        [self.pendingOfferredPops addObject:offer.pop];
                    } else if (offer.status == kOfferMeetUpProposed) {
                        [self.meetupProposedOffers addObject:offer];
                        [self.meetupProposedPops addObject:offer.pop];
                    }

                    // reload table if necessary
                    [self.tableView reloadData];
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
    switch (self.segmentedControl.selectedSegmentIndex) {
        case 1:
            // sort the table for Accepted Offer
            return self.meetupProposedPops == nil ? 0 : self.meetupProposedPops.count;
        default:
            return self.pendingOfferredPops == nil ? 0 : self.pendingOfferredPops.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"listingCell";
    LPPopListingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];

    if (!cell) {
        cell = [[LPPopListingTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }

    LPPop *pop;
    LPOffer *offer;

    switch (self.segmentedControl.selectedSegmentIndex) {
        case 1:
            // sort the table for Accepted Offer
            pop = [self.meetupProposedPops objectAtIndex:indexPath.row];
            offer = [self.meetupProposedOffers objectAtIndex:indexPath.row];
            break;
        default:
            // TODO All pending offers
            pop = [self.pendingOfferredPops objectAtIndex:indexPath.row];
            offer = [self.myPendingOffers objectAtIndex:indexPath.row];
            break;
    }

    // check the status of the offer
    NSString *statusStr = @"";

    switch (offer.status) {
        case kOfferPending:
            statusStr = @"Offer sent";
            break;
        case kOfferMeetUpProposed:
            statusStr = @"Confirmation needed";
            break;
        case kOfferMeetUpAccepted:
            statusStr = @"Confirm meetup!";
            break;
        case kOfferNotAccepted:
            statusStr = @"Not accepted";
            break;
        case kOfferDeclined:
            statusStr = @"Offer declined";
            break;
        case kOfferCompleted:
            statusStr = @"Completed";
        default:
            break;
    }

    cell.offerStatusLabel.text = statusStr;
    cell.titleLabel.text = pop.title;

    // load image
    PFFile *imgFile = pop.images.firstObject;
    [cell.imgView sd_setImageWithURL:[NSURL URLWithString:imgFile.url]];

    return cell;
}

#pragma mark SegmentedControl

- (IBAction)viewSelected:(id)sender {
    [self.tableView reloadData];
}

@end
