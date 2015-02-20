//
//  LPUserRatingTableViewCell.m
//  Lopop
//
//  Created by Troy Ling on 2/20/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "LPUserRatingTableViewCell.h"

@implementation LPUserRatingTableViewCell

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)layoutSubviews {
    [super layoutSubviews];

    // circle profile
    self.profileImageView.layer.cornerRadius = self.profileImageView.bounds.size.width / 2.0f;
    self.profileImageView.clipsToBounds = YES;
}

@end
