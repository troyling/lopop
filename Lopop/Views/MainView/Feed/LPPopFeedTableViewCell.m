//
//  LPPopFeedTableViewCell.m
//  Lopop
//
//  Created by Troy Ling on 1/24/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "LPPopFeedTableViewCell.h"

@implementation LPPopFeedTableViewCell
CGFloat const MARGIN_OFFSET = 10.0f;

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)setFrame:(CGRect)frame {
    frame.size.height -= MARGIN_OFFSET;
    [super setFrame:frame];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    // No selection when cell tapped
    // [super setSelected:selected animated:animated];
}

@end