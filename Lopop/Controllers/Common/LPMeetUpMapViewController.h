//
//  LPMeetUpMapViewController.h
//  Lopop
//
//  Created by Troy Ling on 2/23/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "LPPop.h"
#import "LPOffer.h"

@interface LPMeetUpMapViewController : UIViewController <MKMapViewDelegate>

@property (strong, nonatomic) LPPop *pop;
@property (strong, nonatomic) LPOffer *offfer;

// Outlets
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end
