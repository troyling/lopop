//
//  LPPop.h
//  Lopop
//
//  Created by Troy Ling on 1/15/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface LPPop : PFObject<PFSubclassing>

+ (NSString *)parseClassName;

@property NSString *type;
@property NSString *description;
@property NSDate *postedDate;
@property NSMutableArray *images;
@property BOOL isSold;
@property float price;
@property PFUser *user;
// TODO add location 

@end
