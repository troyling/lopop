//
//  LPFollowerTableViewCell.h
//  Lopop
//
//  Created by Troy Ling on 2/18/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LPAssociatedButton.h"

@interface LPFollowerTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet LPAssociatedButton *followBtn;

@end
