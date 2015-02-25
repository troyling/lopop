//
//  LPLocationPickerViewController.m
//  Lopop
//
//  Created by Troy Ling on 2/21/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "LPLocationPickerViewController.h"
#import "LPLocationHelper.h"

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

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    CLLocation *loc = [[CLLocation alloc] initWithLatitude:self.mapView.centerCoordinate.latitude longitude:self.mapView.centerCoordinate.longitude];
    self.location = loc;
    [LPLocationHelper getAddressForLocation:self.location withBlock:^(NSString *address, NSError *error) {
        if (!error) {
            self.addressLabel.text = address;
        }
    }];
}

- (IBAction)dismiss:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
