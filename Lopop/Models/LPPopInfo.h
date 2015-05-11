//
//  LPPopInfo.h
//  Lopop
//
//  Created by Troy Ling on 3/30/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "LPPop.h"

@interface LPPopInfo : PFObject<PFSubclassing>

+ (NSString *)parseClassName;

@property LPPop *pop;
@property NSNumber *numViews;
@property PFRelation *viewedUsers;

@end
