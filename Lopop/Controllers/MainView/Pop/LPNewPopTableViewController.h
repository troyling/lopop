//
//  LPNewPopViewController.h
//  Lopop
//
//  Created by Troy Ling on 1/14/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface LPNewPopTableViewController : UITableViewController <UIAlertViewDelegate, UITextFieldDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UITextField *priceTextField;
@property (weak, nonatomic) NSString* category;

@property (weak, nonatomic) IBOutlet UIButton *imageBtn1;
@property (weak, nonatomic) IBOutlet UIButton *imageBtn2;
@property (weak, nonatomic) IBOutlet UIButton *imageBtn3;
@property (weak, nonatomic) IBOutlet UIButton *imageBtn4;

@property (weak, nonatomic) IBOutlet MKMapView *mapview;

- (IBAction)cancelNewPop:(id)sender;
- (IBAction)addPhoto:(id)sender;
- (IBAction)createPop:(id)sender;

@end
