//
//  AppDelegate.m
//  SQuInt2014
//
//  Created by csjan on 4/17/14.
//  Copyright (c) 2014 tapgo. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>
#import "UIColor+ProjectColors.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //[Parse enableLocalDatastore];
    [Parse setApplicationId:@"PLlbyPCGMrfHvghx1sllgLmNRIwz00l7PHYZdAvd"
                  clientKey:@"9LIHOaADcFXDINWNOvCO5Rr9XYKd1jV2A3aB70Ca"];
    
    //we don't do tracking analytics for now...
    //[PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    // Register for Push Notitications, if running iOS 8
     if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
         UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                         UIUserNotificationTypeBadge |
                                                         UIUserNotificationTypeSound);
         UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                                  categories:nil];
         [application registerUserNotificationSettings:settings];
         [application registerForRemoteNotifications];
         NSLog(@"IOS8 PUSH");
     } else {
         // Register for Push Notifications before iOS 8
         [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                          UIRemoteNotificationTypeAlert |
                                                          UIRemoteNotificationTypeSound)];
         NSLog(@"IOS<=7 PUSH");
     }
    
    // This sets the background color of the navigation
    [[UINavigationBar appearance] setBarTintColor:[UIColor main_blue]];
    
    // This sets the text color of the navigation links
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    // This sets the title color of the navigation bar
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Light" size:19.0]}];
    
    [[UITabBar appearance] setTintColor:[UIColor whiteColor]];
    [[UITabBar appearance] setBarTintColor:[UIColor dark_blue]];
    //crashes ios 7 + iphone 4s for some reason
    //[[UITabBar appearance] setTranslucent:NO];
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"HelveticaNeue-Light" size:10.0f], NSFontAttributeName, nil] forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"HelveticaNeue-Light" size:10.0f], NSFontAttributeName, nil] forState:UIControlStateHighlighted];
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"HelveticaNeue-Light" size:10.0f], NSFontAttributeName, nil] forState:UIControlStateSelected];
    
    [application setStatusBarStyle:UIStatusBarStyleLightContent];
    
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    currentInstallation.channels = @[ @"global" ];
    [currentInstallation saveInBackground];
    NSLog(@"REGISTER FOR PUSH CALLBACK");
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"REMOTE PUSH REGISTER ERROR:%@", error);
}

- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo {
    //[PFPush handlePush:userInfo];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"gotchatinapp" object:nil];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if (currentInstallation.badge != 0) {
        currentInstallation.badge = 0;
        [currentInstallation saveEventually];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
