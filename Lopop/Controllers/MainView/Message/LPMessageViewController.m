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
#import "LPMainViewTabBarController.h"

@implementation LPMessageViewController

- (void)viewDidLoad {
    //TODO: add time to message
    [super viewDidLoad];
    [self loadContactData];
    [self initMessageController];

    self.messageArray = [[NSMutableArray alloc] init];
    [self.messageArray addObjectsFromArray:[[LPChatManager getInstance] getChatMessagesWith:self.chatModel.contactId]];
    [self observeMessageChangeNotification];
}

- (void)loadContactData {
    PFQuery *query = [PFUser query];
    query.cachePolicy = kPFCachePolicyCacheElseNetwork;
    [query whereKey:@"objectId" equalTo:self.chatModel.contactId];
    [query findObjectsInBackgroundWithBlock: ^(NSArray *objects, NSError *error) {
        if (!error && objects.count == 1) {
            self.navigationItem.title = objects.firstObject[@"name"];
        }
    }];
}


- (void)initMessageController {
    self.inputToolbar.contentView.leftBarButtonItem = nil; // disable accessory item

    // style
    JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
    self.outgoinBubble = [bubbleFactory outgoingMessagesBubbleImageWithColor:[LPUIHelper lopopColor]];
    self.incomingBubble = [bubbleFactory incomingMessagesBubbleImageWithColor:[LPUIHelper infoColor]];
    self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
    self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;

    // sender
    self.senderId = [PFUser currentUser].objectId;
    self.senderDisplayName = [PFUser currentUser][@"name"];
}

- (void)observeMessageChangeNotification {
    [[NSNotificationCenter defaultCenter]
     addObserver:self
	    selector:@selector(reloadTableData:)
     name:ChatManagerMessageViewUpdateNotification
     object:nil];

    // keyboard
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onKeyboardShow) name:UIKeyboardDidShowNotification object:nil];
}

- (void)onKeyboardShow {
    [self scrollToBottomAnimated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter]
     removeObserver:self name:ChatManagerMessageViewUpdateNotification object:nil];
}

- (void)reloadTableData:(NSNotification *)notification {
    if ([notification.object isKindOfClass:[LPMessageModel class]]) {
        [self.messageArray addObject:notification.object];
    }
    else {
        NSLog(@"Error in observer in messageViewController");
    }

    // update table
    [self.collectionView reloadData];
    [self scrollToBottomAnimated:YES];
}

#pragma mark - JSQMessages CollectionView DataSource

- (id <JSQMessageData> )collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self adaptMessage:[self.messageArray objectAtIndex:indexPath.item]];
}

- (id <JSQMessageBubbleImageDataSource> )collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    JSQMessage *message = [self adaptMessage:[self.messageArray objectAtIndex:indexPath.item]];

    if ([message.senderId isEqualToString:self.senderId]) {
        return self.outgoinBubble;
    }
    return self.incomingBubble;
}

- (id <JSQMessageAvatarImageDataSource> )collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath {
    // This logic should be consistent with what you return from `heightForCellTopLabelAtIndexPath:
    if (indexPath.item % 10 == 0) {
        JSQMessage *message = [self adaptMessage:[self.messageArray objectAtIndex:indexPath.item]];
        return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
    }

    return nil;
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.messageArray count];
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    JSQMessage *msg = [self adaptMessage:[self.messageArray objectAtIndex:indexPath.item]];
    if (!msg.isMediaMessage) {
        if ([msg.senderId isEqualToString:self.senderId]) {
            cell.textView.textColor = [UIColor whiteColor];
        }
        else {
            cell.textView.textColor = [UIColor whiteColor];
        }

        cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor,
                                              NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
    }

    return cell;
}

