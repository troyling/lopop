//
//  LPIntroViewController.m
//  Lopop
//
//  Created by Troy Ling on 3/5/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "LPIntroViewController.h"
#import "LPUIHelper.h"
#import "Lopop-Swift.h"
#import "RateView.h"

#define NUMBER_OF_PAGES 5
#define timeForPage(page) (NSInteger)(self.view.frame.size.width * (page - 1))
#define TITLE_CENTER CGPointMake(self.view.center.x, self.offerImageView.frame.origin.y * 0.5)
#define TITLE_SIZE 26

#define DESC_CENTER CGPointMake(self.view.center.x, self.pageControl.frame.origin.y - OFFSET_Y)
#define DESC_SIZE 18

#define SLIDE_VIEW_WIDTH 275.0f
#define SLIDE_VIEW_HEIGHT 220.0f

#define OFFSET_Y (self.pageControl.frame.origin.y - self.meetupImageView.frame.origin.y - self.meetupImageView.frame.size.height) * 0.5

@interface LPIntroViewController ()

@property (retain, nonatomic) UIPageControl *pageControl;
@property (retain, nonatomic) CLLocationManager *locationManager;

@property (strong, nonatomic) UILabel *browseLabel;
@property (strong, nonatomic) UILabel *offerLabel;
@property (strong, nonatomic) UILabel *meetupLabel;
@property (strong, nonatomic) UILabel *rateLabel;

@property (strong, nonatomic) UILabel *permissionDescLabel;

@property (strong, nonatomic) UIImageView *browseImageView;
@property (strong, nonatomic) UIImageView *offerImageView;
@property (strong, nonatomic) UIImageView *meetupImageView;
@property (strong, nonatomic) UIImageView *rateImageView;
@property (strong, nonatomic) UIImageView *profImageView;

@property (strong, nonatomic) UIButton *locationBtn;
@property (strong, nonatomic) UIButton *startBtn;

@property (strong, nonatomic) DesignableView *starView;

@end

@implementation LPIntroViewController

- (id)init {
    if ((self = [super init])) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;

    self.scrollView.layer.backgroundColor = [LPUIHelper lopopColor].CGColor;
    self.scrollView.contentSize = CGSizeMake(NUMBER_OF_PAGES * CGRectGetWidth(self.view.frame),
                                             CGRectGetHeight(self.view.frame));
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.accessibilityLabel = @"Lopop";
    self.scrollView.accessibilityIdentifier = @"Lopop";


    self.pageControl = [[UIPageControl alloc] init];
    self.pageControl.numberOfPages = 5;
    self.pageControl.currentPage = 0;
    [self.pageControl sizeToFit];
    self.pageControl.center = CGPointMake(self.view.center.x, [LPUIHelper screenHeight] - 30);
    [self.view addSubview:self.pageControl];

    [self placeViews];
    [self configureAnimation];

    self.delegate = self;
}

