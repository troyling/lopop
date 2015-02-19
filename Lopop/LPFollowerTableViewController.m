//
//  LPFollowerTableViewController.m
//  Lopop
//
//  Created by Troy Ling on 1/30/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "LPFollowerTableViewController.h"
#import "LPUserRelationship.h"
#import "LPFollowerTableViewCell.h"
#import "UIImageView+WebCache.h"

@interface LPFollowerTableViewController ()

@property (strong, nonatomic) NSMutableArray *contents;

@end

@implementation LPFollowerTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.query) {
        [self.query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                self.contents = [[NSMutableArray alloc] initWithArray:objects];
                [self.tableView reloadData];
            }
        }];
    }
    
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
    NSInteger rows = 0;
    if (self.contents) {
        rows = self.contents.count;
    }
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *reusedIdentifier = @"LPFollowerCell";
    LPFollowerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusedIdentifier forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[LPFollowerTableViewCell alloc] init];
    }
    
    // display the content from the given array
    if (self.contents) {
        LPUserRelationship *relationship = [self.contents objectAtIndex:indexPath.row];
        PFUser *userToDisplay;
        if (self.type == FOLLOWING_USER) {
            userToDisplay = relationship.followedUser;
        } else if (self.type == FOLLOWER) {
            userToDisplay = relationship.follower;
        }
        
//        [userToDisplay fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
//            if (!error) {
//                // FIXME change username to name
//                if (userToDisplay.email) {
//                    cell.textLabel.text = userToDisplay.email;
//                } else {
//                    cell.textLabel.text = userToDisplay.username;
//                }
//            } else {
//                // FIXEME error handling
//                NSLog(@"Error: %@", error);
//            }
//        }];
        if ([userToDisplay isDataAvailable]) {
            [cell.profileImageView sd_setImageWithURL:userToDisplay[@"profilePictureUrl"]];
            cell.nameLabel = userToDisplay[@"name"];
//            cell.followBtn
        } else {
            [userToDisplay fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                if (!error) {
                    [cell.profileImageView sd_setImageWithURL:userToDisplay[@"profilePictureUrl"]];
                    cell.nameLabel.text = userToDisplay[@"name"];
                }
            }];
        }
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
