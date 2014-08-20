//
//  TellMeMyLocation.m
//  PatronApp
//
//  Created by Josh Holtz on 5/23/12.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#define kLocationUpdateTimeout              10.0
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

@implementation TellMeMyLocation

static CLLocation *_currentDeviceLocation;
static CLLocation *_currentSelectedLocation;
static CLLocation *_currentMapCenterLocation;

static NSString *_currentDeviceLocationName;
static NSString *_currentSelectedLocationName;
static NSString *_currentMapCenterLocationName;

static NSString *_currentDeviceLocationZip;
static NSString *_currentSelectedLocationZip;
static NSString *_currentMapCenterLocationZip;

static NSDate *_lastDeviceLocationRefresh;

#pragma mark - Public Implemention

- (void)findMe:(CLLocationAccuracy)accuracy {
    // finish immediately if the device location was refreshed recently
    if (_lastDeviceLocationRefresh && self.bestLocation) {
        NSTimeInterval diff = [[NSDate date] timeIntervalSinceDate:_lastDeviceLocationRefresh];
        if (diff <= kTimeBetweenLocationRefreshes) {
            [self found:self.bestLocation];
            return;
        }
    }
    
    if ([CLLocationManager locationServicesEnabled] && ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined)) {
        if (!self.locationManager) {
            self.locationManager = [[CLLocationManager alloc] init];
            [self.locationManager setDelegate:self];
        }
        
        [self.locationManager setDesiredAccuracy:accuracy];
        [self.locationManager startUpdatingLocation];
        [self performSelector:@selector(stopUpdatingLocationAfterTimeout:) withObject:self.locationManager afterDelay:kLocationUpdateTimeout];
    }
    else if (![CLLocationManager locationServicesEnabled]) {
        NSDictionary *userInfo = @{
                                   NSLocalizedDescriptionKey : @"App Permission Denied",
                                   NSLocalizedRecoverySuggestionErrorKey : @"To re-enable, please go to Settings and turn on Location Service for this app."
                                   };
        NSError *error = [NSError errorWithDomain:kTellMeMyLocationDomain code:1 userInfo:userInfo];
        
        [self fail:error];
    }
    else if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorized) {
        NSDictionary *userInfo = @{
                                   NSLocalizedDescriptionKey : @"Permission Denied",
                                   NSLocalizedRecoverySuggestionErrorKey : @"To re-enable, please go to Settings and turn on Location Services"
                                   };
        NSError *error = [NSError errorWithDomain:kTellMeMyLocationDomain code:1 userInfo:userInfo];
        
        [self fail:error];
    }
    else {
        // fall through with an invalid location
        CLLocationCoordinate2D coordinate = kCLLocationCoordinate2DInvalid;
        CLLocation * location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
        [self found:location];
    }
}

- (void)findMe:(CLLocationAccuracy)accuracy found:(FoundBlock)foundBlock failure:(FailureBlock)failureBlock {
    if (foundBlock) {
        self.foundBlock = foundBlock;
    }
    if (failureBlock) {
        self.failureBlock = failureBlock;
    }
    
    [self findMe:accuracy];
}

