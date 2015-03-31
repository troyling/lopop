//
//  LPNewMeetupViewController.m
//  Lopop
//
//  Created by Troy Ling on 3/31/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "LPNewMeetupViewController.h"
#import "UIImageView+WebCache.h"
#import "LPLocationHelper.h"

@interface LPNewMeetupViewController ()

@end

@implementation LPNewMeetupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadMeetupView];
}

- (void)loadMeetupView {
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

    if (self.offer.meetUpLocation) {
        [LPLocationHelper getAddressForGeoPoint:self.offer.meetUpLocation withBlock:^(NSString *address, NSError *error) {
            if (!error) {
                [self.pickLocationBtn setTitle:address forState:UIControlStateNormal];
            }
        }];
    } else {
        [LPLocationHelper getAddressForGeoPoint:self.pop.location withBlock:^(NSString *address, NSError *error) {
            if (!error) {
                [self.pickLocationBtn setTitle:address forState:UIControlStateNormal];
            }
        }];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)selectTime:(id)sender {
}

- (IBAction)pickLocatino:(id)sender {
}

- (IBAction)confirmMeetup:(id)sender {
}

- (IBAction)dismiss:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
