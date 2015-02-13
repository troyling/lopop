//
//  LPShareViewController.m
//  Lopop
//
//  Created by Troy Ling on 2/10/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "LPShareViewController.h"
#import <FacebookSDK/FBLinkShareParams.h>
#import <FacebookSDK/FBDialogs.h>
#import <FacebookSDK/FBWebDialogs.h>
#import "WXApi.h"
#import "WeiboSDK.h"
#import "LPAlertViewHelper.h"
#import "LPSocialHelper.h"

// TODO couple ways to improve this
// 1. Add source to keep track of where users are coming from
// 2. Hash the URL to protect our data
// 3. Shorten url

@interface LPShareViewController ()

@property (weak, nonatomic) IBOutlet UIButton *smsBtn;
@property (weak, nonatomic) IBOutlet UIButton *emailBtn;

@property (retain, nonatomic) FBLinkShareParams *params; // params used for sharing on fb and fb messenger

@end

@implementation LPShareViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // check if Messenger is installed
    self.params = [LPSocialHelper fbParamsWithPop:self.pop];
    if (![FBDialogs canPresentMessageDialogWithParams:self.params]) {
        self.messengerBtn.hidden = YES;
    }
}

- (IBAction)shareOnFacebook:(id)sender {
    if ([FBDialogs canPresentShareDialogWithParams:self.params]) {
        // Present the share dialog on the Facebook app
        [FBDialogs presentShareDialogWithParams:self.params clientState:nil handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
            if (error) {
                [LPAlertViewHelper fatalErrorAlert:@"Unable to share the pop at this moment. Please try again later"];
            } else {
                // TODO add indicator
                // TODO check if the message is shared
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
                // TODO check if the message is shared
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
    // present actionsheet
    if ([WXApi isWXAppInstalled]) {
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"WeChat Friend", @"WeChat Timeline", nil];
        [sheet showInView:self.view];
    } else {
        [LPAlertViewHelper fatalErrorAlert:@"Unable to share with WeChat. Please make sure you have WeChat installed on your device."];
    }
}

- (IBAction)shareWithSms:(id)sender {
    if ([MFMessageComposeViewController canSendText]) {
        MFMessageComposeViewController *vc = [[MFMessageComposeViewController alloc] init];
        NSString *body = [self.pop shareMsg];
        vc.body = body;
        vc.messageComposeDelegate = self;
        [self presentViewController:vc animated:YES completion:NULL];
    } else {
        [LPAlertViewHelper fatalErrorAlert:@"Unable to send text message."];
    }
}

- (IBAction)shareOnWeibo:(id)sender {
    if ([WeiboSDK isCanShareInWeiboAPP]) {
        WBMessageObject *message = [WBMessageObject message];
        message.text = self.pop.popDescription;

        WBImageObject *imgObj = [WBImageObject object];
        PFFile *imgFile = self.pop.images.firstObject;
        imgObj.imageData = [imgFile getData];

        message.imageObject = imgObj;
        WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:message];
        [WeiboSDK sendRequest:request];
    } else {
        [LPAlertViewHelper fatalErrorAlert:@"Unable to share on Weibo."];
    }
}

- (IBAction)shareWithEmail:(id)sender {
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *vc = [[MFMailComposeViewController alloc] init];
        vc.mailComposeDelegate = self;

        NSString *subject = [NSString stringWithFormat:@"[Lopop] %@", self.pop.title];
        NSString *body = [self.pop shareMsg];

        [vc setSubject:subject];
        [vc setMessageBody:body isHTML:NO];
        [self presentViewController:vc animated:YES completion:NULL];
    } else {
        [LPAlertViewHelper fatalErrorAlert:@"Unable to send email now. Please try again later."];
    }
}

- (IBAction)copyLinkToClipboard:(id)sender {
    UIPasteboard *pb = [UIPasteboard generalPasteboard];
    [pb setString:[self.pop publicLink]];

    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *copyBtn = sender;
        [copyBtn setTitle:@"Copied!" forState:UIControlStateNormal];
    }
}

- (IBAction)dismissView:(id)sender {
    [self dismissViewControllerAnimated:NO completion:NULL];
}

#pragma mark Actionsheet

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    WXMediaMessage *message = [LPSocialHelper wechatMessageWithPop:self.pop];
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;

    NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];

    if ([title isEqualToString:@"WeChat Friend"]) {
        req.scene = WXSceneSession;
    } else if ([title isEqualToString:@"WeChat Timeline"]) {
        req.scene = WXSceneTimeline;
    }

    [WXApi sendReq:req];
}

#pragma mark MailController

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    if (error) {
        [LPAlertViewHelper fatalErrorAlert:error.description];
    } else {
        if (result == MFMailComposeResultSent) {
            [self.emailBtn setTitle:@"Sent!" forState:UIControlStateNormal];
        } else if (result == MFMailComposeResultSaved) {
            [self.emailBtn setTitle:@"Draft saved" forState:UIControlStateNormal];
        }
    }
    [controller dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark MessageController

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    if (result == MessageComposeResultSent) {
        [self.smsBtn setTitle:@"Sent!" forState:UIControlStateNormal];
    }
    [controller dismissViewControllerAnimated:YES completion:NULL];
}

@end
