//
//  LPOffer.h
//  Lopop
//
//  Created by Troy Ling on 2/9/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "LPPop.h"

@interface LPOffer : PFObject<PFSubclassing>

@property LPPop *pop;
@property PFUser *fromUser;

@end
