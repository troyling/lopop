//
//  PUFormValidator.m
//  Popup
//
//  Created by Troy Ling on 12/28/14.
//  Copyright (c) 2014 The Popup App. All rights reserved.
//

#import "LPFormValidator.h"

@implementation LPFormValidator

+ (BOOL)isTextfieldsFilled:(NSArray *)fields {
    for (id f in fields) {
        if ([f class] == [UITextField class]) {
            UITextField *field = (UITextField *) f;
            NSString *content = [field.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if ([content isEqualToString:@""]) {
                return false;
            }
        } else {
            NSLog(@"The given element is not a textfield");
        }
    }
    return true;
}

@end
