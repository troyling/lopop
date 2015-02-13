//
//  LPShareViewController.m
//  Lopop
//
//  Created by Troy Ling on 2/10/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "LPShareViewController.h"
#import "WXApi.h"
#import "WeiboSDK.h"
#import "LPAlertViewHelper.h"
#import <FacebookSDK/FBLinkShareParams.h>
#import <FacebookSDK/FBDialogs.h>
#import <FacebookSDK/FBWebDialogs.h>

@interface LPShareViewController ()

@property (weak, nonatomic) IBOutlet UIButton *smsBtn;
@property (weak, nonatomic) IBOutlet UIButton *emailBtn;

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

    if (![WXApi isWXAppInstalled]) {
        // TODO disable wechat button
        NSLog(@"WX is not installed");
    }
}

- (NSString *)publicLink:(LPPop *)pop {
    // TODO fix the link
    //    NSString *linkStr = [NSString stringWithFormat:@"https://lopopapp/pop/%@", pop.objectId];
    NSString *linkStr = [NSString stringWithFormat:@"https://www.crunchbase.com/organization/lopop"];
    return linkStr;
}

- (FBLinkShareParams *)populateParamsWithPop:(LPPop *)pop {
    NSString *linkStr = [self publicLink:self.pop];
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

- (WXMediaMessage *)wechatMsgWithPop:(LPPop *)pop {
    NSString *linkStr = [self publicLink:self.pop];

    WXMediaMessage *message = [WXMediaMessage message];
    message.title = pop.title;
    message.description = pop.popDescription;

    // TODO compress the image
    //    PFFile *imgFile = pop.images.firstObject;
    //    UIImage *img = [UIImage imageWithData:[imgFile getData]];
    //    [message setThumbImage:img];

    WXWebpageObject *ext = [WXWebpageObject object];
    ext.webpageUrl = linkStr;

    message.mediaObject = ext;
    message.mediaTagName = @"Lopop";

    return message;
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
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"WeChat Friend", @"WeChat Timeline", nil];
    [sheet showInView:self.view];
}

- (IBAction)shareWithSms:(id)sender {
    if ([MFMessageComposeViewController canSendText]) {
        MFMessageComposeViewController *vc = [[MFMessageComposeViewController alloc] init];
        NSString *body = [NSString stringWithFormat:@"Check out this Pop:\n\n%@ \n %@ \n\n %@",
                          self.pop.title,
                          self.pop.popDescription,
                          [self publicLink:self.pop]];
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
        NSString *body = [NSString stringWithFormat:@"Check out this Pop:\n\n%@ \n %@ \n\n %@",
                          self.pop.title,
                          self.pop.popDescription,
                          [self publicLink:self.pop]];

        [vc setSubject:subject];
        [vc setMessageBody:body isHTML:NO];
        [self presentViewController:vc animated:YES completion:NULL];
    } else {
        [LPAlertViewHelper fatalErrorAlert:@"Unable to send email now. Please try again later."];
    }
}

- (IBAction)copyLinkToClipboard:(id)sender {
    UIPasteboard *pb = [UIPasteboard generalPasteboard];
    [pb setString:[self publicLink:self.pop]];

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
    WXMediaMessage *message = [self wechatMsgWithPop:self.pop];
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
