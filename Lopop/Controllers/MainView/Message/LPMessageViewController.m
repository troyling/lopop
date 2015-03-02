//
//  MessageViewController.m
//  Lopop
//
//  Created by Ruofan Ding on 1/31/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "LPMessageViewController.h"
#import "LPMessageModel.h"
#import "LPChatManager.h"
#import <Parse/Parse.h>
#import "LPUIHelper.h"



@implementation LPMessageViewController

NSString * const FirebaseUrl = @"https://vivid-heat-6123.firebaseio.com/";

- (void)viewDidLoad {
    [super viewDidLoad];

    if(self.offerUser != nil){
        self.chatModel = [[LPChatManager getInstance] startChatWithContactId:self.offerUser[@"name"]];
    }
    self.navigationItem.title = self.offerUser[@"name"];

    self.tableView.allowsSelection=NO;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.inputField.delegate = self;

    
    self.messageArray = [[NSMutableArray alloc] init];
    [self.messageArray addObjectsFromArray:[[LPChatManager getInstance] getChatMessagesWith:self.chatModel.contactId]];
    [self observeMessageChangeNotification];
    
    [self.inputField setReturnKeyType:UIReturnKeySend];
    self.inputField.enablesReturnKeyAutomatically = YES;
}

- (void) observeMessageChangeNotification {
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(reloadTableData:)
     name:ChatManagerMessageViewUpdateNotification
     object:nil];
}

- (void)reloadTableData:(NSNotification*)notification {
    if([notification.object isKindOfClass:[LPMessageModel class]]){
        [self.messageArray addObject:notification.object];
    }else{
        NSLog(@"Error in observer in messageViewController");
    }

    [self.tableView reloadData];
    if(self.messageArray.count > 0){ //move to the latest message
        NSIndexPath * indexPath = [NSIndexPath indexPathForRow:self.messageArray.count - 1 inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}




- (void)moveToTheLastMessage{
    if(self.messageArray.count > 0){
        NSIndexPath * indexPath = [NSIndexPath indexPathForRow:self.messageArray.count - 1 inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

#pragma mark - delegate for tableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView*)table numberOfRowsInSection:(NSInteger)section
{
    // This is the number of chat messages.
    return [self.messageArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    LPMessageModel* message = [self.messageArray objectAtIndex:indexPath.row];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [LPUIHelper screenWidth], MAXFLOAT)];
    return [LPUIHelper heightOfText: message.content forLabel:label] + 30.0f;

}

- (UITableViewCell*)tableView:(UITableView*)table cellForRowAtIndexPath:(NSIndexPath *)index
{
    static NSString *CellIdentifier = @"MessageCell";
    UITableViewCell *cell = [table dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
    }
    
    cell.textLabel.font = [UIFont systemFontOfSize:18];
    cell.textLabel.numberOfLines = 0;
    LPMessageModel *message = [self.messageArray objectAtIndex:index.row];
    
    cell.textLabel.text = message.content;
    
    if([message.senderId isEqualToString: self.chatModel.contactId]){
        cell.textLabel.textAlignment = NSTextAlignmentLeft;
    }else{
        cell.textLabel.textAlignment = NSTextAlignmentRight;
    }
    
    //cell.detailTextLabel.text = chatMessage[@"name"];
    return cell;
}



#pragma mark - send message
// This method is called when the user enters text in the text field.
// We add the chat message to our Firebase.
- (BOOL)textFieldShouldReturn:(UITextField*)textField
{
    //[textField resignFirstResponder];
    
    [[LPChatManager getInstance] sendMessage:textField.text to:self.chatModel];//TODO
    
    [textField setText:@""];
    return NO;
}

#pragma mark - handle keyboard

// Subscribe to keyboard show/hide notifications.
- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(keyboardWillShow:)
     name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(keyboardDidShow:)
     name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(keyboardWillHide:)
     name:UIKeyboardWillHideNotification object:nil];
}

// Unsubscribe from keyboard show/hide notifications.
- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter]
     removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter]
     removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter]
     removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter]
     removeObserver:self name:ChatManagerMessageViewUpdateNotification object:nil];
}

// Slide the view containing the table view and
// text field upwards when the keyboard shows,
- (void)keyboardWillShow:(NSNotification*)notification
{
    CGRect keyboardEndFrame;
    [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey]
     getValue:&keyboardEndFrame];
    
    
    CGRect frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.x, self.view.frame.size.width, self.view.frame.size.height - keyboardEndFrame.size.height);

    self.view.frame = frame;
}

// Scroll the tableView to the last message cell.
- (void)keyboardDidShow:(NSNotification*)notification
{
    if(self.messageArray.count > 0){
        NSIndexPath * indexPath = [NSIndexPath indexPathForRow:self.messageArray.count - 1 inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }

}

// Slide the view containing the table view and
// text field downwards when the keyboard hides,
- (void)keyboardWillHide:(NSNotification*)notification
{
    CGRect keyboardEndFrame;
    [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey]
     getValue:&keyboardEndFrame];
    
    CGRect frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.x, self.view.frame.size.width, self.view.frame.size.height + keyboardEndFrame.size.height);
    
    self.view.frame = frame;
}

// This method will be called when the user touches on the tableView, at
// which point we will hide the keyboard (if open). This method is called
// because UITouchTableView.m calls nextResponder in its touch handler.
- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
    if ([self.inputField isFirstResponder]) {
        [self.inputField resignFirstResponder];
    }
}

@end
