//
//  LPRateUserViewController.h
//  Lopop
//
//  Created by Troy Ling on 2/25/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "LPOffer.h"

@interface LPRateUserViewController : UIViewController

@property (assign, nonatomic) id delegate;

@property (retain, nonatomic) PFUser *user;
@property (retain, nonatomic) LPOffer *offer;

@property (weak, nonatomic) IBOutlet UIImageView *profileImgView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIView *ratingView;

- (IBAction)dismiss:(id)sender;
- (IBAction)finishMeetUpAndShare:(id)sender;

@end
