//
//  AppDelegate.m
//  SF iOS
//
//  Created by Amit Jain on 7/28/17.
//  Copyright © 2017 Amit Jain. All rights reserved.
//

#import "AppDelegate.h"
#import "NSNotification+ApplicationEventNotifications.h"
#import <UserNotifications/UserNotifications.h>
#import "EventChanges.h"
#import "SwipableNavigationContainer.h"

@interface AppDelegate ()

@property (nonatomic) SwipableNavigationContainer *navigationContainer;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window makeKeyAndVisible];
    
    [[UNUserNotificationCenter currentNotificationCenter]
     requestAuthorizationWithOptions:UNAuthorizationOptionAlert
     completionHandler:^(BOOL granted, NSError *error){}];
    
    /* 2019-04-09 Placeholder
    [application setMinimumBackgroundFetchInterval:21600]; // 6 hours
    */
    
    EventDataSource *datasource = [[EventDataSource alloc] initWithEventType:EventTypeSFCoffee];
    EventsFeedViewController *feedController = [[EventsFeedViewController alloc] initWithDataSource:datasource];
    
    self.window.rootViewController = feedController;
    
    return true;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.navigationContainer = [[SwipableNavigationContainer alloc] init];
    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self.navigationContainer.window makeKeyAndVisible];
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[NSNotificationCenter defaultCenter] postNotificationName:NSNotification.applicationBecameActiveNotification object:nil];
}

- (UIWindow *)window {
    return self.navigationContainer.window;
}

// MARK: - Background Fetch
- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {
    EventChanges *eventChanges = [[EventChanges alloc] init];
    [eventChanges checkForEventDifferences];
}

@end
