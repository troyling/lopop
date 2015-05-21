//
//  LPMeetUpTableViewController.m
//  Lopop
//
//  Created by Troy Ling on 5/14/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "LPMeetUpTableViewController.h"
#import "LPMessageViewController.h"
#import "LPMeetUpTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "LPLocationHelper.h"
#import "LPUIHelper.h"
#import "LPOffer.h"
#import "LPPop.h"

@interface LPMeetUpTableViewController ()

@property (strong, nonatomic) NSMutableArray *offers;
@property (strong, nonatomic) NSMutableSet *notifiedOfferIds;

@end

@implementation LPMeetUpTableViewController

static int TWO_HOURS_IN_SEC = 7200;

- (void)viewDidLoad {
    [super viewDidLoad];

    // find all scheduled offer ids
    self.notifiedOfferIds = [[NSMutableSet alloc] init];
    [self mapScheduledNotificaiton];

    NSLog(@"Notification %@", self.notifiedOfferIds);

    self.tableView.rowHeight = 245.0f;

    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];

    [self loadData];
}

- (void)loadData {
    self.offers = [[NSMutableArray alloc] init];

    // two types of meetups here
    // my selling meetup
    LPOfferStatus status = kOfferMeetUpAccepted;

    PFQuery *myListingQuery = [LPPop query];
    [myListingQuery whereKey:@"seller" equalTo:[PFUser currentUser]];

    PFQuery *incomingOfferQuery = [LPOffer query];
    [incomingOfferQuery whereKey:@"status" equalTo:[NSNumber numberWithInt:status]];
    [incomingOfferQuery whereKey:@"pop" matchesQuery:myListingQuery];

    // my buying meetup
    PFQuery *myOfferQuery = [LPOffer query];
    [myOfferQuery whereKey:@"fromUser" equalTo:[PFUser currentUser]];
    [myOfferQuery whereKey:@"status" equalTo:[NSNumber numberWithInt:status]];

    // compound query
    PFQuery *offerQuery = [PFQuery orQueryWithSubqueries:@[incomingOfferQuery, myOfferQuery]];
    [offerQuery includeKey:@"fromUser"];
    [offerQuery includeKey:@"pop"];
    [offerQuery orderByDescending:@"meetUpTime"];
    [offerQuery findObjectsInBackgroundWithBlock:^(NSArray *offers, NSError *error) {
        if (!error) {
            [self.offers addObjectsFromArray:offers];
            [self.tableView reloadData];
        } else {
            NSLog(@"%@", error);
        }
    }];
}

