//
//  LPNewPopViewController.m
//  Lopop
//
//  Created by Troy Ling on 1/14/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "LPNewPopViewController.h"
#import "LPPermissionValidator.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "LPPop.h"

@interface LPNewPopViewController ()

@property NSMutableArray *images;
@property LPPop *pop;

@end

@implementation LPNewPopViewController

float const LEAST_COMPRESSION = 1.0f;
NSString *const TAKE_PHOTO = @"Take photo";
NSString *const CHOOSE_FROM_PHOTO_LIBRARY = @"Choose from library";
NSString *const BTN_TITLE_CONFIRMATION = @"Yes";
NSString *const BTN_TITLE_DISMISS = @"Dismiss";
NSString *const BTN_TITLE_CANCEL = @"Cancel";

- (void)viewDidLoad {
    [super viewDidLoad];
    // instatiate the new pop object
    self.pop = [LPPop object];
    self.images = [[NSMutableArray alloc] init];
}

- (IBAction)cancelNewPop:(id)sender {
    // TODO we might want to save the data as the user start filling in data, especially uploading pictures will be time-consuming.
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Discard the pop?" delegate:self cancelButtonTitle:BTN_TITLE_CANCEL otherButtonTitles:BTN_TITLE_CONFIRMATION, nil];
    [alert show];
}

- (IBAction)createPop:(id)sender {
    self.pop.type = [self.typeTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    self.pop.description = [self.descriptionTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    self.pop.images = self.images;
    self.pop.user = [PFUser currentUser];
    [self.pop saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            // Successfully posted
            [self dismissViewControllerAnimated:YES completion:NULL];
        }   
    }];
}

- (IBAction)addPhoto:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:BTN_TITLE_CANCEL destructiveButtonTitle:nil otherButtonTitles:nil, nil];
    [actionSheet addButtonWithTitle:TAKE_PHOTO];
    [actionSheet addButtonWithTitle:CHOOSE_FROM_PHOTO_LIBRARY];
    [actionSheet showInView:self.view];
}

- (void)takePicture {
    if ([LPPermissionValidator isCameraAccessible]) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
        imagePicker.allowsEditing = YES;
        [self presentViewController:imagePicker animated:YES completion:NULL];
    } else {
        // TODO changed it to add a button to access the system settings
        [self fatalError:@"Unable to take picture. Please allow camera permission in settings"];
    }
}

- (void)chooseImages {
    if ([LPPermissionValidator isPhotoLibraryAccessible]) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
        imagePicker.allowsEditing = YES;
        [self presentViewController:imagePicker animated:YES completion:NULL];
    } else {
        [self fatalError:@"Unable to choose picture. Please allow photo library access permission in settings"];
    }
}

#pragma mark actionSheet
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([title isEqualToString:TAKE_PHOTO]) {
        [self takePicture];
    } else if ([title isEqualToString:CHOOSE_FROM_PHOTO_LIBRARY]) {
        [self chooseImages];
    }
}

#pragma mark imagePickerController
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = info[UIImagePickerControllerEditedImage];
    if (!image) {
        image = info[UIImagePickerControllerOriginalImage];
    }
    NSData *imageData = UIImageJPEGRepresentation(image, LEAST_COMPRESSION);
    PFFile *parseImage = [PFFile fileWithData:imageData]; // PFFile has 10MB of size limit
    [parseImage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            // TODO stop the progress indicator and show the image in the view
            [self.images addObject:parseImage];
            self.imageView.image = image;
        } else {
            [self fatalError:[error localizedDescription]];
        }
    }];
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark alertView
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:BTN_TITLE_CONFIRMATION]) {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
    }
}

// TODO make this global
- (void)fatalError:(NSString *)errorMsg {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:errorMsg delegate:nil cancelButtonTitle:BTN_TITLE_DISMISS otherButtonTitles:nil, nil];
    [alert show];
}

@end
