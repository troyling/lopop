//
//  LPImageShowcaseViewController.h
//  Lopop
//
//  Created by Troy Ling on 2/9/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LPImageShowcaseViewController : UIViewController <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *imageScrollView;
@property (weak, nonatomic) IBOutlet UILabel *indicatorLabel;

@property (strong, nonatomic) NSArray *images;
@property (assign) NSUInteger index;

@end
