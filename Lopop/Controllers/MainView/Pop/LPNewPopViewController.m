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

@property NSMutableArray *imageFiles;
@property LPPop *pop;
@property NSArray *imageBtns;
@property UIImage *defaultBtnImage;
@property UIButton *clearImageBtn;

@end

@implementation LPNewPopViewController

float const LEAST_COMPRESSION = 1.0f;
NSString *const TAKE_PHOTO = @"Take photo";
NSString *const CHOOSE_FROM_PHOTO_LIBRARY = @"Choose from library";
NSString *const BTN_TITLE_CONFIRMATION = @"Yes";
NSString *const BTN_TITLE_DISMISS = @"Dismiss";
NSString *const BTN_TITLE_CANCEL = @"Cancel";
NSString *const BTN_TITLE_DELETE = @"Delete Image";

- (void)viewDidLoad {
    [super viewDidLoad];
    // instatiate the new pop object
    self.pop = [LPPop object];
    self.imageFiles = [[NSMutableArray alloc] init];
    self.imageBtns = @[self.imageBtn1, self.imageBtn2, self.imageBtn3, self.imageBtn4];
    self.defaultBtnImage = [self.imageBtn1 imageForState:UIControlStateNormal];
    [self setupImageButtons];
}

- (IBAction)cancelNewPop:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Discard the pop?" delegate:self cancelButtonTitle:BTN_TITLE_CANCEL otherButtonTitles:BTN_TITLE_CONFIRMATION, nil];
    [alert show];
}

- (IBAction)createPop:(id)sender {
//    self.pop.type = [self.typeTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    self.pop.description = [self.descriptionTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    self.pop.user = [PFUser currentUser];
    self.pop.images = self.imageFiles;
    [self.pop saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            // Successfully posted
            [self dismissViewControllerAnimated:YES completion:NULL];
        }   
    }];
}

- (IBAction)addPhoto:(id)sender {
    UIActionSheet *actionSheet;
    self.clearImageBtn = (UIButton *)sender;
    if ([self.clearImageBtn backgroundImageForState:UIControlStateNormal]) {
        actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:BTN_TITLE_CANCEL destructiveButtonTitle:BTN_TITLE_DELETE otherButtonTitles:nil, nil];
    } else {
        actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:BTN_TITLE_CANCEL destructiveButtonTitle:nil otherButtonTitles:nil, nil];
        [actionSheet addButtonWithTitle:TAKE_PHOTO];
        [actionSheet addButtonWithTitle:CHOOSE_FROM_PHOTO_LIBRARY];
    }
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

- (void)removeImageAtBtn:(NSUInteger)index {
    [self.imageFiles removeObjectAtIndex:index];
    [self reloadButtonImages];
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


- (void)reloadButtonImages {
    for (NSInteger i = 0; i < self.imageBtns.count; i++) {
        if (i < self.imageFiles.count) {
            UIImage *bkgImg = [UIImage imageWithData:[[self.imageFiles objectAtIndex:i] getData]];
            [[self.imageBtns objectAtIndex:i] setImage:nil forState:UIControlStateNormal];
            [[self.imageBtns objectAtIndex:i] setBackgroundImage:bkgImg forState:UIControlStateNormal];
        } else {
            [[self.imageBtns objectAtIndex:i] setImage:self.defaultBtnImage forState:UIControlStateNormal];
            [[self.imageBtns objectAtIndex:i] setBackgroundImage:nil forState:UIControlStateNormal];
        }
    }
}

- (void)setupImageButtons {
    CGColorRef lopopColor = [[UIColor colorWithRed:0.33 green:0.87 blue:0.75 alpha:1] CGColor];
    NSUInteger tag = 0;
    for (UIButton *btn in self.imageBtns) {
        btn.layer.borderColor = lopopColor;
        btn.layer.borderWidth = 1.0f;
        btn.tag = tag++;
    }
}

#pragma mark actionSheet
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.destructiveButtonIndex) {
        [self.clearImageBtn setBackgroundImage:nil forState:UIControlStateNormal];
        [self.clearImageBtn setImage:self.defaultBtnImage forState:UIControlStateNormal];
        [self removeImageAtBtn:self.clearImageBtn.tag];
    } else {
        NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
        if ([title isEqualToString:TAKE_PHOTO]) {
            [self takePicture];
        } else if ([title isEqualToString:CHOOSE_FROM_PHOTO_LIBRARY]) {
            [self chooseImages];
        }
    }
}

#pragma mark imagePickerController
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = info[UIImagePickerControllerEditedImage];
    if (!image) {
        image = info[UIImagePickerControllerOriginalImage];
    }
    NSData *imageData = UIImagePNGRepresentation(image);
    PFFile *parseImageFile = [PFFile fileWithData:imageData]; // PFFile has 10MB of size limit
    [parseImageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            // TODO stop the progress indicator and show the image in the view
            [self.imageFiles addObject:parseImageFile];
            [self reloadButtonImages];
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
