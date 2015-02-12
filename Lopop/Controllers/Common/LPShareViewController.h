//
//  LPShareViewController.h
//  Lopop
//
//  Created by Troy Ling on 2/10/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LPPop.h"

@interface LPShareViewController : UIViewController <UIActionSheetDelegate>

@property (strong, nonatomic) LPPop *pop;
@property (weak, nonatomic) IBOutlet UIButton *messengerBtn;

- (IBAction)shareOnFacebook:(id)sender;
- (IBAction)shareOnMessenger:(id)sender;
- (IBAction)shareOnWeChat:(id)sender;
- (IBAction)shareOnWeibo:(id)sender;
- (IBAction)shareWithEmail:(id)sender;
- (IBAction)copyLinkToClipboard:(id)sender;

- (IBAction)dismissView:(id)sender;

@end
