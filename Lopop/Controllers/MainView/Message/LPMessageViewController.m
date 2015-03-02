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

NSString *const FirebaseUrl = @"https://vivid-heat-6123.firebaseio.com/";

- (void)viewDidLoad {
    [super viewDidLoad];

    // TODO get user
    self.navigationItem.title = self.offerUser[@"name"];

    self.inputToolbar.contentView.leftBarButtonItem = nil; // disable accessory item

    JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
    self.outgoinBubble = [bubbleFactory outgoingMessagesBubbleImageWithColor:[LPUIHelper lopopColor]];
    self.incomingBubble = [bubbleFactory incomingMessagesBubbleImageWithColor:[LPUIHelper infoColor]];

    // sender
    self.senderId = [PFUser currentUser].objectId;
    self.senderDisplayName = [PFUser currentUser][@"name"];

    self.messageArray = [[NSMutableArray alloc] init];
    [self.messageArray addObjectsFromArray:[[LPChatManager getInstance] getChatMessagesWith:self.chatModel.contactId]];
    [self observeMessageChangeNotification];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if ([self.tabBarController isKindOfClass:[LPMainViewTabBarController class]]) {
        [(LPMainViewTabBarController *)self.tabBarController setTabBarVisible:NO animated:YES];
    }
}

// Unsubscribe from keyboard show/hide notifications.
- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter]
     removeObserver:self name:ChatManagerMessageViewUpdateNotification object:nil];
}

- (void)observeMessageChangeNotification {
    [[NSNotificationCenter defaultCenter]
     addObserver:self
	    selector:@selector(reloadTableData:)
     name:ChatManagerMessageViewUpdateNotification
     object:nil];
}

- (void)reloadTableData:(NSNotification *)notification {
    if ([notification.object isKindOfClass:[LPMessageModel class]]) {
        [self.messageArray addObject:notification.object];
    }
    else {
        NSLog(@"Error in observer in messageViewController");
    }
    // TODO rewrite this
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
    /**
     *  Return `nil` here if you do not want avatars.
     *  If you do return `nil`, be sure to do the following in `viewDidLoad`:
     *
     *  self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
     *  self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
     *
     *  It is possible to have only outgoing avatars or only incoming avatars, too.
     */

    /**
     *  Return your previously created avatar image data objects.
     *
     *  Note: these the avatars will be sized according to these values:
     *
     *  self.collectionView.collectionViewLayout.incomingAvatarViewSize
     *  self.collectionView.collectionViewLayout.outgoingAvatarViewSize
     *
     *  Override the defaults in `viewDidLoad`
     */

    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath {
    /**
     *  This logic should be consistent with what you return from `heightForCellTopLabelAtIndexPath:`
     *  The other label text delegate methods should follow a similar pattern.
     *
     *  Show a timestamp for every 3rd message
     */
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
            cell.textView.textColor = [UIColor blackColor];
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
    /**
     *  Each label in a cell has a `height` delegate method that corresponds to its text dataSource method
     */

    /**
     *  This logic should be consistent with what you return from `attributedTextForCellTopLabelAtIndexPath:`
     *  The other label height delegate methods should follow similarly
     *
     *  Show a timestamp for every 3rd message
     */
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
    return [JSQMessage messageWithSenderId:msg.senderId displayName:self.offerUser[@"name"] text:msg.content];
}

@end
