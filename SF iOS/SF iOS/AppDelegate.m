//
//  AppDelegate.m
//  SF iOS
//
//  Created by Amit Jain on 7/28/17.
//  Copyright © 2017 Amit Jain. All rights reserved.
//

#import "AppDelegate.h"
#import "NSNotification+ApplicationEventNotifications.h"
#import "FeedFetchService.h"
#import "SwipableNavigationContainer.h"

#import "EventDataSource.h"
#import <UserNotifications/UserNotifications.h>

@interface AppDelegate ()

@property (nonatomic) SwipableNavigationContainer *navigationContainer;

@property (nonatomic) FeedFetchService *service;

@property (nonatomic) EventDataSource *eventDataSource;
@property (nonatomic) UIBackgroundTaskIdentifier backgroundTaskId;

@end

@implementation AppDelegate

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[UNUserNotificationCenter currentNotificationCenter]
     requestAuthorizationWithOptions:UNAuthorizationOptionAlert|UNAuthorizationOptionBadge|UNAuthorizationOptionSound
     completionHandler:^(BOOL granted, NSError *error){}];
    
    [application setMinimumBackgroundFetchInterval:21600]; // 6 hours
    self.eventDataSource = [[EventDataSource alloc] init];
    
    self.service = [[FeedFetchService alloc] init];
    
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
    if ([application applicationState] != UIApplicationStateBackground) {
        completionHandler(UIBackgroundFetchResultNoData);
        return;
    }
    
    if ([application applicationState] == UIApplicationStateBackground) {
        dispatch_async(dispatch_get_main_queue(), ^{            
            self.backgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithName:@"events" expirationHandler:^{
                [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskId];
                self.backgroundTaskId = UIBackgroundTaskInvalid;
            }];
            
            [self.eventDataSource refresh];
            
            [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskId];
            self.backgroundTaskId = UIBackgroundTaskInvalid;
            
            completionHandler(UIBackgroundFetchResultNewData);
        });
    } else {
        completionHandler(UIBackgroundFetchResultNoData);
    }
}

@end
