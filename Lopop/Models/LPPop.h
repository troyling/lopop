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

@property NSString *title;
@property NSString *category;
@property NSString *description;
@property PFUser *seller;
@property NSMutableArray *images;
@property PFGeoPoint *location;
@property BOOL isSold;
@property NSNumber *price;
// TODO add location 

@end
