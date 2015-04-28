//
//  LPNewMeetupViewController.m
//  Lopop
//
//  Created by Troy Ling on 3/31/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//
//  This is the controller that presents shows the meet up info based on the status of the offer.
//  It will preview the propose mode only if the offer is meetup is proposed or accepted

#import "LPNewMeetupViewController.h"
#import "LPLocationPickerViewController.h"
#import "LPTimePickerViewController.h"
#import "UIImageView+WebCache.h"
#import "LPLocationHelper.h"
#import "LPAlertViewHelper.h"

@interface LPNewMeetupViewController ()
@property (retain, nonatomic) PFGeoPoint *meetUpLocation;
@property (retain, nonatomic) NSDate *meetUpTime;

@end

@implementation LPNewMeetupViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // wrapping to show all contents on label and buttons
    self.timeLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.locationLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.pickTimeBtn.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.pickLocationBtn.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;

    [self loadMeetupView];
}

- (void)loadMeetupView {
    self.meetUpLocation = self.offer.meetUpLocation == nil ? self.pop.location : self.offer.meetUpLocation;
    self.meetUpTime = self.offer.meetUpTime;

    if (self.offer.fromUser.isDataAvailable) {
        [self loadProfileView];
    }
    else {
        [self.offer.fromUser fetchInBackgroundWithBlock: ^(PFObject *object, NSError *error) {
            if (!error) {
                [self loadProfileView];
            } else {
                // TODO error handling
                NSLog(@"Unable to get fromUser");
            }
        }];
    }

    [self loadTimeIconImageView];
    [self loadLocaitonIconImageView];

    if (self.offer.status == kOfferMeetUpProposed || self.offer.status == kOfferAccepted) {
        [self setPreviewMode];
    }
    else {
        [self setProposeMode];
    }
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
    [self.offer saveEventually: ^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            // change the UI of this view once the meetup is saved
            [self setPreviewMode];
        }
        else {
            [LPAlertViewHelper fatalErrorAlert:@"Unable to save the meet up. Please try again later."];
        }
    }];
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

        // Change state of icon in the future
        [self loadLocaitonIconImageView];
    }
    else if ([unwindsegue.sourceViewController isKindOfClass:[LPTimePickerViewController class]]) {
        LPTimePickerViewController *vc = unwindsegue.sourceViewController;
        [self.pickTimeBtn setTitle:vc.timeLabel.text forState:UIControlStateNormal];
        self.meetUpTime = vc.datePicker.date;

        // change state of icon
        [self loadTimeIconImageView];
    }

    [self showConfirmBtnIfNecessary];
}

#pragma mark UI Helper

- (void)loadProfileView {
    self.nameLabel.text = self.offer.fromUser[@"name"];
    [self.profileImgView sd_setImageWithURL:self.offer.fromUser[@"profilePictureUrl"]];
    self.profileImgView.layer.cornerRadius = self.profileImgView.frame.size.height / 2.0f;
    self.profileImgView.clipsToBounds = YES;
}

/**
 *  Set view for displaying info of the meet up
 */
- (void)setPreviewMode {
    if (self.offer.meetUpTime) {
        NSTimeZone *timeZoneLocal = [NSTimeZone localTimeZone];
        NSDateFormatter *outputDateFormatter = [[NSDateFormatter alloc] init];
        [outputDateFormatter setTimeZone:timeZoneLocal];
        [outputDateFormatter setDateFormat:@"EEE, MMM d, h:mm a"];
        NSString *outputString = [outputDateFormatter stringFromDate:self.offer.meetUpTime];

        [self.timeLabel setText:outputString];
    }

    [LPLocationHelper getAddressForGeoPoint:self.offer.meetUpLocation withBlock: ^(NSString *address, NSError *error) {
        if (!error) {
            [self.locationLabel setText:address];
        }
    }];

    // show labels
    self.timeLabel.hidden = NO;
    self.locationLabel.hidden = NO;

    // hide buttons, icon, and label
    self.pickTimeBtn.hidden = YES;
    self.pickLocationBtn.hidden = YES;
    self.confirmBtn.hidden = YES;
    self.alertImgView.hidden = YES;
    self.alertMsgLabel.hidden = YES;

    // TODO change button color to indicate the status
}

/**
 *  Set view for proposing meeting up
 */
- (void)setProposeMode {
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

    [self showConfirmBtnIfNecessary];
}

- (void)showConfirmBtnIfNecessary {
    self.confirmBtn.hidden = !(self.meetUpLocation && self.meetUpTime);
}

- (void)loadTimeIconImageView {
    if (self.meetUpTime != nil) {
        [self.timeIconImgView setImage:[UIImage imageNamed:@"icon_clock_fill"]];
    }
    else {
        [self.timeIconImgView setImage:[UIImage imageNamed:@"icon_clock_gray"]];
    }
}

- (void)loadLocaitonIconImageView {
    if (self.meetUpLocation != nil) {
        [self.locationIconImgView setImage:[UIImage imageNamed:@"icon_location_fill"]];
    }
    else {
        [self.locationIconImgView setImage:[UIImage imageNamed:@"icon_location_gray"]];
    }
}

@end
