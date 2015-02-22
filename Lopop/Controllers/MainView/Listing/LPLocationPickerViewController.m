//
//  LPLocationPickerViewController.m
//  Lopop
//
//  Created by Troy Ling on 2/21/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "LPLocationPickerViewController.h"

@interface LPLocationPickerViewController ()

@end

@implementation LPLocationPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // init mapview
    self.mapView.delegate = self;

    if (self.location) {
        [self.mapView setCenterCoordinate:self.location.coordinate animated:NO];

        MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(self.location.coordinate, 0.03, 0.03);
        MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:viewRegion];

        [self.mapView setRegion:adjustedRegion animated:NO];
    }
}

- (void)updateAddress {
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

            self.addressLabel.text = address;
        }
    }];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    CLLocation *loc = [[CLLocation alloc] initWithLatitude:self.mapView.centerCoordinate.latitude longitude:self.mapView.centerCoordinate.longitude];
    self.location = loc;
    [self updateAddress];
}

- (IBAction)dismiss:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
