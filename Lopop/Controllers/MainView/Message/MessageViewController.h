//
//  MessageViewController.h
//  Lopop
//
//  Created by Ruofan Ding on 1/31/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Firebase/firebase.h"



@interface MessageViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *inputField;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
- (IBAction)sendMessage:(id)sender;

@property Firebase *firebase;
@property (nonatomic, strong) NSMutableArray* chatArray;


@end
