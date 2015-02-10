//
//  LPPopDetailViewController.h
//  Lopop
//
//  Created by Troy Ling on 1/26/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "LPUserRatingView.h"
#import "LPPop.h"

typedef enum {
    OfferNotSent = 0,
    OfferSent,
    Purchased,
    Sold
} OfferState;

@interface LPPopDetailViewController : UIViewController <UIScrollViewDelegate, MKMapViewDelegate>

@property (strong, nonatomic) LPPop *pop;

@property (weak, nonatomic) IBOutlet UIScrollView *imageScrollView;
@property (weak, nonatomic) IBOutlet UIView *numPhotoView;
@property (weak, nonatomic) IBOutlet UILabel *numPhotoLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *offerBtn;

@property (weak, nonatomic) IBOutlet LPUserRatingView *userRatingView;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (retain, nonatomic) NSString *priceText;
@property (retain ,nonatomic) NSString *distanceText;

- (void)setUIForOfferState:(OfferState)state;

@end
