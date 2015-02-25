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
#import "LPChatModel.h"
#import "LPPop.h"

@interface LPMessageViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (retain, nonatomic) LPPop *pop;
@property (retain, nonatomic) PFUser *offerUser;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *inputField;
@property LPChatModel* chatModel;

@property Firebase *firebase;
@property (nonatomic, strong) NSMutableArray* messageArray;

@end
