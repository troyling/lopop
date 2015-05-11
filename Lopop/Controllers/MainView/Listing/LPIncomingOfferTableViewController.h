//
//  LPIncomingOfferTableViewController.h
//  Lopop
//
//  Created by Troy Ling on 2/20/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LPPop.h"

@interface LPIncomingOfferTableViewController : UITableViewController <UITableViewDataSource, UITableViewDataSource>

@property (retain, nonatomic) LPPop *pop;

// header view
@property (weak, nonatomic) IBOutlet UIImageView *popImgView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *numViewLabel;
@property (weak, nonatomic) IBOutlet UILabel *numOfferLabel;

@end
