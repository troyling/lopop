//
//  LPRating.h
//  Lopop
//
//  Created by Troy Ling on 2/25/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import <Parse/Parse.h>
#import "LPOffer.h"

@interface LPUserRating : PFObject<PFSubclassing>

+ (NSString *)parseClassName;

@property PFUser *user;
@property PFUser *rater;
@property LPOffer *offer;
@property NSNumber *rating;
@property NSString *comment;

@end
