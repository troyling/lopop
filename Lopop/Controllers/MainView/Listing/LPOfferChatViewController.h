//
//  LPOfferChatViewController.h
//  Lopop
//
//  Created by Troy Ling on 2/21/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Lopop-Swift.h"
#import "LPPop.h"

@interface LPOfferChatViewController : UIViewController

@property (strong, nonatomic) LPPop *pop;
@property (strong, nonatomic) PFUser *offerUser;

@property (weak, nonatomic) IBOutlet UIImageView *popImgView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet DesignableButton *timeSelectorBtn;
@property (weak, nonatomic) IBOutlet DesignableButton *locationBtn;
@property (weak, nonatomic) IBOutlet DesignableButton *meetupBtn;

- (IBAction)proposeMeetup:(id)sender;

@end
