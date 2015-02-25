//
//  LPMeetUpMapViewController.m
//  Lopop
//
//  Created by Troy Ling on 2/23/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "LPMeetUpMapViewController.h"
#import "MKAnnotationView+WebCache.h"
#import "UIImageView+WebCache.h"
#import <Firebase/Firebase.h>
#import "LPLocationHelper.h"
#import "LPUIHelper.h"
#import "RateView.h"
#import "LPPop.h"

typedef NS_ENUM(NSInteger, LPMeetUpMapViewMode) {
    kMeetUpPreview,
    kMeetUpInAction,
    kMeetUpCompleted
};

@interface LPMeetUpMapViewController ()

@property (strong, nonatomic) LPPop *pop;
@property (strong, nonatomic) PFUser *meetUpUser;
@property (strong, nonatomic) NSDate *meetUpTime;
@property (strong, nonatomic) CLLocation *meetUpLocation;
@property (strong, nonatomic) CLLocation *meetUpUserLocation;
@property (retain, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) Firebase *meetUpUserFbRef;
@property (strong, nonatomic) Firebase *myFbRef;
@property MKPointAnnotation *meetUpUserLocationAnnotation;
@property MKPointAnnotation *meetUpLocationAnnotation;
@property LPMeetUpMapViewMode displayMode;

// UI components
@property CGRect contactBtnFrame;
@property CGRect contactBrnFrameWithOffset;

@property BOOL isMyLocationInitialized;

@end

@implementation LPMeetUpMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // delegate
    self.mapView.delegate = self;

    // start location manager
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;

    // UI
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    self.closeBtn.layer.zPosition = MAXFLOAT;
    self.meetUpTimeBtn.layer.zPosition = MAXFLOAT - 1.0f;

    // button position
    self.contactBtnFrame = self.contactUserBtn.frame;
    self.contactBrnFrameWithOffset = CGRectMake(self.contactBtnFrame.origin.x + self.contactBtnFrame.size.width + 8.0f, self.contactBtnFrame.origin.y, self.contactBtnFrame.size.width, self.contactBtnFrame.size.height);

    // interaction
    [self.meetUpTimeBtn addTarget:self action:@selector(togglePopDetailView) forControlEvents:UIControlEventTouchUpInside];
    [self.startMeetUpBtn addTarget:self action:@selector(startMeetup) forControlEvents:UIControlEventTouchUpInside];

    // Fetch data
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
}

- (void)loadData {
    self.meetUpUser = [self.offer.fromUser.objectId isEqualToString:[PFUser currentUser].objectId] ? self.pop.seller : self.offer.fromUser;
    self.meetUpTime = self.offer.meetUpTime; //meetup time in UTC
    self.meetUpLocation = [[CLLocation alloc] initWithLatitude:self.offer.meetUpLocation.latitude longitude:self.offer.meetUpLocation.longitude];

    // determine the mode of the map view
    [self setupMode];

    // UI
    NSTimeZone *timeZoneLocal = [NSTimeZone localTimeZone];
    NSDateFormatter *outputDateFormatter = [[NSDateFormatter alloc] init];
    [outputDateFormatter setTimeZone:timeZoneLocal];
    [outputDateFormatter setDateFormat:@"  EEE, MMM d, h:mm a  "];
    NSString *outputString = [outputDateFormatter stringFromDate:self.meetUpTime];

    [self.meetUpTimeBtn setTitle:outputString forState:UIControlStateNormal];
    [self.meetUpTimeBtn setImage:[UIImage imageNamed:@"icon_dropdown_line.png"] forState:UIControlStateNormal];

    // load views
    [self loadPopInfo];
    [self loadMapView];
    [self.meetUpUser fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error) {
            [self loadMeetUpUserInfo];
        }
    }];
}

- (void)setupMode {
    NSDate *currentTime = [NSDate date];
    NSInteger diff = [self.offer.meetUpTime timeIntervalSinceDate:currentTime];

    switch (self.offer.status) {
        case kOfferAccepted:
            if (diff <= -3600) {
                // overdue. 1 hour past the meet up time
                self.displayMode = kMeetUpPreview;
                            NSLog(@"PREVIEW");

            } else if (-3600 < diff && diff < 3600) {
                // time of the meetup. able to view other's location
                self.displayMode = kMeetUpInAction;
                            NSLog(@"in action");
            } else {
                // preview mode. Meet up is in the future
                self.displayMode = kMeetUpPreview;
                NSLog(@"PREVIEW");
            }
            break;
        case kOfferCompleted:
            self.displayMode = kMeetUpCompleted;
            NSLog(@"Completed");
            break;
        default:
            self.displayMode = kMeetUpPreview;
            NSLog(@"PREVIEW");
            break;
    }
}

