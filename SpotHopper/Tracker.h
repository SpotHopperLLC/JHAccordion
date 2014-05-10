//
//  Tracker.h
//  SpotHopper
//
//  Created by Brennan Stehling on 4/15/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Tracker : NSObject

// Mixpanel
+ (void)track:(NSString *)event;
+ (void)track:(NSString *)event properties:(NSDictionary *)properties;

// Sentry
+ (void)logInfo:(NSString *)message;
+ (void)logWarning:(NSString *)message;
+ (void)logError:(NSString *)message;
+ (void)logFatal:(NSString *)message;

@end
