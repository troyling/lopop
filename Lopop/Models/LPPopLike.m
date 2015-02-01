//
//  LPPopLike.m
//  Lopop
//
//  Created by Hongbo Fang on 1/31/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "LPPopLike.h"

@implementation LPPopLike
@dynamic pop;
@dynamic likedUser;
+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"PopLike";
}
@end
