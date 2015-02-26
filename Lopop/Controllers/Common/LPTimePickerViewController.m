//
//  LPTimePickerViewController.m
//  Lopop
//
//  Created by Troy Ling on 2/21/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "LPTimePickerViewController.h"

@interface LPTimePickerViewController ()

@end

@implementation LPTimePickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    if (self.date) {
        self.datePicker.date = self.date;
        [self pickerValueChanged:self];
    }

    [self.datePicker addTarget:self action:@selector(pickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    self.datePicker.minimumDate = [NSDate date];
}

- (IBAction)dismiss:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark Time Picker Delegate

- (IBAction)pickerValueChanged:(id)sender {
    NSTimeZone *timeZoneLocal = [NSTimeZone localTimeZone];
    NSDateFormatter *outputDateFormatter = [[NSDateFormatter alloc] init];
    [outputDateFormatter setTimeZone:timeZoneLocal];
    [outputDateFormatter setDateFormat:@"EEE, MMM d, h:mm a"];
    NSString *outputString = [outputDateFormatter stringFromDate:self.datePicker.date];

    self.timeLabel.text = outputString;
}

@end
