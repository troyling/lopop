//
//  LPNewMeetupViewController.m
//  Lopop
//
//  Created by Troy Ling on 3/31/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//
//  This is the controller that presents shows the meet up info based on the status of the offer.
//
//  It will be in meetup propose mode for only seller when
//          - offer.status = kOfferPending
//
//  meetup confirm mode for buyer when
//          - offer.status = kOfferMeetUpProposed
//
//  preview mode for
//          Buyer: when
//              - proposed a meetup
//          Seller: when
//              - confirm a meetup

#import "LPNewMeetupViewController.h"
#import "LPLocationPickerViewController.h"
#import "LPTimePickerViewController.h"
#import "UIImageView+WebCache.h"
#import "LPPushHelper.h"
#import "LPLocationHelper.h"
#import "LPAlertViewHelper.h"
#import "LPUIHelper.h"

typedef enum {
    kBuyerMode = 0,
    kSellerMode
} LPViewMode;

@interface LPNewMeetupViewController ()
@property (retain, nonatomic) PFGeoPoint *meetUpLocation;
@property (retain, nonatomic) NSDate *meetUpTime;
@property (retain, nonatomic) PFUser *meetUpUser;
@property (assign) LPViewMode mode;

@end

@implementation LPNewMeetupViewController

NSString *const MSG_MEETUP_REQUEST_SENT = @"Please be patient as the user responses to your meet up request";
NSString *const MSG_MEETUP_PROPOSED = @"Seller proposed the following meet up";
NSString *const MSG_MEETUP_CONFIRMED = @"You will be going to the following meet up";

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

    if ([[PFUser currentUser].objectId isEqualToString:self.offer.fromUser.objectId]) {
        self.meetUpUser = self.pop.seller;
        self.mode = kBuyerMode;
    }
    else {
        self.meetUpUser = self.offer.fromUser;
        self.mode = kSellerMode;
    }

    if (self.meetUpUser.isDataAvailable) {
        [self loadProfileView];
    }
    else {
        [self.meetUpUser fetchInBackgroundWithBlock: ^(PFObject *object, NSError *error) {
            if (!error) {
                [self loadProfileView];
            }
            else {
                // TODO error handling
                NSLog(@"Unable to get fromUser");
            }
        }];
    }

    [self loadTimeIconImageView];
    [self loadLocaitonIconImageView];

    if (self.offer.status == kOfferMeetUpProposed) {
        [self setConfirmMeetupMode];
    }
    else if (self.offer.status == kOfferMeetUpAccepted) {
        [self setPreviewMode];
    }
    else {
        [self setProposeMode];
    }
}

#pragma mark - Navigation Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
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

#pragma mark Actions

- (IBAction)confirmMeetup:(id)sender {
    if (self.offer.status == kOfferPending) {
        // propose mode
        self.offer.status = kOfferMeetUpProposed;
        self.offer.meetUpLocation = self.meetUpLocation;
        self.offer.meetUpTime = self.meetUpTime;
    }
    else if (self.offer.status == kOfferMeetUpProposed) {
        // comfirm meetup mode
        self.offer.status = kOfferMeetUpAccepted;
    }

    [self.offer saveEventually: ^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            // change the UI of this view once the meetup is saved
            if (self.offer.status == kOfferMeetUpProposed) {
                [self setPreviewMode];
                [LPPushHelper sendPushWithOffer:self.offer];
            } if (self.offer.status == kOfferMeetUpAccepted) {
                [self setPreviewMode];
                PFUser *currentUser = [PFUser currentUser];
                if (currentUser != nil) {
                    NSString *msg = [NSString stringWithFormat:@"%@ confirmed your meet up", currentUser[@"name"]];
                    [LPPushHelper sendPushWithPop:self.pop withMsg:msg];
                }
            }
        }
        else {
            [LPAlertViewHelper fatalErrorAlert:@"Unable to save the meet up. Please try again later."];
        }
    }];
}

- (IBAction)dismiss:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark UI Helper

/**
 *  Set view for displaying info of the meet up, as well as allowing user to accept a meetup proposal
 */
- (void)setPreviewMode {
    [self disableProposeViews];

    if (self.offer.status == kOfferMeetUpProposed) {
        self.alertMsgLabel.text = self.mode == kSellerMode ? MSG_MEETUP_REQUEST_SENT : MSG_MEETUP_PROPOSED;
    }
    else if (self.offer.status == kOfferMeetUpAccepted) {
        self.alertMsgLabel.text = MSG_MEETUP_CONFIRMED;
    }

    self.confirmBtn.hidden = YES;
}

- (void)setConfirmMeetupMode {
    [self disableProposeViews];

    if (self.mode == kBuyerMode) {
        // allow buyer to confirm the meetup
        self.confirmBtn.hidden = NO;
        self.confirmBtn.backgroundColor = [LPUIHelper infoColor];

        self.alertMsgLabel.text = MSG_MEETUP_PROPOSED;
        self.alertMsgLabel.hidden = NO;

        [self.confirmBtn setTitle:@"Confirm" forState:UIControlStateNormal];
    }
    else {
        // show seller that buyer needs to confirm
        self.confirmBtn.hidden = YES;
        self.alertMsgLabel.text = MSG_MEETUP_REQUEST_SENT;
        self.alertMsgLabel.hidden = NO;
    }
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

- (void)disableProposeViews {
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
    self.alertImgView.hidden = YES;
}

- (void)showConfirmBtnIfNecessary {
    self.confirmBtn.hidden = !(self.meetUpLocation && self.meetUpTime);
}

- (void)loadProfileView {
    self.nameLabel.text = self.meetUpUser[@"name"];
    [self.profileImgView sd_setImageWithURL:self.meetUpUser[@"profilePictureUrl"]];

    // circular imageview UI
    self.profileImgView.layer.cornerRadius = self.profileImgView.frame.size.height / 2.0f;
    self.profileImgView.clipsToBounds = YES;
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
