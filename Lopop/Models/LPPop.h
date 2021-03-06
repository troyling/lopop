//
//  LPPop.h
//  Lopop
//
//  Created by Troy Ling on 1/15/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

typedef enum {
    kPopCreated = 0,
    kPopOfferConfirmed,
    kPopcompleted
} LPPopStatus;

@interface LPPop : PFObject<PFSubclassing>

+ (NSString *)parseClassName;

@property NSString *title;
@property NSString *category;
@property NSString *popDescription;
@property PFUser *seller;
@property NSMutableArray *images; //
@property PFGeoPoint *location;
@property LPPopStatus status;
@property NSNumber *price;

- (NSString *)publicLink;
- (NSString *)shareMsg;
- (NSString *)publicPriceStr;

@end
