//
//  PUFormValidator.h
//  Popup
//
//  Helper class for form validation
//
//  Created by Troy Ling on 12/28/14.
//  Copyright (c) 2014 The Popup App. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface LPFormValidator : NSObject

+ (BOOL)isTextfieldsFilled:(NSArray *)fields;

@end
