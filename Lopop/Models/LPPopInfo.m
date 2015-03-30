//
//  LPPopInfo.m
//  Lopop
//
//  Created by Troy Ling on 3/30/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "LPPopInfo.h"

@implementation LPPopInfo

@dynamic numViews;
@dynamic pop;
@dynamic viewedUsers;

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"PopInfo";
}

@end
