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
#import "LPPop.h"

@interface LPNewPopViewController ()
@property NSMutableArray *images;
@property LPPop *pop;
@end

@implementation LPNewPopViewController
float const LEAST_COMPRESSION = 1.0f;

- (void)viewDidLoad {
    [super viewDidLoad];
    // instatiate the new pop object
    self.pop = [LPPop object];
    self.images = [[NSMutableArray alloc] init];
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
    imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
    imagePicker.allowsEditing = YES;
    [self presentViewController:imagePicker animated:YES completion:NULL];
}

- (IBAction)cancelNewPop:(id)sender {
    // TODO we might want to save the data as the user start filling in data, especially uploading pictures will be time-consuming.
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Discard the pop?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
    [alert show];
}

- (IBAction)createPop:(id)sender {
    self.pop.type = [self.typeTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    self.pop.description = [self.descriptionTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    // image needs to be saved when the user start populating the image
    self.pop.images = self.images;
//    self.pop[@"image"] = self.images.firstObject;
    self.pop.user = [PFUser currentUser];
    [self.pop saveInBackground];
}

- (IBAction)addPhoto:(id)sender {
    // TODO detection needs to be changed to account for access to the photo library
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

#pragma mark actionSheet
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([title isEqualToString:@"Take photo"]) {
        [self _takePicture];
    } else if ([title isEqualToString:@"Choose from library"]) {
        [self _chooseImages];
    }
}

#pragma mark imagePickerController
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = info[UIImagePickerControllerEditedImage];
    if (!image) {
        image = info[UIImagePickerControllerOriginalImage];
    }
    // save the image to server in background
    NSData *imageData = UIImageJPEGRepresentation(image, LEAST_COMPRESSION);
    
    // PFFile has 10MB of size limit
    PFFile *parseImage = [PFFile fileWithData:imageData];
    [parseImage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!succeeded) {
            [self _fatalError:[error localizedDescription]];
        } else {
            // stop the progress indicator and show the image in the view
            [self.images addObject:parseImage];
            self.imageView.image = image;
        }
    }];
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark alertView
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Yes"]) {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
    }
}

// make this global
- (void)_fatalError:(NSString *)errorMsg {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:errorMsg delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil];
    [alert show];
}

@end
 