//
//  AppDelegate.m
//  Lopop
//
//  Created by Troy Ling on 1/9/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "AppDelegate.h"
#import "LPSignUpViewController.h"
#import "LPMainViewTabBarController.h"
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
    
    // [Optional] Track statistics around application opens.
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    // detect if the user is cached
    UIStoryboard *storyboard = self.window.rootViewController.storyboard;
    UIViewController *vc = [PFUser currentUser] ? [storyboard instantiateViewControllerWithIdentifier:@"LPMainViewTabBarController"] : [storyboard instantiateViewControllerWithIdentifier:@"LPSignUpViewController"];
    self.window.rootViewController = vc;
    
    // apply global tint
    [[UITabBar appearance] setTintColor:[UIColor colorWithRed:0.33 green:0.87 blue:0.75 alpha:1]];
    
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
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
    //[FBAppEvents activateApp];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication
                        withSession:[PFFacebookUtils session]];
}

@end
