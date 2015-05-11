//
//  LPPopListingTableViewCell.h
//  Lopop
//
//  Created by Troy Ling on 2/16/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LPPopListingTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *numOfferLabel;
@property (weak, nonatomic) IBOutlet UILabel *offerStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *numViewLabel;
@property (weak, nonatomic) IBOutlet UILabel *numLikeLabel;

@property (weak, nonatomic) IBOutlet UIImageView *indicationImgView;


@end
