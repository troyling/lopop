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
    // TODO detection needs to be changed
    if ([LPDevicePermissionValidator canAddPhoto]) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:nil, nil];
        [actionSheet addButtonWithTitle:@"Take photo"];
        [actionSheet addButtonWithTitle:@"Choose from library"];
        [actionSheet showInView:self.view];
    } else {
        NSLog(@"Error");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Cannot take a picture. Please make sure you allow the Lopop to use the camera." delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([title isEqualToString:@"Take photo"]) {
        [self _takePicture];
    } else if ([title isEqualToString:@"Choose from library"]) {
        [self _chooseImages];
    }
}

- (void)_takePicture {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
    imagePicker.allowsEditing = YES;
    [self presentViewController:imagePicker animated:YES completion:NULL];
}

- (void)_chooseImages {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
//    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
    imagePicker.allowsEditing = YES;
    [self presentViewController:imagePicker animated:YES completion:NULL];
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
 