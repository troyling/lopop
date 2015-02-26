//
//  LPRateUserViewController.m
//  Lopop
//
//  Created by Troy Ling on 2/25/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "LPRateUserViewController.h"
#import "LPMeetUpMapViewController.h"
#import "UIImageView+WebCache.h"
#import "LPUserRating.h"
#import "LPUIHelper.h"
#import "RateView.h"

@interface LPRateUserViewController ()

@property (retain, nonatomic) RateView *rv;

@end

@implementation LPRateUserViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    if ([self.user isDataAvailable]) {
        [self loadData];
    } else {
        [self.user fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            if (!error) {
                [self loadData];
            }
        }];
    }
}

- (void)loadData {
    [self.profileImgView sd_setImageWithURL:[NSURL URLWithString:self.user[@"profilePictureUrl"]]];
    self.profileImgView.layer.cornerRadius = self.profileImgView.bounds.size.width / 2.0f;
    self.profileImgView.clipsToBounds = YES;

    self.nameLabel.text = self.user[@"name"];

    // rate view
    self.rv = [RateView rateViewWithRating:0];
    self.rv.step = 1.0f;
    self.rv.canRate = YES;
    self.rv.starSize = 30.0f;
    self.rv.starBorderColor = [UIColor clearColor];
    self.rv.starNormalColor = [UIColor lightGrayColor];
    self.rv.starFillColor = [LPUIHelper ratingStarColor];
    self.rv.center = CGPointMake(self.ratingView.frame.size.width / 2.0f, self.ratingView.frame.size.height / 2.0f);
    [self.ratingView addSubview:self.rv];
}

- (IBAction)dismiss:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)finishMeetUpAndShare:(id)sender {
    LPUserRating *rate = [LPUserRating object];
    rate.user = self.user;
    rate.rater = [PFUser currentUser];
    rate.rating = [NSNumber numberWithFloat:self.rv.rating];
    rate.offer = self.offer;
    // TODO implement this with UI later
    // rate.comment = ...
    [rate saveEventually];

    [self dismissViewControllerAnimated:YES completion:^{
        if (self.delegate && [self.delegate isKindOfClass:[LPMeetUpMapViewController class]]) {
            [self.delegate dismissViewControllerAnimated:YES completion:NULL];
        }
    }];
}

@end
