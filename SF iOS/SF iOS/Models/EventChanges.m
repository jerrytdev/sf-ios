//
//  EventChanges.m
//  SF iOS
//
//  Created by Jerry Tung on 4/4/19.
//  Copyright © 2019 Amit Jain. All rights reserved.
//

#import "EventChanges.h"
#import "Event.h"
#import "FeedFetchService.h"
#import "UNUserNotificationCenter+Convenience.h"
#import "NSDate+Utilities.h"

@interface EventChanges ()
@property (nonatomic) FeedFetchService *service;
@end

@implementation EventChanges

- (instancetype)init {
    if (self = [super init]) {
        self.service = [[FeedFetchService alloc] init];
    }
    return self;
}

// MARK: - Check for changes
- (void)checkForEventDifferences {
    
    [self fetchAndCompareEvents:^(NSArray<Event*> *updatedEvents, NSError *error) {
        if (updatedEvents.count > 0) {
            
            NSString *contentTitle = [NSString stringWithFormat:@"%ld Coffee Events Changed", updatedEvents.count];
            
            NSMutableArray *body = [[NSMutableArray alloc] init];
            for (Event *event in updatedEvents) {
                [body addObject:event.name];
            }
            
            NSString *contentBody = [body componentsJoinedByString:@", "];
            
            [[UNUserNotificationCenter currentNotificationCenter] scheduleNotificationWithIdentifier:nil contentTitle:contentTitle contentBody:contentBody];
        }
    }];
}


- (void)fetchAndCompareEvents:(void (^)(NSArray<Event*> * __nullable events, NSError * __nullable error))completion {
    dispatch_queue_t defaultQueue = dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0);
    dispatch_group_t eventsGroup = dispatch_group_create();
    
    __block NSArray<Event*> *events;
    dispatch_group_enter(eventsGroup);
    dispatch_group_async(eventsGroup, defaultQueue, ^() {
        [self getLatestEvents:^(NSArray<Event*> *currentEvents, NSError *error) {
            if (!error) {
                events = currentEvents;
                dispatch_group_leave(eventsGroup);
            } else {
                NSLog(@"Update events error: %@", error.localizedDescription);
            }
        }];
    });
    
    __block NSArray<Event*> *persistedEvents;
    dispatch_group_enter(eventsGroup);
    dispatch_group_async(eventsGroup, defaultQueue, ^() {
        [self eventsFromPersistence:^(NSArray<Event*> *savedEvents, NSError *error) {
            if (!error) {
                persistedEvents = savedEvents;
                dispatch_group_leave(eventsGroup);
            } else {
                NSLog(@"Persisted events error: %@", error.localizedDescription);
            }
        }];
    });
    
    dispatch_group_notify(eventsGroup, dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^(){
        if (persistedEvents && events) {
            NSArray *updatedEvents = [self compareFutureEvents:events withStoredEvents:persistedEvents];
            completion(updatedEvents,nil);
        }
    });
}

// Note: Check for changes two hours in the past
- (NSArray<Event*> *)compareFutureEvents:(NSArray<Event*> *)futureEvents withStoredEvents:(NSArray<Event*> *)storedEvents {
    
    NSPredicate *futureEventsPredicate = [NSPredicate predicateWithFormat:@"self.date >= %@", [[NSDate date] dateByAddingTimeInterval:-7200]];
    NSArray *upcomingEvents = [futureEvents filteredArrayUsingPredicate:futureEventsPredicate];
    NSArray *persistedEvents = [storedEvents filteredArrayUsingPredicate:futureEventsPredicate];
    
    NSMutableArray *differencesArray = [[NSMutableArray alloc] init];
    for (Event *event in upcomingEvents) {
        if ([persistedEvents containsObject:event] == NO) {
            [differencesArray addObject:event];
        }
    }
    return differencesArray;
}


// Current list on server
- (void)getLatestEvents:(void (^)(NSArray<Event*> * __nullable events, NSError * __nullable error))completion {
    [self.service getFeedWithHandler:^(NSArray<Event *> * _Nonnull feedFetchItems, NSError * _Nullable error) {
        if (error) {
            completion(nil,error);
        } else {
            completion(feedFetchItems,nil);
        }
    }];
}


- (void)eventsFromPersistence:(void (^)(NSArray<Event*> * __nullable events, NSError * __nullable error))completion {
    completion(@[],nil);
}

@end
