//
//  LPNewPopViewController.m
//  Lopop
//
//  Created by Troy Ling on 1/14/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "LPNewPopTableViewController.h"
#import "LPPopCategoryTableViewController.h"
#import "LPPermissionValidator.h"
#import "LPAlertViewHelper.h"
#import "LPUIHelper.h"
#import "CRToast.h"
#import "LPPop.h"

@interface LPNewPopTableViewController ()

@property CLLocationManager *locationManager;
@property NSMutableArray *imageFiles;
@property NSArray *imageBtns;
@property UIImage *defaultBtnImage;
@property UIButton *clearImageBtn;
@property PFGeoPoint *popLocation;
@property NSInteger savedImages;

@end

@implementation LPNewPopTableViewController

float const COMPRESSION_QUALITY = 0.3f;
double const MAP_ZOO_IN_DEGREE = 0.005f;
NSString *const TAKE_PHOTO = @"Take photo";
NSString *const CHOOSE_FROM_PHOTO_LIBRARY = @"Choose from library";
NSString *const BTN_TITLE_CONFIRMATION = @"Yes";
NSString *const BTN_TITLE_DISMISS = @"Dismiss";
NSString *const BTN_TITLE_CANCEL = @"Cancel";
NSString *const BTN_TITLE_DELETE = @"Delete Image";
NSString *const UITEXTVIEW_DESCRIPTION_PLACEHOLDER = @"Description...";

- (void)viewDidLoad {
    [super viewDidLoad];
    // instatiate the new pop object
    self.imageFiles = [[NSMutableArray alloc] init];
    self.imageBtns = @[self.imageBtn1, self.imageBtn2, self.imageBtn3, self.imageBtn4];
    self.defaultBtnImage = [self.imageBtn1 imageForState:UIControlStateNormal];

    // textarea markup
    [self setupImageButtons];
    self.descriptionTextView.delegate = self;
    self.descriptionTextView.text = UITEXTVIEW_DESCRIPTION_PLACEHOLDER;
    self.descriptionTextView.textColor = [UIColor lightGrayColor];

    // user location
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;

    // setup mapview
    self.mapview.showsUserLocation = NO;
    self.mapview.userInteractionEnabled = YES;

    self.savedImages = 0;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupLocationForPop];
}

- (void)setupLocationForPop {
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];

    if (status == kCLAuthorizationStatusDenied) {
        [LPAlertViewHelper fatalErrorAlert:@"Please allow location permission in app Settings to create a Pop"];
        [self dismissViewControllerAnimated:YES completion:NULL];
    } else {
        [self.locationManager startUpdatingLocation];
    }
}

- (void)zoomInToMyLocation {
    NSLog(@"zoom to my lcoation");
    MKCoordinateRegion region;
    region.center.latitude = self.locationManager.location.coordinate.latitude;
    region.center.longitude = self.locationManager.location.coordinate.longitude;
    region.span.longitudeDelta = MAP_ZOO_IN_DEGREE;
    region.span.latitudeDelta = MAP_ZOO_IN_DEGREE;
    [self.mapview setRegion:region animated:NO];
}

- (IBAction)cancelNewPop:(id)sender {
    if ([self isAllFieldEmpty]) {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Discard the pop?" delegate:self cancelButtonTitle:BTN_TITLE_CANCEL otherButtonTitles:BTN_TITLE_CONFIRMATION, nil];
        [alert show];
    }
}

