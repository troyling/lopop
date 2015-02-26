//
//  LPListingDetailViewController.m
//  Lopop
//
//  Created by Troy Ling on 2/20/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "LPListingDetailViewController.h"
#import "LPIncomingOfferTableViewController.h"
#import "LPMainViewTabBarController.h"
#import "UIImageView+WebCache.h"

@interface LPListingDetailViewController ()

@end

@implementation LPListingDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadHeaderView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    // engage user by hiding tabbar
    if ([self.tabBarController isKindOfClass:[LPMainViewTabBarController class]]) {
        LPMainViewTabBarController *tb = (LPMainViewTabBarController *) self.tabBarController;
        [tb setTabBarVisible:NO animated:YES];
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
    if ([segue.destinationViewController isKindOfClass:[LPIncomingOfferTableViewController class]]) {
        LPIncomingOfferTableViewController *vc = segue.destinationViewController;
        vc.pop = self.pop;
    }
}

@end
