//
//  LPSettingsTableViewController.m
//  Lopop
//
//  Created by Troy Ling on 1/29/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "LPSettingsTableViewController.h"
#import "LPUserProfileTableViewController.h"
#import "LPInfoDisplayViewController.h"
#import "LPMainViewTabBarController.h"
#import "LPAlertViewHelper.h"
#import "LPChatManager.h"
#import "LPCache.h"

@interface LPSettingsTableViewController ()

@end

@implementation LPSettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([self.tabBarController isKindOfClass:[LPMainViewTabBarController class]]) {
        [(LPMainViewTabBarController *)self.tabBarController setTabBarVisible:YES animated:YES];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[LPUserProfileTableViewController class]]) {
        if ([segue.identifier isEqualToString:@"currentUserProfile"]) {
            LPUserProfileTableViewController *vc = segue.destinationViewController;
            vc.user = [PFUser currentUser];
        }
    } else if ([segue.destinationViewController isKindOfClass:[LPInfoDisplayViewController class]]) {
        LPInfoDisplayViewController *vc = segue.destinationViewController;
        if ([segue.identifier isEqualToString:@"privacySegue"]) {
            vc.type = kPrivacy;
        } else if ([segue.identifier isEqualToString:@"faqSegue"]) {
            vc.type = kFaq;
        } else {
            vc.type = kTerms;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    // tag 999 -> logout cell
    if (cell.tag == 999) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Are you sure you want to log out?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
        [alert show];
    } else if (cell.tag == 998) {
        // jump to facebook
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.facebook.com/pages/Lopop-LLC/509359395869209"]];
    } else if (cell.tag == 997 ) {
        // feedback
        if ([MFMailComposeViewController canSendMail]) {
            MFMailComposeViewController *vc = [[MFMailComposeViewController alloc] init];
            vc.mailComposeDelegate = self;

            NSString *subject = @"Feedback - Lopop iOS app";

            [vc setSubject:subject];
            [vc setToRecipients:[NSArray arrayWithObject:@"thelopopapp@gmail.com"]];
            [self presentViewController:vc animated:YES completion:NULL];
        } else {
            [LPAlertViewHelper fatalErrorAlert:@"Unable to send email now. Please try again later."];
        }
    }
}

#pragma mark alertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if ([title isEqualToString:@"Yes"]) {
        [PFUser logOut];
        [[LPChatManager getInstance] close];
        [[LPCache getInstance] clear];
        UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"LPSignUpViewController"];
        [self presentViewController:vc animated:NO completion:nil];
    }
}

#pragma mark MailController

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    if (error) {
        [LPAlertViewHelper fatalErrorAlert:error.description];
    } else {
        if (result == MFMailComposeResultSent) {
            NSLog(@"thanks for your feedback");
        }
    }
    [controller dismissViewControllerAnimated:YES completion:NULL];
}

@end
