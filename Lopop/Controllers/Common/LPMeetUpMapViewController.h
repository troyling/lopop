//
//  LPMeetUpMapViewController.h
//  Lopop
//
//  Created by Troy Ling on 2/23/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Lopop-Swift.h"
#import "LPOffer.h"

@interface LPMeetUpMapViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) LPOffer *offer;

// Outlets
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

// pop view
@property (weak, nonatomic) IBOutlet UIButton *closeBtn;
@property (weak, nonatomic) IBOutlet UIButton *meetUpTimeBtn;
@property (weak, nonatomic) IBOutlet DesignableView *popDetailView;
@property (weak, nonatomic) IBOutlet UIImageView *popImgView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

@property (weak, nonatomic) IBOutlet UIButton *zoomBtn;

@property (weak, nonatomic) IBOutlet UILabel *eventLabel;

// user view
@property (weak, nonatomic) IBOutlet UIImageView *profileImgView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UIView *userRatingView;
@property (weak, nonatomic) IBOutlet DesignableButton *contactUserBtn;
@property (weak, nonatomic) IBOutlet DesignableButton *startMeetUpBtn;

- (IBAction)dismiss:(id)sender;
- (IBAction)contactUser:(id)sender;
- (IBAction)zoomToFit:(id)sender;

@end
