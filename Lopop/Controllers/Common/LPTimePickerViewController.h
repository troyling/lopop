//
//  LPTimePickerViewController.h
//  Lopop
//
//  Created by Troy Ling on 2/21/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LPTimePickerViewController : UIViewController <UIPickerViewDelegate>

@property (retain, nonatomic) NSDate *date;

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

- (IBAction)dismiss:(id)sender;

@end
