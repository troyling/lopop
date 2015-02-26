//
//  LPMakeOfferViewController.m
//  Lopop
//
//  Created by Troy Ling on 2/6/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "LPMakeOfferViewController.h"
#import "LPPopDetailViewController.h"
#import "LPOffer.h"

@interface LPMakeOfferViewController ()

@end

@implementation LPMakeOfferViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // TODO adjust for scroll view to avoid the keyboard from blocking the content
    
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

@end
