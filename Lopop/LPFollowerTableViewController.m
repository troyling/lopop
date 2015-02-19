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
#import "LPUserProfileViewController.h"
#import "LPUserRelationship.h"
#import "LPUIHelper.h"

@interface LPFollowerTableViewController ()

@property (strong, nonatomic) NSMutableArray *userRelationships;
@property (strong, nonatomic) NSMutableSet *myFollowingUsers;

@end

@implementation LPFollowerTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.myFollowingUsers = [[NSMutableSet alloc] init];

    PFQuery *folloingQuery = [LPUserRelationship query];
    folloingQuery.cachePolicy = kPFCachePolicyCacheThenNetwork;
    [folloingQuery whereKey:@"follower" equalTo:[PFUser currentUser]];
    [folloingQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            for (LPUserRelationship *r in objects) {
                [self.myFollowingUsers addObject:r.followedUser.objectId];
            }
        }
    }];

    if (self.query) {
        [self.query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                self.userRelationships = [[NSMutableArray alloc] initWithArray:objects];
                if (self.myFollowingUsers.count > 0) {
                    [self.tableView reloadData];
                }
            }
        }];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rows = 0;
    if (self.userRelationships) {
        rows = self.userRelationships.count;
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
    if (self.userRelationships) {
        LPUserRelationship *relationship = [self.userRelationships objectAtIndex:indexPath.row];
        PFUser *userToDisplay;
        if (self.contentType == FOLLOWING_USER) {
            userToDisplay = relationship.followedUser;
        } else if (self.contentType == FOLLOWER) {
            userToDisplay = relationship.follower;
        }

        // fetch user data, if necessary
        if ([userToDisplay isDataAvailable]) {
            [self loadFollowerCell:cell atIndexPath:indexPath withUser:userToDisplay];
        } else {
            [userToDisplay fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                if (!error) {
                    [self loadFollowerCell:cell atIndexPath:indexPath withUser:userToDisplay];
                }
            }];
        }
    }
    return cell;
}

#pragma mark UI

- (void)loadFollowerCell:(LPFollowerTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath withUser:(PFUser *)user {
    [cell.profileImageView sd_setImageWithURL:user[@"profilePictureUrl"]];
    cell.nameLabel.text = user[@"name"];

    // configure follow button
    if (self.myFollowingUsers.count > 0 && ![user.objectId isEqualToString:[PFUser currentUser].objectId]) {
        if ([self.myFollowingUsers containsObject:user.objectId]) {
            // following this user already
            [cell.followBtn setTitle:@"Following" forState:UIControlStateNormal];
            [cell.followBtn setBackgroundColor:[LPUIHelper lopopColor]];
            [cell.followBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            cell.followBtn.layer.borderWidth = 0.0f;
            // add unfollow action
        } else {
            [cell.followBtn setTitle:@"+ Follow" forState:UIControlStateNormal];
            // add follow action
        }
        cell.followBtn.hidden = NO;
    }
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
    if ([segue.destinationViewController isKindOfClass:[LPUserProfileViewController class]]) {
        if ([sender isKindOfClass:[LPFollowerTableViewCell class]]) {
            LPUserProfileViewController *vc = segue.destinationViewController;
            LPFollowerTableViewCell *cell = sender;
            NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
            if (indexPath.row < self.userRelationships.count) {
                LPUserRelationship *relationship = [self.userRelationships objectAtIndex:indexPath.row];

                if (self.contentType == FOLLOWER) {
                    vc.targetUser = relationship.follower;
                } else {
                    vc.targetUser = relationship.followedUser;
                }
            } else {
                NSLog(@"error");
            }
        }
    }
}


@end
