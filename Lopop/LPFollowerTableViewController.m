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
#import "LPAssociatedButton.h"
#import "LPUserHelper.h"

@interface LPFollowerTableViewController ()

@property (strong, nonatomic) NSMutableArray *userRelationships;
@property (strong, nonatomic) NSMutableSet *myFollowingUsers;
@property (strong, nonatomic) LPAssociatedButton *clickedBtn;

@end

@implementation LPFollowerTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // configure table
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

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

    // move inset line
    cell.separatorInset = UIEdgeInsetsMake(0.0f, cell.profileImageView.bounds.size.width + 15.0f, 0.0f, 0.0f);

    // configure follow button
    if (self.myFollowingUsers.count > 0) {
        if (![user.objectId isEqualToString:[PFUser currentUser].objectId]) {
            if ([self.myFollowingUsers containsObject:user.objectId]) {
                [self setUnfollowLayoutForButton:cell.followBtn];
            } else {
                [self setFollowLayoutForButton:cell.followBtn];
            }
            cell.followBtn.hidden = NO;
        }
        cell.followBtn.associatedOjbect = user;
    }
}

- (void)setUnfollowLayoutForButton:(UIButton *)button {
    [button setTitle:@"Following" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setBackgroundColor:[LPUIHelper lopopColor]];

    button.layer.borderWidth = 0.0f;
    [button addTarget:self action:@selector(attemptUnfollowUser:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setFollowLayoutForButton:(UIButton *)button {
    [button setTitle:@"+ Follow" forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor whiteColor]];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

    button.layer.borderWidth = 1.0f;
    button.layer.borderColor = [UIColor blackColor].CGColor;

    // add follow action
    [button addTarget:self action:@selector(followUser:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark UIActionsheet

- (IBAction)attemptUnfollowUser:(id)sender {
    PFUser *user;
    NSString *sheetTitle;

    if ([sender isKindOfClass:[LPAssociatedButton class]]) {
        self.clickedBtn = sender;
        user = self.clickedBtn.associatedOjbect;
    }

    if (user) {
        sheetTitle = [NSString stringWithFormat:@"Unfollow %@?", user[@"name"]];
    }

    UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:sheetTitle delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Unfollow" otherButtonTitles:nil, nil];
    [as showInView:self.view];
}

- (IBAction)followUser:(id)sender {
    if ([sender isKindOfClass:[LPAssociatedButton class]]) {
        LPAssociatedButton *btn = sender;
        PFUser *userToFollow = btn.associatedOjbect;
        [LPUserHelper followUserInBackground:userToFollow withBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [btn removeTarget:self action:@selector(followUser:) forControlEvents:UIControlEventTouchUpInside];
                [self setUnfollowLayoutForButton:btn];
            }
        }];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([title isEqualToString:@"Unfollow"]) {
        if (self.clickedBtn.associatedOjbect) {
            // unfollow the user
            PFUser *userToUnfollow = self.clickedBtn.associatedOjbect;
            [LPUserHelper unfollowUserInBackground:userToUnfollow withBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    // remove and attach new action
                    [self.clickedBtn removeTarget:self action:@selector(attemptUnfollowUser:) forControlEvents:UIControlEventTouchUpInside];
                    [self setFollowLayoutForButton:self.clickedBtn];

                    // remove reference
                    self.clickedBtn = nil;
                }
            }];
        }
    }
}

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
