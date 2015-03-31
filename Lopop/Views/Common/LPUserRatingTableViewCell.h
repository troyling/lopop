//
//  LPUserRatingTableViewCell.h
//  Lopop
//
//  Created by Troy Ling on 2/20/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "RateView.h"
#import "LPAssociatedButton.h"

@interface LPUserRatingTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet RateView *userRateView;
@property (weak, nonatomic) IBOutlet UIButton *actionBtn;
@property (weak, nonatomic) IBOutlet UIButton *expandBtn;

@property (assign, nonatomic) BOOL isInitialized;

@end
