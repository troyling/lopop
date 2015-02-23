//
//  LPMeetUpMapViewController.m
//  Lopop
//
//  Created by Troy Ling on 2/23/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "LPMeetUpMapViewController.h"
#import "LPPop.h"

@interface LPMeetUpMapViewController ()

@property (strong, nonatomic) LPPop *pop;
@property (strong, nonatomic) PFUser *meetUpUser;
@property (strong, nonatomic) NSDate *meetUpTime;
@property (strong, nonatomic) CLLocation *meetUpLocation;

@end

@implementation LPMeetUpMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    PFQuery *query = [LPOffer query];
    [query whereKey:@"objectId" equalTo:self.offer.objectId];
    [query includeKey:@"pop"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error && objects.count == 1) {
            LPOffer *offer = objects.firstObject;
            self.offer = offer;
            self.pop = self.offer.pop;
            [self loadData];
        }
    }];

    // FIXME the meetup user is not always the fromUser of the offers
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)loadData {
    self.meetUpUser = self.offer.fromUser;
    self.meetUpTime = self.offer.meetUpTime; //meetup time in UTC
    self.meetUpLocation = [[CLLocation alloc] initWithLatitude:self.offer.meetUpLocation.latitude longitude:self.offer.meetUpLocation.longitude];

    [self.meetUpUser fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error) {
            [self loadMeetUpUserInfo];
        }
    }];
}

- (void)loadMeetUpUserInfo {
    NSLog(@"meetupUser: %@", self.meetUpUser);
}

@end
