//
//  AppDelegate.m
//  Lopop
//
//  Created by Troy Ling on 1/9/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "AppDelegate.h"
#import "WeiboSDK.h"
#import "LPSignUpViewController.h"
#import "LPMainViewTabBarController.h"
#import "LPUIHelper.h"
#import <Parse/Parse.h>
#import <FacebookSDK/FacebookSDK.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Initialize Parse.
    [Parse setApplicationId:@"9Of1MI65pusWlQ4qXlXOzQSjsqFDLQbpxe6DepXk"
                  clientKey:@"TPOPIODRPCUvPxoguXUPcUNffAN56uLN3PGWZ4Fl"];
    
    [PFFacebookUtils initializeFacebook];

    // Notification
    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                    UIUserNotificationTypeBadge |
                                                    UIUserNotificationTypeSound);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                             categories:nil];
    [application registerUserNotificationSettings:settings];
    [application registerForRemoteNotifications];

    // Register WeChat
    [WXApi registerApp:@"wx1256c4ac9c7155a8"];

    // Register Weibo
    [WeiboSDK enableDebugMode:YES];
    [WeiboSDK registerApp:@"3279676740"];
    
    // [Optional] Track statistics around application opens.
    if (application.applicationState != UIApplicationStateBackground) {
        BOOL preBackgroundPush = ![application respondsToSelector:@selector(backgroundRefreshStatus)];
        BOOL oldPushHandlerOnly = ![self respondsToSelector:@selector(application:didReceiveRemoteNotification:fetchCompletionHandler:)];
        BOOL noPushPayload = ![launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (preBackgroundPush || oldPushHandlerOnly || noPushPayload) {
            [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
        }
    }
    
    // detect if the user is cached
    UIStoryboard *storyboard = self.window.rootViewController.storyboard;
    UIViewController *vc = [PFUser currentUser] ? [storyboard instantiateViewControllerWithIdentifier:@"LPMainViewTabBarController"] : [storyboard instantiateViewControllerWithIdentifier:@"LPSignUpViewController"];
    self.window.rootViewController = vc;
    
    // apply global tint
    [[UITabBar appearance] setTintColor:[LPUIHelper lopopColor]];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

    // clear the badge
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if (currentInstallation.badge != 0) {
        currentInstallation.badge = 0;
        [currentInstallation saveEventually];
    }

    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
    //[FBAppEvents activateApp];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    // TODO conditionally handle url for weibo, wechat, and
    //    [WeiboSDK handleOpenURL:url delegate:self];

    // direct to Wechat if it is installed
    return [WXApi handleOpenURL:url delegate:self];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    // TODO conditionally handle url for weibo, wechat, and
    //    [WeiboSDK handleOpenURL:url delegate:self];

    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication
                        withSession:[PFFacebookUtils session]];
}

#pragma mark Notification

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    currentInstallation.channels = @[ @"global" ];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    if (application.applicationState == UIApplicationStateInactive) {
        [PFAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    if (application.applicationState == UIApplicationStateInactive) {
        [PFAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
    }
}

@end
