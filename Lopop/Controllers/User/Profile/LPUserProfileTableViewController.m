//
//  LPUserProfileTableViewController.m
//  Lopop
//
//  Created by Troy Ling on 3/7/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "LPUserProfileTableViewController.h"
#import "LPUserRatingDetailViewController.h"
#import "LPMainViewTabBarController.h"
#import "LPPopListingTableViewCell.h"
#import "LPPopDetailViewController.h"
#import "LPFollowerTableViewCell.h"
#import "LPPermissionValidator.h"
#import "UIImageView+WebCache.h"
#import "UIImage+ImageEffects.h"
#import "LPUserRelationship.h"
#import "HMSegmentedControl.h"
#import "LPAlertViewHelper.h"
#import "LPLocationHelper.h"
#import "LPUserHelper.h"
#import "LPUIHelper.h"
#import "LPCache.h"
#import "LPPop.h"

#define QUERY_LIMIT 40
#define PROFILE_FOLLOW_BUTTON_TAG 999

@interface LPUserProfileTableViewController ()

@property (retain, nonatomic) NSMutableArray *currentPops;
@property (retain, nonatomic) NSMutableArray *pastPops;
@property (retain, nonatomic) NSMutableArray *following;
@property (retain, nonatomic) NSMutableArray *followers;

@property (assign, nonatomic) NSInteger numCurrentPops;
@property (assign, nonatomic) NSInteger numPastPops;
@property (assign, nonatomic) NSInteger numFollowing;
@property (assign, nonatomic) NSInteger numFollowers;

@property (retain, nonatomic) HMSegmentedControl *segmentedControl;
@property (retain, nonatomic) UIButton *clickedBtn;

@end

@implementation LPUserProfileTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [[LPCache getInstance] synchronizeFollowingForCurrentUserInBackgroundIfNecessary];
    [self loadSegmentedControl];
    [self queryForPops:NO];
    [self loadUserInfo];

    // init
    self.currentPops = [NSMutableArray array];
    self.pastPops = [NSMutableArray array];
    self.following = [NSMutableArray array];
    self.followers = [NSMutableArray array];

    if ([self.user isDataAvailable]) {
        [self loadUserProfile];
    }
    else {
        [self.user fetchInBackgroundWithBlock: ^(PFObject *object, NSError *error) {
            if (!error) {
                [self loadUserProfile];
            }
        }];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if ([self.tabBarController isKindOfClass:[LPMainViewTabBarController class]]) {
        [(LPMainViewTabBarController *)self.tabBarController setTabBarVisible:NO animated:YES];
    }
}

#pragma mark - InitSetup

- (void)loadUserProfile {
    self.nameLabel.text = self.user[@"name"];

    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 2;
    self.profileImageView.clipsToBounds = YES;
    [self.profileImageView sd_setImageWithURL:self.user[@"profilePictureUrl"] placeholderImage:nil completed: ^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (!error) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
                //Background Thread
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    UIImage *bkgImg = [self.profileImageView.image applyBlurWithRadius:20
                                                                             tintColor:[UIColor colorWithWhite:0.0 alpha:0.2]
                                                                 saturationDeltaFactor:1.3
                                                                             maskImage:nil];
                    self.profBkgImageView.image = bkgImg;
                });
            });
        }
    }];

    // profile image
    if ([[PFUser currentUser].objectId isEqualToString:self.user.objectId]) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(udpateProfileImage:)];
        self.profileImageView.userInteractionEnabled = YES;
        [self.profileImageView addGestureRecognizer:tap];
    }

    // follow button
    if (![self.user.objectId isEqualToString:[PFUser currentUser].objectId]) {
        // other user
        if ([[LPCache getInstance] isCurrentUserFollowingUser:self.user]) {
            [self setUnfollowLayoutForButton:self.followBtn];
        } else {
            [self setFollowLayoutForButton:self.followBtn];
        }
        self.followBtn.hidden = NO;
    }
}

