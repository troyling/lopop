//
//  LPUserProfileTableViewController.m
//  Lopop
//
//  Created by Troy Ling on 3/7/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "LPUserProfileTableViewController.h"
#import "UIImageView+WebCache.h"
#import "UIImage+ImageEffects.h"
#import "HMSegmentedControl.h"
#import "LPUIHelper.h"
#import "LPPop.h"
#import "LPUserRelationship.h"
#import "LPFollowerTableViewCell.h"
#import "LPUserHelper.h"

@interface LPUserProfileTableViewController ()

@property (retain, nonatomic) NSMutableArray *currentPops;
@property (retain, nonatomic) NSMutableArray *pastPops;
@property (retain, nonatomic) NSMutableArray *following;
@property (retain, nonatomic) NSMutableArray *followers;

@property (retain, nonatomic) HMSegmentedControl *segmentedControl;
@property (retain, nonatomic) UIButton *clickedBtn;

@end

@implementation LPUserProfileTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self loadSegmentedControl];

    // init
    self.currentPops = [NSMutableArray array];
    self.pastPops = [NSMutableArray array];
    self.following = [NSMutableArray array];
    self.followers = [NSMutableArray array];

    if ([self.user isDataAvailable]) {
        [self loadUserInfo];
    }
    else {
        [self.user fetchInBackgroundWithBlock: ^(PFObject *object, NSError *error) {
            if (!error) {
                [self loadUserInfo];
            }
        }];
    }
}

- (void)loadUserInfo {
    self.nameLabel.text = self.user[@"name"];

    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 2;
    self.profileImageView.clipsToBounds = YES;
    [self.profileImageView sd_setImageWithURL:self.user[@"profilePictureUrl"] placeholderImage:nil completed: ^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (!error) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
                //Background Thread
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    UIImage *bkgImg = [self.profileImageView.image applyBlurWithRadius:20
                                                                             tintColor:[UIColor colorWithWhite:1.0 alpha:0.2]
                                                                 saturationDeltaFactor:1.3
                                                                             maskImage:nil];
                    self.profBkgImageView.image = bkgImg;
                });
            });
        }
    }];
}

- (void)loadSegmentedControl {
    self.segmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:@[@"Selling", @"Sold", @"Following", @"Followers"]];
    self.segmentedControl.frame = self.segmentedControlView.bounds;
    [self.segmentedControl addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];
    self.segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleArrow;
    self.segmentedControl.backgroundColor = [LPUIHelper lopopColorWithAlpha:0.8];
    self.segmentedControl.selectionIndicatorColor = [UIColor whiteColor];
    self.segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    self.segmentedControl.segmentWidthStyle = HMSegmentedControlSegmentWidthStyleFixed;
    self.segmentedControl.titleTextAttributes = @{ NSFontAttributeName : [UIFont systemFontOfSize:14],
                                                   NSForegroundColorAttributeName : [UIColor whiteColor] };
    self.segmentedControl.selectedTitleTextAttributes = @{ NSFontAttributeName : [UIFont boldSystemFontOfSize:16],
                                                           NSForegroundColorAttributeName : [UIColor whiteColor] };
    [self.segmentedControlView addSubview:self.segmentedControl];
}


#pragma mark segmentedControl

- (IBAction)segmentedControlChangedValue:(id)sender {
    switch (self.segmentedControl.selectedSegmentIndex) {
        case 1:
            NSLog(@"sold");
            break;

        case 2:
            NSLog(@"following");
            [self queryForFollowing];
            break;

        case 3:
            // follower
            NSLog(@"followers");
            [self queryForFollowers];
            break;

        default:
            // current pops
            NSLog(@"pops");
            break;
    }
}

#pragma mark Parse

- (void)queryForPops {
    PFQuery *query = [LPPop query];
    [query orderByDescending:@"createdAt"];
    [query setLimit:40];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            [self.currentPops addObjectsFromArray:objects];
            [self.tableView reloadData];
        }
    }];
}

- (void)queryForPastPops {

}

- (void)queryForFollowing {
    PFQuery *query = [LPUserRelationship query];
    [query orderByDescending:@"createdAt"];
    [query whereKey:@"follower" equalTo:self.user];
    [query includeKey:@"followedUser"];
    query.limit = 40;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            for (LPUserRelationship *relationship in objects) {
                [self.following addObject:relationship.followedUser];
            }
            [self.tableView reloadData];
        }
    }];
}

