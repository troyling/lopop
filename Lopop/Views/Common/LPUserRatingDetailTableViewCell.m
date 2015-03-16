//
//  LPUserRatingDetailTableViewCell.m
//  Lopop
//
//  Created by Troy Ling on 3/15/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "LPUserRatingDetailTableViewCell.h"

@implementation LPUserRatingDetailTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews {
    [super layoutSubviews];

    // circle profile
    self.profileImageView.layer.cornerRadius = self.profileImageView.bounds.size.width / 2.0f;
    self.profileImageView.clipsToBounds = YES;

}

@end
