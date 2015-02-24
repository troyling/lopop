//
//  LPMeetUpMapViewController.m
//  Lopop
//
//  Created by Troy Ling on 2/23/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "LPMeetUpMapViewController.h"
#import "UIImageView+WebCache.h"
#import "LPUIHelper.h"
#import "RateView.h"
#import "LPPop.h"

@interface LPMeetUpMapViewController ()

@property (strong, nonatomic) LPPop *pop;
@property (strong, nonatomic) PFUser *meetUpUser;
@property (strong, nonatomic) NSDate *meetUpTime;
@property (strong, nonatomic) CLLocation *meetUpLocation;
@property (retain, nonatomic) CLLocationManager *locationManager;
@property BOOL isMapViewInitialized;

@end

@implementation LPMeetUpMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // nav bar
    [self.navigationController setNavigationBarHidden:YES animated:YES];

    // delegate
    self.mapView.delegate = self;

    // UI
    self.closeBtn.layer.zPosition = MAXFLOAT;
    self.meetUpTimeLabel.layer.zPosition = MAXFLOAT - 1.0f;

    // Fetch data
    // TODO check status of the offer
    PFQuery *query = [LPOffer query];
    [query whereKey:@"objectId" equalTo:self.offer.objectId];
    [query includeKey:@"pop"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error && objects.count == 1) {
            LPOffer *offer = objects.firstObject;
            self.offer = offer;
            self.pop = self.offer.pop;
            [self loadData];
        }
    }];
    // FIXME the meetup user is not always the fromUser of the offers
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
}

- (void)loadData {
    self.meetUpUser = self.offer.fromUser;
    self.meetUpTime = self.offer.meetUpTime; //meetup time in UTC
    self.meetUpLocation = [[CLLocation alloc] initWithLatitude:self.offer.meetUpLocation.latitude longitude:self.offer.meetUpLocation.longitude];

    // UI
    NSTimeZone *timeZoneLocal = [NSTimeZone localTimeZone];
    NSDateFormatter *outputDateFormatter = [[NSDateFormatter alloc] init];
    [outputDateFormatter setTimeZone:timeZoneLocal];
    [outputDateFormatter setDateFormat:@"EEE, MMM d, h:mm a"];
    NSString *outputString = [outputDateFormatter stringFromDate:self.meetUpTime];

    self.meetUpTimeLabel.text = outputString;

    // load views
    [self loadPopInfo];
    [self loadMapView];
    [self.meetUpUser fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error) {
            [self loadMeetUpUserInfo];
        }
    }];
}

# pragma mark Load subviews

- (void)loadPopInfo {
    if (self.pop) {
        // pop icon
        PFFile *imgFile = self.pop.images.firstObject;
        NSString *urlStr = imgFile.url;
        [self.popImgView sd_setImageWithURL:[NSURL URLWithString:urlStr]];

        // labels
        self.titleLabel.text = self.pop.title;
        self.priceLabel.text = [self.pop publicPriceStr];
    }
}

- (void)loadMapView {
    if (self.meetUpLocation) {
        self.isMapViewInitialized = NO;

        // display region in map
        MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(self.meetUpLocation.coordinate, 0.03, 0.03);
        MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:viewRegion];
        [self.mapView setCenterCoordinate:self.meetUpLocation.coordinate animated:NO];
        [self.mapView setRegion:adjustedRegion animated:NO];

        // add annotation
        MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
        point.coordinate = self.meetUpLocation.coordinate;
        [self.mapView addAnnotation:point];

        // locate myself
        if ([CLLocationManager locationServicesEnabled]) {
            [self.locationManager startUpdatingLocation];

            if (self.locationManager.location) {
                self.mapView.showsUserLocation = YES;
            }
        }
    }
}

- (void)loadMeetUpUserInfo {
    if (self.meetUpUser) {
        // user icon
        [self.profileImgView sd_setImageWithURL:[NSURL URLWithString:self.meetUpUser[@"profilePictureUrl"]]];
        self.profileImgView.layer.cornerRadius = self.profileImgView.bounds.size.width / 2.0f;
        self.profileImgView.clipsToBounds = YES;

        self.usernameLabel.text = self.meetUpUser[@"name"];

        // load user rating
        RateView *rv = [RateView rateViewWithRating:4.4f];
        rv.starFillColor = [LPUIHelper ratingStarColor];
        rv.starSize = 15.0f;
        rv.starNormalColor = [UIColor lightGrayColor];
        rv.starBorderColor = [UIColor clearColor];
        [self.userRatingView addSubview:rv];
    }
}

- (void)zoomToMeetUpLocation {
    MKMapRect zoomRect = MKMapRectNull;
    NSMutableArray *annotations = [[NSMutableArray alloc] initWithArray:self.mapView.annotations];
    [annotations addObject:self.mapView.userLocation];

    for (id <MKAnnotation> annotation in annotations) {
        MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
        MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1);
        zoomRect = MKMapRectUnion(zoomRect, pointRect);
    }

    double inset = -zoomRect.size.width * 3.0;
    [self.mapView setVisibleMapRect:MKMapRectInset(zoomRect, inset, inset) animated:NO];
}

#pragma mark Actions

- (IBAction)dismiss:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)contactUser:(id)sender {
    NSLog(@"Contact user");
}

#pragma mark Map Annotation

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if (annotation == self.mapView.userLocation) return nil;

    MKAnnotationView *view = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"popLocaiton"];
    [view setImage:[UIImage imageNamed:@"icon_location_fill.png"]];
    [view setCanShowCallout:NO];
    return view;
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    if (!self.isMapViewInitialized) {
        self.isMapViewInitialized = YES;
        [self zoomToMeetUpLocation];
    }
}

@end
