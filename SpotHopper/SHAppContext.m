//
//  SHAppContext.m
//  SpotHopper
//
//  Created by Brennan Stehling on 9/18/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "SHAppContext.h"

#import "Tracker+Events.h"
#import "SHAppUtil.h"
#import "SHNotifications.h"
#import "SHLocationManager.h"
#import "JTSReachabilityResponder.h"

#import <Parse/Parse.h>

#define kMetersPerMile 1609.344

#define kLocationUpdateTimeout 10.0

#define kLastLocationLat @"last_location_lat"
#define kLastLocationLng @"last_location_lng"
#define kLastLocationName @"last_location_name"
#define kLastLocationDate @"last_location_date"
#define kLastLocationNameShort @"last_location_name_short"

#pragma mark - Class Extension
#pragma mark -

@interface SHAppContext ()

@property (readwrite, strong, nonatomic) SpotListRequest *spotlistRequest;
@property (readwrite, strong, nonatomic) DrinkListRequest *drinkListRequest;
@property (readwrite, strong, nonatomic) SpotListModel *spotlist;
@property (readwrite, strong, nonatomic) DrinkListModel *drinklist;
@property (readwrite, assign, nonatomic) CLLocationCoordinate2D mapCoordinate;
@property (readwrite, assign, nonatomic) CLLocationDistance radius;

@property (readwrite, strong, nonatomic) CLLocation *deviceLocation;
@property (readwrite, strong, nonatomic) CheckInModel *checkin;

@property (readwrite, strong, nonatomic) NSString *activityName;
@property (readwrite, strong, nonatomic) NSDate *activityStartDate;

@end

@implementation SHAppContext

static CLLocation *_currentDeviceLocation;
static CLLocation *_currentSelectedLocation;
static CLLocation *_currentMapCenterLocation;

static NSString *_currentDeviceLocationName;
static NSString *_currentSelectedLocationName;
static NSString *_currentMapCenterLocationName;

static NSString *_currentDeviceLocationZip;
static NSString *_currentSelectedLocationZip;
static NSString *_currentMapCenterLocationZip;

+ (instancetype)defaultInstance {
    static SHAppContext *defaultInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        defaultInstance = [[SHAppContext alloc] init];
    });
    return defaultInstance;
}

- (CLLocation *)mapLocation {
    if (CLLocationCoordinate2DIsValid(self.mapCoordinate)) {
        CLLocation *location = [[CLLocation alloc] initWithLatitude:self.mapCoordinate.latitude longitude:self.mapCoordinate.longitude];
        return location;
    }
    
    return nil;
}

- (CGFloat)radiusInMiles {
    return self.radius / kMetersPerMile;
}

- (void)changeContextToMode:(SHMode)mode specialsSpotlist:(SpotListModel *)spotlist {
    self.mode = mode;
    self.spotlist = spotlist;
    
    self.spotlistRequest = nil;
    self.drinkListRequest = nil;
    self.drinklist = nil;
}

- (void)changeContextToMode:(SHMode)mode spotlistRequest:(SpotListRequest *)spotlistRequest spotlist:(SpotListModel *)spotlist {
    self.mode = mode;
    self.spotlistRequest = spotlistRequest;
    self.spotlist = spotlist;
    
    self.drinkListRequest = nil;
    self.drinklist = nil;
}

- (void)changeContextToMode:(SHMode)mode drinklistRequest:(DrinkListRequest *)drinklistRequest drinklist:(DrinkListModel *)drinklist {
    self.mode = mode;
    self.drinkListRequest = drinklistRequest;
    self.drinklist = drinklist;
    
    self.spotlistRequest = nil;
    self.spotlist = nil;
}

- (void)changeMapCoordinate:(CLLocationCoordinate2D)mapCoordinate andRadius:(CLLocationDistance)radius {
    self.mapCoordinate = mapCoordinate;
    self.radius = radius;
}

- (void)changeDeviceLocation:(CLLocation *)deviceLocation {
    self.deviceLocation = deviceLocation;
}

- (void)changeCheckin:(CheckInModel *)checkin {
    self.checkin = checkin;
}

- (void)startActivity:(NSString *)activityName {
    DebugLog(@"%@ - %@", NSStringFromSelector(_cmd), activityName);
    self.activityName = activityName;
    self.activityStartDate = [NSDate date];
}

