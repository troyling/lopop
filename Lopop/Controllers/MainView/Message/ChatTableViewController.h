//
//  ChatTableViewController.h
//  Lopop
//
//  Created by Ruofan Ding on 2/3/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Firebase/Firebase.h>

@interface ChatTableViewController : UITableViewController

@property (nonatomic, strong) NSMutableArray* chatArray;
@property Firebase * firebase;

- (IBAction)newChat:(id)sender;

@end