+ (BOOL)needsLocationServicesPermissions {
    return ([CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined);
}

+ (CLLocation *)currentLocation {
    if (_currentDeviceLocation && CLLocationCoordinate2DIsValid(_currentDeviceLocation.coordinate)) {
        return _currentDeviceLocation;
    }
    else if (_currentSelectedLocation && CLLocationCoordinate2DIsValid(_currentSelectedLocation.coordinate)) {
        return _currentSelectedLocation;
    }
    
    return nil;
}

+ (NSString *)currentLocationName {
    if (_currentDeviceLocation && _currentDeviceLocationName.length) {
        return _currentDeviceLocationName;
    }
    else if (_currentDeviceLocation && _currentDeviceLocationName.length) {
        return _currentDeviceLocationName;
    }
    
    return nil;
}

+ (NSString *)currentLocationZip {
    if (_currentDeviceLocation && _currentDeviceLocationZip.length) {
        return _currentDeviceLocationZip;
    }
    else if (_currentDeviceLocation && _currentSelectedLocationZip.length) {
        return _currentSelectedLocationZip;
    }
    
    return nil;
}

+ (void)setCurrentDeviceLocation:(CLLocation *)deviceLocation {
    _currentDeviceLocation = deviceLocation;
    _lastDeviceLocationRefresh = [NSDate date];
    

    [[[CLGeocoder alloc] init] reverseGeocodeLocation:deviceLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        if (!error && placemarks.count) {
            CLPlacemark *placemark = placemarks[0];
            _currentDeviceLocationName = [TellMeMyLocation shortLocationNameFromPlacemark:placemark];
            _currentDeviceLocationZip = placemark.postalCode;
        }
    }];
}

+ (CLLocation *)currentDeviceLocation {
    return _currentDeviceLocation;
}

+ (NSString *)currentDeviceLocationName {
    if (_currentDeviceLocation && _currentDeviceLocationName.length) {
        return _currentDeviceLocationName;
    }
    
    return nil;
}

+ (NSString *)currentDeviceLocationZip {
    return _currentDeviceLocationZip;
}

+ (void)setCurrentSelectedLocation:(CLLocation *)selectedLocation {
    _currentSelectedLocation = selectedLocation;
    
    [[[CLGeocoder alloc] init] reverseGeocodeLocation:selectedLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        if (!error && placemarks.count) {
            CLPlacemark *placemark = placemarks[0];
            _currentSelectedLocationName = [TellMeMyLocation shortLocationNameFromPlacemark:placemark];
            _currentSelectedLocationZip = placemark.postalCode;
        }
    }];
}

+ (CLLocation *)currentSelectedLocation {
    return _currentSelectedLocation;
}

+ (NSString *)currentSelectedLocationName {
    if (_currentSelectedLocation && _currentSelectedLocationName.length) {
        return _currentSelectedLocationName;
    }
    
    return nil;
}

+ (NSString *)currentSelectedLocationZip {
    return _currentSelectedLocationZip;
}

+ (CLLocation *)mapCenterLocation {
    return _currentMapCenterLocation;
}

+ (void)setMapCenterLocation:(CLLocation *)mapCenterLocation {
    _currentMapCenterLocation = mapCenterLocation;
    
    [[[CLGeocoder alloc] init] reverseGeocodeLocation:mapCenterLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        if (!error && placemarks.count) {
            CLPlacemark *placemark = placemarks[0];
            _currentMapCenterLocationName = [TellMeMyLocation shortLocationNameFromPlacemark:placemark];
            _currentMapCenterLocationZip = placemark.postalCode;
        }
    }];
}

+ (NSString *)mapCenterLocationName {
    if (_currentMapCenterLocation && _currentMapCenterLocationName.length) {
        return _currentMapCenterLocationName;
    }
    
    return nil;
}

+ (NSString *)mapCenterLocationZip {
    return _currentMapCenterLocationZip;
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
                CLPlacemark *placemark = placemarks[0];
                
                [self setLastLocationName:[self locationNameFromPlacemark:placemark]];
                
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
                
                [self setLastLocationNameShort:[self shortLocationNameFromPlacemark:placemark]];
            } else {
                [self setLastLocationName:[TellMeMyLocation locationNameFromPlacemark:nil]];
            }
            
            NSCAssert([NSThread isMainThread], @"Must be main thread");
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kTellMeMyLocationChangedNotification object:nil];
        }
        
        completionHandler();
    }];
}

