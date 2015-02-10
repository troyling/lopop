//
//  LPPopLocationViewController.h
//  Lopop
//
//  Created by Troy Ling on 2/3/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <Parse/Parse.h>

@interface LPPopLocationViewController : UIViewController <MKMapViewDelegate>

@property (retain, nonatomic) PFGeoPoint *center;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end
