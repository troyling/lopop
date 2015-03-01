//
//  LPMakeOfferViewController.h
//  Lopop
//
//  Created by Troy Ling on 2/6/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Lopop-Swift.h"
#import "LPPop.h"

@interface LPMakeOfferViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UITextField *greetingTextField;
@property (weak, nonatomic) IBOutlet DesignableView *offerView;
@property (weak, nonatomic) IBOutlet DesignableButton *confirmBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *offerViewAlignmentY;

@property (assign, nonatomic) NSString *priceStr;
@property (assign, nonatomic) NSString *nameStr;
@property (assign, nonatomic) UIImage *profileImage;
@property (strong, nonatomic) LPPop *pop;

- (IBAction)dismissViewController:(id)sender;
- (IBAction)confirmOffer:(id)sender;

@end
