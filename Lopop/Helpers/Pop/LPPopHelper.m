//
//  LPPopHelper.m
//  Lopop
//
//  Created by Troy Ling on 2/16/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "LPPopHelper.h"
#import <Parse/Parse.h>
#import "LPOffer.h"

@implementation LPPopHelper

+ (void)countOffersToPop:(LPPop *)pop inBackgroundWithBlock:(void (^)(int count, NSError *error))completionBlock {
    PFQuery *countQuery = [LPOffer query];
    [countQuery whereKey:@"pop" equalTo:pop];
    [countQuery countObjectsInBackgroundWithBlock:^(int count, NSError *error) {
        if (completionBlock) {
            completionBlock(count, nil);
        }
    }];
}

@end
