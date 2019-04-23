//
//  UserLocation.h
//  SF iOS
//
//  Created by Amit Jain on 8/1/17.
//  Copyright © 2017 Amit Jain. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreLocation;

NS_ASSUME_NONNULL_BEGIN

@class UserLocation;

@protocol UserLocationDelegate
- (void)userLocationPermissionsChanged:(CLAuthorizationStatus)status;
@end

@interface UserLocation : NSObject <CLLocationManagerDelegate>

@property (nonatomic, weak) id<UserLocationDelegate> delegate;

- (BOOL)canRequestUserLocation;
- (BOOL)canRequestLocationPermission;
- (void)requestLocationPermission;

typedef void(^UserLocationRequestCompletionHandler)(CLLocation *_Nullable currentLocation, NSError *_Nullable error);
- (void)requestWithCompletionHandler:(UserLocationRequestCompletionHandler)completionHandler;

@end
NS_ASSUME_NONNULL_END