- (void)loadUserInfo {
    [LPUserHelper findUserInfoInBackground:self.user withBlock:^(LPUserInfo *userInfo, BOOL succeeded, NSError *error) {
        if (!error) {
            // rating
            if (userInfo.numRating != 0) {
                float avgRating = [userInfo userAvgRating];
                RateView *rv = [RateView rateViewWithRating:avgRating];
                rv.starFillColor = [LPUIHelper ratingStarColor];
                rv.starBorderColor = [UIColor clearColor];
                rv.starSize = 15.0f;
                rv.starNormalColor = [UIColor lightGrayColor];
                [self.userRatingView addSubview:rv];

                // this might need more work
                UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(rv.frame.size.width + 4, rv.frame.origin.y + 2, 100, 12)];
                l.textAlignment = NSTextAlignmentLeft;
                l.textColor = [UIColor whiteColor];
                l.font = [UIFont systemFontOfSize:12];
                l.text = [NSString stringWithFormat:@"· %@", userInfo.numRating];
                [self.userRatingView addSubview:l];

                // dynamic size
                float labelOffsetX = [l.text boundingRectWithSize:l.frame.size
                                                          options:NSStringDrawingUsesLineFragmentOrigin
                                                       attributes:@{ NSFontAttributeName:l.font }
                                                          context:nil].size.width;

                float adjustedWidth = rv.frame.size.width + labelOffsetX;
                self.userRatingView.frame = CGRectMake(self.userRatingView.frame.origin.x, self.userRatingView.frame.origin.y, adjustedWidth, 20);
                self.userRatingView.center = CGPointMake([LPUIHelper screenWidth] * 0.5, self.userRatingView.center.y);
            } else {
                [self showNoCommentMsg];
            }

            // location
            if (userInfo.location != nil) {
                [LPLocationHelper getRegionForGeoPoint:userInfo.location withBlock:^(NSString *address, NSError *error) {
                    if (!error) {
                        self.locationLabel.text = address;
                    }
                }];
            } else {
                [self showUnspecifiedLocationMsg];
            }

            // add action listener to rateview
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showAllUserRating:)];
            self.userRatingView.userInteractionEnabled = YES;
            [self.userRatingView addGestureRecognizer:tap];
        } else {
            [self showUnspecifiedLocationMsg];
            [self showNoCommentMsg];
        }
    }];
}

- (void)showNoCommentMsg {
    UILabel *l = [[UILabel alloc] init];
    l.text = @"No review yet";
    l.font = [UIFont boldSystemFontOfSize:12.0f];
    l.textColor = [UIColor lightGrayColor];
    [l sizeToFit];
    [self.userRatingView addSubview:l];

    // adjust width
    float adjustedWidth = [l.text boundingRectWithSize:l.frame.size
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                            attributes:@{ NSFontAttributeName:l.font }
                                               context:nil].size.width;
    self.userRatingView.frame = CGRectMake(self.userRatingView.frame.origin.x, self.userRatingView.frame.origin.y, adjustedWidth, 20);
    self.userRatingView.center = CGPointMake([LPUIHelper screenWidth] * 0.5, self.userRatingView.center.y);
}

- (void)showUnspecifiedLocationMsg {
    self.locationLabel.text = @"Unspecified";
    self.locationLabel.font = [UIFont boldSystemFontOfSize:12.0f];
    self.locationLabel.textColor = [UIColor lightGrayColor];
}

- (void)loadSegmentedControl {
    self.segmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:@[@"Pops", @"Completed", @"Following", @"Followers"]];
    self.segmentedControl.frame = CGRectMake(0, 0, [LPUIHelper screenWidth], 60);
    self.segmentedControl.userDraggable = NO;
    [self.segmentedControl addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];
    self.segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleArrow;
    self.segmentedControl.backgroundColor = [UIColor clearColor];
    self.segmentedControl.selectionIndicatorColor = [UIColor whiteColor];
    self.segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    self.segmentedControl.segmentWidthStyle = HMSegmentedControlSegmentWidthStyleFixed;
    self.segmentedControl.titleTextAttributes = @{ NSFontAttributeName : [UIFont systemFontOfSize:14],
                                                   NSForegroundColorAttributeName : [UIColor whiteColor] };
    self.segmentedControl.selectedTitleTextAttributes = @{ NSFontAttributeName : [UIFont boldSystemFontOfSize:16],
                                                           NSForegroundColorAttributeName : [UIColor whiteColor] };
    [self.segmentedControlView addSubview:self.segmentedControl];
    self.segmentedControlView.layer.zPosition = MAXFLOAT; // bring it to front

    [self loadUserStats];
}

