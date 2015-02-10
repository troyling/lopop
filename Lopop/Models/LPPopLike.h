//
//  LPPopLike.h
//  Lopop
//
//  Created by Hongbo Fang on 1/31/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LPPop.h"

@interface LPPopLike : PFObject<PFSubclassing>
+ (NSString *)parseClassName;
@property LPPop *pop;
@property PFUser *likedUser;
@end
