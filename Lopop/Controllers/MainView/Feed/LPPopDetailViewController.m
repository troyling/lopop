//
//  LPPopDetailViewController.m
//  Lopop
//
//  Created by Troy Ling on 1/26/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "LPPopDetailViewController.h"
#import "LPShareViewController.h"
#import "LPMainViewTabBarController.h"
#import "LPUserProfileViewController.h"
#import "LPPopLocationViewController.h"
#import "LPImageShowcaseViewController.h"
#import "LPMakeOfferViewController.h"
#import "LPAlertViewHelper.h"
#import "LPShareViewController.h"
#import "LPUIHelper.h"
#import "LPOffer.h"
#import "UIImageView+WebCache.h"
#import <QuartzCore/QuartzCore.h>

@interface LPPopDetailViewController ()

@property (retain, nonatomic) NSMutableArray *images;
@property NSUInteger numImages;

@end


@implementation LPPopDetailViewController

double const MAP_ZOOM_IN_DEGREE = 0.008f;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // delegate
    self.imageScrollView.delegate = self;
    self.mapView.delegate = self;
    
    // load image from cache or server
    [self retreveImages];
    
    self.images = [[NSMutableArray alloc] init];
    self.numImages = self.pop.images.count;
    
    // photo number label
    self.numPhotoView.layer.zPosition = MAXFLOAT; // always on top
    self.numPhotoView.hidden = YES;
    
    // labels
    self.titleLabel.text = self.pop.title;
    self.distanceLabel.text = self.distanceText;
    self.priceLabel.text = self.priceText;
    self.descriptionLabel.text = self.pop.popDescription;
    
    // load seller profile and rating
    [self loadSellerRatingView];
    
    // responsive text
    [self resizeDescriptionLabel];
    
    // mapview
    self.mapView.scrollEnabled = NO;
    self.mapView.zoomEnabled = NO;
    [self zoomInToMyLocation];
    
    // add annotation
    MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
    point.coordinate = CLLocationCoordinate2DMake(self.pop.location.latitude, self.pop.location.longitude);
    [self.mapView addAnnotation:point];

    // add gestures
    [self addGestureToViewUserProfile];
    [self addGestureToMapView];
    [self addGestureToImageScrollView];

    // check for offer state
    [self checkForOffer];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // hide tab bar
    if ([self.tabBarController isKindOfClass:[LPMainViewTabBarController class]]) {
        LPMainViewTabBarController *tb = (LPMainViewTabBarController *) self.tabBarController;
        [tb setTabBarVisible:NO animated:YES];
    }
}

- (void)zoomInToMyLocation {
    MKCoordinateRegion region;
    PFGeoPoint *popLocation = self.pop.location;
    region.center.latitude = popLocation.latitude;
    region.center.longitude = popLocation.longitude;
    region.span.longitudeDelta = MAP_ZOOM_IN_DEGREE;
    region.span.latitudeDelta = MAP_ZOOM_IN_DEGREE;
    [self.mapView setRegion:region animated:NO];
}

- (void)checkForOffer {
    PFQuery *offerQuery = [LPOffer query];
    [offerQuery whereKey:@"fromUser" equalTo:[PFUser currentUser]];
    [offerQuery whereKey:@"pop" equalTo:self.pop];
    [offerQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            if (objects.count > 0) {
                [self setUIForOfferState:OfferSent];
            }
        }
    }];
}
#pragma mark UI elements

- (void)resizeDescriptionLabel {
    CGFloat labelHeight = [LPUIHelper heightOfText:self.pop.popDescription forLabel:self.descriptionLabel];
    CGRect newFrame = self.descriptionLabel.frame;
    newFrame.size.height = labelHeight;
    self.descriptionLabel.frame = newFrame;
}

- (void)loadSellerRatingView {
    PFUser *seller = self.pop.seller;
    [seller fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error) {
            self.userRatingView.nameLabel.text = self.pop.seller[@"name"];
            
            // FIXME implement review and change it to reflect the actual rating
            RateView *rv = [RateView rateViewWithRating:4.4f];
            rv.starFillColor = [LPUIHelper ratingStarColor];
            rv.starSize = 15.0f;
            rv.starNormalColor = [UIColor lightGrayColor];
            [self.userRatingView.userRateView addSubview:rv];

            // Profile picture
            // FIXME move UI code back to view class
            [self.userRatingView.profileImageView sd_setImageWithURL:[NSURL URLWithString:self.pop.seller[@"profilePictureUrl"]]];
            self.userRatingView.profileImageView.layer.cornerRadius = 25.0f;
            self.userRatingView.profileImageView.clipsToBounds = YES;
//            [self loadProfilePictureWithURL:self.pop.seller[@"profilePictureUrl"]];
        }
    }];
}

