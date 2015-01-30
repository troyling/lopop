//
//  LPUserRelationship.h
//  Lopop
//
//  Created by Troy Ling on 1/29/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface LPUserRelationship : PFObject<PFSubclassing>

+ (NSString *)parseClassName;

@property PFUser *follower;
@property PFUser *followedUser;

@end
