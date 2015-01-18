//
//  LPDevicePermissionValidator.m
//  Lopop
//
//  Created by Troy Ling on 1/14/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "LPPermissionValidator.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <UIKit/UIKit.h>

@implementation LPPermissionValidator

+ (BOOL)isCameraAuthorized {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    return status != AVAuthorizationStatusDenied && status != AVAuthorizationStatusRestricted;
}

+ (BOOL)canCameraTakeImage {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        NSArray *availableTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
        if ([availableTypes containsObject:(NSString *)kUTTypeImage]) {
            return YES;
        }
    }
    return NO;
}

+ (BOOL)isCameraAccessible {
    return [self isCameraAuthorized] && [self canCameraTakeImage];
}

+ (BOOL)isPhotoLibraryAccessible {
    ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
    return status != ALAuthorizationStatusDenied && status != ALAuthorizationStatusRestricted;
}

+ (BOOL)isLocationServiceAvailable {
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    return status != kCLAuthorizationStatusDenied && status != kCLAuthorizationStatusRestricted;
}

@end
