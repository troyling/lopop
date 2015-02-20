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

@end
