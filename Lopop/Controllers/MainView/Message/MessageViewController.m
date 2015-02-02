//
//  MessageViewController.m
//  Lopop
//
//  Created by Ruofan Ding on 1/31/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "MessageViewController.h"
#import "ChatMessage.h"

@implementation MessageViewController
- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.allowsSelection=NO;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.inputField.delegate = self;
    
    [self.inputField setReturnKeyType:UIReturnKeySend];
    self.inputField.enablesReturnKeyAutomatically = YES;
    
    self.chatArray = [[NSMutableArray alloc] init];
    
    self.firebase = [[Firebase alloc] initWithUrl:@"https://vivid-heat-6123.firebaseio.com/"];
    
    // This allows us to check if these were messages already stored on the server
    // when we booted up (YES) or if they are new messages since we've started the app.
    // This is so that we can batch together the initial messages' reloadData for a perf gain.
    __block BOOL initialAdds = YES;
    
    [self.firebase observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
        [self.chatArray addObject:[ChatMessage fromDict:snapshot.value]];
        // Reload the table view so the new message will show up.
        if (!initialAdds) {
            [self.tableView reloadData];
            NSIndexPath * indexPath = [NSIndexPath indexPathForRow:self.chatArray.count - 1 inSection:0];
            
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
    }];
    
    // Value event fires right after we get the events already stored in the Firebase repo.
    // We've gotten the initial messages stored on the server, and we want to run reloadData on the batch.
    // Also set initialAdds=NO so that we'll reload after each additional childAdded event.
    [self.firebase observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        // Reload the table view so that the intial messages show up
        [self.tableView reloadData];
        initialAdds = NO;
    }];
}

#pragma mark - delegate for tableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView*)table numberOfRowsInSection:(NSInteger)section
{
    // This is the number of chat messages.
    return [self.chatArray count];
}

- (UITableViewCell*)tableView:(UITableView*)table cellForRowAtIndexPath:(NSIndexPath *)index
{
    static NSString *CellIdentifier = @"MessageCell";
    UITableViewCell *cell = [table dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.textLabel.font = [UIFont systemFontOfSize:18];
        cell.textLabel.numberOfLines = 0;
    }
    
    ChatMessage *message = [self.chatArray objectAtIndex:index.row];
    
    cell.textLabel.text = message.content;
    //cell.detailTextLabel.text = chatMessage[@"name"];
    return cell;
}

#pragma mark - send message
// This method is called when the user enters text in the text field.
// We add the chat message to our Firebase.
- (BOOL)textFieldShouldReturn:(UITextField*)textField
{
    //[textField resignFirstResponder];
    
    ChatMessage* msg = [ChatMessage alloc];
    msg.content = textField.text;
    [[self.firebase childByAutoId] setValue:[msg toDict]];
    
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
    if(self.chatArray.count > 0){
        NSIndexPath * indexPath = [NSIndexPath indexPathForRow:self.chatArray.count - 1 inSection:0];
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