- (IBAction)createPop:(id)sender {
    NSString *title = [self.titleTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *category = self.categoryLabel.text;
    NSString *description = [self.descriptionTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *priceStr = [self.priceTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    CLLocation *popLocation = [[CLLocation alloc] initWithLatitude:self.mapview.centerCoordinate.latitude longitude:self.mapview.centerCoordinate.longitude];

    if (title.length == 0) {
        [LPAlertViewHelper fatalErrorAlert:@"Please enter the title of your Pop"];
        return;
    }

    if (category.length == 0) {
        [LPAlertViewHelper fatalErrorAlert:@"Please enter select a cagetory for you Pop"];
        return;
    }

    if ([description isEqualToString:UITEXTVIEW_DESCRIPTION_PLACEHOLDER] || description.length == 0) {
        [LPAlertViewHelper fatalErrorAlert:@"Please write a short description introducing your Pop"];
        return;
    }

    if (priceStr.length == 0) {
        [LPAlertViewHelper fatalErrorAlert:@"Remeber to set a price for your Pop. You don't want to get nothing"];
        return;
    }

    if (self.imageFiles.count == 0) {
        [LPAlertViewHelper fatalErrorAlert:@"A picture is worth a thousand words. Please upload at least one picture related to your Pop."];
        return;
    }

    if (![PFUser currentUser]) {
        [LPAlertViewHelper fatalErrorAlert:@"Please login to create a Pop"];
        return;
    }

    if (!popLocation) {
        [LPAlertViewHelper fatalErrorAlert:@"Don't be a ninja. Let people know where you are poping."];
        return;
    }

    // save data to backend
    LPPop *newPop = [LPPop object];
    newPop.title = title;
    newPop.category = category;
    newPop.popDescription = description;
    newPop.seller = [PFUser currentUser];
    newPop.images = self.imageFiles;
    newPop.location = [PFGeoPoint geoPointWithLocation:popLocation];
    newPop.price = [NSNumber numberWithDouble:[priceStr doubleValue]];
    newPop.status = kPopCreated;
    for (PFFile *f in self.imageFiles) {
        [f saveInBackgroundWithBlock: ^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                if (++self.savedImages == self.imageFiles.count) {
                    [newPop saveEventually: ^(BOOL succeeded, NSError *error) {
                        if (!error) {
                            // done
                            [self showCreatePopSuccess];
                        }
                        else {
                            // error. Unable to save
                            [self showCreatePopError];
                        }
                    }];
                }
            }
        }];
    }
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)showCreatePopSuccess {
    NSDictionary *options = @{
                              kCRToastTextKey : @"Pop created!",
                              kCRToastTextAlignmentKey : @(NSTextAlignmentCenter),
                              kCRToastBackgroundColorKey : [UIColor greenColor],
                              kCRToastNotificationPresentationTypeKey : @(CRToastPresentationTypeCover),
                              kCRToastNotificationTypeKey : @(CRToastTypeNavigationBar),
                              kCRToastAnimationInTypeKey : @(CRToastAnimationTypeGravity),
                              kCRToastAnimationOutTypeKey : @(CRToastAnimationTypeLinear),
                              kCRToastAnimationInDirectionKey : @(CRToastAnimationDirectionTop),
                              kCRToastAnimationOutDirectionKey : @(CRToastAnimationDirectionTop)
                              };
    [CRToastManager showNotificationWithOptions:options
                                completionBlock: ^{
                                    NSLog(@"Completed");
                                }];
}

- (void)showCreatePopError {
    NSDictionary *options = @{
                              kCRToastTextKey : @"Unable to create pop. Please try again later",
                              kCRToastTextAlignmentKey : @(NSTextAlignmentCenter),
                              kCRToastBackgroundColorKey : [UIColor redColor],
                              kCRToastNotificationTypeKey : @(CRToastTypeNavigationBar),
                              kCRToastNotificationPresentationTypeKey : @(CRToastPresentationTypeCover),
                              kCRToastAnimationInTypeKey : @(CRToastAnimationTypeGravity),
                              kCRToastAnimationOutTypeKey : @(CRToastAnimationTypeGravity),
                              kCRToastAnimationInDirectionKey : @(CRToastAnimationDirectionTop),
                              kCRToastAnimationOutDirectionKey : @(CRToastAnimationDirectionTop)
                              };
    [CRToastManager showNotificationWithOptions:options
                                completionBlock: ^{
                                    NSLog(@"Completed");
                                }];
}

- (IBAction)addPhoto:(id)sender {
    UIActionSheet *actionSheet;
    self.clearImageBtn = (UIButton *)sender;
    if ([self.clearImageBtn backgroundImageForState:UIControlStateNormal]) {
        actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:BTN_TITLE_CANCEL destructiveButtonTitle:BTN_TITLE_DELETE otherButtonTitles:nil, nil];
    }
    else {
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
        [self presentViewController:imagePicker animated:YES completion:NULL];
    }
    else {
        // TODO changed it to add a button to access the system settings
        [LPAlertViewHelper fatalErrorAlert:@"Unable to take picture. Please allow camera permission in settings"];
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
        [self presentViewController:imagePicker animated:YES completion:NULL];
    }
    else {
        [LPAlertViewHelper fatalErrorAlert:@"Unable to choose picture. Please allow photo library access permission in settings"];
    }
}

