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
}

- (void)layoutSubviews {
    self.imgView.clipsToBounds = YES;
}

@end
