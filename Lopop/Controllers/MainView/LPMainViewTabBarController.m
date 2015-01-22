//
//  LPMainViewTabBarController.m
//  Lopop
//
//  Created by Troy Ling on 1/13/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "LPMainViewTabBarController.h"
#import "LPNewPopTableViewController.h"

@implementation LPMainViewTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addNewPopBtnToTabBar];
}

- (void)addNewPopBtnToTabBar {
    float tabWidth = self.tabBar.layer.bounds.size.width / 5.0;
    float tabHeight = self.self.tabBar.layer.bounds.size.height;
    
    UIColor *appColor = [UIColor colorWithRed:0.33 green:0.87 blue:0.75 alpha:1];
    UIImage *btnImage = [UIImage imageNamed:@"plus-32.png"];
    
    float verticalInset = (tabHeight - btnImage.size.height) / 2;
    float horizontalInset = (tabWidth - btnImage.size.width) / 2;
    
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0.0, 0.0, tabWidth, tabHeight);

    [button setImage:btnImage forState:UIControlStateNormal];
    [button setBackgroundColor:appColor];
    [button setImageEdgeInsets:UIEdgeInsetsMake(verticalInset, horizontalInset, verticalInset, horizontalInset)];
    
    // shift button if necessary
    CGFloat heightDifference = btnImage.size.height - tabHeight;
    if (heightDifference < 0) {
        button.center = self.tabBar.center;
    } else {
        CGPoint center = self.tabBar.center;
        center.y = center.y - heightDifference/2.0;
        button.center = center;
    }
    [self.view addSubview:button];
    
    // connect new pop action
    [button addTarget:self
               action:@selector(presentNewPop)
     forControlEvents:UIControlEventTouchUpInside];
}


- (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, self.tabBar.layer.bounds.size.width, self.tabBar.layer.bounds.size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}


- (void)presentNewPop {
    UIStoryboard *sb = [self storyboard];
    LPNewPopTableViewController *vc = [sb instantiateViewControllerWithIdentifier:@"LPNewPopViewController"];
    [self presentViewController:vc animated:YES completion:NULL];
}

@end
