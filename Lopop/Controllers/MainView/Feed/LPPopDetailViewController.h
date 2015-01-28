//
//  LPPopDetailViewController.h
//  Lopop
//
//  Created by Troy Ling on 1/26/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LPPop.h"

@interface LPPopDetailViewController : UIViewController

@property (strong, nonatomic) LPPop *pop;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIPageControl *imageViewPageControl;

@end
