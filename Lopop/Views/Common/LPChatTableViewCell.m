//
//  LPChatTableViewCell.m
//  Lopop
//
//  Created by Troy Ling on 5/15/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "LPChatTableViewCell.h"

@implementation LPChatTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.profileImgView.clipsToBounds = YES;
    self.profileImgView.layer.cornerRadius = self.profileImgView.bounds.size.height / 2.0f;

    self.numUnreadMsgLabel.clipsToBounds = YES;
    self.numUnreadMsgLabel.layer.cornerRadius = self.numUnreadMsgLabel.bounds.size.height / 2.0f;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
