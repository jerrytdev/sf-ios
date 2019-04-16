//
//  AppDelegate.m
//  SF iOS
//
//  Created by Amit Jain on 7/28/17.
//  Copyright © 2017 Amit Jain. All rights reserved.
//

#import "AppDelegate.h"
#import "NSNotification+ApplicationEventNotifications.h"
//#import <UserNotifications/UserNotifications.h>
#import "UNUserNotificationCenter+Convenience.h"
#import "FeedFetchService.h"
#import "EventChanges.h"
#import "SwipableNavigationContainer.h"
#import <Realm/Realm.h>

@interface AppDelegate ()

@property (nonatomic) SwipableNavigationContainer *navigationContainer;

//@property (nonatomic) EventDataSource *dataSource;
//@property (nonatomic) EventChanges *eventChanges;
@property (nonatomic) FeedFetchService *service;

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
    
    // 2019-04-09 Placeholder
    [application setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum]; // 6 hours
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSLog(@"paths %@",paths);
    
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
    if ([application backgroundRefreshStatus] != UIBackgroundRefreshStatusAvailable) {
        completionHandler(UIBackgroundFetchResultNoData);
    }
    
    if ([application applicationState] == UIApplicationStateBackground) {

        [self.service getFeedWithHandler:^(NSArray<Event *> * _Nonnull feedFetchItems, NSError * _Nullable error) {
            if (error) {
                completionHandler(UIBackgroundFetchResultFailed);
            }
            // Persist your data easily
            RLMRealm *realm = [RLMRealm defaultRealm];
            
            // Fetch all existing events from the realm and map by {eventID : Event}
            NSMutableDictionary *existingEvents = [[NSMutableDictionary alloc] init];
            for (Event *object in [Event allObjects]) {
                [existingEvents setObject:object forKey:object.eventID];
            }
            
            // determine if the
            NSMutableArray *addToRealm = [NSMutableArray array];
            for (Event *parsedEvent in feedFetchItems) {
                Event *existingEvent = existingEvents[parsedEvent.eventID];
                if (existingEvent) {
                    // If the event exists in the realm AND the parsed event is different, add it to the realm
                    if(![existingEvent isEqual:parsedEvent]) {
                        [addToRealm addObject:parsedEvent];
                    }
                } else {
                    // if this is an item that is not in the realm, add it
                    [addToRealm addObject:parsedEvent];
                }
            }
            
            [realm transactionWithBlock:^{
                [realm addOrUpdateObjects:addToRealm];
                NSString *contentBody = [NSString stringWithFormat:@"Num: %ld",addToRealm.count];
                [[UNUserNotificationCenter currentNotificationCenter] scheduleNotificationWithIdentifier:nil contentTitle:@"Events" contentBody:contentBody];
                completionHandler(UIBackgroundFetchResultNewData);
            }];
        }];
        
        /*
        EventChanges *eventChanges = [[EventChanges alloc] init];
        [eventChanges checkForEventDifferences];
        
        [eventChanges eventsChanged:nil withError:nil withCompletion:^(NSNumber *_Nullable eventsHaveChanged, NSError *_Nullable error){
            if (error) {
                completionHandler(UIBackgroundFetchResultFailed);
            }
//            if ([eventsHaveChanged boolValue]) {
                completionHandler(UIBackgroundFetchResultNewData);
//            } else {
//                completionHandler(UIBackgroundFetchResultNoData);
//            }
        }];
        */
        
    } else {
        completionHandler(UIBackgroundFetchResultNoData);

    }
    
}

@end
