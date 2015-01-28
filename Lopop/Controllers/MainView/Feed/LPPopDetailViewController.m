//
//  LPPopDetailViewController.m
//  Lopop
//
//  Created by Troy Ling on 1/26/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "LPPopDetailViewController.h"

@interface LPPopDetailViewController ()

@property (retain, nonatomic) NSMutableArray *images;
@property NSInteger currentImageIndex;

@end

@implementation LPPopDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // load image from cache or server
    [self retreveImages];
    
    self.currentImageIndex = 0;
    self.images = [[NSMutableArray alloc] init];
    self.imageViewPageControl.numberOfPages = self.pop.images.count;
    self.imageViewPageControl.currentPage = 0;
    
    // gesture
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeftToPreviousImage)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRightToNextImage)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    
    [self.imageView setUserInteractionEnabled:YES];
    [self.imageView addGestureRecognizer:swipeLeft];
    [self.imageView addGestureRecognizer:swipeRight];
}

- (void)retreveImages {
    NSArray *imageFiles = self.pop.images;
    for (PFFile *file in imageFiles) {
        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
                [self.images addObject:[UIImage imageWithData:data]];
                
                if (self.images.count == self.pop.images.count) {
                    [self showImageView];
                }
            } else {
                // FIXME with a fatal error prompt
                NSLog(@"Can't retrieve image from server");
            }
        }];
    }
}

- (void)showImageView {
    self.imageView.image = [self.images objectAtIndex:self.currentImageIndex];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)swipeLeftToPreviousImage {
    NSLog(@"left");
    if (self.pop.images.count == 1) return;
    
    if (self.currentImageIndex == self.pop.images.count - 1) {
        self.currentImageIndex = 0;
    } else {
        self.currentImageIndex++;
    }
    self.imageViewPageControl.currentPage = self.currentImageIndex;
    [self.imageView setImage:[self.images objectAtIndex:self.currentImageIndex]];
}

- (void)swipeRightToNextImage {
    NSLog(@"right");
    if (self.pop.images.count == 1) return;
    
    if (self.currentImageIndex == 0) {
        self.currentImageIndex = self.pop.images.count - 1;
    } else {
        self.currentImageIndex--;
    }
    self.imageViewPageControl.currentPage = self.currentImageIndex;
    [self.imageView setImage:[self.images objectAtIndex:self.currentImageIndex]];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
