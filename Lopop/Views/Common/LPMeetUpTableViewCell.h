//
//  LPOfferTableViewCell.h
//  Lopop
//
//  Created by Troy Ling on 5/16/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LPMeetUpTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *profileImgView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UIButton *contactButton;
@property (weak, nonatomic) IBOutlet UIButton *remindButton;
@property (weak, nonatomic) IBOutlet UILabel *popTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *reminderLabel;

@end
