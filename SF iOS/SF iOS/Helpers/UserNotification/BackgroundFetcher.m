//
//  BackgroundFetcher.m
//  Coffup
//
//  Created by Jerry Tung on 4/17/19.
//

#import "BackgroundFetcher.h"
#import "EventDataSource.h"
#import <UserNotifications/UserNotifications.h>
#import "UNUserNotificationCenter+ConvenienceInitializer.h"

@interface BackgroundFetcher () <EventDataSourceDelegate>
@property (nonatomic) EventDataSource *backgroundDataSource;
@property (nonatomic, copy) void (^backgroundCompletionBlock)(UIBackgroundFetchResult);
@end

@implementation BackgroundFetcher

//@property (nonatomic) void (^backgroundCompletionBlock)(UIBackgroundFetchResult);


- (instancetype)initWithCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {
    if (self = [super init]) {
        // Ok, at this point we create our background data source, remember that the app delegate is retaining this instance of the data source.
        self.backgroundDataSource = [[EventDataSource alloc] initWithEventType:EventTypeSFCoffee];
        
        // Self is the delegate for the backgroundDataSource, which means that it will be told "Hey, there are changes" or "Hey, something went wrong" and one other thing that we don't care about.
        self.backgroundDataSource.delegate = self;
        
        // Hey look, we are able to retain the block and call it from one of the delegate callbacks. 👍
        self.backgroundCompletionBlock = completionHandler;
        
        // start the process
        [self.backgroundDataSource refresh];
    }
    
    return self;
}

// This gets called after the data source requests from the server and adds to the realm database. It's telling us what changed.
- (void)didChangeDataSourceWithInsertions:(nullable NSArray<NSIndexPath *> *)insertions updates:(nullable NSArray<NSIndexPath *> *)updates deletions:(nullable NSArray<NSIndexPath *> *)deletions {
    
    if (insertions == nil && deletions == nil && updates == nil) {
        return;
    }
    NSLog(@"%@  %@  %@", insertions, updates, deletions);
    
        // Check for the early return opportunity
        if ([updates count] == 0 && [deletions count] == 0 && [insertions count] == 0) {
                // should be obvious, but we DO NOT want to send a local notification in this case
                NSString *contentTitle = @"Coffee Events No change";
                NSString *contentBody = @"No changes";
                [[UNUserNotificationCenter currentNotificationCenter] scheduleNotificationWithIdentifier:nil contentTitle:contentTitle contentBody:contentBody];
        
                // looks like the data source told us that nothing changed. We're done so
                // we give that feedback to the OS. Maybe next time it'll request a little
                // less frequently.
            
                self.backgroundCompletionBlock(UIBackgroundFetchResultNoData);
//            self.backgroundCompletionBlock = nil;
                return;
            }
    
        // Updates have a specific notification: "Blue  bottle updated" or whatever
        for (NSIndexPath *update in updates) {
                NSString *contentTitle = @"Coffee Events change";
                Event *event = [self.backgroundDataSource eventAtIndex:[update row]];
                NSString *contentBody = [NSString stringWithFormat:@"%@ at %@ has changed. Find the latest info in app.", event.name, event.venueName];
                // Special note here, the eventID should probably be passed in, otherwise we'll only get the last notification here. We really want all of them probably.
                [[UNUserNotificationCenter currentNotificationCenter] scheduleNotificationWithIdentifier:event.eventID contentTitle:contentTitle contentBody:contentBody];
            }
    
        // This is a new event, it should have a nice alert.
        for (NSIndexPath *insert in insertions) {
                Event *event = [self.backgroundDataSource eventAtIndex:[insert row]];
                NSString *contentTitle = @"New Coffee Event";
                NSString *contentBody = [NSString stringWithFormat:@"meet your friends at %@ for %@", event.venueName, event.name];
                [[UNUserNotificationCenter currentNotificationCenter] scheduleNotificationWithIdentifier:event.eventID contentTitle:contentTitle contentBody:contentBody];
            }
    
        // And finally deletes get custom copy
        for (NSIndexPath *delete in deletions) {
                Event *event = [self.backgroundDataSource eventAtIndex:[delete row]];
                NSString *contentTitle = @"Coffee Event Cancelled";
                NSString *contentBody = [NSString stringWithFormat:@"%@ has been cancelled", event.name];
                [[UNUserNotificationCenter currentNotificationCenter] scheduleNotificationWithIdentifier:event.eventID contentTitle:contentTitle contentBody:contentBody];
            }

    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:(updates.count+insertions.count+deletions.count)];
    
        // Tell the OS that we got new data. It should adjust accordingly.
        self.backgroundCompletionBlock(UIBackgroundFetchResultNewData);
    }

- (void)didFailToUpdateWithError:(nonnull NSError *)error {
        self.backgroundCompletionBlock(UIBackgroundFetchResultFailed);
    }

- (void)willUpdateDataSource:(nonnull EventDataSource *)datasource {
        // no op. We asked it to update
}

@end
