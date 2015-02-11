//
//  LPListingTableViewController.m
//  Lopop
//
//  Created by Troy Ling on 2/10/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "LPListingTableViewController.h"
#import "LPPop.h"
#import "LPOffer.h"

@interface LPListingTableViewController ()

@property (strong, nonatomic) NSMutableArray *listings;
@property (strong, nonatomic) NSMutableArray *offerredPops;
@property (assign) LPDisplayState displayState;

@end

@implementation LPListingTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.displayState = LPListingDisplay;
    [self loadData];
}

- (void)loadData {
    // populate data for user

    PFQuery *listingQuery = [LPPop query];
    [listingQuery whereKey:@"seller" equalTo:[PFUser currentUser]];
    [listingQuery orderByDescending:@"createdAt"];
    [listingQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            self.listings = [[NSMutableArray alloc] initWithArray:objects];
            [self.tableView reloadData];
        }
    }];

    self.offerredPops = [[NSMutableArray alloc] init];
    PFQuery *offerQuery = [LPOffer query];
    [offerQuery whereKey:@"fromUser" equalTo:[PFUser currentUser]];
    [offerQuery includeKey:@"pop"];
    [offerQuery orderByDescending:@"createdAt"];
    [offerQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            for(id o in objects) {
                if ([o isKindOfClass:[LPOffer class]]) {
                    LPOffer *offer = o;
                    [self.offerredPops addObject:offer.pop];
                }
            }
        }
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rows;

    switch (self.displayState) {
        case LPListingDisplay:
            rows = self.listings == nil ? 0 : self.listings.count;
            break;
        case LPOfferDisplay:
            rows = self.offerredPops == nil ? 0 : self.offerredPops.count;
            break;
        default:
            rows = 0;
            break;
    }

    return rows;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"listingCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];

    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }

    LPPop *pop = self.displayState == LPListingDisplay ? [self.listings objectAtIndex:indexPath.row] : [self.offerredPops objectAtIndex:indexPath.row];

    cell.textLabel.text = pop.title;

    PFFile *file = pop.images.firstObject;
    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
            UIImage *img = [UIImage imageWithData:data];
            cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
            cell.imageView.image = img;
            cell.imageView.clipsToBounds = YES;
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)viewSelected:(id)sender {
    switch(self.segmentedControl.selectedSegmentIndex) {
        case 0:
            // Listing view
            if (self.displayState == LPOfferDisplay) {
                self.displayState = LPListingDisplay;
                [self.tableView reloadData];
            } else {
                self.displayState = LPListingDisplay;
            }

            break;
        case 1:
            // offer view
            if (self.displayState == LPListingDisplay) {
                self.displayState = LPOfferDisplay;
                [self.tableView reloadData];
            } else {
                self.displayState = LPOfferDisplay;
            }

            break;
        default:
            break;
    }
}

@end

