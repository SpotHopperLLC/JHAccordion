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
#import "UserModel.h"
#import "ClientSessionManager.h"

#import "SHAppConfiguration.h"

#define kUnknown @"Unknown"

@implementation Tracker

+ (void)track:(NSString *)event {
    if ([SHAppConfiguration isTrackingEnabled]) {
        DebugLog(@"event: %@", event);
        [[Mixpanel sharedInstance] track:event];
    }
}

+ (void)track:(NSString *)event properties:(NSDictionary *)properties {
    [self track:event properties:properties andTrackUserAction:FALSE];
}

+ (void)track:(NSString *)event properties:(NSDictionary *)properties andTrackUserAction:(BOOL)trackUserAction {
    DebugLog(@"Event: %@", event);
    DebugLog(@"Properties: %@", properties);
    
    if ([SHAppConfiguration isTrackingEnabled]) {
        [[Mixpanel sharedInstance] track:event properties:properties];
        
        if (trackUserAction) {
            [self trackUserAction:event];
        }
    }
}

+ (void)identifyUser {
    if ([SHAppConfiguration isTrackingEnabled] && [UserModel isLoggedIn]) {
        UserModel *user = [[ClientSessionManager sharedClient] currentUser];
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        NSString *userId = [NSString stringWithFormat:@"%@", user.ID];
        [mixpanel createAlias:userId forDistinctID:mixpanel.distinctId];
        [mixpanel identify:mixpanel.distinctId];
    }
}

+ (void)trackUserWithProperties:(NSDictionary *)properties {
    [self trackUserWithProperties:properties updateLocation:FALSE];
}

+ (void)trackUserWithProperties:(NSDictionary *)properties updateLocation:(BOOL)updateLocation {
    if (![SHAppConfiguration isTrackingEnabled] || ![[ClientSessionManager sharedClient] isLoggedIn]) {
        return;
    }
    
    UserModel *user = [[ClientSessionManager sharedClient] currentUser];
    
    id birthYear = @"NULL";
    if (user.birthday) {
        NSAssert(user.birthday, @"Date must be defined");
        NSUInteger componentFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
        NSDateComponents *components = [[NSCalendar currentCalendar] components:componentFlags fromDate:user.birthday];
        birthYear = [NSNumber numberWithInteger:[components year]];
    }
    
    NSMutableDictionary *updatedProperties = properties.mutableCopy;
    
    NSString *authorizationStatus = nil;
    switch ([CLLocationManager authorizationStatus]) {
        case kCLAuthorizationStatusRestricted:
            authorizationStatus = @"Restricted";
            break;
        case kCLAuthorizationStatusDenied:
            authorizationStatus = @"Denied";
            break;
        case kCLAuthorizationStatusAuthorized:
            authorizationStatus = @"Authorized";
            break;
            
        default:
            authorizationStatus = @"Not Determined";
            break;
    }
    
    [updatedProperties addEntriesFromDictionary:@{
                                                  @"name" : user.name.length ? user.name : @"NULL",
                                                  @"role" : user.role.length ? user.role : @"NULL",
                                                  @"email" : user.email.length ? user.email : @"NULL",
                                                  @"facebookId" : user.facebookId.length ? user.facebookId : @"NULL",
                                                  @"twitterId" : user.twitterId.length ? user.twitterId : @"NULL",
                                                  @"gender" : user.gender.length ? user.gender : @"NULL",
                                                  @"birthYear" : birthYear,
                                                  @"locationServices" : authorizationStatus
                                                  }];
    
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    
    if (updateLocation) {
        [updatedProperties addEntriesFromDictionary:[self locationProperties]];
        [mixpanel.people set:updatedProperties];
    }
    else {
        [mixpanel.people set:updatedProperties];
    }
}

+ (void)trackUserAction:(NSString *)actionName {
    if (![SHAppConfiguration isTrackingEnabled] || ![[ClientSessionManager sharedClient] isLoggedIn]) {
        return;
    }
    
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel.people increment:actionName by:[NSNumber numberWithInt:1]];
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
    NSMutableDictionary *updatedProperties = properties.mutableCopy;
    [updatedProperties addEntriesFromDictionary:[self locationProperties]];
    [Tracker track:eventName properties:updatedProperties];
}

+ (NSDictionary *)locationProperties {
    CLLocation *currentLocation = [TellMeMyLocation currentLocation];
    CLLocation *mapCenterLocation = [TellMeMyLocation mapCenterLocation];
    NSString *currentLocationName = [TellMeMyLocation currentLocationName];
    NSString *mapCenterLocationName = [TellMeMyLocation mapCenterLocationName];
    NSString *currentLocationZip = [TellMeMyLocation currentLocationZip];
    NSString *mapCenterLocationZip = [TellMeMyLocation mapCenterLocationZip];

    CLLocationDistance distance = [mapCenterLocation distanceFromLocation:currentLocation];
    
    NSString *authorizationStatus = nil;
    
    switch ([CLLocationManager authorizationStatus]) {
        case kCLAuthorizationStatusRestricted:
            authorizationStatus = @"Restricted";
            break;
        case kCLAuthorizationStatusDenied:
            authorizationStatus = @"Denied";
            break;
        case kCLAuthorizationStatusAuthorized:
            authorizationStatus = @"Authorized";
            break;
            
        default:
            authorizationStatus = @"Not Determined";
            break;
    }
    
    NSMutableDictionary *locationProperties = @{}.mutableCopy;
    locationProperties[@"Distance in meters"] = [NSNumber numberWithFloat:distance];
    locationProperties[@"Location Services"] = authorizationStatus;
    
    locationProperties[@"Current location name"] = currentLocationName.length ? currentLocationName : kUnknown;
    locationProperties[@"Current location zip"] = currentLocationZip.length ? currentLocationZip : kUnknown;
    locationProperties[@"Current latitude"] = [NSNumber numberWithFloat:currentLocation.coordinate.latitude];
    locationProperties[@"Current longitude"] = [NSNumber numberWithFloat:currentLocation.coordinate.longitude];
    
    locationProperties[@"Center location name"] = mapCenterLocationName.length ? mapCenterLocationName : kUnknown;
    locationProperties[@"Center location zip"] = mapCenterLocationZip.length ? mapCenterLocationZip : kUnknown;
    locationProperties[@"Center latitude"] = [NSNumber numberWithFloat:mapCenterLocation.coordinate.latitude];
    locationProperties[@"Center longitude"] = [NSNumber numberWithFloat:mapCenterLocation.coordinate.longitude];
    
    DebugLog(@"locationProperties: %@", locationProperties);
    
    return locationProperties;
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