- (void)placeViews {
    // images
    CGColorRef borderColor = [UIColor colorWithRed:0.35 green:0.35 blue:0.35 alpha:1].CGColor;

    self.browseImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"intro_browse"]];
    self.browseImageView.bounds = CGRectMake(0, 0, SLIDE_VIEW_WIDTH, SLIDE_VIEW_HEIGHT);
    self.browseImageView.center = self.view.center;
    self.browseImageView.contentMode = UIViewContentModeScaleToFill;
    self.browseImageView.frame = CGRectOffset(self.browseImageView.frame, 0, 0);
    self.browseImageView.layer.borderWidth = 3.0f;
    self.browseImageView.layer.borderColor = borderColor;
    [self.scrollView addSubview:self.browseImageView];

    self.offerImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"intro_offer"]];
    self.offerImageView.bounds = CGRectMake(0, 0, SLIDE_VIEW_WIDTH * 0.8, SLIDE_VIEW_WIDTH * 0.8);
    self.offerImageView.center = self.view.center;
    self.offerImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.offerImageView.frame = CGRectOffset(self.offerImageView.frame, timeForPage(2), 0);
    self.offerImageView.alpha = 0.0f;
    self.offerImageView.layer.borderWidth = 3.0f;
    self.offerImageView.layer.borderColor = borderColor;
    [self.scrollView addSubview:self.offerImageView];

    self.meetupImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"intro_meetup"]];
    self.meetupImageView.bounds = CGRectMake(0, 0, SLIDE_VIEW_WIDTH * 0.8, SLIDE_VIEW_WIDTH);
    self.meetupImageView.center = self.view.center;
    self.meetupImageView.contentMode = UIViewContentModeScaleToFill;
    self.meetupImageView.frame = CGRectOffset(self.meetupImageView.frame, timeForPage(3), 0);
    self.meetupImageView.layer.borderWidth = 3.0f;
    self.meetupImageView.layer.borderColor = borderColor;
    [self.scrollView addSubview:self.meetupImageView];

    self.rateImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"intro_rate"]];
    self.rateImageView.bounds = CGRectMake(0, 0, SLIDE_VIEW_WIDTH * 0.8, SLIDE_VIEW_WIDTH * 0.9);
    self.rateImageView.center = self.view.center;
    self.rateImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.rateImageView.frame = CGRectOffset(self.rateImageView.frame, timeForPage(4), 0);
    self.rateImageView.layer.borderWidth = 3.0f;
    self.rateImageView.layer.borderColor = borderColor;
    [self.scrollView addSubview:self.rateImageView];

    self.profImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"intro_icon.jpg"]];
    self.profImageView.bounds = CGRectMake(0, 0, 38, 38);
    self.profImageView.layer.cornerRadius = self.profImageView.frame.size.width / 2.0f;
    self.profImageView.clipsToBounds = YES;
    self.profImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.profImageView.center = CGPointMake(self.view.center.x + SLIDE_VIEW_WIDTH * 0.5 * 0.75 + 5, self.view.center.y + SLIDE_VIEW_HEIGHT * 0.25 + 5);
    self.profImageView.layer.zPosition = MAXFLOAT;
    [self.scrollView addSubview:self.profImageView];

    // title
    UILabel *browseTitle = [[UILabel alloc] init];
    browseTitle.text = @"Browse";
    [browseTitle setFont:[UIFont systemFontOfSize:TITLE_SIZE]];
    browseTitle.textColor = [UIColor whiteColor];
    [browseTitle sizeToFit];
    browseTitle.center = TITLE_CENTER;
    [self.scrollView addSubview:browseTitle];

    UILabel *offerTitle = [[UILabel alloc] init];
    offerTitle.text = @"Offer";
    [offerTitle setFont:[UIFont systemFontOfSize:TITLE_SIZE]];
    offerTitle.textColor = [UIColor whiteColor];
    [offerTitle sizeToFit];
    offerTitle.center = TITLE_CENTER;
    offerTitle.frame = CGRectOffset(offerTitle.frame, timeForPage(2), 0);
    [self.scrollView addSubview:offerTitle];

    UILabel *meetupTitle = [[UILabel alloc] init];
    meetupTitle.text = @"Meet up";
    [meetupTitle setFont:[UIFont systemFontOfSize:TITLE_SIZE]];
    meetupTitle.textColor = [UIColor whiteColor];
    [meetupTitle sizeToFit];
    meetupTitle.center = TITLE_CENTER;
    meetupTitle.frame = CGRectOffset(meetupTitle.frame, timeForPage(3), 0);
    [self.scrollView addSubview:meetupTitle];

    UILabel *rateTitle = [[UILabel alloc] init];
    rateTitle.text = @"Rate";
    [rateTitle setFont:[UIFont systemFontOfSize:TITLE_SIZE]];
    rateTitle.textColor = [UIColor whiteColor];
    [rateTitle sizeToFit];
    rateTitle.center = TITLE_CENTER;
    rateTitle.frame = CGRectOffset(rateTitle.frame, timeForPage(4), 0);
    [self.scrollView addSubview:rateTitle];

    UILabel *permissionTitle = [[UILabel alloc] init];
    permissionTitle.text = @"One more thing";
    [permissionTitle setFont:[UIFont systemFontOfSize:TITLE_SIZE]];
    permissionTitle.textColor = [UIColor whiteColor];
    [permissionTitle sizeToFit];
    permissionTitle.center = TITLE_CENTER;
    permissionTitle.frame = CGRectOffset(permissionTitle.frame, timeForPage(5), 0);
    [self.scrollView addSubview:permissionTitle];

    // descriptions
    UILabel *browseDescLabel = [[UILabel alloc] init];
    browseDescLabel.text = @"Browse for items around you, or around the world.";
    [browseDescLabel setFont:[UIFont systemFontOfSize:DESC_SIZE]];
    browseDescLabel.textColor = [UIColor whiteColor];
    [browseDescLabel sizeToFit];
    browseDescLabel.numberOfLines = 0;
    browseDescLabel.bounds = CGRectMake(0, 0, [LPUIHelper screenWidth] - 70, 50);
    browseDescLabel.center = DESC_CENTER;
    browseDescLabel.textAlignment = NSTextAlignmentCenter;
    [self.scrollView addSubview:browseDescLabel];

    UILabel *offerDescLabel = [[UILabel alloc] init];
    offerDescLabel.text = @"Send an offer to people for your favorite items.";
    [offerDescLabel setFont:[UIFont systemFontOfSize:DESC_SIZE]];
    offerDescLabel.textColor = [UIColor whiteColor];
    [offerDescLabel sizeToFit];
    offerDescLabel.numberOfLines = 0;
    offerDescLabel.bounds = CGRectMake(0, 0, [LPUIHelper screenWidth] - 70, 50);
    offerDescLabel.center = DESC_CENTER;
    offerDescLabel.frame = CGRectOffset(offerDescLabel.frame, timeForPage(2), 0);
    offerDescLabel.textAlignment = NSTextAlignmentCenter;
    [self.scrollView addSubview:offerDescLabel];

    UILabel *meetupDescrLabel = [[UILabel alloc] init];
    meetupDescrLabel.text = @"Schedule a time and location. Show up, meet up, and wrap up.";
    [meetupDescrLabel setFont:[UIFont systemFontOfSize:DESC_SIZE]];
    meetupDescrLabel.textColor = [UIColor whiteColor];
    [meetupDescrLabel sizeToFit];
    meetupDescrLabel.numberOfLines = 0;
    meetupDescrLabel.bounds = CGRectMake(0, 0, [LPUIHelper screenWidth] - 70, 50);
    meetupDescrLabel.center = DESC_CENTER;
    meetupDescrLabel.frame = CGRectOffset(meetupDescrLabel.frame, timeForPage(3), 0);
    meetupDescrLabel.textAlignment = NSTextAlignmentCenter;
    [self.scrollView addSubview:meetupDescrLabel];

    UILabel *rateDescLabel = [[UILabel alloc] init];
    rateDescLabel.text = @"Shoot stars for you experience and spread the words.";
    [rateDescLabel setFont:[UIFont systemFontOfSize:DESC_SIZE]];
    rateDescLabel.textColor = [UIColor whiteColor];
    [rateDescLabel sizeToFit];
    rateDescLabel.numberOfLines = 0;
    rateDescLabel.bounds = CGRectMake(0, 0, [LPUIHelper screenWidth] - 70, 50);
    rateDescLabel.center = DESC_CENTER;
    rateDescLabel.frame = CGRectOffset(rateDescLabel.frame, timeForPage(4), 0);
    rateDescLabel.textAlignment = NSTextAlignmentCenter;
    [self.scrollView addSubview:rateDescLabel];

    self.permissionDescLabel = [[UILabel alloc] init];
    self.permissionDescLabel.text = @"Location access is required for customized experience.";
    [self.permissionDescLabel setFont:[UIFont systemFontOfSize:DESC_SIZE]];
    self.permissionDescLabel.textColor = [UIColor whiteColor];
    [self.permissionDescLabel sizeToFit];
    self.permissionDescLabel.numberOfLines = 0;
    self.permissionDescLabel.bounds = CGRectMake(0, 0, [LPUIHelper screenWidth] - 70, 50);
    self.permissionDescLabel.center = DESC_CENTER;
    self.permissionDescLabel.frame = CGRectOffset(self.permissionDescLabel.frame, timeForPage(5), 0);
    self.permissionDescLabel.textAlignment = NSTextAlignmentCenter;
    [self.scrollView addSubview:self.permissionDescLabel];

    // location service permission button
    self.locationBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, SLIDE_VIEW_WIDTH, 40)];
    [self.locationBtn setTitle:@"Grant Location Access" forState:UIControlStateNormal];
    self.locationBtn.backgroundColor = [LPUIHelper alertColor];
    self.locationBtn.center = self.view.center;
    self.locationBtn.frame = CGRectOffset(self.locationBtn.frame, timeForPage(5), 0);
    [self.locationBtn addTarget:self action:@selector(requestLocationServicePermission) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:self.locationBtn];

    // start button
    self.startBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, SLIDE_VIEW_WIDTH * 0.5, 40)];
    [self.startBtn setTitle:@"Get started!" forState:UIControlStateNormal];
    self.startBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    self.startBtn.layer.borderWidth = 1.0f;
    self.startBtn.center = DESC_CENTER;
    self.startBtn.frame = CGRectOffset(self.startBtn.frame, timeForPage(5), 0);
    [self.startBtn addTarget:self action:@selector(startUsingApp) forControlEvents:UIControlEventTouchUpInside];
    self.startBtn.hidden = YES;
    [self.scrollView addSubview:self.startBtn];

    // rate view
    RateView *rv = [RateView rateViewWithRating:5.0];
    rv.starFillColor = [LPUIHelper ratingStarColor];
    rv.starBorderColor = [UIColor clearColor];
    rv.starSize = 23.0f;
    rv.starNormalColor = [UIColor lightGrayColor];

    self.starView = [[DesignableView alloc] init];
    [self.starView sizeToFit];
    self.starView.center = self.view.center;
    self.starView.frame = rv.frame;
    self.starView.frame = CGRectOffset(self.starView.frame, timeForPage(4) + self.view.center.x - self.starView.frame.size.width / 2.0f, self.view.center.y + 46);
    [self.starView addSubview:rv];
    [self.scrollView addSubview:self.starView];
    self.starView.hidden = YES; // for pop animation
}

