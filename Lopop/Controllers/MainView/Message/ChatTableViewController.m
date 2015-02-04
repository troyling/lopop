//
//  ChatTableViewController.m
//  Lopop
//
//  Created by Ruofan Ding on 2/3/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "ChatTableViewController.h"
#import <Parse/Parse.h>
#import "MessageViewController.h"
#import "ChatModel.h"

@interface ChatTableViewController ()

@end


@implementation ChatTableViewController
Firebase * userRef;
NSString * FirebaseUrl1 = @"https://vivid-heat-6123.firebaseio.com/";
NSString * userId;
NSString * troyId = @"qXHdNj9Skh";


- (void)viewDidLoad {
    [super viewDidLoad];
    userId = [[PFUser currentUser] objectId];
    
    userRef = [[Firebase alloc] initWithUrl:
                [FirebaseUrl1 stringByAppendingString: [@"users/" stringByAppendingString: userId]]];
    
    self.chatArray = [[NSMutableArray alloc] init];
    
    __block BOOL initialAdds = YES;
    
    [userRef observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
        [self.chatArray addObject:[ChatModel fromDict:snapshot.value]];
        // Reload the table view so the new message will show up.
        if (!initialAdds) {
            [self.tableView reloadData];/*
                                         NSIndexPath * indexPath = [NSIndexPath indexPathForRow:self.messageArray.count - 1 inSection:0];
                                         [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];*/
        }
    }];
    
    [userRef observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        [self.tableView reloadData];
        initialAdds = NO;
    }];
    

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    
    ChatModel * a_chat = [self.chatArray objectAtIndex:indexPath.row];
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
        MessageViewController * vc = [segue destinationViewController];
        if([sender isKindOfClass: [UITableViewCell class]]){
            NSInteger index = [self.tableView indexPathForCell:(UITableViewCell *) sender].row;
            ChatModel * cm = [self.chatArray objectAtIndex: index];
            vc.chatId = cm.chatId;
        }
    }
}



- (IBAction)newChat:(id)sender {
    ChatModel* aChatModel = [ChatModel alloc];
    aChatModel.contactId = troyId;
    
    //Generate a new chat in '/chats'
    Firebase * aChatRef = [[[Firebase alloc] initWithUrl:[FirebaseUrl1 stringByAppendingString: @"chats"]] childByAutoId];
    [aChatRef setValue: @{@"user1" : userId, @"user2" : troyId}];
    aChatModel.chatId = aChatRef.key;

    //Add a chatInfo to the chat list of '/users/user-id'
    [[userRef childByAutoId] setValue:[aChatModel toDict]];
    
    //Also add the chatInfo to contact's chat list
    aChatModel.contactId = userId;
    Firebase * contactRef = [[Firebase alloc] initWithUrl:
                             [FirebaseUrl1 stringByAppendingString: [@"users/" stringByAppendingString: troyId]]];
    [[contactRef childByAutoId] setValue:[aChatModel toDict]];
}
@end
