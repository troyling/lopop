//
//  LPPop.m
//  Lopop
//
//  Created by Troy Ling on 1/15/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "LPPop.h"
#import <Parse/PFObject+Subclass.h>

@implementation LPPop

@dynamic type;
@dynamic description;
@dynamic postedDate;
@dynamic images;
@dynamic isSold;
@dynamic price;
@dynamic user;

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"Pop";
}

@end
