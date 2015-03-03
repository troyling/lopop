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
#import "LPPopLike.h"
#import "LPUIHelper.h"
#import "UIImageView+WebCache.h"
#import "LPLocationHelper.h"
#import "UIViewController+ScrollingNavbar.h"

typedef enum {
    kFeed = 0,
    kSearch,
} LPTableDisplayType;

@interface LPFeedTableViewController ()

@property (strong, nonatomic) NSMutableArray *pops;
@property (strong, nonatomic) NSMutableArray *userLikedPops;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *userLocation;
@property (assign, nonatomic) CGFloat lastContentOffsetY;
@property (strong, nonatomic) NSDate *queryLastOjbectTimestamp;

// Searching
@property LPTableDisplayType displayType;
@property (strong, nonatomic) UISearchController *searchController;
@property (retain, nonatomic) NSMutableArray *searchResults;
@property (retain, nonatomic) UIVisualEffectView *blurView;
@property (retain, nonatomic) UILabel *noMatchLabel;

@end

@implementation LPFeedTableViewController
NSInteger const QUERY_LIMIT = 20;
CGFloat const ROW_HEIGHT_OFFSET = 75.0f;
CGFloat const IMAGE_WIDTH_TO_HEIGHT_RATIO = 0.6f;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self followScrollView:self.tableView withDelay:3.0f];

    // delegate
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.feedTableView.delegate = self;
    self.feedTableView.dataSource = self;

    // init property
    self.pops = [NSMutableArray array];
    self.searchResults = [NSMutableArray array];
    self.queryLastOjbectTimestamp = [NSDate date];

    [self initView];
    [self initSearchController];
    [self initRefreshControl];

    // query data
    self.displayType = kFeed;
    [self queryPopsForLoadMore:NO];

    // get user lcoation
    [self getUserCurrentLocation];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self showNavBarAnimated:NO];
}

- (void)initView {
    // blurview
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    self.blurView = [[UIVisualEffectView alloc] initWithEffect:blur];
    self.blurView.frame = CGRectMake(0, 0, [LPUIHelper screenWidth], [LPUIHelper screenHeight]);
    self.blurView.hidden = YES;
    [self.view addSubview:self.blurView];

    // No found label
    self.noMatchLabel = [[UILabel alloc] initWithFrame:self.tableView.frame];
    self.noMatchLabel.text = @"Sorry we couln'd find any match 😞";
    self.noMatchLabel.textAlignment = NSTextAlignmentCenter;
    self.noMatchLabel.hidden = YES;
    self.noMatchLabel.layer.zPosition = MAXFLOAT;
    self.noMatchLabel.center = self.tableView.center;
    [self.view addSubview:self.noMatchLabel];

    // content offset used to calculate view position
    self.lastContentOffsetY = self.tableView.contentOffset.y;

    // tableview
    self.tableView.rowHeight = [LPUIHelper screenWidth] * IMAGE_WIDTH_TO_HEIGHT_RATIO + ROW_HEIGHT_OFFSET;
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

#pragma mark Backend

- (void)queryPopsForLoadMore:(BOOL)loadMore {
    // start query
    PFQuery *popQuery = [LPPop query];

    // FIXME prompt lcoation service request when the app first started
    if (!self.userLocation) {
        [self getUserCurrentLocation];
    }

    // TODO: Fix this to sort based on location
    //    if (self.userLocation) {
    //        [popQuery whereKey:@"location" nearGeoPoint:[PFGeoPoint
    //        geoPointWithLocation:self.userLocation] withinKilometers:10.0f];
    //    }

    popQuery.limit = QUERY_LIMIT;
    [popQuery orderByDescending:@"createdAt"];
    [popQuery includeKey:@"seller"];

    if (!loadMore) {
        self.queryLastOjbectTimestamp = [NSDate date];
    }

    if (self.pops.count == 0) {
        popQuery.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    else {
        popQuery.cachePolicy = kPFCachePolicyNetworkOnly;
        [popQuery whereKey:@"createdAt" lessThan:self.queryLastOjbectTimestamp];
    }

    [popQuery
     findObjectsInBackgroundWithBlock: ^(NSArray *objects, NSError *error) {
         if (!error) {
             if (objects.count > 0) {
                 if (self.pops.count > 0) {
                     if ([objects.lastObject isKindOfClass:[LPPop class]]) {
                         LPPop *lastPop = objects.lastObject;
                         self.queryLastOjbectTimestamp = lastPop.createdAt;
                     }
                 }

                 if (!loadMore) {
                     NSRange range = NSMakeRange(0, self.pops.count);
                     [self.pops replaceObjectsInRange:range withObjectsFromArray:objects];
                 }
                 else {
                     [self.pops addObjectsFromArray:objects];
                 }

                 self.noContentLabel.hidden = YES;
                 [self.feedTableView reloadData];

                 if (!loadMore) {
                     [self scrollToTableViewTop];
                 }
                 // TODO stop the loading indicator
             }
             else {
                 // nothing to display
                 self.noContentLabel.hidden = NO;
             }
         }
     }];

    self.userLikedPops = [[NSMutableArray alloc] init];
    PFQuery *likeQuery = [PFQuery queryWithClassName:[LPPopLike parseClassName]];
    [likeQuery whereKey:@"likedUser" equalTo:[PFUser currentUser]];
    [likeQuery
     findObjectsInBackgroundWithBlock: ^(NSArray *objects, NSError *error) {
         [self.userLikedPops addObjectsFromArray:objects];
     }];
}

- (void)searchPopFor:(NSString *)searchItem {
    PFQuery *titleSearch = [LPPop query];
    [titleSearch whereKey:@"title" matchesRegex:searchItem modifiers:@"i"];

    PFQuery *descriptionSearch = [LPPop query];
    [descriptionSearch whereKey:@"popDescription" matchesRegex:searchItem modifiers:@"i"];

    PFQuery *query = [PFQuery orQueryWithSubqueries:@[titleSearch, descriptionSearch]];
    [query orderByDescending:@"createdAt"];
    [query includeKey:@"seller"];

    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            [self.searchResults removeAllObjects];

            if (objects.count > 0) {
                [self.searchResults addObjectsFromArray:objects];
                [self searchBarActive:NO];
                [self.tableView reloadData];
            } else {
                // unable to find any match
                self.noMatchLabel.hidden = NO;
                [self searchBarActive:NO];
                [self.tableView reloadData];
            }
        } else {
            //TODO: error indictaing
        }
    }];
}

