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

typedef enum {
    kOfferPending = 0,      // offer is sent by buyer
    kOfferMeetUpProposed,   // meetup is proposed by seller
    kOfferMeetUpAccepted,   // meetup is confirmed by buyer
    kOfferNotAccepted,      // offer is not accepted since seller decides to go with other offer
    kOfferDeclined,         // offer is declined by seller
    kOfferCompleted         // offer is finished
} LPOfferStatus;

@interface LPOffer : PFObject<PFSubclassing>

@property LPPop *pop;
@property PFUser *fromUser;
@property NSString *greeting;
@property PFGeoPoint *meetUpLocation;
@property NSDate *meetUpTime; // UTC timezone
@property LPOfferStatus status;

@end
