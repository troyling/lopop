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
@property (retain, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) Firebase *meetUpUserFbRef;
@property (strong, nonatomic) Firebase *myFbRef;
@property MKPointAnnotation *meetUpUserLocationPin;
@property MKPointAnnotation *meetUpLocationAnnotation;
@property LPMeetUpMapViewMode displayMode;

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
    // UI Interaction
    [UIView animateWithDuration:0.3 animations:^{
        self.startMeetUpBtn.frame = CGRectMake(self.startMeetUpBtn.frame.origin.x + self.startMeetUpBtn.frame.size.width + 8.0f, self.startMeetUpBtn.frame.origin.y, self.startMeetUpBtn.frame.size.width, self.startMeetUpBtn.frame.size.height);
        self.contactUserBtn.frame = CGRectMake(self.contactUserBtn.frame.origin.x + self.contactUserBtn.frame.size.width + 8.0f, self.contactUserBtn.frame.origin.y, self.contactUserBtn.frame.size.width, self.contactUserBtn.frame.size.height);
    }];

    // TODO alert user's that his/her location will be shared with the other user
    self.displayMode = kMeetUpInAction;
    [self enterTradeMode];
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

            // update UI
            self.meetUpUserLocationPin.coordinate = CLLocationCoordinate2DMake(latitude, longitude);
        }

        // remove nodes
        [[self.meetUpUserFbRef childByAppendingPath:snapshot.key] removeValue];
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
        [self updateAddress]; // FIXME change this to a helper function

        // display region in map
        [self zoomToMeetUpLocation];

        // FIXME add meetup user to map when his/her location becomes available
//        self.meetUpUserLocationPin = [[MKPointAnnotation alloc] init];
//        [self.mapView addAnnotation:self.meetUpUserLocationPin];
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

- (void)updateAddress {
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:self.offer.meetUpLocation.latitude longitude:self.offer.meetUpLocation.longitude];    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if(placemarks && placemarks.count > 0) {
            CLPlacemark *placemark= [placemarks objectAtIndex:0];

            NSString *address = @"";
            if ([placemark subThoroughfare]) {
                address = [address stringByAppendingString:[placemark subThoroughfare]];
            }

            if ([placemark thoroughfare]) {
                address = [address stringByAppendingString:[NSString stringWithFormat:@" %@", [placemark thoroughfare]]];
            }

            if ([placemark locality]) {
                address = address.length > 0 ? [address stringByAppendingString:[NSString stringWithFormat:@", %@", [placemark locality]]] : [address stringByAppendingString:[NSString stringWithFormat:@"%@", [placemark locality]]];;
            }

            if ([placemark administrativeArea]) {
                address = address.length > 0 ? [address stringByAppendingString:[NSString stringWithFormat:@", %@", [placemark administrativeArea]]] : [address stringByAppendingString:[NSString stringWithFormat:@"%@", [placemark administrativeArea]]];;
            }

            if ([placemark postalCode]) {
                address = address.length > 0 ? [address stringByAppendingString:[NSString stringWithFormat:@", %@", [placemark postalCode]]] : [address stringByAppendingString:[NSString stringWithFormat:@"%@", [placemark postalCode]]];
            }
            self.meetUpLocationAnnotation.title = address;
        }
    }];
}

#pragma mark Map - Zooming

- (void)zoomToMeetUpLocation {
    MKCoordinateRegion region;
    region.center = self.meetUpLocation.coordinate;
    region.span.latitudeDelta = 0.009f;
    region.span.longitudeDelta = 0.009f;
    [self.mapView setRegion:region animated:NO];
}

- (void)zoomToFitAllAnnotation {
    MKMapRect zoomRect = MKMapRectNull;
    NSMutableArray *annotations = [[NSMutableArray alloc] initWithArray:self.mapView.annotations];
    [annotations addObject:self.mapView.userLocation];

    for (id <MKAnnotation> annotation in annotations) {
//        if ([annotation isEqual:self.meetUpUserLocationPin]) continue; // skip annotation

        MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
        MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1);
        zoomRect = MKMapRectUnion(zoomRect, pointRect);
    }

    double inset = -zoomRect.size.width * 3.0;
    [self.mapView setVisibleMapRect:MKMapRectInset(zoomRect, inset, inset) animated:YES];
}

#pragma mark Interactions

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

#pragma mark Actions

- (IBAction)dismiss:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)contactUser:(id)sender {
    NSLog(@"Contact user");
}

#pragma mark Map Annotation

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if (annotation == self.mapView.userLocation) return nil; // my location

    MKAnnotationView *view;
    if (annotation == self.meetUpUserLocationPin) {
        // TODO change icon for the user
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

#pragma mark mapView delegate

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    NSLog(@"Location updated");
    if (!self.isMyLocationInitialized) {
        self.isMyLocationInitialized = YES;
        [self zoomToFitAllAnnotation];
    }

    // send my location update to firebase
    NSDictionary *locationUpdate = @{
                                     @"latitude" : [NSNumber numberWithDouble:userLocation.coordinate.latitude],
                                     @"longitude" : [NSNumber numberWithDouble:userLocation.coordinate.longitude]
                                     };
//    [self.myFbRef removeValue];
    [[self.myFbRef childByAutoId] setValue:locationUpdate];
}

@end
