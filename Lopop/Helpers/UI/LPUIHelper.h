//
//  LPUIHelper.h
//  Lopop
//
//  Created by Troy Ling on 1/29/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface LPUIHelper : NSObject

+ (UIColor *)lopopColor;
+ (UIColor *)lopopColorWithAlpha:(double)alpha;
+ (UIColor *)infoColor;
+ (UIColor *)ratingStarColor;
+ (UIImage *)convertViewToImage:(UIView *)view;
+ (CGFloat)heightOfText:(NSString *)textStr forLabel:(UILabel *)label;
+ (CGFloat)screenWidth;

@end
