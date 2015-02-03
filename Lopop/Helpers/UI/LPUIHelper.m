//
//  LPUIHelper.m
//  Lopop
//
//  Created by Troy Ling on 1/29/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "LPUIHelper.h"

@implementation LPUIHelper

+ (UIColor *)lopopColor {
    return [UIColor colorWithRed:0.33 green:0.87 blue:0.75 alpha:1];
}

+ (CGFloat)screenWidth {
    CGRect bounds = [[UIScreen mainScreen] bounds];
    return bounds.size.width;
}

+ (UIImage *)convertViewToImage:(UIView *)view {
    UIGraphicsBeginImageContext(view.bounds.size);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

+ (CGFloat)heightOfText:(NSString *)textStr forLabel:(UILabel *)label {
    UILabel *gettingSizeLabel = [[UILabel alloc] init];
    gettingSizeLabel.font = label.font;
    gettingSizeLabel.text = textStr;
    gettingSizeLabel.numberOfLines = 0;
    gettingSizeLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    CGSize maximumLabelSize = CGSizeMake(label.frame.size.width, 9999);
    CGSize expectSize = [gettingSizeLabel sizeThatFits:maximumLabelSize];
    return expectSize.height;
}

@end
