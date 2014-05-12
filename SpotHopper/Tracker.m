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

#import "Mixpanel.h"
#import "RavenClient.h"

@implementation Tracker

+ (void)track:(NSString *)event {
    if (kAnalyticsEnabled) {
        [[Mixpanel sharedInstance] track:event];
    }
}

+ (void)track:(NSString *)event properties:(NSDictionary *)properties {
    if (kAnalyticsEnabled) {
        [[Mixpanel sharedInstance] track:event properties:properties];
    }
}

+ (void)logInfo:(NSString *)message class:(Class)class trace:(NSString *)trace {
    [self logForLevel:@"INFO" message:message class:class trace:trace];
}

+ (void)logWarning:(NSString *)message class:(Class)class trace:(NSString *)trace {
    [self logForLevel:@"WARNING" message:message class:class trace:trace];
}

+ (void)logError:(NSString *)message class:(Class)class trace:(NSString *)trace {
    [self logForLevel:@"ERROR" message:message class:class trace:trace];
}

+ (void)logFatal:(NSString *)message class:(Class)class trace:(NSString *)trace {
    [self logForLevel:@"FATAL" message:message class:class trace:trace];
}

#pragma mark - Private
#pragma mark -

+ (void)logForLevel:(NSString *)level message:(NSString *)message class:(Class)class trace:(NSString *)trace {
    NSString *logMessage = [NSString stringWithFormat:@"ERROR: %@ - %@ - %@", message, NSStringFromClass(class), trace];
    [[RavenClient sharedClient] captureMessage:logMessage level:kRavenLogLevelDebugError];
    DebugLog(@"%@", logMessage);
}

@end
