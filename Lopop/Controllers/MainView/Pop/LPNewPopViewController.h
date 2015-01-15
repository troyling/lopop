//
//  LPNewPopViewController.h
//  Lopop
//
//  Created by Troy Ling on 1/14/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LPNewPopViewController : UIViewController <UIAlertViewDelegate, UITextFieldDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

- (IBAction)cancelNewPop:(id)sender;
- (IBAction)addPhoto:(id)sender;

@end
