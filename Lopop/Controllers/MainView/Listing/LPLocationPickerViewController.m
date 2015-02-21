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

    // Do any additional setup after loading the view.
    if (self.location) {
        [self.mapView setCenterCoordinate:self.location.coordinate animated:NO];

        MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(self.location.coordinate, 0.03, 0.03);
        MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:viewRegion];

        [self.mapView setRegion:adjustedRegion animated:NO];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateAddressWithLocation: (CLLocation *)location {
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if(placemarks && placemarks.count > 0)
        {
            CLPlacemark *placemark= [placemarks objectAtIndex:0];
            NSString *address = [NSString stringWithFormat:@"%@ %@, %@, %@, %@", [placemark subThoroughfare], [placemark thoroughfare], [placemark locality], [placemark administrativeArea], [placemark postalCode]];
            self.addressLabel.text = address;
        }
    }];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    CLLocation *loc = [[CLLocation alloc] initWithLatitude:self.mapView.centerCoordinate.latitude longitude:self.mapView.centerCoordinate.longitude];
    [self updateAddressWithLocation:loc];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)pickThisLocation:(id)sender {
    NSLog(@"Select this location");
}

@end
