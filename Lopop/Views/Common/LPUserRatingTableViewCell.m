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

    // button
    self.actionBtn.layer.cornerRadius = 3.0f;
}

- (void)setFrame:(CGRect)frame {
    frame.size.height -= 15.0f;
    frame.size.width -= 30.0f;
    frame.origin.x += 15.0f;
    frame.origin.y += 15.0f;
    [super setFrame:frame];

    // apply shadow effect
    self.layer.shadowOffset = CGSizeMake(1, 0);
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowRadius = 5.0f;
    self.layer.shadowOpacity = 0.25f;

    CGRect shadowFrame = self.layer.bounds;
    CGPathRef shadowPath = [UIBezierPath bezierPathWithRect:shadowFrame].CGPath;
    self.layer.shadowPath = shadowPath;
}

@end