- (void)loadUserStats {
    // query for numbers
    PFQuery *numCurrentPopQuery = [LPPop query];
    numCurrentPopQuery.cachePolicy = kPFCachePolicyCacheThenNetwork;
    [numCurrentPopQuery whereKey:@"seller" equalTo:self.user];
    [numCurrentPopQuery whereKey:@"status" notEqualTo:[NSNumber numberWithInteger:kPopcompleted]];
    [numCurrentPopQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (!error) {
            self.numCurrentPops = number;
            [self replaceSegmentedControlTitleAtIndex:0 withString:[NSString stringWithFormat:@"%ld\nPops", (long)self.numCurrentPops]];
        }
    }];

    PFQuery *numPastPopsQuery = [LPPop query];
    numPastPopsQuery.cachePolicy = kPFCachePolicyCacheThenNetwork;
    [numPastPopsQuery whereKey:@"seller" equalTo:self.user];
    [numPastPopsQuery whereKey:@"status" equalTo:[NSNumber numberWithInteger:kPopcompleted]];
    [numPastPopsQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (!error) {
            self.numPastPops = number;
            [self replaceSegmentedControlTitleAtIndex:1 withString:[NSString stringWithFormat:@"%ld\nCompleted", (long)self.numPastPops]];
        }
    }];

    PFQuery *numFollowingQuery = [LPUserRelationship query];
    numFollowingQuery.cachePolicy = kPFCachePolicyCacheThenNetwork;
    [numFollowingQuery whereKey:@"follower" equalTo:self.user];
    [numFollowingQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (!error) {
            self.numFollowing = number;
            [self replaceSegmentedControlTitleAtIndex:2 withString:[NSString stringWithFormat:@"%ld\nFollowing", (long)self.numFollowing]];
        }
    }];

    PFQuery *numFollowersQuery = [LPUserRelationship query];
    numFollowersQuery.cachePolicy = kPFCachePolicyCacheThenNetwork;
    [numFollowersQuery whereKey:@"followedUser" equalTo:self.user];
    [numFollowersQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (!error) {
            self.numFollowers = number;
            [self replaceSegmentedControlTitleAtIndex:3 withString:[NSString stringWithFormat:@"%ld\nFollowers", (long)self.numFollowers]];
        }
    }];
}

#pragma mark segmentedControl

- (IBAction)segmentedControlChangedValue:(id)sender {
    switch (self.segmentedControl.selectedSegmentIndex) {
        case 1:
            // past pops
            [self queryForPastPops:NO];
            break;
        case 2:
            // following
            [self queryForFollowing:NO];
            break;
        case 3:
            // follower
            [self queryForFollowers:NO];
            break;
        default:
            // current pops
            [self queryForPops:NO];
            break;
    }
}

#pragma mark Parse

- (void)queryForPops:(BOOL)loadMore {
    PFQuery *query = [LPPop query];
    query.limit = QUERY_LIMIT;
    query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    [query orderByDescending:@"createdAt"];
    [query whereKey:@"seller" equalTo:self.user];
    [query whereKey:@"status" notEqualTo:[NSNumber numberWithInteger:kPopcompleted]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            if (objects.count != 0) {
                if (loadMore) {
                    [self.currentPops addObjectsFromArray:objects];
                } else {
                    NSRange range = NSMakeRange(0, self.currentPops.count);
                    [self.currentPops replaceObjectsInRange:range withObjectsFromArray:objects];
                }
            } else {
                // TODO show end
                NSLog(@"that's all");
            }
            [self.tableView reloadData];
        }
    }];
}