- (void)configureAnimation {
    // fading
    IFTTTAlphaAnimation *profImageAlphaAnimation = [IFTTTAlphaAnimation animationWithView:self.profImageView];
    [profImageAlphaAnimation addKeyFrame:[IFTTTAnimationKeyFrame keyFrameWithTime:timeForPage(0.8) andAlpha:0.0f]];
    [profImageAlphaAnimation addKeyFrame:[IFTTTAnimationKeyFrame keyFrameWithTime:timeForPage(1) andAlpha:1.0f]];
    [profImageAlphaAnimation addKeyFrame:[IFTTTAnimationKeyFrame keyFrameWithTime:timeForPage(2) andAlpha:1.0f]];
    [profImageAlphaAnimation addKeyFrame:[IFTTTAnimationKeyFrame keyFrameWithTime:timeForPage(3) andAlpha:1.0f]];
    [profImageAlphaAnimation addKeyFrame:[IFTTTAnimationKeyFrame keyFrameWithTime:timeForPage(4) andAlpha:1.0f]];
    [profImageAlphaAnimation addKeyFrame:[IFTTTAnimationKeyFrame keyFrameWithTime:timeForPage(4.35) andAlpha:0.0f]];
    [self.animator addAnimation:profImageAlphaAnimation];

    IFTTTAlphaAnimation *browseAlphaAnimation = [IFTTTAlphaAnimation animationWithView:self.browseImageView];
    [browseAlphaAnimation addKeyFrame:[IFTTTAnimationKeyFrame keyFrameWithTime:timeForPage(0.8) andAlpha:0.0f]];
    [browseAlphaAnimation addKeyFrame:[IFTTTAnimationKeyFrame keyFrameWithTime:timeForPage(1) andAlpha:1.0f]];
    [browseAlphaAnimation addKeyFrame:[IFTTTAnimationKeyFrame keyFrameWithTime:timeForPage(2) andAlpha:0.0f]];
    [self.animator addAnimation:browseAlphaAnimation];

    IFTTTAlphaAnimation *offerAlphaAnimation = [IFTTTAlphaAnimation animationWithView:self.offerImageView];
    [offerAlphaAnimation addKeyFrame:[IFTTTAnimationKeyFrame keyFrameWithTime:timeForPage(1) andAlpha:0.0f]];
    [offerAlphaAnimation addKeyFrame:[IFTTTAnimationKeyFrame keyFrameWithTime:timeForPage(2) andAlpha:1.0f]];
    [offerAlphaAnimation addKeyFrame:[IFTTTAnimationKeyFrame keyFrameWithTime:timeForPage(3) andAlpha:0.0f]];
    [self.animator addAnimation:offerAlphaAnimation];

    IFTTTAlphaAnimation *meetupAlphaAnimation = [IFTTTAlphaAnimation animationWithView:self.meetupImageView];
    [meetupAlphaAnimation addKeyFrame:[IFTTTAnimationKeyFrame keyFrameWithTime:timeForPage(2) andAlpha:0.0f]];
    [meetupAlphaAnimation addKeyFrame:[IFTTTAnimationKeyFrame keyFrameWithTime:timeForPage(3) andAlpha:1.0f]];
    [meetupAlphaAnimation addKeyFrame:[IFTTTAnimationKeyFrame keyFrameWithTime:timeForPage(4) andAlpha:0.0f]];
    [self.animator addAnimation:meetupAlphaAnimation];

    IFTTTAlphaAnimation *rateAlphaAnimation = [IFTTTAlphaAnimation animationWithView:self.rateImageView];
    [rateAlphaAnimation addKeyFrame:[IFTTTAnimationKeyFrame keyFrameWithTime:timeForPage(3) andAlpha:0.0f]];
    [rateAlphaAnimation addKeyFrame:[IFTTTAnimationKeyFrame keyFrameWithTime:timeForPage(4) andAlpha:1.0f]];
    [rateAlphaAnimation addKeyFrame:[IFTTTAnimationKeyFrame keyFrameWithTime:timeForPage(4.35) andAlpha:0.0f]];
    [self.animator addAnimation:rateAlphaAnimation];

    // frame animaiton
    IFTTTFrameAnimation *profImageViewFrameAnimation = [IFTTTFrameAnimation animationWithView:self.profImageView];
    [profImageViewFrameAnimation addKeyFrame:[IFTTTAnimationKeyFrame keyFrameWithTime:timeForPage(1) andFrame:self.profImageView.frame]];
    [profImageViewFrameAnimation addKeyFrame:[IFTTTAnimationKeyFrame keyFrameWithTime:timeForPage(2)
                                                                             andFrame:CGRectOffset(CGRectInset(self.profImageView.frame, -25, -25), timeForPage(2) - (SLIDE_VIEW_WIDTH * 0.5 * 0.75 + 5), -90)]];
    [profImageViewFrameAnimation addKeyFrame:[IFTTTAnimationKeyFrame keyFrameWithTime:timeForPage(3)
                                                                             andFrame:CGRectOffset(CGRectInset(self.profImageView.frame, 3, 3), timeForPage(3) - SLIDE_VIEW_WIDTH * 0.75 + 8, 57)]];
    [profImageViewFrameAnimation addKeyFrame:[IFTTTAnimationKeyFrame keyFrameWithTime:timeForPage(4)
                                                                             andFrame:CGRectOffset(CGRectInset(self.profImageView.frame, -10, -10), timeForPage(4) - (SLIDE_VIEW_WIDTH * 0.5 * 0.75 + 5), -85)]];
    [self.animator addAnimation:profImageViewFrameAnimation];

}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat pageWidth = self.scrollView.frame.size.width;
    float fractionalPage = self.scrollView.contentOffset.x / pageWidth;
    NSInteger page = lround(fractionalPage);
    self.pageControl.currentPage = page;

    if (page == 3) {
        // pop rate view
        [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(showStarView) userInfo:nil repeats:NO];
    } else {
        self.starView.hidden = YES;
    }

    self.profImageView.layer.cornerRadius = self.profImageView.frame.size.width / 2.0f;
    [super scrollViewDidScroll:scrollView]; // maintain IFTTT animation
}

