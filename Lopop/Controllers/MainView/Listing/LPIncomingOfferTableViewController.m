//
//  LPIncomingOfferTableViewController.m
//  Lopop
//
//  Created by Troy Ling on 2/20/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "LPIncomingOfferTableViewController.h"
#import "LPUserRatingTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "LPOffer.h"

@interface LPIncomingOfferTableViewController ()

@property (strong, nonatomic) NSMutableArray *incomingOffers;

@end

@implementation LPIncomingOfferTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSLog(@"WTF");

    [self loadData];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


- (void)loadData {
    if (self.pop) {
        PFQuery *query = [LPOffer query];
        [query whereKey:@"pop" equalTo:self.pop];
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

    return cell;
}

- (void)loadCell:(LPUserRatingTableViewCell *)cell withOfferUserData:(PFUser *)offerUser {
    cell.nameLabel.text = offerUser[@"name"];
    [cell.profileImageView sd_setImageWithURL:offerUser[@"profilePictureUrl"]];

    // FIXME implement review and change it to reflect the actual rating
    RateView *rv = [RateView rateViewWithRating:4.4f];

    rv.starFillColor = [UIColor colorWithRed:0.99 green:0.7 blue:0.16 alpha:1];
    rv.starSize = 15.0f;
    rv.starNormalColor = [UIColor lightGrayColor];
    [cell.userRateView addSubview:rv];
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
