//
//  LPLocationPickerViewController.h
//  Lopop
//
//  Created by Troy Ling on 2/21/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface LPLocationPickerViewController : UIViewController <MKMapViewDelegate>

@property (retain, nonatomic) CLLocation *location;

@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

- (IBAction)pickThisLocation:(id)sender;
- (IBAction)dismiss:(id)sender;

@end
