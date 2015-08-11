//
//  AppDelegate.m
//  cm_math_one
//
//  Created by csjan on 6/16/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>
#import "UIColor+ProjectColors.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //Parse
    [Parse setApplicationId:@"2JF8yrgsM5H261Gju4rzKfxFurDZluOfWUq9UnCV"
                  clientKey:@"9pGuToEnzGXInGk7vTtfKzpU5rfvNAU0EBHdMPsZ"];
    [PFUser enableRevocableSessionInBackground];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    // Register for Push Notitications, if running iOS 8
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                        UIUserNotificationTypeBadge |
                                                        UIUserNotificationTypeSound);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                                 categories:nil];
        [application registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
        NSLog(@"iOS8 Push registration");
    } else {
        // Register for Push Notifications before iOS 8
        [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                         UIRemoteNotificationTypeAlert |
                                                         UIRemoteNotificationTypeSound)];
        NSLog(@"iOS<=7 Push registration");
    }

    //styling
    // This sets the background color of the navigation
    [[UINavigationBar appearance] setBarTintColor:[UIColor nav_bar]];
    // This sets the text color of the navigation links
    [[UINavigationBar appearance] setTintColor:[UIColor light_button_txt]];
    // This sets the title color of the navigation bar
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue" size:19.0]}];
    
    [[UITabBar appearance] setTintColor:[UIColor light_button_txt]];
    [[UITabBar appearance] setBarTintColor:[UIColor tab_bar]];
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"HelveticaNeue" size:10.0f], NSFontAttributeName, [UIColor lightGrayColor], NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"HelveticaNeue" size:10.0f], NSFontAttributeName, nil] forState:UIControlStateHighlighted];
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"HelveticaNeue" size:10.0f], NSFontAttributeName, [UIColor light_button_txt], NSForegroundColorAttributeName,nil] forState:UIControlStateSelected];
    [application setStatusBarStyle:UIStatusBarStyleLightContent];
    
    //track first open for instruction page
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults objectForKey:@"appsetup"])
    {
        [defaults setBool:NO forKey:@"chooseeventsetup"];
        [defaults setBool:NO forKey:@"homesetup"];
        [defaults setValue:@1 forKey:@"appsetup"];
        [defaults synchronize];
    }
    
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    currentInstallation.channels = @[ @"global" ];
    [currentInstallation saveInBackground];
    NSLog(@"Did register for remote notifications (callback)");
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"Did fail to register for remote notifications (callback) error:%@", error);
}

- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo {
    //[PFPush handlePush:userInfo];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"gotchatinapp" object:nil];
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
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if (currentInstallation.badge != 0) {
        currentInstallation.badge = 0;
        [currentInstallation saveEventually];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
