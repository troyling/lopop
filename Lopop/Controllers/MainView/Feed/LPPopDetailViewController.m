//
//  LPPopDetailViewController.m
//  Lopop
//
//  Created by Troy Ling on 1/26/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "LPPopDetailViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface LPPopDetailViewController ()

@property (retain, nonatomic) NSMutableArray *images;
@property (retain, nonatomic) NSMutableArray *imageViews;
@property NSUInteger numImages;

@end

@implementation LPPopDetailViewController

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
                NSLog(@"Can't retrieve image from server");
            }
        }];
    }
}

#pragma mark scrollView
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // remove top offset
    [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, 0.0f)];
    CGFloat width = scrollView.frame.size.width;
    NSInteger page = (scrollView.contentOffset.x + (0.5f * width)) / width + 1;
    self.numPhotoLabel.text = [NSString stringWithFormat:@"Photo %ld/%ld", (long)page, self.numImages];
}

@end

