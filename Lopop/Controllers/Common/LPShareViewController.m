//
//  LPShareViewController.m
//  Lopop
//
//  Created by Troy Ling on 2/10/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "LPShareViewController.h"
#import "LPAlertViewHelper.h"
#import <FacebookSDK/FBLinkShareParams.h>
#import <FacebookSDK/FBDialogs.h>
#import <FacebookSDK/FBWebDialogs.h>

@interface LPShareViewController ()

@end

@implementation LPShareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)shareOnFacebook:(id)sender {
    // TODO couple ways to improve this
    // 1. Add source to keep track of where users are coming from
    // 2. Hash the URL to protect our data
    // 3. Shorten url

    // TODO fix the link
    //    NSString *linkStr = [NSString stringWithFormat:@"https://lopopapp/pop/%@", self.pop.objectId];
    NSString *linkStr = [NSString stringWithFormat:@"https://www.crunchbase.com/organization/lopop"];
    NSURL *link = [NSURL URLWithString:linkStr];

    // TODO generate a thumbnail when user creating a pop
    PFFile *thumbnail = self.pop.images.firstObject;
    NSURL *pictureUrl = [NSURL URLWithString:thumbnail.url];
    FBLinkShareParams *params = [[FBLinkShareParams alloc] initWithLink:link name:self.pop.title caption:@"Lopop" description:self.pop.popDescription picture:pictureUrl];

    if ([FBDialogs canPresentShareDialogWithParams:params]) {
        // Present the share dialog on the Facebook app
        [FBDialogs presentShareDialogWithParams:params clientState:nil handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
            if (error) {
                [LPAlertViewHelper fatalErrorAlert:@"Unable to share the pop at this moment. Please try again later"];
            } else {
                // TODO add indicator
                NSLog(@"Share successfully");
            }
        }];
    } else {
        // Present the feed dialog
        NSDictionary *dictParams = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    params.name, @"name",
                                    params.caption, @"caption",
                                    linkStr, @"link",
                                    self.pop.popDescription, @"description",
                                    thumbnail.url, @"picture",
                                    nil];

        [FBWebDialogs presentFeedDialogModallyWithSession:nil parameters:dictParams handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
            if (error) {
                [LPAlertViewHelper fatalErrorAlert:@"Unable to share the pop at this moment. Please try again later"];
            } else {
                // TODO add indicator
                NSLog(@"Share successfully");
            }
        }];
    }
}

- (IBAction)shareOnWeChat:(id)sender {
    NSLog(@"Share on wechat");
}

- (IBAction)shareOnWeibo:(id)sender {
    NSLog(@"Share on weibo");
}

- (IBAction)shareWithEmail:(id)sender {
    NSLog(@"Share with email");
}

- (IBAction)copyLinkToClipboard:(id)sender {
    NSLog(@"Copy to clipboard");
}

- (IBAction)dismissView:(id)sender {
    [self dismissViewControllerAnimated:NO completion:NULL];
}

@end
