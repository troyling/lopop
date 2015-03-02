//
//  MessageViewController.m
//  Lopop
//
//  Created by Ruofan Ding on 1/31/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "LPMessageViewController.h"
#import "LPMessageModel.h"
#import "LPChatManager.h"
#import <Parse/Parse.h>
#import "LPUIHelper.h"
#import "LPMainViewTabBarController.h"



@implementation LPMessageViewController

NSString *const FirebaseUrl = @"https://vivid-heat-6123.firebaseio.com/";

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = self.offerUser[@"name"];

    self.inputToolbar.contentView.leftBarButtonItem = nil; // disable accessory item

    // sender
    self.senderId = [PFUser currentUser].objectId;
    self.senderDisplayName = [PFUser currentUser][@"name"];

    self.messageArray = [[NSMutableArray alloc] init];
    [self.messageArray addObjectsFromArray:[[LPChatManager getInstance] getChatMessagesWith:self.chatModel.contactId]];
    [self observeMessageChangeNotification];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if ([self.tabBarController isKindOfClass:[LPMainViewTabBarController class]]) {
        [(LPMainViewTabBarController *)self.tabBarController setTabBarVisible:NO animated:YES];
    }
}

// Unsubscribe from keyboard show/hide notifications.
- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter]
     removeObserver:self name:ChatManagerMessageViewUpdateNotification object:nil];
}

- (void)observeMessageChangeNotification {
    [[NSNotificationCenter defaultCenter]
     addObserver:self
	    selector:@selector(reloadTableData:)
     name:ChatManagerMessageViewUpdateNotification
     object:nil];
}

- (void)reloadTableData:(NSNotification *)notification {
    if ([notification.object isKindOfClass:[LPMessageModel class]]) {
        [self.messageArray addObject:notification.object];
    }
    else {
        NSLog(@"Error in observer in messageViewController");
    }
    // TODO rewrite this
}

#pragma mark - JSQMessagesViewController method overrides

- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                  senderId:(NSString *)senderId
         senderDisplayName:(NSString *)senderDisplayName
                      date:(NSDate *)date {
    //TODO: check for msg length, empty
    [[LPChatManager getInstance] sendMessage:text to:self.chatModel];
    [self finishSendingMessageAnimated:YES];
}

@end
