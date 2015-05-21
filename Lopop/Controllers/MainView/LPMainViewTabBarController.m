//
//  LPMainViewTabBarController.m
//  Lopop
//
//  Created by Troy Ling on 1/13/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "LPMainViewTabBarController.h"
#import "LPNewPopTableViewController.h"
#import "LPUIHelper.h"
#import "LPCache.h"
#import "LPChatManager.h"
#import <Parse/Parse.h>

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@interface LPMainViewTabBarController ()

@property (strong, nonatomic) UIButton *popButton;

@end

@implementation LPMainViewTabBarController

float const NUM_TABS = 5.0;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self displayPopButton];

    // set status bar color
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, [LPUIHelper screenWidth], 20)];
        view.backgroundColor=[LPUIHelper lopopColor];
        [self.view addSubview:view];
    }

    // fetching data
    [[PFUser currentUser] fetchInBackground];
    [[LPCache getInstance] synchronizeFollowingForCurrentUserInBackground];
    [LPChatManager initChatManager];

    [self updateTotalUnreadMessages:self];
    [self observeChatManagerNotification];
}

#pragma mark Custom Button

- (void)displayPopButton {
    // calculation
    float tabWidth = self.tabBar.layer.bounds.size.width / NUM_TABS;
    float tabHeight = self.self.tabBar.layer.bounds.size.height;
    
    UIImage *btnImage = [UIImage imageNamed:@"pop_white.png"];
    
    // inset withing the button
    float verticalInset = (tabHeight - btnImage.size.height) / 2;
    float horizontalInset = (tabWidth - btnImage.size.width) / 2;
    
    // pop button
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0.0, 0.0, tabWidth, tabHeight);

    [button setImage:btnImage forState:UIControlStateNormal];
    [button setBackgroundColor:[LPUIHelper lopopColor]];
    [button setImageEdgeInsets:UIEdgeInsetsMake(verticalInset, horizontalInset, verticalInset, horizontalInset)];
    
    // shift button if necessary
    CGFloat heightDifference = btnImage.size.height - tabHeight;
    if (heightDifference < 0) {
        button.center = self.tabBar.center;
    } else {
        CGPoint center = self.tabBar.center;
        center.y = center.y - heightDifference/2.0;
        button.center = center;
    }

    // action
    [button addTarget:self
               action:@selector(presentNewPop)
     forControlEvents:UIControlEventTouchUpInside];
    
    //add button to view
    self.popButton = button;
    [self.view addSubview:button];
}

- (void)presentNewPop {
    LPNewPopTableViewController *vc = [[self storyboard] instantiateViewControllerWithIdentifier:@"LPNewPopViewController"];
    [self presentViewController:vc animated:YES completion:NULL];
}

#pragma mark TabBar manipulation
- (void)setTabBarVisible:(BOOL)visible animated:(BOOL)animated {
    if ([self tabBarIsVisible] == visible) return;
    
    // get a frame calculation ready
    CGRect frame = self.tabBar.frame;
    CGFloat height = frame.size.height;
    CGFloat offsetY = (visible)? -height : height;
    
    // btn
    CGRect btnFrame = self.popButton.frame;
    CGFloat btnHeight = btnFrame.size.height;
    CGFloat btnOffsetY = (visible) ? -btnHeight : btnHeight;
    
    // zero duration means no animation
    CGFloat duration = (animated)? 0.3 : 0.0;
    
    [UIView animateWithDuration:duration animations:^{
        self.tabBar.frame = CGRectOffset(frame, 0, offsetY);
        self.popButton.frame = CGRectOffset(btnFrame, 0, btnOffsetY);
    }];
}

- (BOOL)tabBarIsVisible {
    return self.tabBar.frame.origin.y < CGRectGetMaxY(self.view.frame);
}

#pragma mark update total number of messages

- (void) observeChatManagerNotification {
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(updateTotalUnreadMessages:)
     name:ChatManagerChatViewUpdateNotification
     object:nil];
}

- (IBAction)updateTotalUnreadMessages:(id)sender {
    NSUInteger numUnreadMsg = [[LPChatManager getInstance] getTotalUnreadMsg];
    if (numUnreadMsg != 0) {
        [[self.tabBar.items objectAtIndex:3] setBadgeValue:[NSString stringWithFormat:@"%ld", numUnreadMsg]];
    } else {
        [[self.tabBar.items objectAtIndex:3] setBadgeValue:nil];
    }

}

@end
