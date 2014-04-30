//
//  TellMeMyLocation.m
//  PatronApp
//
//  Created by Josh Holtz on 5/23/12.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#define kLocationUpdateTimeout              2.0
#define kTimeBetweenLocationRefreshes       30
#define kSimulatorLatitude                  43.060179
#define kSimulatorLongitude                 -87.885228

#define kLastLocationLat @"last_location_lat"
#define kLastLocationLng @"last_location_lng"
#define kLastLocationName @"last_location_name"
#define kLastLocationDate @"last_location_date"
#define kLastLocationNameShort @"last_location_name_short"

#import "TellMeMyLocation.h"

#import <CoreLocation/CoreLocation.h>

NSString * const kTellMeMyLocationChangedNotification = @"TellMeMyLocationChangedNotification";

@interface TellMeMyLocation() <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, copy) FoundBlock foundBlock;
@property (nonatomic, copy) FailureBlock failureBlock;

@property (nonatomic, strong) CLLocation *bestLocation;

@end

@implementation TellMeMyLocation {
    CLAuthorizationStatus _authorizationStatus;
}

static CLLocation *_currentDeviceLocation;
static NSDate *_lastDeviceLocationRefresh;

#pragma mark - Public Implemention

- (void)findMe:(CLLocationAccuracy)accuracy found:(FoundBlock)foundBlock failure:(FailureBlock)failureBlock {
    // finish immediately if the device location was refreshed recently
    if (_lastDeviceLocationRefresh && _bestLocation && foundBlock) {
        NSTimeInterval diff = [[NSDate date] timeIntervalSinceDate:_lastDeviceLocationRefresh];
        if (diff <= kTimeBetweenLocationRefreshes) {
            foundBlock(_bestLocation);
            return;
        }
    }
    
    if ([CLLocationManager locationServicesEnabled]) {
        if ([CLLocationManager authorizationStatus]==kCLAuthorizationStatusDenied){
            failureBlock([NSError errorWithDomain:kTellMeMyLocationDomain code:1 userInfo:@{
                                                                                              NSLocalizedDescriptionKey : @"App Permission Denied",
                                                                                              NSLocalizedRecoverySuggestionErrorKey : @"To re-enable, please go to Settings and turn on Location Service for this app."
                                                                                              }]);
            return;
        }
    }
    else {
        failureBlock([NSError errorWithDomain:kTellMeMyLocationDomain code:1 userInfo:@{
                                                                                          NSLocalizedDescriptionKey : @"Permission Denied",
                                                                                          NSLocalizedRecoverySuggestionErrorKey : @"To re-enable, please go to Settings and turn on Location Services"
                                                                                          }]);
        return;
    }
    
    if (_locationManager == nil) {
        _locationManager = [[CLLocationManager alloc] init];
        [_locationManager setDelegate:self];
    }
    
    _foundBlock = [foundBlock copy];
    _failureBlock = [failureBlock copy];

    [_locationManager setDesiredAccuracy:accuracy];
    [_locationManager startUpdatingLocation];
    [self performSelector:@selector(stopUpdatingLocationAfterTimeout:) withObject:_locationManager afterDelay:kLocationUpdateTimeout];

}

+ (CLLocation *)currentDeviceLocation {
    return _currentDeviceLocation;
}

