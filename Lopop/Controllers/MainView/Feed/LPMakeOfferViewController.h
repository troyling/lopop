//
//  LPMakeOfferViewController.h
//  Lopop
//
//  Created by Troy Ling on 2/6/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LPMakeOfferViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UITextField *commentTextField;

@property (assign, nonatomic) NSString *priceStr;
@property (assign, nonatomic) NSString *nameStr;
@property (assign, nonatomic) UIImage *profileImage;

- (IBAction)dismissViewController:(id)sender;
- (IBAction)confirmOffer:(id)sender;

@end
