//
//  LPMeetUpMapViewController.m
//  Lopop
//
//  Created by Troy Ling on 2/23/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "LPMeetUpMapViewController.h"
#import "UIImageView+WebCache.h"
#import "LPUIHelper.h"
#import "RateView.h"
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

    self.mapView.delegate = self;

    // TODO check status of the view
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

    // load UI
    NSTimeZone *timeZoneLocal = [NSTimeZone localTimeZone];
    NSDateFormatter *outputDateFormatter = [[NSDateFormatter alloc] init];
    [outputDateFormatter setTimeZone:timeZoneLocal];
    [outputDateFormatter setDateFormat:@"EEE, MMM d, h:mm a"];
    NSString *outputString = [outputDateFormatter stringFromDate:self.meetUpTime];

    self.meetUpTimeLabel.text = [NSString stringWithFormat:@"Meet up at %@" , outputString];

    [self loadPopInfo];

    [self.meetUpUser fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error) {
            [self loadMeetUpUserInfo];
        }
    }];
}

- (void)loadPopInfo {
    if (self.pop) {
        // pop icon
        PFFile *imgFile = self.pop.images.firstObject;
        NSString *urlStr = imgFile.url;
        [self.popImgView sd_setImageWithURL:[NSURL URLWithString:urlStr]];

        // labels
        self.titleLabel.text = self.pop.title;
        self.priceLabel.text = [self.pop publicPriceStr];
    }
}

- (void)loadMeetUpUserInfo {
    if (self.meetUpUser) {
        // user icon
        [self.profileImgView sd_setImageWithURL:[NSURL URLWithString:self.meetUpUser[@"profilePictureUrl"]]];
        self.profileImgView.layer.cornerRadius = self.profileImgView.bounds.size.width / 2.0f;
        self.profileImgView.clipsToBounds = YES;

        self.usernameLabel.text = self.meetUpUser[@"name"];

        // load user rating
        RateView *rv = [RateView rateViewWithRating:4.4f];
        rv.starFillColor = [LPUIHelper ratingStarColor];
        rv.starSize = 15.0f;
        rv.starNormalColor = [UIColor lightGrayColor];
        [self.userRatingView addSubview:rv];
    }
}

- (IBAction)dismiss:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)contactUser:(id)sender {
}

@end