- (void)initRefreshControl {
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self
                       action:@selector(refreshPops)
             forControlEvents:UIControlEventValueChanged];
    refreshControl.attributedTitle =
    [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    self.refreshControl = refreshControl;
}

- (void)initSearchController {
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.searchBar.delegate = self;
    self.searchController.searchBar.placeholder = @"What are you looking for?";
    [self.searchController.searchBar sizeToFit];
    self.definesPresentationContext = YES;
    self.tableView.tableHeaderView = self.searchController.searchBar;
}

- (void)refreshPops {
    if (self.displayType == kSearch) {
        [self.refreshControl endRefreshing];
        return;
    }

    [self queryPopsForLoadMore:NO];
    // add last update
    if (self.refreshControl) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMM d, h:mm a"];
        NSString *title =
        [NSString stringWithFormat:@"Last update: %@",
         [formatter stringFromDate:[NSDate date]]];
        NSDictionary *attrsDictionary =
        [NSDictionary dictionaryWithObject:[UIColor blackColor]
                                    forKey:NSForegroundColorAttributeName];
        NSAttributedString *attributedTitle =
        [[NSAttributedString alloc] initWithString:title
                                        attributes:attrsDictionary];
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
            if ([self.tabBarController
                 isKindOfClass:[LPMainViewTabBarController class]]) {
                LPMainViewTabBarController *tb =
                (LPMainViewTabBarController *)self.tabBarController;
                [tb setTabBarVisible:NO animated:YES];
            }
        }
        else if (margin < -15.0f) {
            // scrolling up
            if ([self.tabBarController
                 isKindOfClass:[LPMainViewTabBarController class]]) {
                LPMainViewTabBarController *tb =
                (LPMainViewTabBarController *)self.tabBarController;
                [tb setTabBarVisible:YES animated:YES];
            }
        }
        self.lastContentOffsetY = scrollView.contentOffset.y;
    }
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView {
        if ([scrollView isEqual:self.tableView]) {
            [self scrollToTableViewTop];
        }
        return NO;

    return YES;
}