- (void)reloadButtonImages {
    for (NSInteger i = 0; i < self.imageBtns.count; i++) {
        if (i < self.imageFiles.count) {
            UIImage *bkgImg = [UIImage imageWithData:[[self.imageFiles objectAtIndex:i] getData]];
            [[self.imageBtns objectAtIndex:i] setImage:nil forState:UIControlStateNormal];
            [[self.imageBtns objectAtIndex:i] setBackgroundImage:bkgImg forState:UIControlStateNormal];
        }
        else {
            [[self.imageBtns objectAtIndex:i] setImage:self.defaultBtnImage forState:UIControlStateNormal];
            [[self.imageBtns objectAtIndex:i] setBackgroundImage:nil forState:UIControlStateNormal];
        }
    }
}

- (void)setupImageButtons {
    CGColorRef lopopColor = [LPUIHelper lopopColor].CGColor;
    NSUInteger tag = 0;
    for (UIButton *btn in self.imageBtns) {
        btn.layer.borderColor = lopopColor;
        btn.layer.borderWidth = 1.0f;
        btn.tag = tag++;
    }
}

- (BOOL)isAllFieldEmpty {
    NSString *title = [self.titleTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *category = self.categoryLabel.text;
    NSString *description = [self.descriptionTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *priceStr = [self.priceTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

    return title.length == 0 &&
        category.length == 0 &&
        ([description isEqualToString:UITEXTVIEW_DESCRIPTION_PLACEHOLDER] || description.length == 0) &&
        priceStr.length == 0 &&
        self.imageFiles.count == 0;
}

#pragma mark - ActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.destructiveButtonIndex) {
        [self.clearImageBtn setBackgroundImage:nil forState:UIControlStateNormal];
        [self.clearImageBtn setImage:self.defaultBtnImage forState:UIControlStateNormal];
        [self removeImageAtBtn:self.clearImageBtn.tag];
    }
    else {
        NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
        if ([title isEqualToString:TAKE_PHOTO]) {
            [self takePicture];
        }
        else if ([title isEqualToString:CHOOSE_FROM_PHOTO_LIBRARY]) {
            [self chooseImages];
        }
    }
}

#pragma mark - ImagePickerController Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = info[UIImagePickerControllerEditedImage];
    if (!image) {
        image = info[UIImagePickerControllerOriginalImage];
    }
    NSData *imageData = UIImageJPEGRepresentation(image, COMPRESSION_QUALITY);
    PFFile *parseImageFile = [PFFile fileWithData:imageData]; // PFFile has 10MB of size limit
    [self.imageFiles addObject:parseImageFile];
    [self reloadButtonImages];
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - AlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:BTN_TITLE_CONFIRMATION]) {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
    }
}

#pragma mark - UITextview Delegate

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:UITEXTVIEW_DESCRIPTION_PLACEHOLDER]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor];
    }
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if ([[textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]) {
        textView.text = UITEXTVIEW_DESCRIPTION_PLACEHOLDER;
        textView.textColor = [UIColor lightGrayColor];
    }
    [textView resignFirstResponder];
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"LPPopCategorySegue"]) {
        if ([segue.destinationViewController isKindOfClass:[LPPopCategoryTableViewController class]]) {
            LPPopCategoryTableViewController *tvc = segue.destinationViewController;
            tvc.vc = self;
        }
    }
}

#pragma mark - CLLocationManager Delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    if (locations != nil && locations.count > 0) {
        [self zoomInToMyLocation];
        [self.locationManager stopUpdatingLocation];
    }
}

@end
