//
//  LPFeedViewController.m
//  Lopop
//
//  Created by Troy Ling on 1/14/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "LPFeedTableViewController.h"
#import "LPNewPopTableViewController.h"
#import "LPPopFeedTableViewCell.h"
#import "LPPopDetailViewController.h"
#import "LPMainViewTabBarController.h"
#import "LPPop.h"
#import <Parse/Parse.h>
#import "LPPopLike.h"

@interface LPFeedTableViewController ()

@property (strong, nonatomic) NSArray *pops;
@property (strong, nonatomic) NSMutableArray *userLikedPops;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *userLocation;
@property (assign, nonatomic) CGFloat lastContentOffsetY;

@end

@implementation LPFeedTableViewController
CGFloat const ROW_HEIGHT_OFFSET = 75.0f;
CGFloat const IMAGE_WIDTH_TO_HEIGHT_RATIO = 0.6f;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // delegate
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.feedTableView.delegate = self;
    self.feedTableView.dataSource = self;
    
    // content offset used to calculate view position
    self.lastContentOffsetY = self.tableView.contentOffset.y;
    
    // init
    CGRect bound = [[UIScreen mainScreen] bounds];
    self.tableView.rowHeight = bound.size.width * IMAGE_WIDTH_TO_HEIGHT_RATIO + ROW_HEIGHT_OFFSET;
    
    // query data
    [self queryForPops];
    
    // configure pull to refresh
    [self initRefreshControl];

    // get user lcoation
    [self getUserCurrentLocation];

    // set table background
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
}

- (void)getUserCurrentLocation {
    [self.locationManager startUpdatingLocation];
    if (self.locationManager.location) {
        self.userLocation = self.locationManager.location;
    }
    [self.locationManager stopUpdatingLocation];
}

- (void)queryForPops {
    // start query
    PFQuery *popQuery = [LPPop query];
    
    // FIXME prompt lcoation service request when the app first started
    if (!self.userLocation) {
        [self getUserCurrentLocation];
    }
    
    // FIXME showing most recent pop for now. Change this to whatever logic we want later
    [popQuery orderByDescending:@"createdAt"];
    
//    if (self.userLocation) {
//        [popQuery whereKey:@"location" nearGeoPoint:[PFGeoPoint geoPointWithLocation:self.userLocation] withinKilometers:10.0f];
//    }
    
    popQuery.cachePolicy = self.pops.count == 0 ? kPFCachePolicyCacheThenNetwork : kPFCachePolicyNetworkOnly;
    
    [popQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            self.pops = [[NSArray alloc] initWithArray:objects];
            NSLog(@"Reloaded");
            [self.feedTableView reloadData];
            // TODO stop the loading indicator
        }
    }];
    self.userLikedPops = [[NSMutableArray alloc] init];
    PFQuery *likeQuery = [PFQuery queryWithClassName:[LPPopLike parseClassName]];
    [likeQuery whereKey:@"likedUser" equalTo:[PFUser currentUser]];
    [likeQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [self.userLikedPops addObjectsFromArray:objects];
    }];
}

- (void)initRefreshControl {
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshPops) forControlEvents:UIControlEventValueChanged];
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    self.refreshControl = refreshControl;
}

- (void)refreshPops {
    [self queryForPops];

    // add last update
    if (self.refreshControl) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMM d, h:mm a"];
        NSString *title = [NSString stringWithFormat:@"Last update: %@", [formatter stringFromDate:[NSDate date]]];
        NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:[UIColor blackColor] forKey:NSForegroundColorAttributeName];
        NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attrsDictionary];
        self.refreshControl.attributedTitle = attributedTitle;

        [self.refreshControl endRefreshing];
    }
}

#pragma mark Scrollview Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.pops.count > 0) {
        CGFloat margin = scrollView.contentOffset.y - self.lastContentOffsetY;

        if (margin > 15.0f) {
            // scrolling down
            if ([self.tabBarController isKindOfClass:[LPMainViewTabBarController class]]) {
                LPMainViewTabBarController *tb = (LPMainViewTabBarController *) self.tabBarController;
                [tb setTabBarVisible:NO animated:YES];
            }
        } else if (margin < -15.0f) {
            // scrolling up
            if ([self.tabBarController isKindOfClass:[LPMainViewTabBarController class]]) {
                LPMainViewTabBarController *tb = (LPMainViewTabBarController *) self.tabBarController;
                [tb setTabBarVisible:YES animated:YES];
            }
        }
        self.lastContentOffsetY = scrollView.contentOffset.y;
    }
}

