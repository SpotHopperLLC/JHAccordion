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

#import "SHAppContext.h"
#import "SHLocationManager.h"
#import "Mixpanel.h"
#import "ErrorModel.h"
#import "UserModel.h"
#import "UserState.h"
#import "ClientSessionManager.h"

#import "SHAppConfiguration.h"

#import <Parse/Parse.h>

#define kUnknown @"Unknown"

@implementation Tracker

+ (void)track:(NSString *)event {
    if ([SHAppConfiguration isTrackingEnabled]) {
        //DebugLog(@"event: %@", event);
        [[Mixpanel sharedInstance] track:event];
    }
}

+ (void)track:(NSString *)event properties:(NSDictionary *)properties {
    [self track:event properties:properties andTrackUserAction:FALSE];
}

+ (void)track:(NSString *)event properties:(NSDictionary *)properties andTrackUserAction:(BOOL)trackUserAction {
    DebugLog(@"Event: %@", event);
//    DebugLog(@"Properties: %@", properties);
    
    if ([SHAppConfiguration isTrackingEnabled]) {
        [[Mixpanel sharedInstance] track:event properties:properties];
        
        if (trackUserAction) {
            [self trackUserAction:event];
        }
    }
}

+ (void)trackInteraction:(NSString *)interaction {
    if (interaction.length && [SHAppConfiguration isParseEnabled]) {
        PFObject *interactionLog = [PFObject objectWithClassName:@"InteractionLog"];
        [interactionLog setObject:interaction forKey:@"interaction"];
        [interactionLog setObject:[PFUser currentUser] forKey:@"user"];
        
        CLLocation *location = [[SHLocationManager defaultInstance] location];
        if (location) {
            PFGeoPoint *point = [PFGeoPoint geoPointWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude];
            [interactionLog setObject:point forKey:@"location"];
        }
        
        [interactionLog setObject:[SHAppConfiguration bundleIdentifier] forKey:@"appIdentifier"];
        [interactionLog setObject:[SHAppConfiguration bundleDisplayName] forKey:@"appName"];
        
        [interactionLog saveEventually];
    }
}

+ (void)identifyUser {
    DebugLog(@"Identifying user with Mixpanel");
    
    if ([SHAppConfiguration isTrackingEnabled] && [UserModel isLoggedIn]) {
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        UserModel *user = [[ClientSessionManager sharedClient] currentUser];
        NSString *userId = [NSString stringWithFormat:@"%@", user.ID];
        [mixpanel identify:mixpanel.distinctId];
        [mixpanel createAlias:userId forDistinctID:mixpanel.distinctId];
        DebugLog(@"mixpanel.distinctId: %@", mixpanel.distinctId);
        
//        [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        
    }
    else if (![UserModel isLoggedIn]) {
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        [mixpanel identify:mixpanel.distinctId];
    }
}

+ (void)trackUserWithProperties:(NSDictionary *)properties {
    [self trackUserWithProperties:properties updateLocation:FALSE];
}

+ (void)trackUserPropertyForKey:(NSString *)key withValue:(NSString *)value {
    if (key.length && value.length) {
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        [mixpanel.people set:@{key : value}];
    }
}

+ (void)trackUserWithProperties:(NSDictionary *)properties updateLocation:(BOOL)updateLocation {
    if (![SHAppConfiguration isTrackingEnabled] || ![[ClientSessionManager sharedClient] isLoggedIn]) {
        return;
    }
    
    UserModel *user = [[ClientSessionManager sharedClient] currentUser];
    
    NSString *birthYear = nil;
    NSString *birthDate = nil;
    if (user.birthday) {
        NSAssert(user.birthday, @"Date must be defined");
        NSUInteger componentFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
        NSDateComponents *components = [[NSCalendar currentCalendar] components:componentFlags fromDate:user.birthday];
        birthYear = [NSString stringWithFormat:@"%li", (long)[components year]];
        birthDate = [NSString stringWithFormat:@"%li-%li-%li", (long)[components year], (long)[components month], (long)[components day]];
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
    
    if (user.name.length) {
        updatedProperties[@"name"] = user.name;
    }
    if (user.role.length) {
        updatedProperties[@"role"] = user.role;
    }
    if (user.email.length) {
        updatedProperties[@"email"] = user.email;
    }
    if (user.facebookId.length) {
        updatedProperties[@"facebookId"] = user.facebookId;
    }
    if (user.twitterId.length) {
        updatedProperties[@"twitterId"] = user.twitterId;
    }
    if (user.gender.length) {
        updatedProperties[@"gender"] = user.gender;
    }
    if (birthYear.length) {
        updatedProperties[@"birthYear"] = birthYear;
    }
    if (birthDate.length) {
        updatedProperties[@"birthDate"] = birthDate;
    }
    
    NSDate *firstUseDate = [UserState firstUseDate];
    if (firstUseDate) {
        updatedProperties[@"firstUseDate"] = firstUseDate;
    }
    
    updatedProperties[@"locationServices"] = authorizationStatus;
    
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    
    if (updateLocation) {
        [updatedProperties addEntriesFromDictionary:[self locationProperties]];
    }
    
    [mixpanel.people set:updatedProperties];
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
    CLLocation *currentLocation = [SHAppContext currentLocation];
    CLLocation *mapCenterLocation = [SHAppContext mapCenterLocation];
    NSString *currentLocationName = [SHAppContext currentLocationName];
    NSString *mapCenterLocationName = [SHAppContext mapCenterLocationName];
    NSString *currentLocationZip = [SHAppContext currentLocationZip];
    NSString *mapCenterLocationZip = [SHAppContext mapCenterLocationZip];

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
    
    return locationProperties;
}

#pragma mark - Private
#pragma mark -

+ (void)logForLevel:(NSString *)level message:(id)message class:(Class)class trace:(NSString *)trace {
    NSString *logMessage = nil;

    if (!message) {
        logMessage = [NSString stringWithFormat:@"%@", @"Error was nil!"];
    }
    else if ([message isKindOfClass:[NSString class]]) {
        NSString *msg = (NSString *)message;
        logMessage = [NSString stringWithFormat:@"ERROR: %@", msg];
    }
    else if ([message isKindOfClass:[NSError class]]) {
        NSError *err = (NSError *)message;
        logMessage = [NSString stringWithFormat:@"ERROR: %@", err.description];
    }
    else if ([message isKindOfClass:[ErrorModel class]]) {
        ErrorModel *err = (ErrorModel *)message;
        logMessage = [NSString stringWithFormat:@"ERROR: %@", err.human];
    }
    
    NSString *className = NSStringFromClass(class);
    
    [self track:@"Log Message" properties:@{
                                            @"Message" : logMessage.length ? logMessage : @"N/A",
                                            @"Class" : className.length ? className : @"N/A",
                                            @"Trace" : trace.length ? trace : @"N/A",
                                            @"Level" : level.length ? level : @"N/A"}];
    
//    CLS_LOG(@"%@ - %@ - %@", logMessage, className, trace);
}

@end
