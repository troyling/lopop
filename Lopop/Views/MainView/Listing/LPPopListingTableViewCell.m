//
//  LPPopListingTableViewCell.m
//  Lopop
//
//  Created by Troy Ling on 2/16/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "LPPopListingTableViewCell.h"

@implementation LPPopListingTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
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

- (void)layoutSubviews {
    self.imgView.clipsToBounds = YES;
}

@end
