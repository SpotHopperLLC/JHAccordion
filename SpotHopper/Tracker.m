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
#import "ErrorModel.h"

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