- (void)setUIForOfferState:(OfferState)state {
    switch (state) {
        case OfferSent:
            self.offerBtn.enabled = NO;
            [self.offerBtn setTitle:@"Offer sent" forState:UIControlStateNormal];
            self.offerBtn.backgroundColor = [LPUIHelper infoColor];
            break;
        default:
            break;
    }
}

- (void)loadImageViews {
    // update photo display
    self.numPhotoLabel.text = [NSString stringWithFormat:@"%d/%ld", 1, (unsigned long)self.numImages];
    self.numPhotoView.hidden = NO;
    
    // init scroll view for displaying images
    self.imageScrollView.pagingEnabled = YES;
    
    CGSize scrollViewSize = self.imageScrollView.frame.size;
    CGFloat imageViewWidth = scrollViewSize.width;
    CGFloat imageViewHeight = scrollViewSize.height;
    self.imageScrollView.contentSize = CGSizeMake(imageViewWidth * self.numImages, imageViewHeight);

    for (NSInteger i = 0; i < self.numImages; i++) {
        CGFloat horizontalOffset = imageViewWidth * i;
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(horizontalOffset, 0, imageViewWidth, imageViewHeight)];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, imageViewWidth, imageViewHeight)];
        
        // layout
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        [imageView setImage:[self.images objectAtIndex:i]];
        [view addSubview:imageView];
        [self.imageScrollView addSubview:view];
    }
}

- (void)retreveImages {
    NSArray *imageFiles = self.pop.images;
    for (PFFile *file in imageFiles) {
        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
                [self.images addObject:[UIImage imageWithData:data]];
                
                // begin works on other UI when all images have been loaded
                if (self.images.count == self.pop.images.count) {
                    [self loadImageViews];
                }
            } else {
                // FIXME with a fatal error prompt
                [LPAlertViewHelper fatalErrorAlert:@"Unable to load images from server"];
            }
        }];
    }
}

#pragma mark gesture

- (void)addGestureToViewUserProfile {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewSellerProfile)];
    self.userRatingView.profileImageView.userInteractionEnabled = YES;
    [self.userRatingView.profileImageView addGestureRecognizer:tap];
}

- (void)addGestureToMapView {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewPopLocation)];
    self.mapView.userInteractionEnabled = YES;
    [self.mapView addGestureRecognizer:tap];
}

- (void)addGestureToImageScrollView {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewImageInDetail)];
    [self.imageScrollView addGestureRecognizer:tap];
}

#pragma mark scrollView

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([scrollView isEqual:self.imageScrollView]) {
        // remove top offset
        [self.imageScrollView setContentOffset:CGPointMake(self.imageScrollView.contentOffset.x, 0.0f)];
        CGFloat width = self.imageScrollView.frame.size.width;
        NSInteger page = (self.imageScrollView.contentOffset.x + (0.5f * width)) / width + 1;
        self.numPhotoLabel.text = [NSString stringWithFormat:@"%ld/%ld", (long)page, (unsigned long)self.numImages];
    }
}

#pragma mark Map Annotation

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    MKAnnotationView *view = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"popLocaiton"];
    [view setImage:[UIImage imageNamed:@"Oval 1@3x.png"]];
    [view setCanShowCallout:NO];
    return view;
}

#pragma mark View Controller Transition

- (void)viewSellerProfile {
    LPUserProfileViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"LPUserProfileViewController"];
    // TODO check if the seller is the currentUser
    vc.targetUser = self.pop.seller;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)viewPopLocation {
    LPPopLocationViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"popLocation"];
    vc.center = self.pop.location;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)viewImageInDetail {
    LPImageShowcaseViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"imageShowcase"];
    
    // TODO Configure this
    CGFloat width = self.imageScrollView.frame.size.width;
    NSInteger page = (self.imageScrollView.contentOffset.x + (0.5f * width)) / width + 1;
    vc.index = page - 1;
    vc.images = self.images;
    [self.navigationController presentViewController:vc animated:NO completion:NULL];
}

#pragma mark segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"makeOfferSegue"]) {
        if ([segue.destinationViewController isKindOfClass:[LPMakeOfferViewController class]]) {
            LPMakeOfferViewController *vc = [segue destinationViewController];
            vc.nameStr = self.userRatingView.nameLabel.text;
            vc.priceStr = self.priceLabel.text;
            vc.profileImage = self.userRatingView.profileImageView.image;
            vc.pop = self.pop;
        }
    } else if ([segue.identifier isEqualToString:@"shareSegue"]) {
        if ([segue.destinationViewController isKindOfClass:[LPShareViewController class]]) {
            LPShareViewController *vc = segue.destinationViewController;
            vc.pop = self.pop;
        }
    }
}

@end