+ (void)setLastLocation:(CLLocation*)location completionHandler:(TellMeMyLocationCompletionHandler)completionHandler {
    // Saves location
    if (location) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:location.coordinate.latitude] forKey:kLastLocationLat];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:location.coordinate.longitude] forKey:kLastLocationLng];
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kLastLocationDate];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kLastLocationLat];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kLastLocationLng];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kLastLocationDate];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // Reverse geocodes
    [[[CLGeocoder alloc] init] reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        
        // Saves location name
        if (!error) {
            if (placemarks.count > 0) {
                CLPlacemark *placemark = [placemarks objectAtIndex:0];
                
                if (placemark.locality.length > 0 && placemark.administrativeArea.length > 0) {
                    NSString *locationName = [NSString stringWithFormat:@"%@, %@, %@", placemark.subLocality, placemark.locality, placemark.administrativeArea];
                    if (locationName.length > 25) {
                        locationName = [NSString stringWithFormat:@"%@, %@", placemark.locality, placemark.administrativeArea];
                    }
                    
                    [self setLastLocationName:locationName];
                } else if (placemark.locality.length > 0) {
                    [self setLastLocationName:placemark.locality];
                } else if (placemark.administrativeArea.length > 0) {
                    [self setLastLocationName:placemark.administrativeArea];
                }
                
                [self setLastLocationNameShort:[NSString stringWithFormat:@"%@, %@", placemark.locality, placemark.administrativeArea]];
            } else {
                [self setLastLocationName:nil];
            }
            
            NSCAssert([NSThread isMainThread], @"Must be main thread");
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kTellMeMyLocationChangedNotification object:nil];
        }
        
        completionHandler();
    }];
}

+ (void)setLastLocationName:(NSString*)name {
    if (name.length) {
        [[NSUserDefaults standardUserDefaults] setObject:name forKey:kLastLocationName];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kLastLocationName];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)setLastLocationNameShort:(NSString*)nameShort {
    if (nameShort.length) {
        [[NSUserDefaults standardUserDefaults] setObject:nameShort forKey:kLastLocationNameShort];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kLastLocationNameShort];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSDate*)lastLocationDate {
    return [[NSUserDefaults standardUserDefaults] objectForKey:kLastLocationDate];
}

+ (CLLocation*)lastLocation {
    NSNumber *lat = [[NSUserDefaults standardUserDefaults] objectForKey:kLastLocationLat];
    NSNumber *lng = [[NSUserDefaults standardUserDefaults] objectForKey:kLastLocationLng];
    
    if (lat && lng) {
        return [[CLLocation alloc] initWithLatitude:lat.floatValue longitude:lng.floatValue];
    }
    return nil;
}

+ (NSString*)lastLocationName {
    NSString *name = [[NSUserDefaults standardUserDefaults] objectForKey:kLastLocationName];
    if (name && name.length) {
        return name;
    }
    else {
        return @"Undefined";
    }
}

+ (NSString*)lastLocationNameShort {
    NSString *nameShort = [[NSUserDefaults standardUserDefaults] objectForKey:kLastLocationNameShort];
    if (nameShort && nameShort.length) {
        return nameShort;
    }
    else {
        return @"Undefined";
    }
}

#pragma mark - Private Implemention

- (void)stopUpdatingLocationAfterTimeout:(CLLocationManager *)manager {
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized) {
        if (manager) {
            [manager stopUpdatingLocation];
            manager.delegate = nil;
        }
    
        [self finishWithBestLocation:_bestLocation error:nil];
    }
}

- (void)finishWithBestLocation:(CLLocation *)location error:(NSError *)error {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopUpdatingLocationAfterTimeout:) object:nil];
    _currentDeviceLocation = location;
    _lastDeviceLocationRefresh = [NSDate date];
    // the following line crashes with bad memory access for no apparent reason
    
    if (error && _failureBlock) {
        _failureBlock(error);
    }
    else if (!error && _foundBlock) {
        _foundBlock(location);
    }
    
    _foundBlock = nil;
    _failureBlock = nil;
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if (_failureBlock) {
        _failureBlock(error);
    }
    
    [_locationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *latestLocation = nil;
    
    if (locations.count) {
        latestLocation = [locations lastObject];
    }
    
    if (_bestLocation == nil) {
        _bestLocation = latestLocation;
    }

    if (latestLocation.horizontalAccuracy < _bestLocation.horizontalAccuracy) {
        self.bestLocation = latestLocation;
    }

    if (_bestLocation.horizontalAccuracy <= manager.desiredAccuracy) {
        [manager stopUpdatingLocation];
        manager.delegate = nil;
        [self finishWithBestLocation:_bestLocation error:nil];
    }
}

@end
