//
//  LPUserRatingView.m
//  Lopop
//
//  Created by Troy Ling on 2/2/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "LPUserRatingView.h"

@implementation LPUserRatingView

- (void)layoutSubviews {
    [super layoutSubviews];

    self.profileImageView.layer.cornerRadius = self.profileImageView.layer.frame.size.width / 2.0f;
    self.profileImageView.clipsToBounds = YES;
}

@end
