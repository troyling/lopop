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
#import "LPMessageModel.h"


@interface LPMessageViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *inputField;
@property (retain, nonatomic) NSString * chatId;

@property USER1OR2 userNumber;
@property Firebase *firebase;
@property (nonatomic, strong) NSMutableArray* messageArray;


@end
