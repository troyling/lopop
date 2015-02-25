//
//  AppDelegate.h
//  Lopop
//
//  Created by Troy Ling on 1/9/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXApi.h"


@interface AppDelegate : UIResponder <UIApplicationDelegate, WXApiDelegate>

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;


@property (strong, nonatomic) UIWindow *window;

- (NSURL *)applicationDocumentsDirectory; // nice to have to reference files for core data
@end

