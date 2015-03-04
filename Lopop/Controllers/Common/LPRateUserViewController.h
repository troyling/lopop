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
#import "Lopop-Swift.h"

@interface LPRateUserViewController : UIViewController <UITextViewDelegate>

@property (assign, nonatomic) id delegate;

@property (retain, nonatomic) PFUser *user;
@property (retain, nonatomic) LPOffer *offer;

@property (weak, nonatomic) IBOutlet UIImageView *profileImgView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet DesignableView *ratingView;
@property (weak, nonatomic) IBOutlet UIView *starRatingView;
@property (weak, nonatomic) IBOutlet DesignableTextView *commentTextView;
@property (weak, nonatomic) IBOutlet UIButton *commentBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rateViewAlignmentY;

- (IBAction)dismiss:(id)sender;
- (IBAction)finishMeetUpAndShare:(id)sender;
- (IBAction)addComment:(id)sender;
- (IBAction)dismissKeyboard:(id)sender;

@end
