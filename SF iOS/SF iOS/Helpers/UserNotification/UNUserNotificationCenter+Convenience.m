//
//  UNUserNotificationCenter+Convenience.m
//  SF iOS
//
//  Created by Jerry Tung on 4/4/19.
//  Copyright © 2019 Amit Jain. All rights reserved.
//

#import "UNUserNotificationCenter+Convenience.h"
#import "NSDate+Utilities.h"

static const NSTimeInterval timeUntilNotification = 10.0;

@implementation UNUserNotificationCenter(Convenience)

- (void)scheduleNotificationWithIdentifier:(NSString*)identifier
                                   content:(UNMutableNotificationContent*)content
                                   trigger:(UNTimeIntervalNotificationTrigger*)trigger {
    content.badge = @(1);
    
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:identifier content:content trigger:trigger];
    
    [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError* error) {
        if (error) {
            NSLog(@"Error: %@", error.localizedDescription);
        }
    }];
}

- (void)scheduleNotificationWithIdentifier:(NSString* __nullable)identifier
                              contentTitle:(NSString*)title
                               contentBody:(NSString*)body {
     
    UNTimeIntervalNotificationTrigger* trigger = [UNTimeIntervalNotificationTrigger
                                                  triggerWithTimeInterval:(timeUntilNotification) repeats: NO];
    
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.title = title;
    content.body = body;
    content.badge = @(1);

    NSString *requestIdentifier = (identifier != nil) ? identifier : [[NSDate date] stringWithformat:@"yyyyMMdd:hhmmss"];
    
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:requestIdentifier content:content trigger:trigger];
    
    NSLog(@"This point");
    [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError* error) {
        if (error) {
            NSLog(@"Error: %@", error.localizedDescription);
        }
    }];
    
}

@end
