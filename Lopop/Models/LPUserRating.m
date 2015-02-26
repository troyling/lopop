//
//  LPRating.m
//  Lopop
//
//  Created by Troy Ling on 2/25/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "LPUserRating.h"

@implementation LPUserRating

@dynamic user;
@dynamic rater;
@dynamic offer;
@dynamic rating;
@dynamic comment;

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"UserRating";
}

@end
