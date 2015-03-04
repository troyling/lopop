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

@end
