//
//  Tracker.m
//  SpotHopper
//
//  Created by Brennan Stehling on 4/15/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

// Disables log messages when debugging is turned off
#ifndef NDEBUG

#define DebugLog(message, ...) NSLog(@"%s: " message, __PRETTY_FUNCTION__, ##__VA_ARGS__)

#else

#define DebugLog(message, ...)

#endif

#import "Tracker.h"

#import "TellMeMyLocation.h"
#import "Mixpanel.h"
#import "RavenClient.h"
#import "ErrorModel.h"

#define kUnknown @"Unknown"

@implementation Tracker

+ (void)track:(NSString *)event {
    if (kAnalyticsEnabled) {
        [[Mixpanel sharedInstance] track:event];
    }
}

+ (void)track:(NSString *)event properties:(NSDictionary *)properties {
    DebugLog(@"Event: %@", event);
    DebugLog(@"Properties: %@", properties);
    
    if (kAnalyticsEnabled) {
        [[Mixpanel sharedInstance] track:event properties:properties];
    }
}

+ (void)logInfo:(id)message class:(Class)class trace:(NSString *)trace {
    [self logForLevel:@"INFO" message:message class:class trace:trace];
}

+ (void)logWarning:(id)message class:(Class)class trace:(NSString *)trace {
    [self logForLevel:@"WARNING" message:message class:class trace:trace];
}

+ (void)logError:(id)message class:(Class)class trace:(NSString *)trace {
    [self logForLevel:@"ERROR" message:message class:class trace:trace];
}

+ (void)logFatal:(id)message class:(Class)class trace:(NSString *)trace {
    [self logForLevel:@"FATAL" message:message class:class trace:trace];
}

#pragma mark - Helpers
#pragma mark -

+ (void)trackLocationPropertiesForEvent:(NSString *)eventName properties:(NSDictionary *)properties {
    [self getPropertiesForLocation:[TellMeMyLocation currentLocation] prefix:@"Current" withCompletionBlock:^(NSDictionary *locationProperties, NSError *error) {
        NSMutableDictionary *updatedProperties = properties.mutableCopy;
        if (locationProperties) {
            [updatedProperties addEntriesFromDictionary:locationProperties];
        }
        
        [Tracker track:eventName properties:updatedProperties];
    }];
}

+ (void)getPropertiesForLocation:(CLLocation *)location prefix:(NSString *)prefix withCompletionBlock:(void (^)(NSDictionary *locationProperties, NSError *error))completionBlock {
    
    if (!location && completionBlock) {
        completionBlock(nil, nil);
        return;
    }
    
    [[[CLGeocoder alloc] init] reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error) {
            [Tracker logError:error class:[Tracker class] trace:NSStringFromSelector(_cmd)];
            if (completionBlock) {
                completionBlock(nil, error);
            }
        }
        else if (placemarks.count) {
            CLPlacemark *placemark = placemarks[0];
            NSString *locationName = [TellMeMyLocation shortLocationNameFromPlacemark:placemark];
            
            NSDictionary *properties = @{
                                         [NSString stringWithFormat:@"%@ location name", prefix] : locationName.length ? locationName : kUnknown,
                                         [NSString stringWithFormat:@"%@ location zip", prefix] : placemark.postalCode.length ? placemark.postalCode : kUnknown,
                                         [NSString stringWithFormat:@"%@ latitude", prefix] : [NSNumber numberWithFloat:location.coordinate.latitude],
                                         [NSString stringWithFormat:@"%@ longitude", prefix] : [NSNumber numberWithFloat:location.coordinate.longitude],
                                         };
            
            if (completionBlock) {
                completionBlock(properties, nil);
            }
        }
        else if (completionBlock) {
            completionBlock(nil, nil);
        }
    }];
}

#pragma mark - Private
#pragma mark -

+ (void)logForLevel:(NSString *)level message:(id)message class:(Class)class trace:(NSString *)trace {
    NSString *logMessage = nil;

    if (!message) {
        logMessage = [NSString stringWithFormat:@"ERROR: %@ - %@ - %@", @"Error was nil!", NSStringFromClass(class), trace];
    }
    else if ([message isKindOfClass:[NSString class]]) {
        NSString *msg = (NSString *)message;
        logMessage = [NSString stringWithFormat:@"ERROR: %@ - %@ - %@", msg, NSStringFromClass(class), trace];
    }
    else if ([message isKindOfClass:[NSError class]]) {
        NSError *err = (NSError *)message;
        logMessage = [NSString stringWithFormat:@"ERROR: %@ - %@ - %@", err.description, NSStringFromClass(class), trace];
    }
    else if ([message isKindOfClass:[ErrorModel class]]) {
        ErrorModel *err = (ErrorModel *)message;
        logMessage = [NSString stringWithFormat:@"ERROR: %@ - %@ - %@", err.human, NSStringFromClass(class), trace];
    }
    
    [[RavenClient sharedClient] captureMessage:logMessage level:kRavenLogLevelDebugError];
    DebugLog(@"%@", logMessage);
}

@end