#pragma mark tableViewDelegateMethod

- (NSInteger)   tableView:(UITableView *)tableView
    numberOfRowsInSection:(NSInteger)section {
    NSUInteger rows = 0;

    if (self.displayType == kFeed) {
        if (self.pops) {
            rows = self.pops.count;
        }
    } else {
        rows = self.searchResults.count;
    }

    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"LPPopFeedTableViewCell";
    LPPopFeedTableViewCell *cell =
    [tableView dequeueReusableCellWithIdentifier:cellIdentifier
                                    forIndexPath:indexPath];

    // load the data onto the cutom cell
    if (!cell) {
        cell = [[LPPopFeedTableViewCell alloc] init];
    }

    LPPop *pop;
    if (self.displayType == kFeed) {
        pop = [self.pops objectAtIndex:indexPath.row];
    } else {
        pop = [self.searchResults objectAtIndex:indexPath.row];
    }

    [self loadCell:cell withPop:pop];
    //        cell.likeBtn.tag = indexPath.row;
    //        [cell.likeBtn addTarget:nil action:@selector(like_pop2:)
    //        forControlEvents:UIControlEventTouchUpInside];
    //        [self updateButton:cell.likeBtn with:pop];

    return cell;
}

- (void)updateButton:(UIButton *)updateButton with:(LPPop *)pop {
    PFQuery *likedQuery = [PFQuery queryWithClassName:[LPPopLike parseClassName]];
    // being followed by other users
    [likedQuery whereKey:@"pop" equalTo:pop];
    [likedQuery countObjectsInBackgroundWithBlock: ^(int number, NSError *error) {
        if (!error) {
            NSMutableArray *popsLikeByCurrentUser = [[NSMutableArray alloc] init];
            for (LPPopLike *pop in self.userLikedPops) {
                if ([pop.likedUser.objectId
                     isEqualToString:[PFUser currentUser].objectId]) {
                    [popsLikeByCurrentUser addObject:pop.pop];
                }
            }
            if ([popsLikeByCurrentUser containsObject:pop]) {
                [updateButton setTitle:[NSString stringWithFormat:@"unlike %d", number]
                              forState:UIControlStateNormal];
            }
            else {
                [updateButton setTitle:[NSString stringWithFormat:@"%d", number]
                              forState:UIControlStateNormal];
            }
        }
        else {
            NSLog(@"%@", error);
        }
    }];
}

- (void)like_pop2:(id)sender {
    UIButton *button = (UIButton *)sender;
    NSInteger row = button.tag;
    LPPop *currentPop = [self.pops objectAtIndex:row];

    PFQuery *likedQuery = [PFQuery queryWithClassName:[LPPopLike parseClassName]];
    // being followed by other users
    [likedQuery whereKey:@"pop" equalTo:currentPop];

    [likedQuery countObjectsInBackgroundWithBlock: ^(int number, NSError *error) {
        if (!error) {
            NSMutableArray *popsLikeByCurrentUser = [[NSMutableArray alloc] init];
            for (LPPopLike *pop in self.userLikedPops) {
                if ([pop.likedUser.objectId
                     isEqualToString:[PFUser currentUser].objectId]) {
                    [popsLikeByCurrentUser addObject:pop.pop];
                }
            }

            if ([popsLikeByCurrentUser containsObject:currentPop]) {
                [likedQuery whereKey:@"likedUser" equalTo:[PFUser currentUser]];
                LPPopLike *popToBeDeleted;
                for (LPPopLike *popLike in self.userLikedPops) {
                    if ([popLike.objectId
                         isEqualToString:[[likedQuery getFirstObject] objectId]]) {
                        popToBeDeleted = popLike;
                        break;
                    }
                }
                [self.userLikedPops removeObject:popToBeDeleted];
                [[likedQuery getFirstObject] deleteInBackground];

                [button setTitle:[NSString stringWithFormat:@"like %d", number - 1]
                        forState:UIControlStateNormal];
            }
            else {
                LPPopLike *like = [LPPopLike object];
                like.pop = currentPop;
                like.likedUser = [PFUser currentUser];
                [like saveInBackgroundWithBlock: ^(BOOL succeeded, NSError *error) {
                    if (!error) {
                        [self.userLikedPops addObject:like];
                        [button
                         setTitle:[NSString stringWithFormat:@"unlike %d", number + 1]
                         forState:UIControlStateNormal];
                    }
                    else {
                        NSLog(@"%@", error);
                    }
                }];
            }
        }
        else {
            NSLog(@"%@", error);
        }
    }];
}

