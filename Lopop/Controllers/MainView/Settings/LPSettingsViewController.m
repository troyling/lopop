//
//  LPSettingsViewController.m
//  Lopop
//
//  Created by Troy Ling on 1/29/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "LPSettingsViewController.h"
#import "LPUserProfileViewController.h"

@interface LPSettingsViewController ()

@end

@implementation LPSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

@end
