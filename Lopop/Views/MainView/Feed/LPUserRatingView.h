//
//  LPUserRatingView.h
//  Lopop
//
//  Created by Troy Ling on 2/2/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RateView.h"

@interface LPUserRatingView : UIView

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet RateView *userRateView;

@end
