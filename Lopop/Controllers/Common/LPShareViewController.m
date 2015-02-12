//
//  LPShareViewController.m
//  Lopop
//
//  Created by Troy Ling on 2/10/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "LPShareViewController.h"
#import "WXApi.h"
#import "LPAlertViewHelper.h"
#import <FacebookSDK/FBLinkShareParams.h>
#import <FacebookSDK/FBDialogs.h>
#import <FacebookSDK/FBWebDialogs.h>

@interface LPShareViewController ()

@property (retain, nonatomic) FBLinkShareParams *params;

@end

@implementation LPShareViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // check if Messenger is installed
    self.params = [self populateParamsWithPop:self.pop];
    if (![FBDialogs canPresentMessageDialogWithParams:self.params]) {
        self.messengerBtn.hidden = YES;
    }
}

- (FBLinkShareParams *)populateParamsWithPop:(LPPop *)pop {
    // TODO fix the link
    //    NSString *linkStr = [NSString stringWithFormat:@"https://lopopapp/pop/%@", self.pop.objectId];
    NSString *linkStr = [NSString stringWithFormat:@"https://www.crunchbase.com/organization/lopop"];
    NSURL *link = [NSURL URLWithString:linkStr];

    PFFile *thumbnail = pop.images.firstObject;
    NSURL *pictureUrl = [NSURL URLWithString:thumbnail.url];

    FBLinkShareParams *params = [[FBLinkShareParams alloc] initWithLink:link
                                                                   name:pop.title
                                                                caption:@"Lopop"
                                                            description:pop.popDescription
                                                                picture:pictureUrl];
    return params;
}

- (IBAction)shareOnFacebook:(id)sender {
    // TODO couple ways to improve this
    // 1. Add source to keep track of where users are coming from
    // 2. Hash the URL to protect our data
    // 3. Shorten url

    if ([FBDialogs canPresentShareDialogWithParams:self.params]) {
        // Present the share dialog on the Facebook app
        [FBDialogs presentShareDialogWithParams:self.params clientState:nil handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
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
                                    self.params.name, @"name",
                                    self.params.caption, @"caption",
                                    self.params.link.absoluteString, @"link",
                                    self.params.description, @"description",
                                    self.params.picture.absoluteString, @"picture",
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

- (IBAction)shareOnMessenger:(id)sender {
    [FBDialogs presentMessageDialogWithParams:self.params clientState:nil handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
        if (error) {
            [LPAlertViewHelper fatalErrorAlert:@"Unable to share with Messenger. Please try again later"];
        } else {
            NSLog(@"Successfully share on Messenger");
        }
    }];
}

- (IBAction)shareOnWeChat:(id)sender {
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = self.pop.title;
    message.description = self.pop.popDescription;

    // TODO compress the image
//    PFFile *imgFile = self.pop.images.firstObject;
//    UIImage *img = [UIImage imageWithData:[imgFile getData]];
//    [message setThumbImage:img];

    WXWebpageObject *ext = [WXWebpageObject object];
    ext.webpageUrl = self.params.link.absoluteString;

    message.mediaObject = ext;
    message.mediaTagName = @"Lopop";

    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = WXSceneTimeline;
    [WXApi sendReq:req];
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
