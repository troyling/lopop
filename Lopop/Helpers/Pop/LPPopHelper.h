//
//  LPPopHelper.h
//  Lopop
//
//  Created by Troy Ling on 2/16/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LPPop.h"

@interface LPPopHelper : NSObject

+ (void)countOffersToPop:(LPPop *)pop inBackgroundWithBlock:(void (^)(int count, NSError *error))completionBlock;

@end
