//
//  LPFollowerTableViewController.h
//  Lopop
//
//  Created by Troy Ling on 1/30/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface LPFollowerTableViewController : UITableViewController <UIActionSheetDelegate>

typedef NS_ENUM(NSUInteger, ContentType) {
    FOLLOWING_USER,
    FOLLOWER
};

@property (retain, nonatomic) PFQuery *query; // Query for the contents to display on this table view
@property (assign, readwrite) ContentType contentType;

@end