- (void)queryForPastPops:(BOOL)loadMore {
    PFQuery *query = [LPPop query];
    query.limit = QUERY_LIMIT;
    query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    [query orderByAscending:@"updatedAt"];
    [query whereKey:@"seller" equalTo:self.user];
    [query whereKey:@"status" equalTo:[NSNumber numberWithInteger:kPopcompleted]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            if (objects.count != 0) {
                if (loadMore) {
                    [self.pastPops addObjectsFromArray:objects];
                } else {
                    NSRange range = NSMakeRange(0, self.pastPops.count);
                    [self.pastPops replaceObjectsInRange:range withObjectsFromArray:objects];
                }
            } else {
                // TODO show end
                NSLog(@"END2");
            }
            [self.tableView reloadData];
        }
    }];
}

- (void)queryForFollowing:(BOOL)loadMore {
    PFQuery *query = [LPUserRelationship query];
    query.limit = QUERY_LIMIT;
    query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    [query orderByDescending:@"createdAt"];
    [query whereKey:@"follower" equalTo:self.user];
    [query includeKey:@"followedUser"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            if (objects.count != 0) {
                if (!loadMore) {
                    [self.following removeAllObjects];
                }
                for (LPUserRelationship *relationship in objects) {
                    [self.following addObject:relationship.followedUser];
                }
            } else {
                // TODO show end
                NSLog(@"END3");
            }
            [self.tableView reloadData];
        }
    }];
}

- (void)queryForFollowers:(BOOL)loadMore {
    PFQuery *query = [LPUserRelationship query];
    query.limit = QUERY_LIMIT;
    query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    [query orderByAscending:@"createdAt"];
    [query whereKey:@"followedUser" equalTo:self.user];
    [query includeKey:@"follower"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            if (objects.count != 0) {
                if (!loadMore) {
                    [self.followers removeAllObjects];
                }
                for (LPUserRelationship *relationship in objects) {
                    [self.followers addObject:relationship.follower];
                }
            } else {
                // TODO show end
                NSLog(@"END 4");
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 56.0f;
    if (self.segmentedControl.selectedSegmentIndex == 0 || self.segmentedControl.selectedSegmentIndex == 1) {
        height = 90.0f;
    }
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.segmentedControl.selectedSegmentIndex == 2 || self.segmentedControl.selectedSegmentIndex == 3) {
        LPFollowerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LPFollowerCell" forIndexPath:indexPath];

        if (!cell) {
            cell = [[LPFollowerTableViewCell alloc] init];
        }

        PFUser *user = (self.segmentedControl.selectedSegmentIndex == 2) ? [self.following objectAtIndex:indexPath.row] : [self.followers objectAtIndex:indexPath.row];

        [cell.profileImageView sd_setImageWithURL:user[@"profilePictureUrl"]];
        cell.nameLabel.text = user[@"name"];

        // move inset line
        cell.separatorInset = UIEdgeInsetsMake(0.0f, cell.profileImageView.bounds.size.width + 15.0f, 0.0f, 0.0f);

        // configure follow button
        if (![user.objectId isEqualToString:[PFUser currentUser].objectId]) {
            // other user
            if ([[LPCache getInstance] isCurrentUserFollowingUser:user]) {
                [self setUnfollowLayoutForButton:cell.followBtn];
            } else {
                [self setFollowLayoutForButton:cell.followBtn];
            }
            cell.followBtn.hidden = NO;
        }
        return cell;
    } else {
        NSString *cellIdentifier = @"popsCell";

        LPPopListingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];

        if (!cell) {
            cell = [[LPPopListingTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }

        LPPop *pop = self.segmentedControl.selectedSegmentIndex == 0 ? [self.currentPops objectAtIndex:indexPath.row] : [self.pastPops objectAtIndex:indexPath.row];

        // load cell
        cell.titleLabel.text = pop.title;
        cell.priceLabel.text = [pop publicPriceStr];
        PFFile *file = pop.images.firstObject;
        [cell.imgView sd_setImageWithURL:[NSURL URLWithString:file.url]];

        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.segmentedControl.selectedSegmentIndex == 2 || self.segmentedControl.selectedSegmentIndex == 3) {
        LPUserProfileTableViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"userProfile"];
        PFUser *user = self.segmentedControl.selectedSegmentIndex == 2 ? [self.following objectAtIndex:indexPath.row] : [self.followers objectAtIndex:indexPath.row];
        vc.user = user;
        [self.navigationController pushViewController:vc animated:YES];
    } else if (self.segmentedControl.selectedSegmentIndex == 0 || self.segmentedControl.selectedSegmentIndex == 1) {
        LPPopDetailViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"detailView"];
        LPPop *pop = self.segmentedControl.selectedSegmentIndex == 0 ? [self.currentPops objectAtIndex:indexPath.row] : [self.pastPops objectAtIndex:indexPath.row];
        vc.pop = pop;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark UIActionsheet

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([title isEqualToString:@"Unfollow"]) {
        if (self.clickedBtn) {
            PFUser *userToUnfollow = self.clickedBtn.tag == 999 ? self.user : [self tableViewItemForButton:self.clickedBtn];
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
    } else if ([title isEqualToString:@"Take photo"]) {
        [self takePicture];

    } else if ([title isEqualToString:@"Choose from library"]) {
        [self chooseImages];
    }
}

#pragma mark imagePickerController

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = info[UIImagePickerControllerEditedImage];
    if (!image) {
        image = info[UIImagePickerControllerOriginalImage];
    }
    NSData *imageData = UIImageJPEGRepresentation(image, 0.5); // 50% compression
    PFFile *parseImageFile = [PFFile fileWithData:imageData]; // PFFile has 10MB of size limit
    [parseImageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [PFUser currentUser][@"profilePictureUrl"] = parseImageFile.url;
            [[PFUser currentUser] saveEventually];
            [[PFUser currentUser] fetchInBackground];

            // update current view
            [self.profileImageView sd_setImageWithURL:[NSURL URLWithString:parseImageFile.url]];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
                //Background Thread
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    UIImage *bkgImg = [image applyBlurWithRadius:20
                                                       tintColor:[UIColor colorWithWhite:1.0 alpha:0.2]
                                           saturationDeltaFactor:1.3
                                                       maskImage:nil];
                    self.profBkgImageView.image = bkgImg;
                });
            });
        }
    }];
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark Helper