- (void)endActivity:(NSString *)activityName {
    DebugLog(@"%@ - %@", NSStringFromSelector(_cmd), activityName);
    if ([activityName isEqualToString:self.activityName]) {
        NSTimeInterval duration = ABS([self.activityStartDate timeIntervalSinceNow]);
        [Tracker trackActivity:activityName duration:duration];

        // reset
        self.activityName = nil;
        self.activityStartDate = nil;
    }
}

#pragma mark - User Profile
#pragma mark -

- (void)setCurrentUserProfile:(SHUserProfileModel *)currentUserProfile {
    _currentUserProfile = currentUserProfile;
    
    [[SHAppUtil defaultInstance] connectParseObjectsWithCompletionBlock:^(BOOL success, NSError *error) {
        if (error) {
            DebugLog(@"Error: %@", error);
        }
        else {
            DebugLog(@"Success: %@", success ? @"YES" : @"NO");
        }
    }];
}


#pragma mark - Location Context
#pragma mark -

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
    
    [[[CLGeocoder alloc] init] reverseGeocodeLocation:deviceLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        if (!error && placemarks.count) {
            CLPlacemark *placemark = placemarks[0];
            _currentDeviceLocationName = [self shortLocationNameFromPlacemark:placemark];
            _currentDeviceLocationZip = placemark.postalCode;
        }
    }];
    
    [self updateLocation:deviceLocation withCompletionBlock:nil];
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
            _currentSelectedLocationName = [self shortLocationNameFromPlacemark:placemark];
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

+ (void)setMapCenterLocation:(CLLocation *)mapCenterLocation {
    _currentMapCenterLocation = mapCenterLocation;
    
    [[[CLGeocoder alloc] init] reverseGeocodeLocation:mapCenterLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        if (!error && placemarks.count) {
            CLPlacemark *placemark = placemarks[0];
            _currentMapCenterLocationName = [self shortLocationNameFromPlacemark:placemark];
            _currentMapCenterLocationZip = placemark.postalCode;
        }
    }];
}

+ (CLLocation *)mapCenterLocation {
    return _currentMapCenterLocation;
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

+ (void)setLastLocation:(CLLocation*)location withCompletionBlock:(void (^)())completionBlock {
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
                [self setLastLocationName:[self locationNameFromPlacemark:nil]];
            }
            
            NSCAssert([NSThread isMainThread], @"Must be main thread");
            
            [SHNotifications locationChanged];
        }
        
        if (completionBlock) {
            completionBlock();
        }
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

+ (CLLocation*)lastLocation {
    NSNumber *lat = [[NSUserDefaults standardUserDefaults] objectForKey:kLastLocationLat];
    NSNumber *lng = [[NSUserDefaults standardUserDefaults] objectForKey:kLastLocationLng];
    
    if (lat && lng) {
        return [[CLLocation alloc] initWithLatitude:lat.floatValue longitude:lng.floatValue];
    }
    return nil;
}

+ (NSDate*)lastLocationDate {
    return [[NSUserDefaults standardUserDefaults] objectForKey:kLastLocationDate];
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

#pragma mark - Location (Private)
#pragma mark -

+ (void)setLastLocationNameShort:(NSString*)nameShort {
    if (nameShort.length) {
        [[NSUserDefaults standardUserDefaults] setObject:nameShort forKey:kLastLocationNameShort];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kLastLocationNameShort];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)updateLocation:(CLLocation *)location withCompletionBlock:(void (^)(NSError *error))completionBlock {
    if (location.horizontalAccuracy > 100) {
        // do not log inaccurate locations
        return;
    }
    
    if (![[JTSReachabilityResponder sharedInstance] isReachable]) {
        [[SHAppUtil defaultInstance] logMessage:@"Network is not reachable" location:location];
    }
    
    NSDictionary *params = @{@"latitude" : [NSNumber numberWithFloat:location.coordinate.latitude], @"longitude" : [NSNumber numberWithFloat:location.coordinate.longitude]};
    
    [PFCloud callFunctionInBackground:@"updateLocation"
                       withParameters:params
                                block:^(NSString *result, NSError *error) {
                                    if (error) {
                                        DebugLog(@"Error: %@", error.localizedDescription);
                                        NSString *message = [NSString stringWithFormat:@"Error: %@", error.localizedDescription];
                                        [[SHAppUtil defaultInstance] logMessage:message location:location];
                                    }
                                }];
}

+ (BOOL)isAtTheCastle:(CLLocation *)location {
    CLLocation *castleLocation = [[CLLocation alloc] initWithLatitude:43.0838262 longitude:-87.8743507];
    CLLocationDistance distance = [castleLocation distanceFromLocation:location];
    
    // distance in meters
    return distance < 50;
}

@end
