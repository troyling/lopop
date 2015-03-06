//
//  LPIntroViewController.m
//  Lopop
//
//  Created by Troy Ling on 3/5/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "LPIntroViewController.h"
#import "LPUIHelper.h"

#define NUMBER_OF_PAGES 5

#define timeForPage(page) (NSInteger)(self.view.frame.size.width * (page - 1))
#define TITLE_CENTER CGPointMake(self.view.center.x, 80)
#define TITLE_SIZE 26

#define DESC_CENTER CGPointMake(self.view.center.x, [LPUIHelper screenHeight] - 100)
#define DESC_SIZE 18

@interface LPIntroViewController ()

@property (retain, nonatomic) UIPageControl *pageControl;

@property (strong, nonatomic) UILabel *browseLabel;
@property (strong, nonatomic) UILabel *offerLabel;
@property (strong, nonatomic) UILabel *meetupLabel;
@property (strong, nonatomic) UILabel *rateLabel;

@property (strong, nonatomic) UIImageView *browseImageView;
@property (strong, nonatomic) UIImageView *offerImageView;
@property (strong, nonatomic) UIImageView *meetupImageView;
@property (strong, nonatomic) UIImageView *rateImageView;
@property (strong, nonatomic) UIImageView *profImageView;

//@property (strong, nonatomic) UILabel *browseDescLabel;
//@property (strong, nonatomic) UILabel *offerDescLabel;
//@property (strong, nonatomic) UILabel *meetupDescLabel;
//@property (strong, nonatomic) UILabel *rateDescLabel;
@end

@implementation LPIntroViewController