#pragma mark - Adjusting cell label heights

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath {
    // This logic should be consistent with what you return from `attributedTextForCellTopLabelAtIndexPath:`
    if (indexPath.item % 10 == 0) {
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }

    return 0.0f;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath {
    /**
     *  iOS7-style sender name labels
     */
    JSQMessage *currentMessage = [self adaptMessage:[self.messageArray objectAtIndex:indexPath.item]];
    if ([[currentMessage senderId] isEqualToString:self.senderId]) {
        return 0.0f;
    }

    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self adaptMessage:[self.messageArray objectAtIndex:indexPath.item - 1]];
        if ([[previousMessage senderId] isEqualToString:[currentMessage senderId]]) {
            return 0.0f;
        }
    }

    return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

#pragma mark - JSQMessagesViewController method overrides

- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                  senderId:(NSString *)senderId
         senderDisplayName:(NSString *)senderDisplayName
                      date:(NSDate *)date {
    //TODO: check for msg length, empty
    [[LPChatManager getInstance] sendMessage:text to:self.chatModel];
    [self finishSendingMessageAnimated:YES];
}

#pragma mark - Responding to collection view tap events

- (void)collectionView:(JSQMessagesCollectionView *)collectionView
                header:(JSQMessagesLoadEarlierHeaderView *)headerView didTapLoadEarlierMessagesButton:(UIButton *)sender {
    NSLog(@"Load earlier messages!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapAvatarImageView:(UIImageView *)avatarImageView atIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Tapped avatar!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Tapped message bubble!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapCellAtIndexPath:(NSIndexPath *)indexPath touchLocation:(CGPoint)touchLocation {
    NSLog(@"Tapped cell at %@!", NSStringFromCGPoint(touchLocation));
}

#pragma mark helper

- (JSQMessage *)adaptMessage:(LPMessageModel *)msg {
    //TODO: add method to look up name
    return [JSQMessage messageWithSenderId:msg.senderId displayName:@"Change my name" text:msg.content];
}

- (void)scrollToBottomAnimated:(BOOL)animated {
    if ([self.collectionView numberOfSections] == 0) {
        return;
    }

    NSInteger items = [self.collectionView numberOfItemsInSection:0];

    if (items == 0) {
        return;
    }

    CGFloat collectionViewContentHeight = [self.collectionView.collectionViewLayout collectionViewContentSize].height;
    BOOL isContentTooSmall = (collectionViewContentHeight < CGRectGetHeight(self.collectionView.bounds));

    if (isContentTooSmall) {
        [self.collectionView scrollRectToVisible:CGRectMake(0.0, collectionViewContentHeight - 1.0f, 1.0f, 1.0f)
                                        animated:animated];
        return;
    }

    NSUInteger finalRow = MAX(0, [self.collectionView numberOfItemsInSection:0] - 1);
    NSIndexPath *finalIndexPath = [NSIndexPath indexPathForItem:finalRow inSection:0];
    CGSize finalCellSize = [self.collectionView.collectionViewLayout sizeForItemAtIndexPath:finalIndexPath];

    CGFloat maxHeightForVisibleMessage = CGRectGetHeight(self.collectionView.bounds) - self.collectionView.contentInset.top - CGRectGetHeight(self.inputToolbar.bounds);

    UICollectionViewScrollPosition scrollPosition = (finalCellSize.height > maxHeightForVisibleMessage) ? UICollectionViewScrollPositionBottom : UICollectionViewScrollPositionTop;

    [self.collectionView scrollToItemAtIndexPath:finalIndexPath
                                atScrollPosition:scrollPosition
                                        animated:animated];
}

#pragma mark methods

- (void)setInputToolbarVerticalOffset:(CGFloat)verticalOffset {
    // stick to bottom
    self.inputToolbar.frame = CGRectMake(0, [LPUIHelper screenHeight] - verticalOffset - self.inputToolbar.frame.size.height, self.inputToolbar.frame.size.width, self.inputToolbar.frame.size.height);
    self.inputToolbar.hidden = NO;
    [self.collectionView reloadData];
    [self.inputToolbar.contentView.textView becomeFirstResponder];
}

- (void)dismissKeyboard {
    [self.inputToolbar.contentView.textView resignFirstResponder];
    self.inputToolbar.hidden = YES;
    [self.collectionView reloadData];
}

@end
