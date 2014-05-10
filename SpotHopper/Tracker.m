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

+ (void)logInfo:(NSString *)message {
    NSString *caller = [[NSThread callStackSymbols] objectAtIndex:1];
    message = [NSString stringWithFormat:@"INFO: %@ (%@)", message, caller];
    [[RavenClient sharedClient] captureMessage:message level:kRavenLogLevelDebugInfo];
    DebugLog(@"%@", message);
}

+ (void)logWarning:(NSString *)message {
    NSString *caller = [[NSThread callStackSymbols] objectAtIndex:1];
    message = [NSString stringWithFormat:@"WARNING: %@ (%@)", message, caller];
    [[RavenClient sharedClient] captureMessage:message level:kRavenLogLevelDebugWarning];
    DebugLog(@"%@", message);
}

+ (void)logError:(NSString *)message {
    NSString *caller = [[NSThread callStackSymbols] objectAtIndex:1];
    message = [NSString stringWithFormat:@"ERROR: %@ (%@)", message, caller];
    [[RavenClient sharedClient] captureMessage:message level:kRavenLogLevelDebugError];
    DebugLog(@"%@", message);
}

+ (void)logFatal:(NSString *)message {
    NSString *caller = [[NSThread callStackSymbols] objectAtIndex:1];
    message = [NSString stringWithFormat:@"FATAL: %@ (%@)", message, caller];
    [[RavenClient sharedClient] captureMessage:message level:kRavenLogLevelDebugFatal];
    DebugLog(@"%@", message);
}

@end