- (id)init {
    if ((self = [super init])) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

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

    // descriptions
    UILabel *browseDescLabel = [[UILabel alloc] init];
    browseDescLabel.text = @"Find out deals around you. Or look what's been selling around the world.";
    [browseDescLabel setFont:[UIFont systemFontOfSize:DESC_SIZE]];
    browseDescLabel.textColor = [UIColor whiteColor];
    [browseDescLabel sizeToFit];
    browseDescLabel.numberOfLines = 0;
    browseDescLabel.bounds = CGRectMake(0, 0, [LPUIHelper screenWidth] - 40, 100);
    browseDescLabel.center = DESC_CENTER;
    browseDescLabel.textAlignment = NSTextAlignmentCenter;
    [self.scrollView addSubview:browseDescLabel];

    UILabel *offerDescLabel = [[UILabel alloc] init];
    offerDescLabel.text = @"Send an offer to people for your favorite items.";
    [offerDescLabel setFont:[UIFont systemFontOfSize:DESC_SIZE]];
    offerDescLabel.textColor = [UIColor whiteColor];
    [offerDescLabel sizeToFit];
    offerDescLabel.numberOfLines = 0;
    offerDescLabel.bounds = CGRectMake(0, 0, [LPUIHelper screenWidth] - 40, 100);
    offerDescLabel.center = DESC_CENTER;
    offerDescLabel.frame = CGRectOffset(offerDescLabel.frame, timeForPage(2), 0);
    offerDescLabel.textAlignment = NSTextAlignmentCenter;
    [self.scrollView addSubview:offerDescLabel];

    UILabel *meetupDescrLabel = [[UILabel alloc] init];
    meetupDescrLabel.text = @"Schedule a time and location with your seller. Show up, meet up, and wrap up.";
    [meetupDescrLabel setFont:[UIFont systemFontOfSize:DESC_SIZE]];
    meetupDescrLabel.textColor = [UIColor whiteColor];
    [meetupDescrLabel sizeToFit];
    meetupDescrLabel.numberOfLines = 0;
    meetupDescrLabel.bounds = CGRectMake(0, 0, [LPUIHelper screenWidth] - 40, 100);
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
    rateDescLabel.bounds = CGRectMake(0, 0, [LPUIHelper screenWidth] - 40, 100);
    rateDescLabel.center = DESC_CENTER;
    rateDescLabel.frame = CGRectOffset(rateDescLabel.frame, timeForPage(4), 0);
    rateDescLabel.textAlignment = NSTextAlignmentCenter;
    [self.scrollView addSubview:rateDescLabel];

    // images
    CGFloat browseImageViewWidth = [LPUIHelper screenWidth] - 100;
    CGFloat browseImageViewHeight = browseImageViewWidth / 1.25;

    self.browseImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"intro_browse"]];
    self.browseImageView.bounds = CGRectMake(0, 0, browseImageViewWidth, browseImageViewHeight);
    self.browseImageView.center = self.view.center;
    self.browseImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.browseImageView.frame = CGRectOffset(self.browseImageView.frame, 0, 0);
    [self.scrollView addSubview:self.browseImageView];

    self.offerImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"intro_offer"]];
    self.offerImageView.bounds = CGRectMake(0, 0, browseImageViewWidth * 0.8, browseImageViewWidth * 0.8);
    self.offerImageView.center = self.view.center;
    self.offerImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.offerImageView.frame = CGRectOffset(self.offerImageView.frame, timeForPage(2), 0);
    self.offerImageView.alpha = 0.0f;
    [self.scrollView addSubview:self.offerImageView];

    self.meetupImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"intro_meetup"]];
    self.meetupImageView.bounds = CGRectMake(0, 0, browseImageViewWidth * 0.8, browseImageViewWidth * 0.8);
    self.meetupImageView.center = self.view.center;
    self.meetupImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.meetupImageView.frame = CGRectOffset(self.meetupImageView.frame, timeForPage(3), 0);
    [self.scrollView addSubview:self.meetupImageView];

    self.rateImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"intro_rate"]];
    self.rateImageView.bounds = CGRectMake(0, 0, browseImageViewWidth * 0.8, browseImageViewWidth * 0.8);
    self.rateImageView.center = self.view.center;
    self.rateImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.rateImageView.frame = CGRectOffset(self.rateImageView.frame, timeForPage(4), 0);
    [self.scrollView addSubview:self.rateImageView];

    self.profImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"intro_icon.jpg"]];
    self.profImageView.bounds = CGRectMake(0, 0, 50, 50);
    self.profImageView.layer.cornerRadius = self.profImageView.frame.size.width / 2.0f;
    self.profImageView.clipsToBounds = YES;
    self.profImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.profImageView.center = self.view.center;
    self.profImageView.layer.zPosition = MAXFLOAT;
    [self.scrollView addSubview:self.profImageView];
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
                                                                             andFrame:CGRectOffset(CGRectInset(self.profImageView.frame, -25, -25), timeForPage(2), -50)]];
    [profImageViewFrameAnimation addKeyFrame:[IFTTTAnimationKeyFrame keyFrameWithTime:timeForPage(3)
                                                                             andFrame:CGRectOffset(CGRectInset(self.profImageView.frame, 5, 5), timeForPage(3), 40)]];
    [profImageViewFrameAnimation addKeyFrame:[IFTTTAnimationKeyFrame keyFrameWithTime:timeForPage(4)
                                                                             andFrame:CGRectOffset(CGRectInset(self.profImageView.frame, -15, -15), timeForPage(4), -40)]];
    [self.animator addAnimation:profImageViewFrameAnimation];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat pageWidth = self.scrollView.frame.size.width;
    float fractionalPage = self.scrollView.contentOffset.x / pageWidth;
    NSInteger page = lround(fractionalPage);
    self.pageControl.currentPage = page;

    self.profImageView.layer.cornerRadius = self.profImageView.frame.size.width / 2.0f;
    [super scrollViewDidScroll:scrollView]; // maintain IFTTT animation
}

#pragma mark - IFTTTAnimatedScrollViewControllerDelegate

- (void)animatedScrollViewControllerDidScrollToEnd:(IFTTTAnimatedScrollViewController *)animatedScrollViewController {
    NSLog(@"Scrolled to end of scrollview!");
}

- (void)animatedScrollViewControllerDidEndDraggingAtEnd:(IFTTTAnimatedScrollViewController *)animatedScrollViewController {
    NSLog(@"Ended dragging at end of scrollview!");
}

@end
