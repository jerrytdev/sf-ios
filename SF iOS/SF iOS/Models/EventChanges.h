//
//  EventChanges.h
//  SF iOS
//
//  Created by Jerry Tung on 4/4/19.
//  Copyright © 2019 Amit Jain. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^EventChangeCompletion)(NSNumber *_Nullable eventsHaveChanged, NSError *_Nullable error);

/**
 Check for new or modified events - display local notification
 */
@interface EventChanges : NSObject

@property(nonatomic, strong) void (^completionHandler)(EventChangeCompletion);

- (instancetype)init;

/**
 Check for differences between the server's event list and the list on the persisted store. Only check for future events.
 */
- (void)checkForEventDifferences;

- (void)eventsChanged:(NSNumber* _Nullable)numberEventsModified withError:(NSError* _Nullable)error withCompletion:(EventChangeCompletion)completionHandler;

@end

NS_ASSUME_NONNULL_END