- (void)startMeetup {
    // TODO check if user disable warning
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sharing location" message:@"Your location will be shared to other user." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Okay", @"Okay and don't show this again", nil];
    [alert show];
}

# pragma mark Firebase

- (void)setupFirebase {
    // init my firebase
    NSString *myFbUrl = [NSString stringWithFormat:@"https://lopop.firebaseio.com/meetups/%@/%@/location", [PFUser currentUser].objectId, self.offer.objectId];
    self.myFbRef = [[Firebase alloc] initWithUrl:myFbUrl];

    // listen to meetup user's location update
    NSString *meetUpUserFbUrl = [NSString stringWithFormat:@"https://lopop.firebaseio.com/meetups/%@/%@/location", self.meetUpUser.objectId, self.offer.objectId];
    self.meetUpUserFbRef = [[Firebase alloc] initWithUrl:meetUpUserFbUrl];

    [[self.meetUpUserFbRef queryLimitedToLast:1] observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
        if (snapshot.value[@"latitude"] != nil && snapshot.value[@"longitude"] != nil) {
            double latitude = [(NSString *)snapshot.value[@"latitude"] doubleValue];
            double longitude = [(NSString *)snapshot.value[@"longitude"] doubleValue];

            self.meetUpUserLocation = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
            [self updateMapViewForMeetUpUserWithLocaiton];
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
        self.isMyLocationInitialized = NO;

        // add annotation
        self.meetUpLocationAnnotation = [[MKPointAnnotation alloc] init];
        self.meetUpLocationAnnotation.coordinate = self.meetUpLocation.coordinate;
        [self.mapView addAnnotation:self.meetUpLocationAnnotation];
        [LPLocationHelper getAddressForLocation:self.meetUpLocation withBlock:^(NSString *address, NSError *error) {
            if (!error) {
                self.meetUpLocationAnnotation.title = address;
            }
        }];

        // display region in map
        [self zoomToMeetUpLocationAnimated:NO];
    }
}

- (void)enterTradeMode {
    if (self.displayMode == kMeetUpInAction) {
        NSLog(@"Enter trade mode");
        // start monitoring my location
        if ([CLLocationManager locationServicesEnabled]) {
            [self.locationManager startUpdatingLocation];

            if (self.locationManager.location) {
                self.mapView.showsUserLocation = YES;
            }
        }
        // load firebase to listen to meetup user's location
        [self setupFirebase];
    } else {
        NSLog(@"ERROR");
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

- (void)updateMapViewForMeetUpUserWithLocaiton {
    NSLog(@"UPDATE MEETUP USER");
    if (!self.meetUpUserLocationAnnotation) {
        self.meetUpUserLocationAnnotation = [[MKPointAnnotation alloc] init];
        [self.mapView addAnnotation:self.meetUpUserLocationAnnotation];
        self.meetUpUserLocationAnnotation.coordinate = self.meetUpUserLocation.coordinate;

        NSLog(@"%@", [NSString stringWithFormat:@"%@ enters the the view!", self.meetUpUser[@"name"]]);
        // inform user that people just enter action mode

        [self zoomToFitAllAnnotation];
    }

    // update location distance
    NSString *distanceStr = [LPLocationHelper stringOfDistanceInMilesBetweenLocations:self.meetUpLocation and:self.meetUpUserLocation withFormat:@"0.##"];
    self.meetUpUserLocationAnnotation.title = [NSString stringWithFormat:@"%@ mi to desinated location", distanceStr];
    self.meetUpUserLocationAnnotation.coordinate = self.meetUpUserLocation.coordinate;

    // inform user when meetup user is approaching
    CLLocationDistance distanceInMile = [distanceStr doubleValue];
    NSLog(@"distance: %f", distanceInMile);
    NSLog(@"OVERLAY NUM: %ld", self.mapView.overlays.count);
    if (self.mapView.overlays.count == 0) {
        if (distanceInMile <= 0.2f) {
            // Meet up user is in 0.2 miles away
            NSLog(@"user is approaching");
            [self informMeetUpUserApproaching];
            MKCircle *circle = [MKCircle circleWithCenterCoordinate:self.meetUpLocation.coordinate radius:200]; // overlay with 400 meters
            [self.mapView addOverlay:circle];
        }
    }

    // if user is in location
    BOOL metUp = [self userMetUp];
    if (metUp) {
        if (self.finishMeetUpBtn.hidden) {
            [self showFinishBtnWithAnimation];
        } else {
            [self animateFinishBtn];
        }
    }

    [self showZoomBtnIfNeeded];
}

#pragma mark helpers

- (BOOL)userMetUp {
    PFGeoPoint *myGeoPoint = [PFGeoPoint geoPointWithLocation:self.locationManager.location];
    PFGeoPoint *meetUpUserGeoPoint = [PFGeoPoint geoPointWithLocation:self.meetUpUserLocation];
    CLLocationDistance myDistanceToUserInMile = [myGeoPoint distanceInMilesTo:meetUpUserGeoPoint];
    return myDistanceToUserInMile <= 0.01875; // within 30 meters
}

- (void)promptMessage:(NSString *)message withDismissTimeInterval:(double)time {
    self.eventLabel.text = message;
    [UIView animateWithDuration:0.3 animations:^{
        self.eventLabel.hidden = NO;
    }];
    [NSTimer scheduledTimerWithTimeInterval:time target:self selector:@selector(hideEventLabel) userInfo:nil repeats:NO];
}

- (void)informMeetUpUserApproaching {
    NSString *msg = [NSString stringWithFormat:@"%@ is approaching to the meetup location", self.meetUpUser[@"name"]];
    [self promptMessage:msg withDismissTimeInterval:5];
}

- (void)hideEventLabel {
    [UIView animateWithDuration:3.0 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.eventLabel.hidden = YES;
    } completion:NULL];
}

- (BOOL)allAnnotationsVisible {
    // check if all annotations are on display
    MKMapRect visibleMapRect = self.mapView.visibleMapRect;
    NSSet *visibleAnnotations = [self.mapView annotationsInMapRect:visibleMapRect];
    return visibleAnnotations.count == self.mapView.annotations.count;
}

- (BOOL)isMeetUpLocationCenterAtMapView {
    return self.mapView.centerCoordinate.latitude == self.meetUpLocation.coordinate.latitude &&
    self.mapView.centerCoordinate.longitude == self.meetUpLocation.coordinate.longitude;
}

- (void)showZoomBtnIfNeeded {
    BOOL needed = (self.displayMode == kMeetUpInAction) ? ![self allAnnotationsVisible] : ![self isMeetUpLocationCenterAtMapView];
    self.zoomBtn.hidden = needed ? NO : YES;
}

#pragma mark Map - Zooming

- (void)zoomToMeetUpLocationAnimated:(BOOL)animated {
    MKCoordinateRegion region;
    region.center = self.meetUpLocation.coordinate;
    region.span.latitudeDelta = 0.009f;
    region.span.longitudeDelta = 0.009f;
    [self.mapView setRegion:region animated:animated];
}

- (void)zoomToFitAllAnnotation {
    MKMapRect zoomRect = MKMapRectNull;
    NSMutableArray *annotations = [[NSMutableArray alloc] initWithArray:self.mapView.annotations];
    [annotations addObject:self.mapView.userLocation];

    for (id <MKAnnotation> annotation in annotations) {
        MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
        MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1);
        zoomRect = MKMapRectUnion(zoomRect, pointRect);
    }

    double inset = -zoomRect.size.width * 3.0;
    [self.mapView setVisibleMapRect:MKMapRectInset(zoomRect, inset, inset) animated:YES];
}

#pragma mark UI Animation

- (void)togglePopDetailView {
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         if (self.popDetailView.frame.origin.y < 0) {
                            // show
                            self.popDetailView.frame = CGRectMake(0, self.meetUpTimeBtn.frame.origin.y + self.meetUpTimeBtn.frame.size.height, self.popDetailView.frame.size.width, self.popDetailView.frame.size.height);
                            self.popDetailView.alpha = 0.8f;
                         } else {
                            // hide
                            self.popDetailView.frame = CGRectMake(0, -21.0f, self.popDetailView.frame.size.width, self.popDetailView.frame.size.height);
                         }
                     }
                    completion:NULL];
}

