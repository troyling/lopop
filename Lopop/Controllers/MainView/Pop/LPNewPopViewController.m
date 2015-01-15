//
//  LPNewPopViewController.m
//  Lopop
//
//  Created by Troy Ling on 1/14/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "LPNewPopViewController.h"
#import "LPDevicePermissionValidator.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface LPNewPopViewController ()

@property UIImage *image;

@end

@implementation LPNewPopViewController

- (IBAction)cancelNewPop:(id)sender {
    // TODO we might want to save the data as the user start filling in data, especially uploading pictures will be time-consuming.
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Discard the pop?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Yes"]) {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
    }
}

- (IBAction)addPhoto:(id)sender {
    if ([LPDevicePermissionValidator canAddPhoto]) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
        [self presentViewController:imagePicker animated:YES completion:NULL];
    } else {
        NSLog(@"Error");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Cannot take a picture. Please make sure you allow the Lopop to use the camera." delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = info[UIImagePickerControllerEditedImage];
    if (!image) {
        image = info[UIImagePickerControllerOriginalImage];
    }
    self.image = image;
    self.imageView.image = self.image;
    [self dismissViewControllerAnimated:YES completion:NULL];
}


@end
 