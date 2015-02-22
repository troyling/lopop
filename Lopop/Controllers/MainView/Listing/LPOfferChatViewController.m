//
//  LPOfferChatViewController.m
//  Lopop
//
//  Created by Troy Ling on 2/21/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "LPOfferChatViewController.h"
#import "LPMessageViewController.h"
#import "UIImageView+WebCache.h"
#import "LPLocationPickerViewController.h"

@interface LPOfferChatViewController ()

@end

@implementation LPOfferChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    if ([self.pop isDataAvailable]) {
        [self loadHeaderView];
    } else {
        [self.pop fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            if (!error) {
                [self loadHeaderView];
            }
        }];
    }
}

- (void)loadHeaderView {
    PFFile *imgFile = self.pop.images.firstObject;
    NSString *urlStr = imgFile.url;
    [self.popImgView sd_setImageWithURL:[NSURL URLWithString:urlStr]];
    self.titleLabel.text = self.pop.title;
    self.priceLabel.text = [self.pop publicPriceStr];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[LPMessageViewController class]]) {
        LPMessageViewController *vc = sender;
        vc.pop = self.pop;
        vc.offerUser = self.offerUser;
    } else if ([segue.destinationViewController isKindOfClass:[LPLocationPickerViewController class]]) {
        LPLocationPickerViewController *vc = segue.destinationViewController;
        CLLocation *location = [[CLLocation alloc] initWithLatitude:self.pop.location.latitude longitude:self.pop.location.longitude];
        vc.location = location;
    }
}

#pragma mark Unwind segue

- (IBAction)prepareForUnwindSegue:(UIStoryboardSegue *)unwindsegue {
    if ([unwindsegue.sourceViewController isKindOfClass:[LPLocationPickerViewController class]]) {
        LPLocationPickerViewController *vc = unwindsegue.sourceViewController;
        CLLocation *proposeLocation = vc.location;
        NSLog(@"%@", proposeLocation);
        NSLog(@"STR: %@", vc.locationStr);
    }
}

@end