- (void)queryForFollowers {
    PFQuery *query = [LPUserRelationship query];
    [query orderByAscending:@"createdAt"];
    [query whereKey:@"followedUser" equalTo:self.user];
    [query includeKey:@"follower"];
    query.limit = 40;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            for (LPUserRelationship *relationship in objects) {
                [self.followers addObject:relationship.follower];
            }
            [self.tableView reloadData];
        }
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rows = 0;

    switch(self.segmentedControl.selectedSegmentIndex) {
        case 1:
            //past
            rows = self.pastPops.count;
            break;
        case 2:
            //following
            rows = self.following.count;
            break;
        case 3:
            //followers
            rows = self.followers.count;
            break;
        default:
            rows = self.currentPops.count;
            break;
    }
    return rows;
}

#pragma mark - TableView Delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.segmentedControl.selectedSegmentIndex == 2 || self.segmentedControl.selectedSegmentIndex == 3) {
        LPFollowerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LPFollowerCell" forIndexPath:indexPath];

        if (!cell) {
            cell = [[LPFollowerTableViewCell alloc] init];
        }

        PFUser *user = (self.segmentedControl.selectedSegmentIndex == 2) ? [self.following objectAtIndex:indexPath.row] : [self.followers objectAtIndex:indexPath.row];

        NSLog(@"user: %@", user);
        [cell.profileImageView sd_setImageWithURL:user[@"profilePictureUrl"]];
        cell.nameLabel.text = user[@"name"];

        // move inset line
        cell.separatorInset = UIEdgeInsetsMake(0.0f, cell.profileImageView.bounds.size.width + 15.0f, 0.0f, 0.0f);

        // configure follow button
        if (![user.objectId isEqualToString:[PFUser currentUser].objectId]) {
            // other user
            if ([LPUserHelper isCurrentUserFollowingUser:user]) {
                [self setUnfollowLayoutForButton:cell.followBtn];
            } else {
                [self setFollowLayoutForButton:cell.followBtn];
            }
            cell.followBtn.hidden = NO;
        }
        return cell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"popsCell" forIndexPath:indexPath];
        return cell;
    }
}

#pragma mark UIActionsheet

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([title isEqualToString:@"Unfollow"]) {
        if (self.clickedBtn) {
            PFUser *userToUnfollow = [self tableViewItemForButton:self.clickedBtn];
            // unfollow the user
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

#pragma mark Helper

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

- (IBAction)attemptUnfollowUser:(id)sender {
    PFUser *user;
    NSString *sheetTitle;

    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *btn = sender;
        user = [self tableViewItemForButton:btn];
    }

    if (user) {
        sheetTitle = [NSString stringWithFormat:@"Unfollow %@?", user[@"name"]];
        self.clickedBtn = sender;
    }

    UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:sheetTitle delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Unfollow" otherButtonTitles:nil, nil];
    [as showInView:self.view];
}

- (IBAction)followUser:(id)sender {
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *btn = sender;
        PFUser *userToFollow = [self tableViewItemForButton:btn];
        [LPUserHelper followUserInBackground:userToFollow withBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [btn removeTarget:self action:@selector(followUser:) forControlEvents:UIControlEventTouchUpInside];
                [self setUnfollowLayoutForButton:btn];
            }
        }];
    }
}

- (id)tableViewItemForButton:(UIButton *)button {
    PFUser *user;
    if ([button.superview.superview isKindOfClass:[LPFollowerTableViewCell class]]) {

        LPFollowerTableViewCell *cell = (LPFollowerTableViewCell *) button.superview.superview;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        user = (self.segmentedControl.selectedSegmentIndex == 2) ? [self.following objectAtIndex:indexPath.row] : [self.followers objectAtIndex:indexPath.row];
    }
    return user;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    //    if ([segue.destinationViewController isKindOfClass:[LPUserProfileTableViewController class]]) {
    //        if ([sender isKindOfClass:[LPFollowerTableViewCell class]]) {
    //            LPUserProfileTableViewController *vc = segue.destinationViewController;
    //            LPFollowerTableViewCell *cell = sender;
    //            NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];



    //            if (indexPath.row < self.userRelationships.count) {
    //                LPUserRelationship *relationship = [self.userRelationships objectAtIndex:indexPath.row];
    //
    //                if (self.contentType == FOLLOWER) {
    //                    vc.targetUser = relationship.follower;
    //                } else {
    //                    vc.targetUser = relationship.followedUser;
    //                }
    //            } else {
    //                NSLog(@"error");
    //            }
    //}
    //}
}

@end
