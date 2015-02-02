//
//  LPPopDetailViewController.m
//  Lopop
//
//  Created by Troy Ling on 1/26/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "LPPopDetailTableViewController.h"
#import "LPUserProfileViewController.h"
#import "LPAlertViewHelper.h"
#import <QuartzCore/QuartzCore.h>

@interface LPPopDetailTableViewController ()

@property (retain, nonatomic) NSMutableArray *images;
@property (retain, nonatomic) NSMutableArray *imageViews;
@property NSUInteger numImages;

@end

@implementation LPPopDetailTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // delegate
    self.imageScrollView.delegate = self;
    
    // load image from cache or server
    [self retreveImages];
    
    self.images = [[NSMutableArray alloc] init];
    self.numImages = self.pop.images.count;
    
    // photo number label
    self.numPhotoView.layer.cornerRadius = 5.0f;
    self.numPhotoView.layer.zPosition = MAXFLOAT; // always on top
    self.numPhotoView.hidden = YES;
    
    // labels
    self.distanceLabel.text = self.distanceText;
    self.priceLabel.text = self.priceText;
    self.descriptionLabel.text = self.pop.popDescription;
    
    // TODO DELETEME!
    [self.pop.seller fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error) {
            [self.profileBtn setTitle:self.pop.seller.email forState:UIControlStateNormal];
        }
    }];
}

- (void)loadImageViews {
    // update photo display
    self.numPhotoView.hidden = NO;
    self.numPhotoLabel.text = [NSString stringWithFormat:@"Photo %d/%ld", 1, self.numImages];
    
    // init scroll view for displaying images
    self.imageScrollView.pagingEnabled = YES;
    
    CGSize scrollViewSize = self.imageScrollView.frame.size;
    CGFloat imageViewWidth = scrollViewSize.width;
    CGFloat imageViewHeight = scrollViewSize.height;
    self.imageScrollView.contentSize = CGSizeMake(imageViewWidth * self.numImages, imageViewHeight);
  
    // add image to views
    self.imageViews = [[NSMutableArray alloc] init];
    
    for (NSInteger i = 0; i < self.numImages; i++) {
        CGFloat horizontalOffset = imageViewWidth * i;
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(horizontalOffset, 0, imageViewWidth, imageViewHeight)];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, imageViewWidth, imageViewHeight)];
        [imageView setImage:[self.images objectAtIndex:i]];
        [view addSubview:imageView];
        [self.imageScrollView addSubview:view];
    }
}

- (void)retreveImages {
    NSArray *imageFiles = self.pop.images;
    for (PFFile *file in imageFiles) {
        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
                [self.images addObject:[UIImage imageWithData:data]];
                
                if (self.images.count == self.pop.images.count) {
                    [self loadImageViews];
                }
            } else {
                // FIXME with a fatal error prompt
                [LPAlertViewHelper fatalErrorAlert:@"Unable to load images from server"];
            }
        }];
    }
}

#pragma mark scrollView
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // remove top offset
    [self.imageScrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, 0.0f)];
    CGFloat width = scrollView.frame.size.width;
    NSInteger page = (scrollView.contentOffset.x + (0.5f * width)) / width + 1;
    self.numPhotoLabel.text = [NSString stringWithFormat:@"Photo %ld/%ld", (long)page, self.numImages];
}

- (IBAction)viewSellerProfile:(id)sender {
    LPUserProfileViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"LPUserProfileViewController"];
    // TODO check if the seller is the currentUser
    vc.targetUser = self.pop.seller;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark TableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat retval = 0.0f;
    CGRect bound = [[UIScreen mainScreen] bounds];
    CGFloat height = bound.size.width * 0.8;
    
    switch (indexPath.row) {
        case 0:
            retval = 50.0f;
            break;
            
        case 1:
            retval = height;
            break;
            
        case 2:
            retval = 100.0f;
            break;
        default:
            break;
    }
    return retval;
}

@end

