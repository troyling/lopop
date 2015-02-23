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
@dynamic status;
@dynamic price;


+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"Pop";
}

- (NSString *)publicLink {
    // TODO fix the link
    //    NSString *linkStr = [NSString stringWithFormat:@"https://lopopapp/pop/%@", pop.objectId];
    NSString *linkStr = [NSString stringWithFormat:@"https://www.crunchbase.com/organization/lopop"];
    return linkStr;
}

- (NSString *)shareMsg {
    if (self.title == nil || self.popDescription == nil) {
        [self fetch];
    }

    NSString *shareMsg = [NSString stringWithFormat:@"Check out this Pop:\n\n%@ \n %@ \n\n %@",
                          self.title,
                          self.popDescription,
                          [self publicLink]];
    return shareMsg;
}

- (NSString *)publicPriceStr {
    if (self.price == nil) {
        [self fetch];
    }

    return [self.price isEqualToNumber:[NSNumber numberWithInt:0]] ? @"  Free!  " : [NSString stringWithFormat:@"  $%@  ", self.price];
}

@end
