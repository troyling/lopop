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

@dynamic title;
@dynamic category;
@dynamic popDescription;
@dynamic seller;
@dynamic images;
@dynamic location;
@dynamic isSold;
@dynamic price;


+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"Pop";
}

@end
