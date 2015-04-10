//
//  LPNewMeetupViewController.m
//  Lopop
//
//  Created by Troy Ling on 3/31/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "LPNewMeetupViewController.h"
#import "LPLocationPickerViewController.h"
#import "LPTimePickerViewController.h"
#import "UIImageView+WebCache.h"
#import "LPLocationHelper.h"

@interface LPNewMeetupViewController ()
@property (retain, nonatomic) PFGeoPoint *meetUpLocation;
@property (retain, nonatomic) NSDate *meetUpTime;

@end

@implementation LPNewMeetupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadMeetupView];
}

- (void)loadMeetupView {
    self.meetUpLocation = self.offer.meetUpLocation == nil ? self.pop.location : self.offer.meetUpLocation;
    self.meetUpTime = self.offer.meetUpTime;

    self.nameLabel.text = self.offer.fromUser[@"name"];
    self.profileImgView.layer.cornerRadius = self.profileImgView.frame.size.height / 2.0f;
    self.profileImgView.clipsToBounds = YES;
    [self.profileImgView sd_setImageWithURL:self.offer.fromUser[@"profilePictureUrl"]];

    if (self.offer.meetUpTime) {
        NSTimeZone *timeZoneLocal = [NSTimeZone localTimeZone];
        NSDateFormatter *outputDateFormatter = [[NSDateFormatter alloc] init];
        [outputDateFormatter setTimeZone:timeZoneLocal];
        [outputDateFormatter setDateFormat:@"EEE, MMM d, h:mm a"];
        NSString *outputString = [outputDateFormatter stringFromDate:self.offer.meetUpTime];
        [self.pickTimeBtn setTitle:outputString forState:UIControlStateNormal];
    }

    [LPLocationHelper getAddressForGeoPoint:self.meetUpLocation withBlock: ^(NSString *address, NSError *error) {
        if (!error) {
            [self.pickLocationBtn setTitle:address forState:UIControlStateNormal];
        }
    }];

    self.pickTimeBtn.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.pickLocationBtn.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;

    [self loadTimeIconImageView];
    [self loadLocaitonIconImageView];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.destinationViewController isKindOfClass:[LPLocationPickerViewController class]]) {
        LPLocationPickerViewController *vc = segue.destinationViewController;
        CLLocation *loc = [[CLLocation alloc] initWithLatitude:self.meetUpLocation.latitude longitude:self.meetUpLocation.longitude];
        vc.location = loc;
    }
    else if ([segue.destinationViewController isKindOfClass:[LPTimePickerViewController class]]) {
        LPTimePickerViewController *vc = segue.destinationViewController;
        vc.date = self.meetUpTime;
    }
}

- (IBAction)confirmMeetup:(id)sender {
    self.offer.status = kOfferMeetUpProposed;
    self.offer.meetUpLocation = self.meetUpLocation;
    self.offer.meetUpTime = self.meetUpTime;
    [self.offer saveEventually];

    // TODO change the UI of this view once the meetup is saved
}

- (IBAction)dismiss:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark Unwind segue

- (IBAction)prepareForUnwindSegue:(UIStoryboardSegue *)unwindsegue {
    if ([unwindsegue.sourceViewController isKindOfClass:[LPLocationPickerViewController class]]) {
        LPLocationPickerViewController *vc = unwindsegue.sourceViewController;
        self.meetUpLocation = [PFGeoPoint geoPointWithLocation:vc.location];
        [self.pickLocationBtn setTitle:vc.addressLabel.text forState:UIControlStateNormal];
        NSLog(@"hi");
        //TODO: Change state of icon in the future
        [self loadLocaitonIconImageView];
    } else if ([unwindsegue.sourceViewController isKindOfClass:[LPTimePickerViewController class]]) {
        LPTimePickerViewController *vc = unwindsegue.sourceViewController;
        [self.pickTimeBtn setTitle:vc.timeLabel.text forState:UIControlStateNormal];
        self.meetUpTime = vc.datePicker.date;
        //TODO change state of icon
        [self loadTimeIconImageView];
    }
}

#pragma mark UI Helper

- (void)loadTimeIconImageView {
    if (self.meetUpTime != nil) {
        [self.timeIconImgView setImage:[UIImage imageNamed:@"icon_clock_fill"]];
    } else {
        [self.timeIconImgView setImage:[UIImage imageNamed:@"icon_clock_gray"]];
    }
}

- (void)loadLocaitonIconImageView {
    if (self.meetUpLocation != nil) {
        [self.locationIconImgView setImage:[UIImage imageNamed:@"icon_location_fill"]];
    } else {
        [self.locationIconImgView setImage:[UIImage imageNamed:@"icon_location_gray"]];
    }
}

@end
