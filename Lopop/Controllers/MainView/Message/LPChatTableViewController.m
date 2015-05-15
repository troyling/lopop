//
//  ChatTableViewController.m
//  Lopop
//
//  Created by Ruofan Ding on 2/3/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "LPChatTableViewController.h"
#import <Parse/Parse.h>
#import "LPMessageViewController.h"
#import "LPChatModel.h"
#import "LPChatManager.h"
#import "LPMainViewTabBarController.h"
#import "UIImageView+WebCache.h"
#import "LPChatTableViewCell.h"

@interface LPChatTableViewController ()

@end

@implementation LPChatTableViewController


- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.chatArray = [[LPChatManager getInstance] getChatArray];
    
    [self observeChatManagerNotification];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([self.tabBarController isKindOfClass:[LPMainViewTabBarController class]]) {
        [(LPMainViewTabBarController *)self.tabBarController setTabBarVisible:YES animated:YES];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if ([self.tabBarController isKindOfClass:[LPMainViewTabBarController class]]) {
        [(LPMainViewTabBarController *)self.tabBarController setTabBarVisible:NO animated:YES];
    }
}

- (void) observeChatManagerNotification {
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(reloadTableData:)
     name:ChatManagerChatViewUpdateNotification
     object:nil];
}

- (void)reloadTableData:(NSNotification*)notification {
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.chatArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = @"chatCell";

    LPChatTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];

    if (!cell) {
        cell = [[LPChatTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }

    LPChatModel * chatModel = [self.chatArray objectAtIndex:indexPath.row];

    if (chatModel.contactId) {
        PFQuery *query = [PFUser query];
        [query whereKey:@"objectId" equalTo:chatModel.contactId];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error && objects.count == 1) {
                PFUser *u = objects.firstObject;
                [cell.profileImgView sd_setImageWithURL:[NSURL URLWithString:u[@"profilePictureUrl"]]];
            }
        }];
    }

    if (chatModel.contactName) {
        cell.nameLabel.text = chatModel.contactName;
    }

    if (chatModel.getLastMessage) {
        cell.lastMsgLabel.text = [chatModel getLastMessage];
    }

    if (chatModel.numberOfUnread != 0) {
        cell.lastMsgLabel.textColor = [UIColor blackColor];
        cell.numUnreadMsgLabel.text = [NSString stringWithFormat:@"%d", chatModel.numberOfUnread];
        cell.numUnreadMsgLabel.hidden = NO;
    } else {
        cell.lastMsgLabel.textColor = [UIColor lightGrayColor];
        cell.numUnreadMsgLabel.hidden = YES;
    }

    return cell;
}



/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:@"conversationSegue"]){
        LPMessageViewController * vc = [segue destinationViewController];
        if([sender isKindOfClass: [UITableViewCell class]]){
            NSInteger index = [self.tableView indexPathForCell:(UITableViewCell *) sender].row;
            vc.chatModel = [self.chatArray objectAtIndex: index];
        }
    }
}



- (IBAction)newChat:(id)sender {
    LPChatModel* chatModel = [[LPChatManager getInstance] getChatModel: @"4N9TIBOwYE"];
    [self.chatArray addObject:chatModel];
    [self.tableView reloadData];
    //[[LPChatManager getInstance] startChatWithContactId:@"pSxj8YdXrp"];
}

- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if(editingStyle == UITableViewCellEditingStyleDelete){
        LPChatModel * a_chat = [self.chatArray objectAtIndex:indexPath.row];
        [[LPChatManager getInstance] deleteChat: a_chat];
        [self.tableView reloadData];
    }
}

@end