- (IBAction)udpateProfileImage:(id)sender {
    UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:@"Change profile picture" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take photo", @"Choose from library", nil];
    [as showInView:self.view];
}

- (void)takePicture {
    if ([LPPermissionValidator isCameraAccessible]) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
        imagePicker.allowsEditing = YES;
        [self presentViewController:imagePicker animated:YES completion:NULL];
    } else {
        // TODO changed it to add a button to access the system settings
        [LPAlertViewHelper fatalErrorAlert:@"Unable to take picture. Please allow camera permission in settings"];
    }
}

- (void)chooseImages {
    if ([LPPermissionValidator isPhotoLibraryAccessible]) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
        imagePicker.allowsEditing = YES;
        [self presentViewController:imagePicker animated:YES completion:NULL];
    } else {
        [LPAlertViewHelper fatalErrorAlert:@"Unable to choose picture. Please allow photo library access permission in settings"];
    }
}

- (IBAction)showAllUserRating:(id)sender {
    [self performSegueWithIdentifier:@"userRatingDetailSegue" sender:self];
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
    [button setBackgroundColor:[UIColor clearColor]];
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
        user = btn.tag == 999 ? self.user : [self tableViewItemForButton:btn];
        sheetTitle = [NSString stringWithFormat:@"Unfollow %@?", user[@"name"]];
        self.clickedBtn = sender;
    }

    UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:sheetTitle delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Unfollow" otherButtonTitles:nil, nil];
    [as showInView:self.view];
}

- (IBAction)followUser:(id)sender {
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *btn = sender;

        // check if the button is the one in profile
        PFUser *userToFollow = btn.tag == PROFILE_FOLLOW_BUTTON_TAG ? self.user : [self tableViewItemForButton:btn];
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

- (void)replaceSegmentedControlTitleAtIndex:(NSInteger)index withString:(NSString *)title {
    NSMutableArray *titles = [NSMutableArray arrayWithArray:self.segmentedControl.sectionTitles];
    [titles replaceObjectAtIndex:index withObject:title];
    [self.segmentedControl setSectionTitles:titles];
    [self.segmentedControl setNeedsDisplay];
}

#pragma mark Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"userRatingDetailSegue"]) {
        LPUserRatingDetailViewController *vc = segue.destinationViewController;
        vc.user = self.user;
    }
}

@end
