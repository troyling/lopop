//
//  LPUserRatingDetailViewController.m
//  Lopop
//
//  Created by Troy Ling on 3/15/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "LPUserRatingDetailViewController.h"
#import "LPUserRatingDetailTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "LPUIHelper.h"
#import "LPUserRating.h"
#import "RateView.h"

@interface LPUserRatingDetailViewController ()

@property (retain, nonatomic) NSMutableArray *ratings;

@end

@implementation LPUserRatingDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"user: %@", self.user);
    // Do any additional setup after loading the view.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.ratings = [NSMutableArray array];

    PFQuery *query = [LPUserRating query];
    [query whereKey:@"user" equalTo:self.user];
    [query includeKey:@"rater"];
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error && objects.count != 0) {
            [self.ratings addObjectsFromArray:objects];
            self.numCommentLabel.text = [NSString stringWithFormat:@"%lu Reviews", (unsigned long)self.ratings.count];
            [self.tableView reloadData];
        }
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.ratings ? self.ratings.count : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"ratingDetailCell";
    LPUserRatingDetailTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];

    if (!cell) {
        cell = [[LPUserRatingDetailTableViewCell alloc] init];
    }
    // load data
    LPUserRating *rating = [self.ratings objectAtIndex:indexPath.row];

    [cell.profileImageView sd_setImageWithURL:rating.rater[@"profilePictureUrl"]];
    cell.nameLabel.text = rating.rater[@"name"];
    cell.timeLabel.text = @"TBD";
    cell.commentLabel.text = rating.comment;

    RateView *rv = [RateView rateViewWithRating:[rating.rating floatValue]];
    rv.starFillColor = [LPUIHelper ratingStarColor];
    rv.starBorderColor = [UIColor clearColor];
    rv.starSize = 15.0f;
    rv.starNormalColor = [UIColor lightGrayColor];
    [cell.ratingView addSubview:rv];

    return cell;
}

- (IBAction)dismiss:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
