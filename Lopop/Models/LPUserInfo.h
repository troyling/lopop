//
//  LPUserInfo.h
//  Lopop
//
//  Created by Troy Ling on 3/1/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import <Parse/Parse.h>

@interface LPUserInfo : PFObject <PFSubclassing>

+ (NSString *)parseClassName;

@property PFUser *user;
@property NSNumber *rating;
@property NSString *gender;
@property NSString *locale;
@property PFGeoPoint *location;

@end
