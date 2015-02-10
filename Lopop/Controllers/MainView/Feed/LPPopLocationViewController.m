//
//  LPPopLocationViewController.m
//  Lopop
//
//  Created by Troy Ling on 2/3/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "LPPopLocationViewController.h"
#import "LPAlertViewHelper.h"

@interface LPPopLocationViewController ()

@end

@implementation LPPopLocationViewController

double const ZOOM_IN_DEGREE = 0.008f;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // delegate
    self.mapView.delegate = self;
    
    if (self.center) {
        [self zoomInToCenter];
        
        // add pin
        MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
        point.coordinate = CLLocationCoordinate2DMake(self.center.latitude, self.center.longitude);
        [self.mapView addAnnotation:point];
    } else {
        [LPAlertViewHelper fatalErrorAlert:@"Unable to load the location"];
        [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
    }
}

-(void)zoomInToCenter {
    MKCoordinateRegion region;
    region.center.latitude = self.center.latitude;
    region.center.longitude = self.center.longitude;
    region.span.longitudeDelta = ZOOM_IN_DEGREE;
    region.span.latitudeDelta = ZOOM_IN_DEGREE;
    [self.mapView setRegion:region animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark MapView Delegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    MKAnnotationView *view = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"popLocation"];
    [view setImage:[UIImage imageNamed:@"Oval 1@3x.png"]];
    [view setCanShowCallout:NO];
    return view;
}

@end
