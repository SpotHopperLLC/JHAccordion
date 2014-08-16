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
        [[Mixpanel sharedInstance] track:event];
    }
}

+ (void)track:(NSString *)event properties:(NSDictionary *)properties {
    [self track:event properties:properties andTrackUserAction:FALSE];
}

+ (void)track:(NSString *)event properties:(NSDictionary *)properties andTrackUserAction:(BOOL)trackUserAction {
//    DebugLog(@"Event: %@", event);
//    DebugLog(@"Properties: %@", properties);
    
    if ([SHAppConfiguration isTrackingEnabled]) {
        [[Mixpanel sharedInstance] track:event properties:properties];
        
        if (trackUserAction) {
            [self trackUserAction:event];
        }
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
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    NSString *userId = [NSString stringWithFormat:@"%@", user.ID];
    [mixpanel createAlias:userId forDistinctID:[mixpanel distinctId]];
    [mixpanel identify:[mixpanel distinctId]];
    
    id birthYear = [NSNull null];
    if (user.birthday) {
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
                                                  @"name" : user.name.length ? user.name : @"",
                                                  @"role" : user.role.length ? user.role : @"",
                                                  @"facebookId" : user.facebookId.length ? user.facebookId : @"",
                                                  @"twitterId" : user.twitterId.length ? user.twitterId : @"",
                                                  @"gender" : user.gender.length ? user.gender : @"",
                                                  @"birthYear" : birthYear,
                                                  @"locationServices" : authorizationStatus
                                                  }];
    
    if (updateLocation) {
        [self fetchLocationPropertiesWithCompletionBlock:^(NSDictionary *locationProperties, NSError *error) {
            [updatedProperties addEntriesFromDictionary:locationProperties];
            [mixpanel.people set:updatedProperties];
        }];
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
    [self fetchLocationPropertiesWithCompletionBlock:^(NSDictionary *locationProperties, NSError *error) {
        NSMutableDictionary *updatedProperties = properties.mutableCopy;
        [updatedProperties addEntriesFromDictionary:locationProperties];
        [Tracker track:eventName properties:updatedProperties];
    }];
}

+ (void)fetchLocationPropertiesWithCompletionBlock:(void (^)(NSDictionary *locationProperties, NSError *error))completionBlock {
    CLLocation *mapCenterLocation = [TellMeMyLocation mapCenterLocation];
    CLLocation *currentLocation = [TellMeMyLocation currentLocation];
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
    
    [self fetchPropertiesForLocation:[TellMeMyLocation currentLocation] prefix:@"Current" withCompletionBlock:^(NSDictionary *currentLocationProperties, NSError *error) {
        if (error) {
            [self logError:error class:[self class] trace:NSStringFromSelector(_cmd)];
        }
        [self fetchPropertiesForLocation:[TellMeMyLocation mapCenterLocation] prefix:@"Center" withCompletionBlock:^(NSDictionary *mapCenterLocationProperties, NSError *error) {
            if (error) {
                [self logError:error class:[self class] trace:NSStringFromSelector(_cmd)];
            }

            NSMutableDictionary *locationProperties = @{}.mutableCopy;
            if (currentLocationProperties) {
                [locationProperties addEntriesFromDictionary:currentLocationProperties];
            }
            
            if (mapCenterLocationProperties) {
                [locationProperties addEntriesFromDictionary:mapCenterLocationProperties];
            }
            
            locationProperties[@"Distance in meters"] = [NSNumber numberWithFloat:distance];
            locationProperties[@"Location Services"] = authorizationStatus;
            
            if (completionBlock) {
                completionBlock(locationProperties, nil);
            }
        }];
    }];
}

+ (void)fetchPropertiesForLocation:(CLLocation *)location prefix:(NSString *)prefix withCompletionBlock:(void (^)(NSDictionary *locationProperties, NSError *error))completionBlock {
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
                                         [NSString stringWithFormat:@"%@ longitude", prefix] : [NSNumber numberWithFloat:location.coordinate.longitude]
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
