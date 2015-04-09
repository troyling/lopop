//
//  LPIncomingOfferTableViewController.m
//  Lopop
//
//  Created by Troy Ling on 2/20/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "LPIncomingOfferTableViewController.h"
#import "LPUserProfileTableViewController.h"
#import "LPMainViewTabBarController.h"
#import "LPUserRatingTableViewCell.h"
#import "LPOfferChatViewController.h"
#import "LPNewMeetupViewController.h"
#import "LPMessageViewController.h"
#import "UIImageView+WebCache.h"
#import "LPChatManager.h"
#import "LPPopHelper.h"
#import "LPUIHelper.h"
#import "LPOffer.h"

@interface LPIncomingOfferTableViewController ()

@property (strong, nonatomic) NSMutableArray *incomingOffers;
@property (strong, nonatomic) NSMutableArray *expandedCellIndexPaths;
@property (retain, nonatomic) LPOffer *transitOffer;

@end

@implementation LPIncomingOfferTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    if ([self.pop isDataAvailable]) {
        [self loadHeaderView];
    } else {
        [self.pop fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            if (!error) {
                [self loadHeaderView];
            }
        }];
    }
    [self loadData];

    self.expandedCellIndexPaths = [NSMutableArray array];

    // UI
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];

    self.navigationItem.title = @"Offers";
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if ([self.tabBarController isKindOfClass:[LPMainViewTabBarController class]]) {
        [((LPMainViewTabBarController *) self.tabBarController) setTabBarVisible:NO animated:YES];
    }
}

- (void)loadHeaderView {
    self.titleLabel.text = self.pop.title;

    [LPPopHelper countOffersToPop:self.pop inBackgroundWithBlock:^(int count, NSError *error) {
        if (!error) {
            self.numOfferLabel.text = [NSString stringWithFormat:@"%d offers", count];
            self.numOfferLabel.hidden = NO;
        }
    }];

    PFFile *file = self.pop.images.firstObject;
    [self.popImgView sd_setImageWithURL:[NSURL URLWithString:file.url]];
}

- (void)loadData {
    if (self.pop) {
        PFQuery *query = [LPOffer query];
        [query whereKey:@"pop" equalTo:self.pop];
        [query includeKey:@"fromUser"];
        [query orderByDescending:@"createdAt"];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                self.incomingOffers = [[NSMutableArray alloc] initWithArray:objects];
                [self.tableView reloadData];
            }
        }];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (self.incomingOffers) ? self.incomingOffers.count : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LPUserRatingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"incomingOfferCell" forIndexPath:indexPath];

    if (!cell) {
        cell = [[LPUserRatingTableViewCell alloc] init];
    }

    if (indexPath.row < self.incomingOffers.count) {
        LPOffer *offer = [self.incomingOffers objectAtIndex:indexPath.row];
        PFUser *offerUser = offer.fromUser;
        if ([offerUser isDataAvailable]) {
            [self loadCell:cell withOfferUserData:offerUser];
        } else {
            [offerUser fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                if (!error) {
                    [self loadCell:cell withOfferUserData:offerUser];
                }
            }];
        }
    }

//    UIView *mask = [[UIView alloc] initWithFrame:cell.bounds];
//    [mask setBackgroundColor:[UIColor colorWithWhite:0.5 alpha:0.5]];
//    [cell addSubview:mask];

    return cell;
}

- (void)loadCell:(LPUserRatingTableViewCell *)cell withOfferUserData:(PFUser *)offerUser {
    cell.nameLabel.text = offerUser[@"name"];

    if (offerUser[@"profilePictureUrl"]) {
        [cell.profileImageView sd_setImageWithURL:offerUser[@"profilePictureUrl"]];
    }

    // FIXME implement review and change it to reflect the actual rating
    RateView *rv = [RateView rateViewWithRating:4.4f];

    rv.starFillColor = [LPUIHelper ratingStarColor];
    rv.starSize = 15.0f;
    rv.starNormalColor = [UIColor lightGrayColor];
    [cell.userRateView addSubview:rv];

    // actions
    [self loadActionsForCell:cell];
}

- (void)loadActionsForCell:(LPUserRatingTableViewCell *)cell {
    cell.profileImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewOfferUserProfile:)];
    [cell.profileImageView addGestureRecognizer:tap];
}

# pragma mark - Actions

- (IBAction)viewOfferUserProfile:(id)sender {
    if ([sender isKindOfClass:[UITapGestureRecognizer class]]) {
        UITapGestureRecognizer *tap = sender;
        LPUserRatingTableViewCell *cell = (LPUserRatingTableViewCell *) [[tap.view superview] superview];

        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        LPOffer *offer = [self.incomingOffers objectAtIndex:indexPath.row];
        PFUser *offerUser = offer.fromUser;

        LPUserProfileTableViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"userProfile"];
        vc.user = offerUser;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - UINavigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // FIXME Message view controller crashes after slide back
    if ([segue.destinationViewController isKindOfClass:[LPMessageViewController class]]) {
        LPMessageViewController *vc = segue.destinationViewController;

        if ([[[sender superview] superview] isKindOfClass:[LPUserRatingTableViewCell class]]) {
            LPUserRatingTableViewCell *cell = (LPUserRatingTableViewCell *) [[sender superview] superview];
            NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
            LPOffer *offer = [self.incomingOffers objectAtIndex:indexPath.row];
            vc.pop = self.pop;
            vc.offerUser = offer.fromUser;
            vc.chatModel = [[LPChatManager getInstance] startChatWithContactId:offer.fromUser.objectId];
        }
    } else if ([segue.identifier isEqualToString:@"scheduleMeetupSegue"]) {
        LPNewMeetupViewController *vc = segue.destinationViewController;

        if ([sender isKindOfClass:[LPUserRatingTableViewCell class]]) {
            LPUserRatingTableViewCell *cell = sender;
            NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
            LPOffer *offer = [self.incomingOffers objectAtIndex:indexPath.row];
            vc.offer = offer;
            vc.pop = self.pop;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // present meet up view

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
