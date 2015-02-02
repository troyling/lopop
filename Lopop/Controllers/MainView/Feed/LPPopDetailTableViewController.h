//
//  LPPopDetailViewController.h
//  Lopop
//
//  Created by Troy Ling on 1/26/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LPPop.h"

@interface LPPopDetailTableViewController : UITableViewController <UIScrollViewDelegate>

@property (strong, nonatomic) LPPop *pop;

@property (weak, nonatomic) IBOutlet UIScrollView *imageScrollView;
@property (weak, nonatomic) IBOutlet UIView *numPhotoView;
@property (weak, nonatomic) IBOutlet UILabel *numPhotoLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *sellerProfileImageView;

@property (weak, nonatomic) IBOutlet UIButton *profileBtn; // TODO delete me!!!!

@property (retain, nonatomic) NSString *priceText;
@property (retain ,nonatomic) NSString *distanceText;

- (IBAction)viewSellerProfile:(id)sender;

@end
