//
//  Tracker.h
//  SpotHopper
//
//  Created by Brennan Stehling on 4/15/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface Tracker : NSObject

// Mixpanel
+ (void)track:(NSString *)event;
+ (void)track:(NSString *)event properties:(NSDictionary *)properties;

// Sentry
+ (void)logInfo:(id)message class:(Class)class trace:(NSString *)trace;
+ (void)logWarning:(id)message class:(Class)class trace:(NSString *)trace;
+ (void)logError:(id)message class:(Class)class trace:(NSString *)trace;
+ (void)logFatal:(id)message class:(Class)class trace:(NSString *)trace;

+ (void)trackLocationPropertiesForEvent:(NSString *)eventName properties:(NSDictionary *)properties;

+ (void)getPropertiesForLocation:(CLLocation *)location prefix:(NSString *)prefix withCompletionBlock:(void (^)(NSDictionary *locationProperties, NSError *error))completionBlock;

@end
