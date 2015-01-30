//
//  LPUserRelationship.m
//  Lopop
//
//  Created by Troy Ling on 1/29/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "LPUserRelationship.h"

@implementation LPUserRelationship

@dynamic follower;
@dynamic followedUser;

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"UserRelationship";
}

@end
