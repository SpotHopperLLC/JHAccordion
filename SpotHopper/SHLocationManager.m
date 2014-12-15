//
//  SHLocationManager.m
//  SpotChat
//
//  Created by Brennan Stehling on 10/9/14.
//  Copyright (c) 2014 SpotHopper LLC. All rights reserved.
//

#import "SHLocationManager.h"

#import "SHAppContext.h"
#import "SHNotifications.h"
#import "SHAppUtil.h"

#import "Tracker.h"

#define kMonitoringEnabledKey @"MonitoringEnabledKey"

#pragma mark - Class Extension
#pragma mark -

@interface SHLocationManager () <CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSTimer *timer;

@end

@implementation SHLocationManager {
    BOOL isWaitingForAuthorization;
}

+ (instancetype)defaultInstance {
    static SHLocationManager *_defaultInstance = nil;
    if (!_defaultInstance) {
        _defaultInstance = [[SHLocationManager alloc] init];
    }
    
    return _defaultInstance;
}

- (CLLocation *)location {
    DebugLog(@"%@ - %@", NSStringFromSelector(_cmd), self.locationManager.location);
    return self.locationManager.location;
}

- (void)wakeUp {
    if (self.isMonitoringEnabled) {
        [self startMonitoring];
    }
}

- (void)setMonitoringEnabled:(BOOL)monitoringEnabled {
    if (_monitoringEnabled != monitoringEnabled) {
        // start or stop location services accordingly
        if (monitoringEnabled && [self startMonitoring]) {
            // false is returned is authorization is need when starting monitoring
            _monitoringEnabled = TRUE;
        }
        else if (!monitoringEnabled && self.locationManager) {
            [self stopMonitoring];
            _monitoringEnabled = FALSE;
        }
        
        if (monitoringEnabled && !_monitoringEnabled) {
            // when authorization changes try again
            isWaitingForAuthorization = TRUE;
        }
        
        // store the current bool
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:[NSNumber numberWithBool:_monitoringEnabled] forKey:kMonitoringEnabledKey];
        [defaults synchronize];
    }
}

- (BOOL)startMonitoring {
    if (!self.locationManager) {
        CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
        
        if (![CLLocationManager locationServicesEnabled] || (status == kCLAuthorizationStatusRestricted || status == kCLAuthorizationStatusDenied)) {
            DebugLog(@"Location Services is not enabled or is not allowed by the device or user");
        }
        else {
            if (!self.locationManager) {
                CLLocationManager *locationManager = [[CLLocationManager alloc] init];
                self.locationManager = locationManager;
                self.locationManager.delegate = self;
            }

            MAAssert(self.locationManager, @"Location Manager must be defined");
            
            if ((status == kCLAuthorizationStatusAuthorized || status == kCLAuthorizationStatusNotDetermined) &&
                [self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
                [self.locationManager requestAlwaysAuthorization];
            }
        }
    }
    
    if (self.locationManager) {
        [self reportCurrentLocation];
        
        MAAssert([CLLocationManager significantLocationChangeMonitoringAvailable], @"Feature must be available");
        
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        self.locationManager.pausesLocationUpdatesAutomatically = YES;
        self.locationManager.activityType = CLActivityTypeAutomotiveNavigation;
        
        [self.locationManager startMonitoringSignificantLocationChanges];
        
        // startMonitoringSignificantLocationChanges and startUpdatingLocation?
        BOOL alsoUpdateLocations = FALSE;
        if (alsoUpdateLocations) {
            self.locationManager.distanceFilter = kCLDistanceFilterNone;
            //self.locationManager.distanceFilter = 25.0;

            [self.locationManager startUpdatingLocation];
        }
        DebugLog(@"Started monitoring significant location changes");
        
        [Tracker logInfo:@"Started monitoring significant location changes" class:[self class] trace:NSStringFromSelector(_cmd)];
    }
    
    return [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways;
}

- (void)reportCurrentLocation {
    if (self.location) {
        [self reportLatestLocations:@[self.location]];
    }
}

- (void)stopMonitoring {
    if (self.locationManager) {
        [self.locationManager stopMonitoringSignificantLocationChanges];
        DebugLog(@"Stopped monitoring significant location changes");
        [Tracker logInfo:@"Stopped monitoring significant location changes" class:[self class] trace:NSStringFromSelector(_cmd)];
    }
}

- (BOOL)isDenied {
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    return ![CLLocationManager locationServicesEnabled] || status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusRestricted;
}

- (BOOL)isAuthorized {
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    
    if ([CLLocationManager locationServicesEnabled]) {
        if (status == kCLAuthorizationStatusAuthorized) {
            return TRUE;
        }
        else if (status != kCLAuthorizationStatusAuthorizedAlways && [self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            // iOS 8+ support
            return status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse;
        }
    }
    
    return FALSE;
}

- (BOOL)isAuthorizationNotDetermined {
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    return status == kCLAuthorizationStatusNotDetermined;
}

#pragma mark - Notifications
#pragma mark -

- (void)reportLatestLocations:(NSArray *)locations {
    if (locations.count) {
        CLLocation *location = locations.firstObject;
        [SHAppContext setCurrentDeviceLocation:location];
    }
}

#pragma mark - CLLocationManagerDelegate
#pragma mark -

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    DebugLog(@"Error: %@", error);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    DebugLog(@"%@, %@", NSStringFromSelector(_cmd), locations);
    
    CLLocation *location = locations.firstObject;
    if (location) {
        [[SHAppUtil defaultInstance] processSignificantLocationChange:location];
    }
    
    [self reportLatestLocations:locations];

    // allow deferring updates for 25 meters and 2 minutes (120 seconds)
    [manager allowDeferredLocationUpdatesUntilTraveled:25.0 timeout:120.0];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (isWaitingForAuthorization && self.isAuthorized) {
        self.monitoringEnabled = TRUE;
    }
}

@end
