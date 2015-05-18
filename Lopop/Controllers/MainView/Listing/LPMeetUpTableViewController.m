//
//  LPMeetUpTableViewController.m
//  Lopop
//
//  Created by Troy Ling on 5/14/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "LPMeetUpTableViewController.h"
#import "LPOffer.h"
#import "LPPop.h"

@interface LPMeetUpTableViewController ()

@property (strong, nonatomic) NSMutableArray *listingMeetUps;
@property (strong, nonatomic) NSMutableArray *offerMeetUps;

@end

@implementation LPMeetUpTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadData];
}

- (void)loadData {
    self.listingMeetUps = [[NSMutableArray alloc] init];
    self.offerMeetUps = [[NSMutableArray alloc] init];
    NSLog(@"WTF");

    // two types of meetups here
    // my selling meetup
    // my buying meetup
    LPOfferStatus status = kOfferMeetUpAccepted;

    PFQuery *myListingQuery = [LPPop query];
    [myListingQuery whereKey:@"seller" equalTo:[PFUser currentUser]];

    PFQuery *incomingOfferQuery = [LPOffer query];
    [incomingOfferQuery whereKey:@"status" equalTo:[NSNumber numberWithInt:status]];
    [incomingOfferQuery whereKey:@"pop" matchesQuery:myListingQuery];
    [incomingOfferQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSLog(@"objectes are: \n%@", objects);
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
    // Return the number of rows in the section.
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

@end
