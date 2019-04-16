//
//  EventChanges.m
//  SF iOS
//
//  Created by Jerry Tung on 4/4/19.
//  Copyright © 2019 Amit Jain. All rights reserved.
//

#import "EventChanges.h"
#import "Event.h"
#import "UNUserNotificationCenter+Convenience.h"
#import "NSDate+Utilities.h"
#import "EventDataSource.h"
#import <Realm/Realm.h>

@interface EventChanges () <EventDataSourceDelegate>
//@property (nonatomic) FeedFetchService *service;
@property(nonatomic, strong) EventDataSource *eventDataSource;

@property(nonatomic, strong) RLMResults<Event*> *persistedEvents;


@end

@implementation EventChanges

- (instancetype)init {
    if (self = [super init]) {
        // Pre-check current and future events
        self.persistedEvents = [Event objectsWhere:@"self.date >= %@", [NSDate date]];
        
        self.eventDataSource = [[EventDataSource alloc] initWithEventType:EventTypeSFCoffee];
        self.eventDataSource.delegate = self;
    }
    return self;
}

// MARK: - Check for changes
- (void)checkForEventDifferences {
    [self.eventDataSource refresh];
}


- (void)eventsChanged:(NSNumber* _Nullable)numberEventsModified withError:(NSError* _Nullable)error withCompletion:(EventChangeCompletion)completionHandler {
    
    if (error) {
        completionHandler(nil,error);
    }
    
//    if ([numberEventsModified integerValue] && !error) {
    
        NSString *contentTitle = [NSString stringWithFormat:@"%ld Coffee Events Changed", [numberEventsModified integerValue]];
        
        NSString *contentBody = @"";
        
        [[UNUserNotificationCenter currentNotificationCenter] scheduleNotificationWithIdentifier:nil contentTitle:contentTitle contentBody:contentBody];
        
        completionHandler(@(YES),nil);
//    }
//
//    completionHandler(@(NO),nil);

    /*
     -(void)getFeedWithHandler:(FeedFetchCompletionHandler)completionHandler {
     FeedFetchOperation *operation = [[FeedFetchOperation alloc] initWithCompletionHandler:^(NSArray<NSDictionary *> *feed, NSError *_Nullable error) {
     NSMutableArray<Event *> *events = [[NSMutableArray alloc] initWithCapacity:feed.count];
     for (NSDictionary *dict in feed) {
     [events addObject:[[Event alloc] initWithDictionary:dict]];
     }
     completionHandler(events, error);
     }];
     [self.feedFetchQueue addOperation:operation];
     }
     */

}

- (NSArray<Event*> *)compareFutureEvents:(RLMResults<Event*> *)futureEvents withStoredEvents:(RLMResults<Event*> *)persistedEvents {
    NSMutableArray *differencesArray = [[NSMutableArray alloc] init];
    for (Event *event in futureEvents) {
        if ([persistedEvents indexOfObject:event] == NSNotFound) {
            [differencesArray addObject:event];
        }
    }
    return differencesArray;
}

// MARK: - EventDataSourceDelegate
- (void)didChangeDataSourceWithInsertions:(nullable NSArray <NSIndexPath *> *)insertions
                                  updates:(nullable NSArray <NSIndexPath *> *)updates
                                deletions:(nullable NSArray <NSIndexPath *> *)deletions {
    NSLog(@"%s",__FUNCTION__);

//    NSLog(@"Strange behavior insertions: %ld\ndeletions: %ld\nupdates: %ld", insertions.count, deletions.count, updates.count);
    
    [[UNUserNotificationCenter currentNotificationCenter] scheduleNotificationWithIdentifier:nil contentTitle:@"No updates" contentBody:@"Did Change"];

}

- (void)willUpdateDataSource:(EventDataSource *)datasource {
    NSLog(@"%s",__FUNCTION__);
    
    RLMResults<Event*> *futureEvents = [Event objectsWhere:@"self.date >= %@", [NSDate date]];
    
    NSArray *eventListModified = [self compareFutureEvents:futureEvents withStoredEvents:_persistedEvents];
    
    if (eventListModified.count > 0) {
        [self eventsChanged:@(eventListModified.count) withError:nil withCompletion:^(NSNumber *_Nullable eventsHaveChanged, NSError *_Nullable error){}];
    }
}

- (void)didFailToUpdateWithError:(NSError *)error {
    NSLog(@"%s",__FUNCTION__);
    [self eventsChanged:nil withError:error withCompletion:^(NSNumber *_Nullable eventsHaveChanged, NSError *_Nullable error){}];
}


@end
