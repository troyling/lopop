//
//  LPPopFeedTableViewCell.m
//  Lopop
//
//  Created by Troy Ling on 1/24/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "LPPopFeedTableViewCell.h"
#import "LPUIHelper.h"

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

- (void)layoutSubviews {
    self.progressView.primaryColor = [LPUIHelper lopopColor];
    self.progressView.showPercentage = YES;
    self.progressView.backgroundRingWidth = 0.0f;

    // seller profile
    self.sellerProfileImgView.layer.cornerRadius = self.sellerProfileImgView.frame.size.width / 2.0f;
    self.sellerProfileImgView.clipsToBounds = YES;
}

@end