+ (NSString *)locationNameFromPlacemark:(CLPlacemark *)placemark {
    if (!placemark) {
        return @"Middle of Nowhere";
    }
    
    if ([self isAtTheCastle:placemark.location]) {
        return @"Stefan's Castle";
    }
    
    if (placemark.subLocality.length && placemark.locality.length && placemark.administrativeArea.length) {
        NSString *locationName = [NSString stringWithFormat:@"%@, %@, %@", placemark.subLocality, placemark.locality, placemark.administrativeArea];
        
        if (locationName.length > 25) {
            locationName = [NSString stringWithFormat:@"%@, %@", placemark.locality, placemark.administrativeArea];
        }
        
        return locationName;
    } else if (placemark.locality.length > 0) {
        return placemark.locality;
    }
    else if (placemark.name.length) {
        return placemark.name;
    }
    
    return @"Unknown";
}

+ (NSString *)shortLocationNameFromPlacemark:(CLPlacemark *)placemark {
    if (!placemark) {
        return @"Middle of Nowhere";
    }
    
    if ([self isAtTheCastle:placemark.location]) {
        return @"Stefan's Castle";
    }
    
    if (placemark.locality.length && placemark.administrativeArea.length) {
        return [NSString stringWithFormat:@"%@, %@", placemark.locality, placemark.administrativeArea];
    }
    else if (placemark.name.length) {
        return placemark.name;
    }
    else {
        return @"Unknown";
    }
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

+ (BOOL)isAtTheCastle:(CLLocation *)location {
    CLLocation *castleLocation = [[CLLocation alloc] initWithLatitude:43.0838262 longitude:-87.8743507];
    CLLocationDistance distance = [castleLocation distanceFromLocation:location];

    // distance in meters
    return distance < 25;
}

#pragma mark - Private Implemention

- (void)stopUpdatingLocationAfterTimeout:(CLLocationManager *)manager {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopUpdatingLocationAfterTimeout:) object:nil];
    
    if (!self.bestLocation) {
        [self performSelector:@selector(stopUpdatingLocationAfterTimeout:) withObject:manager afterDelay:1.0f];
        return;
    }
    
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized) {
        if (manager) {
            [manager stopUpdatingLocation];
            manager.delegate = nil;
        }
    
        [self finishWithBestLocation:self.bestLocation error:nil];
    }
}

- (void)finishWithBestLocation:(CLLocation *)location error:(NSError *)error {
    if (!error) {
        [TellMeMyLocation setCurrentDeviceLocation:location];
    }
    
    if ((error || !location) && self.failureBlock) {
        [self fail:error];
    }
    else if (!error && self.foundBlock) {
        [self found:location];
    }
}

- (void)found:(CLLocation *)location {
    if ([self.delegate respondsToSelector:@selector(tellMeMyLocation:didFindLocation:)]) {
        [self.delegate tellMeMyLocation:self didFindLocation:location];
    }
    
    if (self.foundBlock) {
        self.foundBlock(location);
    }
    
    self.foundBlock = nil;
    self.failureBlock = nil;
}

- (void)fail:(NSError *)error {
    if (!error) {
        error = [NSError errorWithDomain:@"Error while using location services" code:1 userInfo:@{}];
    }
    
    if ([self.delegate respondsToSelector:@selector(tellMeMyLocation:didFailWithError:)]) {
        [self.delegate tellMeMyLocation:self didFailWithError:error];
    }

    if (self.failureBlock) {
        self.failureBlock(error);
    }
    
    self.foundBlock = nil;
    self.failureBlock = nil;
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopUpdatingLocationAfterTimeout:) object:nil];
    [self.locationManager stopUpdatingLocation];
    
    [self fail:error];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *latestLocation = nil;
    
    if (locations.count) {
        latestLocation = [locations lastObject];
    }
    
    if (self.bestLocation == nil) {
        self.bestLocation = latestLocation;
    }

    if (latestLocation.horizontalAccuracy < self.bestLocation.horizontalAccuracy) {
        self.bestLocation = latestLocation;
    }

    if (self.bestLocation.horizontalAccuracy <= manager.desiredAccuracy) {
        [manager stopUpdatingLocation];
        manager.delegate = nil;
        [self finishWithBestLocation:self.bestLocation error:nil];
    }
}

@end
