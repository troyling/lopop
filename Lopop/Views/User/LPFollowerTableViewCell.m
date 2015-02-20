//
//  LPFollowerTableViewCell.m
//  Lopop
//
//  Created by Troy Ling on 2/18/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "LPFollowerTableViewCell.h"

@implementation LPFollowerTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews {
    [super layoutSubviews];

    // draw profile picture view in circle
    self.profileImageView.layer.cornerRadius = self.profileImageView.bounds.size.width / 2.0f;
    self.profileImageView.clipsToBounds = YES;

    // round button
    self.followBtn.layer.cornerRadius = 3.0f;
}

@end
