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

@interface LPMeetUpMapViewController : UIViewController <MKMapViewDelegate>

@property (strong, nonatomic) LPOffer *offer;

// Outlets
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

// pop view
@property (weak, nonatomic) IBOutlet UIButton *closeBtn;
@property (weak, nonatomic) IBOutlet UILabel *meetUpTimeLabel;
@property (weak, nonatomic) IBOutlet DesignableView *popDetailView;
@property (weak, nonatomic) IBOutlet UIImageView *popImgView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

// user view
@property (weak, nonatomic) IBOutlet UIImageView *profileImgView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UIView *userRatingView;

- (IBAction)dismiss:(id)sender;
- (IBAction)contactUser:(id)sender;

@end
