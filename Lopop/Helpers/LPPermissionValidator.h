//
//  LPDevicePermissionValidator.h
//  Lopop
//
//  Created by Troy Ling on 1/14/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LPPermissionValidator : NSObject

+ (BOOL)isCameraAuthroized;
+ (BOOL)isCameraAvailable;
+ (BOOL)isCameraAccessible;
+ (BOOL)isLocationServiceAvailable;
+ (BOOL)isPhotoLibraryAccessible;

@end