- (void)hideStartButtonWithAnimation {
    // UI Interaction
    [UIView animateWithDuration:0.3 animations:^{
        self.startMeetUpBtn.frame = CGRectMake(self.startMeetUpBtn.frame.origin.x + self.startMeetUpBtn.frame.size.width + 8.0f, self.startMeetUpBtn.frame.origin.y, self.startMeetUpBtn.frame.size.width, self.startMeetUpBtn.frame.size.height);
        self.contactUserBtn.frame = self.contactBrnFrameWithOffset;
    }];
}

- (void)showFinishBtnWithAnimation {
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.contactUserBtn.frame = self.contactBtnFrame;
    } completion:^(BOOL finished) {
        self.finishMeetUpBtn.hidden = NO;
        [self animateFinishBtn];
    }];
}

- (void)animateFinishBtn {
    self.finishMeetUpBtn.animation = @"pop";
    self.finishMeetUpBtn.duration = 1.0f;
    [self.finishMeetUpBtn animate];
}

#pragma mark Actions

- (IBAction)dismiss:(id)sender {
    [self.myFbRef removeAllObservers];
    [self.meetUpUserFbRef removeAllObservers];
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)contactUser:(id)sender {
    NSLog(@"num of annotations: %lu", (unsigned long)self.mapView.annotations.count);
    NSLog(@"Contact user");
}

