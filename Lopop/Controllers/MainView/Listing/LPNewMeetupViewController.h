//
//  LPNewMeetupViewController.h
//  Lopop
//
//  Created by Troy Ling on 3/31/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LPPop.h"
#import "LPOffer.h"
#import "Lopop-Swift.h"

@interface LPNewMeetupViewController : UIViewController

@property (retain, nonatomic) LPPop *pop;
@property (retain, nonatomic) LPOffer *offer;

// View
@property (weak, nonatomic) IBOutlet UIImageView *profileImgView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *pickTimeBtn;
@property (weak, nonatomic) IBOutlet UIButton *pickLocationBtn;
@property (weak, nonatomic) IBOutlet DesignableButton *confirmBtn;

@property (weak, nonatomic) IBOutlet UIImageView *timeIconImgView;
@property (weak, nonatomic) IBOutlet UIImageView *locationIconImgView;

- (IBAction)confirmMeetup:(id)sender;

- (IBAction)dismiss:(id)sender;

@end
