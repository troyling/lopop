//
//  LPDevicePermissionValidator.m
//  Lopop
//
//  Created by Troy Ling on 1/14/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "LPDevicePermissionValidator.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <UIKit/UIKit.h>

@implementation LPDevicePermissionValidator

+ (BOOL)canAddPhoto {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        NSArray *availableTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
        if ([availableTypes containsObject:(NSString *)kUTTypeImage]) {
            return YES;
        }
    }
    return NO;
}

@end
