//
//  LPPopHelper.m
//  Lopop
//
//  Created by Troy Ling on 2/16/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "LPPopHelper.h"
#import <Parse/Parse.h>
#import "LPPopInfo.h"
#import "LPOffer.h"

@implementation LPPopHelper

+ (void)countOffersToPop:(LPPop *)pop inBackgroundWithBlock:(void (^)(int count, NSError *error))completionBlock {
    PFQuery *countQuery = [LPOffer query];
    [countQuery whereKey:@"pop" equalTo:pop];
    [countQuery countObjectsInBackgroundWithBlock: ^(int count, NSError *error) {
        if (completionBlock) {
            completionBlock(count, nil);
        }
    }];
}

+ (void)incrementNumViewsInBackgroundForPop:(LPPop *)pop {
    PFQuery *query = [LPPopInfo query];
    [query whereKey:@"pop" equalTo:pop];
    [query findObjectsInBackgroundWithBlock: ^(NSArray *objects, NSError *error) {
        if (!error) {
            if (objects.count == 1) {
                LPPopInfo *popInfo = objects.firstObject;
                NSInteger newCount = popInfo.numViews.intValue + 1;
                popInfo.numViews = [NSNumber numberWithInteger:newCount];
                if ([PFUser currentUser]) {
                    [popInfo.viewedUsers addObject:[PFUser currentUser]];
                }
                [popInfo saveEventually];
            }
            else if (objects.count == 0) {
                // Create a new pop info
                LPPopInfo *popInfo = [LPPopInfo object];
                popInfo.pop = pop;
                popInfo.numViews = [NSNumber numberWithInt:1];
                if ([PFUser currentUser]) {
                    [popInfo.viewedUsers addObject:[PFUser currentUser]];
                }
                [popInfo saveEventually];
            }
            else {
                // ERROR
                NSLog(@"ERROR: More than one popinfo for a pop");
            }
        }
        else {
            // Error
            NSLog(@"ERROR connecting the DB");
        }
    }];
}

@end
