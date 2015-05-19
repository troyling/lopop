//
//  LPInfoDisplayViewController.h
//  Lopop
//
//  Created by Troy Ling on 5/19/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    kTerms = 1,
    kPrivacy,
    kFaq
} LPInfoDisplayType;

@interface LPInfoDisplayViewController : UIViewController

@property (assign, nonatomic) LPInfoDisplayType type;

@end