#pragma mark tableViewDelegateMethod

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSUInteger rows = 0;
    if (self.pops) {
        rows = self.pops.count;
    }
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"LPPopFeedTableViewCell";
    LPPopFeedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    // load the data onto the cutom cell
    if (!cell) {
        cell = [[LPPopFeedTableViewCell alloc] init];
    }

    if (self.pops) {
        LPPop *pop = [self.pops objectAtIndex:indexPath.row];
        CLLocationDistance distance = [pop.location distanceInMilesTo:[PFGeoPoint geoPointWithLocation:self.userLocation]];
        
        cell.titleLabel.text = pop.title;
        
        NSString *priceStr = [pop.price isEqualToNumber:[NSNumber numberWithInt:0]] ? @"  Free!  " : [NSString stringWithFormat:@"  $%@  ", pop.price];
        cell.priceLabel.text = priceStr;
        
        // format distance
        NSNumberFormatter *formater = [[NSNumberFormatter alloc] init];
        [formater setPositiveFormat:@"0.##"];
        NSString *distanceStr = [formater stringFromNumber:[NSNumber numberWithDouble:distance]];
        cell.distanceLabel.text = [[NSString alloc] initWithFormat:@"%@ mi", distanceStr];
        
        // load image
        PFFile *popImageFile = pop.images.firstObject;
        [popImageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
                UIImage *img = [UIImage imageWithData:data scale:0.05f];
                cell.imgView.image = img;
                cell.imgView.clipsToBounds = YES;
            }
        }];
        
        cell.likeBtn.tag = indexPath.row;
        
        [cell.likeBtn addTarget:nil action:@selector(like_pop2:) forControlEvents:UIControlEventTouchUpInside];
        
        [self updateButton:cell.likeBtn with:pop];
}
    
    return cell;
}

- (void)updateButton:(UIButton*)updateButton with:(LPPop*)pop{
    PFQuery *likedQuery = [PFQuery queryWithClassName:[LPPopLike parseClassName]];
    // being followed by other users
    [likedQuery whereKey:@"pop" equalTo:pop];
    [likedQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (!error) {
            NSMutableArray *popsLikeByCurrentUser = [[NSMutableArray alloc] init];
            for (LPPopLike *pop in self.userLikedPops) {
                if ([pop.likedUser.objectId isEqualToString:[PFUser currentUser].objectId]) {
                    [popsLikeByCurrentUser addObject:pop.pop];
                }
            }
            if ([popsLikeByCurrentUser containsObject:pop]) {
                [updateButton setTitle:[NSString stringWithFormat:@"unlike %d", number] forState:UIControlStateNormal];
            } else {
                [updateButton setTitle:[NSString stringWithFormat:@"like %d", number] forState:UIControlStateNormal];
            }
            
        } else {
            NSLog(@"%@", error);
        }
    }];
}

- (void)like_pop2:(id) sender {
    UIButton *button = (UIButton*) sender;
    NSInteger row = button.tag;
    LPPop *currentPop = [self.pops objectAtIndex:row];
    
    
    PFQuery *likedQuery = [PFQuery queryWithClassName:[LPPopLike parseClassName]];
    // being followed by other users
    [likedQuery whereKey:@"pop" equalTo:currentPop];
    
    [likedQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (!error) {
            NSMutableArray *popsLikeByCurrentUser = [[NSMutableArray alloc] init];
            for (LPPopLike *pop in self.userLikedPops) {
                if ([pop.likedUser.objectId isEqualToString:[PFUser currentUser].objectId]) {
                    [popsLikeByCurrentUser addObject:pop.pop];
                }
            }

            if ([popsLikeByCurrentUser containsObject:currentPop]) {
                
                [likedQuery whereKey:@"likedUser" equalTo:[PFUser currentUser]];
                LPPopLike *popToBeDeleted;
                for (LPPopLike *popLike in self.userLikedPops) {
                    if ([popLike.objectId isEqualToString:[[likedQuery getFirstObject] objectId]]) {
                        popToBeDeleted = popLike;
                        break;
                    }
                }
                [self.userLikedPops removeObject:popToBeDeleted];
                [[likedQuery getFirstObject] deleteInBackground];
                
                [button setTitle:[NSString stringWithFormat:@"like %d", number - 1] forState:UIControlStateNormal];
            } else {
                LPPopLike *like = [LPPopLike object];
                like.pop = currentPop;
                like.likedUser = [PFUser currentUser];
                [like saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (!error) {
                        [self.userLikedPops addObject:like];
                        [button setTitle:[NSString stringWithFormat:@"unlike %d", number + 1] forState:UIControlStateNormal];
                    } else {
                        NSLog(@"%@", error);
                        
                    }
                }];
               
            }
        } else {
            NSLog(@"%@", error);
        }
        
    }];
    

}
- (void)like_pop:(id) sender {
    UIButton *button = (UIButton*) sender;
    NSInteger row = button.tag;
    LPPopLike *like = [LPPopLike object];
    like.pop = [self.pops objectAtIndex:row];
    like.likedUser = [PFUser currentUser];
    [like saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            [self updateButton:button with:[self.pops objectAtIndex:row]];
        } else {
            NSLog(@"%@", error);
        }
    }];
    }

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.pops) {
        if (indexPath.row == (self.pops.count - 1)) {
            // TODO load more item from Parse
            NSLog(@"Time to load more item from server");
        }
    }
}

#pragma mark segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue destinationViewController] isKindOfClass:[LPPopDetailViewController class]]) {
        LPPopFeedTableViewCell *cell = (LPPopFeedTableViewCell *)sender;
        LPPopDetailViewController *vc = segue.destinationViewController;
        
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        
        vc.pop = [self.pops objectAtIndex:indexPath.row];
        
        // setup destination
        vc.priceText = cell.priceLabel.text;
        vc.distanceText = cell.distanceLabel.text;
    }
}


@end
