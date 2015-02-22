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

@interface LPOfferChatViewController ()

@property (retain, nonatomic) CLLocation *location;

@end

@implementation LPOfferChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];

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

- (void)loadData {
    self.location = [[CLLocation alloc] initWithLatitude:self.pop.location.latitude longitude:self.pop.location.longitude];

    // UI
    self.title = self.offerUser[@"name"];
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
        if(placemarks && placemarks.count > 0)
        {
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
                address = address.length > 0 ? [address stringByAppendingString:[NSString stringWithFormat:@", %@", [placemark administrativeArea]]] : [address stringByAppendingString:[NSString stringWithFormat:@"%@", [placemark administrativeArea]]];
            }

            [self.locationBtn setTitle:address forState:UIControlStateNormal];
        }
    }];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[LPMessageViewController class]]) {
        LPMessageViewController *vc = sender;
        vc.pop = self.pop;
        vc.offerUser = self.offerUser;
    } else if ([segue.destinationViewController isKindOfClass:[LPLocationPickerViewController class]]) {
        LPLocationPickerViewController *vc = segue.destinationViewController;
        vc.location = self.location;
    }
}

#pragma mark Unwind segue

- (IBAction)prepareForUnwindSegue:(UIStoryboardSegue *)unwindsegue {
    if ([unwindsegue.sourceViewController isKindOfClass:[LPLocationPickerViewController class]]) {
        LPLocationPickerViewController *vc = unwindsegue.sourceViewController;
        CLLocation *meetupLocation = vc.location;
        self.location = meetupLocation;

        // TODO save meetupLocation to server
        [self.locationBtn setTitle:vc.locationStr forState:UIControlStateNormal];
    }
}

@end