- (void)like_pop:(id)sender {
    UIButton *button = (UIButton *)sender;
    NSInteger row = button.tag;
    LPPopLike *like = [LPPopLike object];
    like.pop = [self.pops objectAtIndex:row];
    like.likedUser = [PFUser currentUser];
    [like saveInBackgroundWithBlock: ^(BOOL succeeded, NSError *error) {
        if (!error) {
            [self updateButton:button with:[self.pops objectAtIndex:row]];
        }
        else {
            NSLog(@"%@", error);
        }
    }];
}

- (void)    tableView:(UITableView *)tableView
      willDisplayCell:(UITableViewCell *)cell
    forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.pops) {
        if (indexPath.row == (self.pops.count - 1)) {
            [self queryPopsForLoadMore:YES];
        }
    }
}

#pragma mark helper

- (void)searchBarActive:(BOOL)active {
    self.tableView.scrollEnabled = !active;
    self.blurView.hidden = !active;
}

- (void)loadCell:(LPPopFeedTableViewCell *)cell withPop:(LPPop *)pop
{
    cell.titleLabel.text = pop.title;
    cell.priceLabel.text = [pop publicPriceStr];

    // distance to pop
    NSString *distanceStr = [LPLocationHelper
                             stringOfDistanceInMilesBetweenGeoPoints:
                             pop.location                        and:[PFGeoPoint geoPointWithLocation:self.userLocation]
                             withFormat:@"0.##"];
    cell.distanceLabel.text =
    [[NSString alloc] initWithFormat:@"%@ mi", distanceStr];

    // load image
    PFFile *popImageFile = pop.images.firstObject;

    [cell.imgView sd_setImageWithURL:[NSURL URLWithString:popImageFile.url] placeholderImage:nil options:0 progress: ^(NSInteger receivedSize, NSInteger expectedSize) {
        cell.progressView.hidden = NO;
        if (receivedSize == 0) {
            [cell.progressView setProgress:0 animated:NO];
        }
        else {
            float progress = (float)receivedSize / (float)expectedSize;
            [cell.progressView setProgress:progress animated:YES];
        }
    } completed: ^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        cell.progressView.hidden = YES;
    }];

    [cell.sellerProfileImgView sd_setImageWithURL:pop.seller[@"profilePictureUrl"]];

    cell.imgView.clipsToBounds = YES;
}

/**
 *  Scroll to the first row of the table. Do nothing if no cell present in the tableview
 */
- (void) scrollToTableViewTop {
    if ((self.displayType == kFeed && self.pops.count > 0) ||
        (self.displayType == kSearch && self.searchResults.count > 0)) {
        NSIndexPath *top = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableView scrollToRowAtIndexPath:top atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

#pragma mark segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue destinationViewController]
         isKindOfClass:[LPPopDetailViewController class]]) {
        LPPopFeedTableViewCell *cell = (LPPopFeedTableViewCell *)sender;
        LPPopDetailViewController *vc = segue.destinationViewController;

        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];

        vc.pop = self.displayType == kFeed ? [self.pops objectAtIndex:indexPath.row] : [self.searchResults objectAtIndex:indexPath.row];

        //TODO: fetch data from model instead
        vc.priceText = cell.priceLabel.text;
        vc.distanceText = cell.distanceLabel.text;
    }
}

#pragma mark searchBar

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.noContentLabel.hidden = YES;
    self.noMatchLabel.hidden = YES;
    [self searchBarActive:YES];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSString *searchItem = [searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    self.displayType = kSearch;
    [self searchPopFor:searchItem];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.noMatchLabel.hidden = YES;
    self.displayType = kFeed;
    [self.tableView reloadData];
    [self searchBarActive:NO];
}

@end
