//
//  LPImageShowcaseViewController.m
//  Lopop
//
//  Created by Troy Ling on 2/9/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "LPImageShowcaseViewController.h"

@interface LPImageShowcaseViewController ()
@end

@implementation LPImageShowcaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.imageScrollView.delegate = self;

    // label always on top
    self.indicatorLabel.layer.zPosition = MAXFLOAT;

    // add gesture to dismiss view
    [self addGestureToView];
    
    [self displayContent];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)displayContent {
    CGSize scrollViewSize = self.imageScrollView.frame.size;
    CGFloat width = scrollViewSize.width;
    CGFloat height = scrollViewSize.height;

    self.imageScrollView.pagingEnabled = YES;
    self.imageScrollView.contentSize = CGSizeMake(width * self.images.count, height);

    // add images to views
    for (NSInteger i = 0; i < self.images.count; i++) {
        UIImage *img = [self.images objectAtIndex:i];
        CGFloat ratio = img.size.width / img.size.height;
        CGFloat adjustedHeight = width * ratio;
        CGFloat offsetY = (height - adjustedHeight) * 0.5;

        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(width * i, offsetY, width, adjustedHeight)];

        // image layout
        imageView.contentMode = UIViewContentModeScaleToFill;
        imageView.clipsToBounds = YES;

        [imageView setImage:img];
        [self.imageScrollView addSubview:imageView];
    }
    
    // scroll to the designated page, if necessary
    if (self.index) {
        [self.imageScrollView scrollRectToVisible:CGRectMake(width * self.index, 0, width, height) animated:NO];
    }
    
    [self updatePageNumber];
}

- (void)updatePageNumber {
    NSInteger page = [self currentImageIndex] + 1;
    self.indicatorLabel.text = [NSString stringWithFormat:@"%ld/%ld", (long)page, (unsigned long)self.images.count];
}

- (NSInteger)currentImageIndex {
    CGFloat width = self.imageScrollView.frame.size.width;
    NSInteger page = (self.imageScrollView.contentOffset.x + (0.5f * width)) / width;
    return page;
}

# pragma mark Gesture

- (void)addGestureToView {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    [self.imageScrollView addGestureRecognizer:tap];
}

# pragma mark ScrollView

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([scrollView isEqual:self.imageScrollView]) {
       [self updatePageNumber];
    }
}

# pragma VC control

- (void)viewTapped:(UITapGestureRecognizer *)sender {
    [self dismissViewControllerAnimated:NO completion:NULL];
}

@end
