//
//  LPMakeOfferViewController.m
//  Lopop
//
//  Created by Troy Ling on 2/6/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "LPMakeOfferViewController.h"
#import "LPPopDetailViewController.h"
#import "LPPushHelper.h"
#import "LPUIHelper.h"
#import "LPOffer.h"

@interface LPMakeOfferViewController ()
@end

@implementation LPMakeOfferViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.greetingTextField.delegate = self;

    // load content
    self.profileImageView.image = self.profileImage;
    self.profileImageView.layer.cornerRadius = self.profileImageView.bounds.size.height / 2.0;
    self.profileImageView.clipsToBounds = YES;
    self.nameLabel.text = self.nameStr;
    self.priceLabel.text = self.priceStr;
}

- (IBAction)dismissViewController:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)confirmOffer:(id)sender {
    // create an offer
    LPOffer *offer = [LPOffer object];
    offer.fromUser = [PFUser currentUser];
    offer.pop = self.pop;
    offer.greeting = [self.greetingTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    offer.status = kOfferPending;

    // FIXME send the comment to the seller as a chat message
    [offer saveEventually:^(BOOL succeeded, NSError *error) {
        if (!error) {
            PFUser *currentUser = [PFUser currentUser];
            if (currentUser != nil) {
                NSString *msg = [NSString stringWithFormat:@"%@ sent you an offer", currentUser[@"name"]];
                [LPPushHelper sendPushWithPop:self.pop withMsg:msg];
                [LPPushHelper setPushChannelForOffer:offer];
            }

            [self dismissViewControllerAnimated:YES completion:NULL];
            [self performSegueWithIdentifier:@"offerSent" sender:self];
        }
    }];
}

#pragma mark Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"offerSent"]) {
        LPPopDetailViewController *vc = [segue destinationViewController];
        [vc setUIForOfferState:OfferSent];
    }
}

#pragma mark UITextField delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    CGFloat newConst = self.offerView.center.y - (self.offerView.frame.size.height / 2.0 + 55.0f); // shift view up
    [self.offerViewAlignmentY setConstant:newConst];
    [self.view setNeedsUpdateConstraints];
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self.offerViewAlignmentY setConstant:0];
    [self.view setNeedsUpdateConstraints];
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO; // avoid new line
}

@end
