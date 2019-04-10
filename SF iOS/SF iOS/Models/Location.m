//
//  Location.m
//  SF iOS
//
//  Created by Amit Jain on 7/28/17.
//  Copyright © 2017 Amit Jain. All rights reserved.
//

#import "Location.h"

@implementation Location

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super init]) {
        self.streetAddress = dict[@"formatted_address"];
        CLLocationDegrees latitude = [dict[@"latitude"] doubleValue];
        CLLocationDegrees longitude = [dict[@"longitude"] doubleValue];
        self.latitude = latitude;
        self.longitude = longitude;
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[self class]] == NO) {
        return NO;
    }
    
    return ([self.streetAddress isEqualToString:((Location*)object).streetAddress] &&
            [self.location distanceFromLocation:((Location*)object).location] < 0.05);
}

+ (NSString *)primaryKey {
    return @"streetAddress";
}

- (CLLocation *)location {
    return [[CLLocation alloc] initWithLatitude:self.latitude
                                      longitude:self.longitude];
}

@end
