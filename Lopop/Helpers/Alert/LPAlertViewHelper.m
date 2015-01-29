//
//  LPAlertViewHelper.m
//  Lopop
//
//  Created by Troy Ling on 1/29/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "LPAlertViewHelper.h"

@implementation LPAlertViewHelper

+ (void)fatalErrorAlert:(NSString *)errorMsg {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:errorMsg delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil];
    [alert show];
}

@end
