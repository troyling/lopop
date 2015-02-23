//
//  LPOfferChatViewController.m
//  Lopop
//
//  Created by Troy Ling on 2/21/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "LPOfferChatViewController.h"
#import "LPMessageViewController.h"
#import "UIImageView+WebCache.h"
#import "LPLocationPickerViewController.h"
#import "LPTimePickerViewController.h"
#import "LPMeetUpMapViewController.h"

@interface LPOfferChatViewController ()


@property (retain, nonatomic) CLLocation *location;
@property (retain, nonatomic) NSDate *meetUpTime;

@end

@implementation LPOfferChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.offer fetchIfNeededInBackground];

    if ([self.pop isDataAvailable]) {
        [self loadData];
    } else {
        [self.pop fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            if (!error) {
                [self loadData];
            }
        }];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    // animation
    if (self.location == nil) {
        self.locationBtn.animation = @"shake";
        self.timeSelectorBtn.force = 0.5f;
        [self.locationBtn animate];
    }

    if (self.meetUpTime == nil) {
        self.timeSelectorBtn.animation = @"shake";
        self.timeSelectorBtn.force = 0.5f;
        [self.timeSelectorBtn animate];
    }
}

- (void)loadData {
    self.location = [[CLLocation alloc] initWithLatitude:self.pop.location.latitude longitude:self.pop.location.longitude];

    // UI
    self.title = self.offer.fromUser[@"name"];

    [self loadHeaderView];
    [self loadAddress];
}

- (void)loadHeaderView {
    PFFile *imgFile = self.pop.images.firstObject;
    NSString *urlStr = imgFile.url;
    [self.popImgView sd_setImageWithURL:[NSURL URLWithString:urlStr]];
    self.titleLabel.text = self.pop.title;
    self.priceLabel.text = [self.pop publicPriceStr];
}

- (void)loadAddress {
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:self.location completionHandler:^(NSArray *placemarks, NSError *error) {
        if(placemarks && placemarks.count > 0) {
            CLPlacemark *placemark= [placemarks objectAtIndex:0];

            NSString *address = @"";
            if ([placemark subThoroughfare]) {
                address = [address stringByAppendingString:[placemark subThoroughfare]];
            }

            if ([placemark thoroughfare]) {
                address = [address stringByAppendingString:[NSString stringWithFormat:@" %@", [placemark thoroughfare]]];
            }

            if ([placemark locality]) {
                address = address.length > 0 ? [address stringByAppendingString:[NSString stringWithFormat:@", %@", [placemark locality]]] : [address stringByAppendingString:[NSString stringWithFormat:@"%@", [placemark locality]]];;
            }

            if ([placemark administrativeArea]) {
                address = address.length > 0 ? [address stringByAppendingString:[NSString stringWithFormat:@", %@", [placemark administrativeArea]]] : [address stringByAppendingString:[NSString stringWithFormat:@"%@", [placemark administrativeArea]]];;
            }

            if ([placemark postalCode]) {
                address = address.length > 0 ? [address stringByAppendingString:[NSString stringWithFormat:@", %@", [placemark postalCode]]] : [address stringByAppendingString:[NSString stringWithFormat:@"%@", [placemark postalCode]]];
            }

            [self.locationBtn setTitle:address forState:UIControlStateNormal];
        }
    }];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[LPMessageViewController class]]) {
        LPMessageViewController *vc = segue.destinationViewController;
        vc.pop = self.pop;
        vc.offerUser = self.offer.fromUser;
    } else if ([segue.destinationViewController isKindOfClass:[LPLocationPickerViewController class]]) {
        LPLocationPickerViewController *vc = segue.destinationViewController;
        vc.location = self.location;
    } else if ([segue.destinationViewController isKindOfClass:[LPTimePickerViewController class]]) {
        LPTimePickerViewController *vc = segue.destinationViewController;
        vc.date = self.meetUpTime;
    }
}

#pragma mark Unwind segue

- (IBAction)prepareForUnwindSegue:(UIStoryboardSegue *)unwindsegue {
    if ([unwindsegue.sourceViewController isKindOfClass:[LPLocationPickerViewController class]]) {
        LPLocationPickerViewController *vc = unwindsegue.sourceViewController;
        CLLocation *meetupLocation = vc.location;
        self.location = meetupLocation;

        // TODO save meetupLocation to server
        [self.locationBtn setTitle:vc.addressLabel.text forState:UIControlStateNormal];
    } else if ([unwindsegue.sourceViewController isKindOfClass:[LPTimePickerViewController class]]) {
        LPTimePickerViewController *vc = unwindsegue.sourceViewController;
        [self.timeSelectorBtn setTitle:vc.timeLabel.text forState:UIControlStateNormal];

        // TODO save meetup time to server
        self.meetUpTime = vc.datePicker.date;
        [self enableMeetupBrn];
    }
}

- (void)enableMeetupBrn {
    if (self.meetupBtn.hidden) {
        self.meetupBtn.animation = @"pop";
        [self.meetupBtn animate];
        self.meetupBtn.hidden = NO;
    }
}

- (IBAction)proposeMeetup:(id)sender {
    // save data
    self.offer.meetUplocation = [PFGeoPoint geoPointWithLocation:self.location];
    self.offer.meetUpTime = self.meetUpTime;
    self.offer.status = kOfferMeetUpProposed;
    [self.offer saveEventually];

    // FIXME allows them to preview the map once both user agrees on the proposal
    LPMeetUpMapViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"meetUpMapViewController"];
    vc.pop = self.pop;
    vc.offfer = self.offer;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