- (void)mapScheduledNotificaiton {
    NSArray *notifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    for (UILocalNotification *n in notifications) {
        NSString *offerObjectId = n.userInfo[@"offerObjectId"];
        if (offerObjectId != nil) {
            [self.notifiedOfferIds addObject:offerObjectId];
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.offers == nil ? 0 : self.offers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    NSString *identifier = @"meetUpCell";
    LPMeetUpTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];

    if (!cell) {
        cell = [[LPMeetUpTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }

    LPOffer *offer = [self.offers objectAtIndex:indexPath.row];

    // Time
    NSTimeZone *timeZoneLocal = [NSTimeZone localTimeZone];
    NSDateFormatter *outputDateFormatter = [[NSDateFormatter alloc] init];
    [outputDateFormatter setTimeZone:timeZoneLocal];
    [outputDateFormatter setDateFormat:@"EEE, MMM d, h:mm a"];
    NSString *outputString = [outputDateFormatter stringFromDate:offer.meetUpTime];
    [cell.timeLabel setText:outputString];

    // location
    [LPLocationHelper getAddressForGeoPoint:offer.meetUpLocation withBlock: ^(NSString *address, NSError *error) {
        if (!error) {
            [cell.locationLabel setText:address];
        }
    }];

    // user
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser != nil && [offer.fromUser.objectId isEqualToString:currentUser.objectId]) {
        // Buying items - display the seller's profile picture
        PFUser *seller = offer.pop.seller;
        if ([seller isDataAvailable]) {
            [cell.profileImgView sd_setImageWithURL:seller[@"profilePictureUrl"]];
            cell.nameLabel.text = seller[@"name"];
        } else {
            [seller fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                if (!error) {
                    [cell.profileImgView sd_setImageWithURL:seller[@"profilePictureUrl"]];
                    cell.nameLabel.text = seller[@"name"];
                }
            }];
        }

        // load buy banner
        cell.bannerLabel.backgroundColor = [LPUIHelper lopopColor];
        cell.bannerLabel.text = @"   Buying";
    } else {
        [cell.profileImgView sd_setImageWithURL:offer.fromUser[@"profilePictureUrl"]];
        cell.nameLabel.text = offer.fromUser[@"name"];

        // load sell banner
        cell.bannerLabel.backgroundColor = [LPUIHelper ratingStarColor];
        cell.bannerLabel.text = @"   Selling";
    }
    // pop info
    cell.popTitleLabel.text = offer.pop.title;

    [self setBtnLayoutForCell:cell withOffer:offer];
    [cell.remindButton addTarget:self action:@selector(toggleMeetUpReminder:) forControlEvents:UIControlEventTouchUpInside];
    [cell.contactButton addTarget:self action:@selector(contactUser:) forControlEvents:UIControlEventTouchUpInside];

    // add fading effect for expired meetups
    cell.contentView.alpha = [offer.meetUpTime timeIntervalSinceNow] > 0 ? 1.0f : 0.4f;

    return cell;
}

#pragma mark ButtonActions

- (IBAction)toggleMeetUpReminder:(id)sender {
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *remindBtn = (UIButton *)sender;
        if ([[[remindBtn superview] superview] isKindOfClass:[LPMeetUpTableViewCell class]]) {
            // find offer based on button's position
            LPMeetUpTableViewCell *cell = (LPMeetUpTableViewCell *)[[remindBtn superview] superview];
            NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
            LPOffer *offer = [self.offers objectAtIndex:indexPath.row];


            if ([self.notifiedOfferIds containsObject:offer.objectId]) {
                NSArray *ns = [[UIApplication sharedApplication] scheduledLocalNotifications];

                NSLog(@"%@", ns);
                for (UILocalNotification *n in ns) {
                    NSString *offerObjectId = n.userInfo[@"offerObjectId"];
                    if (offerObjectId != nil && [self.notifiedOfferIds containsObject:offerObjectId]) {
                        [[UIApplication sharedApplication] cancelLocalNotification:n];
                    }
                }

                NSLog(@"%@", [[UIApplication sharedApplication] scheduledLocalNotifications]);
                [self.notifiedOfferIds removeObject:offer.objectId];
            } else {
                // schedule local notification
                NSTimeInterval timeInterval = [offer.meetUpTime timeIntervalSinceNow] - TWO_HOURS_IN_SEC;;

                if (timeInterval > 0) {
                    NSString *alertMsg = [NSString stringWithFormat:@"You will be meeting with %@ in two hours", offer.fromUser[@"name"]];
                    NSDate *fireDate = [NSDate dateWithTimeIntervalSinceNow:timeInterval];

                    UILocalNotification *notification = [[UILocalNotification alloc] init];
                    notification.fireDate = fireDate;
                    notification.alertBody = alertMsg;
                    notification.userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:offer.objectId, @"offerObjectId", nil];

                    NSMutableArray *notifications = [NSMutableArray arrayWithArray:[[UIApplication sharedApplication] scheduledLocalNotifications]];
                    [notifications addObject:notification];
                    [[UIApplication sharedApplication] setScheduledLocalNotifications:notifications];

                    [self.notifiedOfferIds addObject:offer.objectId];
                } else {
                    NSLog(@"unable to schedule");
                }
            }

            [self setBtnLayoutForCell:cell withOffer:offer];
        }
    }
}

- (IBAction)contactUser:(id)sender {
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *remindBtn = (UIButton *)sender;
        if ([[[remindBtn superview] superview] isKindOfClass:[LPMeetUpTableViewCell class]]) {
            // find offer based on button's position
            LPMeetUpTableViewCell *cell = (LPMeetUpTableViewCell *)[[remindBtn superview] superview];
            NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
            LPOffer *offer = [self.offers objectAtIndex:indexPath.row];

            PFUser *currentUser = [PFUser currentUser];

            LPMessageViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"chatViewController"];
            vc.offerUser = (currentUser != nil && [offer.fromUser.objectId isEqualToString:currentUser.objectId]) ? offer.pop.seller : offer.fromUser;
            [self showViewController:vc sender:self];
        }
    }
}

#pragma mark UI helper

- (void)setBtnLayoutForCell:(LPMeetUpTableViewCell *)cell withOffer:(LPOffer *)offer {
    if ([self.notifiedOfferIds containsObject:offer.objectId]) {
        // notification is already scheduled
        [cell.remindButton setImage:[UIImage imageNamed:@"icon_reminder_added"] forState:UIControlStateNormal];
        cell.reminderLabel.hidden = NO;
    } else {
        [cell.remindButton setImage:[UIImage imageNamed:@"icon_reminder_add"] forState:UIControlStateNormal];
        cell.reminderLabel.hidden = YES;
    }
}

@end
