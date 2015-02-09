//
//  LPMakeOfferViewController.m
//  Lopop
//
//  Created by Troy Ling on 2/6/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "LPMakeOfferViewController.h"

@interface LPMakeOfferViewController ()

@end

@implementation LPMakeOfferViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // load content
    self.profileImageView.image = self.profileImage;
    self.profileImageView.layer.cornerRadius = self.profileImageView.bounds.size.height / 2.0;
    self.profileImageView.clipsToBounds = YES;
    self.nameLabel.text = self.nameStr;
    self.priceLabel.text = self.priceStr;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)dismissViewController:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)confirmOffer:(id)sender {
    NSLog(@"Confirm clicked");
}
@end
