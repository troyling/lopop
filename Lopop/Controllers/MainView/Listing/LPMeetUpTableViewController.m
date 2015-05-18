//
//  LPMeetUpTableViewController.m
//  Lopop
//
//  Created by Troy Ling on 5/14/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "LPMeetUpTableViewController.h"
#import "LPMeetUpTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "LPLocationHelper.h"
#import "LPOffer.h"
#import "LPPop.h"

@interface LPMeetUpTableViewController ()

@property (strong, nonatomic) NSMutableArray *offers;

@end

@implementation LPMeetUpTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.rowHeight = 245.0f;

    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];

    [self loadData];
}

- (void)loadData {
    self.offers = [[NSMutableArray alloc] init];

    // two types of meetups here
    // my selling meetup
    LPOfferStatus status = kOfferMeetUpAccepted;

    PFQuery *myListingQuery = [LPPop query];
    [myListingQuery whereKey:@"seller" equalTo:[PFUser currentUser]];

    PFQuery *incomingOfferQuery = [LPOffer query];
    [incomingOfferQuery whereKey:@"status" equalTo:[NSNumber numberWithInt:status]];
    [incomingOfferQuery whereKey:@"pop" matchesQuery:myListingQuery];

    // my buying meetup
    PFQuery *myOfferQuery = [LPOffer query];
    [myOfferQuery whereKey:@"fromUser" equalTo:[PFUser currentUser]];
    [myOfferQuery whereKey:@"status" equalTo:[NSNumber numberWithInt:status]];

    // compound query
    PFQuery *offerQuery = [PFQuery orQueryWithSubqueries:@[incomingOfferQuery, myOfferQuery]];
    [offerQuery includeKey:@"fromUser"];
    [offerQuery includeKey:@"pop"];
    [offerQuery orderByDescending:@"meetUpTime"];
    [offerQuery findObjectsInBackgroundWithBlock:^(NSArray *offers, NSError *error) {
        if (!error) {
            [self.offers addObjectsFromArray:offers];
            [self.tableView reloadData];
        } else {
            NSLog(@"%@", error);
        }
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.offers == nil ? 0 : self.offers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    NSString *identifier = @"meetUpCell";
    LPMeetUpTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];

    if (!cell) {
        cell = [[LPMeetUpTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }

    LPOffer *offer = [self.offers objectAtIndex:indexPath.row];

    // Time
    NSTimeZone *timeZoneLocal = [NSTimeZone localTimeZone];
    NSDateFormatter *outputDateFormatter = [[NSDateFormatter alloc] init];
    [outputDateFormatter setTimeZone:timeZoneLocal];
    [outputDateFormatter setDateFormat:@"EEE, MMM d, h:mm a"];
    NSString *outputString = [outputDateFormatter stringFromDate:offer.meetUpTime];
    [cell.timeLabel setText:outputString];

    // location
    [LPLocationHelper getAddressForGeoPoint:offer.meetUpLocation withBlock: ^(NSString *address, NSError *error) {
        if (!error) {
            [cell.locationLabel setText:address];
        }
    }];

    // user
    [cell.profileImgView sd_setImageWithURL:offer.fromUser[@"profilePictureUrl"]];
    cell.nameLabel.text = offer.fromUser[@"name"];

    // pop info
    cell.popTitleLabel.text = offer.pop.title;

    // TODO add action listeners for buttons


    return cell;
}

@end