- (void)showStarView {
    self.starView.hidden = NO;
    self.starView.animation = @"pop";
    self.starView.curve = @"easeIn";
    self.starView.duration = 0.5f;
    [self.starView animate];
}

#pragma mark - Permission

- (void)requestLocationServicePermission {
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (status == kCLAuthorizationStatusNotDetermined) {
        if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            [self.locationManager requestWhenInUseAuthorization];
        }
    }
}

- (void)startUsingApp {
    NSLog(@"Start using our app.");
}

#pragma mark - LocationManager Delegation

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status != kCLAuthorizationStatusNotDetermined) {
        if (status != kCLAuthorizationStatusDenied) {
            [self.locationBtn removeTarget:self action:@selector(openLocationSettings) forControlEvents:UIControlEventTouchUpInside];
            [self.locationBtn setTitle:@"Access Granted" forState:UIControlStateNormal];
            self.locationBtn.backgroundColor = [LPUIHelper infoColor];
            self.permissionDescLabel.hidden = YES;
            self.startBtn.hidden = NO;
        } else {
            [self.locationBtn setTitle:@"Not Granted :(" forState:UIControlStateNormal];
            [self.locationBtn addTarget:self action:@selector(openLocationSettings) forControlEvents:UIControlEventTouchUpInside];
        }
    }
}

- (void)openLocationSettings {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}

#pragma mark - IFTTTAnimatedScrollViewControllerDelegate

- (void)animatedScrollViewControllerDidScrollToEnd:(IFTTTAnimatedScrollViewController *)animatedScrollViewController {
    NSLog(@"Scrolled to end of scrollview!");
}

- (void)animatedScrollViewControllerDidEndDraggingAtEnd:(IFTTTAnimatedScrollViewController *)animatedScrollViewController {
    NSLog(@"Ended dragging at end of scrollview!");
}

@end
