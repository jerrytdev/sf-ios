//
//  EventChanges.h
//  SF iOS
//
//  Created by Jerry Tung on 4/4/19.
//  Copyright © 2019 Amit Jain. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


/**
 Check for new or modified events - display local notification
 */
@interface EventChanges : NSObject
- (instancetype)init;

/**
 Check for differences between the server's event list and the list on the persisted store. Only check for future events.
 */
- (void)checkForEventDifferences;

@end

NS_ASSUME_NONNULL_END
