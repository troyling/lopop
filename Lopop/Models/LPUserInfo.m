//
//  LPUserInfo.m
//  Lopop
//
//  Created by Troy Ling on 3/1/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "LPUserInfo.h"

@implementation LPUserInfo

@dynamic user;
@dynamic totalRating;
@dynamic numRating;
@dynamic gender;
@dynamic locale;
@dynamic location;

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"UserInfo";
}

- (float)userAvgRating {
    if (!(self.numRating && self.totalRating)) [self fetch];

    float avgRating = 0.0f;
    if (!(self.numRating == 0 || self.totalRating == 0)) {
        avgRating = [self.totalRating floatValue] / [self.numRating floatValue];
    }
    return avgRating;
}

@end
