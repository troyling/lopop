//
//  LPOffer.m
//  Lopop
//
//  Created by Troy Ling on 2/9/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "LPOffer.h"
#import <Parse/PFObject+Subclass.h>

@implementation LPOffer

@dynamic pop;
@dynamic fromUser;
@dynamic greeting;
@dynamic meetUplocation;
@dynamic meetUpTime;
@dynamic status;

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"Offer";
}

@end
