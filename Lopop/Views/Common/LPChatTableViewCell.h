//
//  LPChatTableViewCell.h
//  Lopop
//
//  Created by Troy Ling on 5/15/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LPChatTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *profileImgView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastMsgLabel;
@property (weak, nonatomic) IBOutlet UILabel *numUnreadMsgLabel;


@end