- (IBAction)zoomToFit:(id)sender {
    self.zoomBtn.hidden = YES;

    if (self.mapView.annotations.count == 1) {
        [self zoomToMeetUpLocationAnimated:YES];
    } else {
        [self zoomToFitAllAnnotation];
    }
}

- (IBAction)finishMeetUp:(id)sender {
    NSLog(@"FINISH MEET UP");
}

#pragma mark AlertView

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if ([title isEqualToString:@"Cancel"]) {
        // do nothing
    } else {
        // begin
        self.displayMode = kMeetUpInAction;
        [self enterTradeMode];

        // UI Interaction
        [self hideStartButtonWithAnimation];

        if ([title isEqualToString:@"Okay and don't show this again"]) {
            // save this
            NSLog(@"SAVE THIS FLAG");
        }
    }
}

#pragma mark MapView

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    NSLog(@"View added");
    if (annotation == self.mapView.userLocation) return nil; // my location

    MKAnnotationView *view;
    if (annotation == self.meetUpUserLocationAnnotation) {
        // TODO change icon for the user
        NSLog(@"Meetup user");
        view = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"meetUpUser"];
        [view setImage:[UIImage imageNamed:@"icon_like_fill.png"]];
        [view setCanShowCallout:YES];
    } else {
        view = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"popLocaiton"];
        [view setImage:[UIImage imageNamed:@"icon_location_fill.png"]];
        [view setCanShowCallout:YES];
    }
    return view;
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    [self showZoomBtnIfNeeded];
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    NSLog(@"Location updated");
    if (!self.isMyLocationInitialized) {
        self.isMyLocationInitialized = YES;
        [self zoomToFitAllAnnotation];
    } else {
        [self showZoomBtnIfNeeded];
    }

    // send my location update to firebase
    NSDictionary *locationUpdate = @{
                                     @"latitude" : [NSNumber numberWithDouble:userLocation.coordinate.latitude],
                                     @"longitude" : [NSNumber numberWithDouble:userLocation.coordinate.longitude]
                                     };
    // remove nodes
    [self.myFbRef removeValue];
    [[self.myFbRef childByAutoId] setValue:locationUpdate];

    // if user's met up
    BOOL metUp = [self userMetUp];
    if (metUp) {
        if (self.finishMeetUpBtn.hidden) {
            [self showFinishBtnWithAnimation];
        } else {
            [self animateFinishBtn];
        }
    }
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    MKCircleRenderer *renderer;
    if ([overlay isKindOfClass:[MKCircle class]]) {
        renderer = [[MKCircleRenderer alloc] initWithOverlay:overlay];
        renderer.fillColor = [LPUIHelper lopopColorWithAlpha:0.1];
        renderer.lineWidth = 1;
        renderer.strokeColor = [LPUIHelper lopopColor];
    }
    return renderer;
}

@end
