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
@interface LPChatTableViewController ()

@end


@implementation LPChatTableViewController
Firebase * userRef;
NSString * FirebaseUrl1 = @"https://vivid-heat-6123.firebaseio.com/";
NSString * userId;
NSString * troyId = @"qXHdNj9Skh";


- (void)viewDidLoad {
    [super viewDidLoad];
    userId = [[PFUser currentUser] objectId];
    
    userRef = [[Firebase alloc] initWithUrl:
                [FirebaseUrl1 stringByAppendingString: [@"users/" stringByAppendingString: userId]]];
    
    self.chatArray = [[LPChatManager getInstance] getVisibleChatArray];
    [self observeChatManagerNotification];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"chatCell"];
    
    LPChatModel * a_chat = [self.chatArray objectAtIndex:indexPath.row];
    PFQuery *query = [PFUser query];
    [query whereKey:@"objectId" equalTo:a_chat.contactId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(! error){
            if([[objects firstObject] isKindOfClass:[PFUser class]]){
                cell.textLabel.text = [objects firstObject] [@"name"];
            }
        }else{
            NSLog(@"fix me in ChatTableViewController: no user found");
        }
    }];
    
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
    [[LPChatManager getInstance] startChatWithContactId:@"pSxj8YdXrp"];
}

- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if(editingStyle == UITableViewCellEditingStyleDelete){
        LPChatModel * a_chat = [self.chatArray objectAtIndex:indexPath.row];
        //[[LPChatManager getInstance] deleteChatWithContactId:a_chat.contactId];
    }
}

@end
