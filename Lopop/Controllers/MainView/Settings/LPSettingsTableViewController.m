//
//  LPSettingsTableViewController.m
//  Lopop
//
//  Created by Troy Ling on 1/29/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "LPSettingsTableViewController.h"
#import "LPUserProfileViewController.h"
#import "LPMainViewTabBarController.h"

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
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"LPDisplayCurrentUserProfile"]) {
        if ([segue.destinationViewController isKindOfClass:[LPUserProfileViewController class]]) {
            LPUserProfileViewController *vc = segue.destinationViewController;
            vc.targetUser = [PFUser currentUser];
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    // tag 999 -> logout cell
    if (cell.tag == 999) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Are you sure you want to log out?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
        [alert show];
    }
}

#pragma mark alertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if ([title isEqualToString:@"Yes"]) {
        [PFUser logOut];
        UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"LPSignUpViewController"];
        [self presentViewController:vc animated:NO completion:nil];
    }
}

@end
