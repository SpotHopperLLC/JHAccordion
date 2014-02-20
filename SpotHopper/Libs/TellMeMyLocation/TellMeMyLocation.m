//
//  TellMeMyLocation.m
//  PatronApp
//
//  Created by Josh Holtz on 5/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#define kLastLocationLat @"last_location_lat"
#define kLastLocationLng @"last_location_lng"
#define kLastLocationName @"last_location_name"

#import "TellMeMyLocation.h"

#import <CoreLocation/CoreLocation.h>

typedef void(^FoundBlock)(CLLocation *userModel);
typedef void(^FailureBlock)();

@interface TellMeMyLocation()

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, copy) FoundBlock foundBlock;
@property (nonatomic, copy) FailureBlock failureBlock;

@end

@implementation TellMeMyLocation

@synthesize locationManager = _locationManager;
@synthesize foundBlock = _foundBlock;
@synthesize failureBlock = _failureBlock;

- (void)findMe:(CLLocationAccuracy)accuracy found:(void(^)(CLLocation *newLocation))foundBlock failure:(void(^)())failureBlock {

    if (_locationManager == nil) {
        _foundBlock = [foundBlock copy];
        _failureBlock = [failureBlock copy];
        
        _locationManager = [[CLLocationManager alloc] init];
    
        [_locationManager setDelegate:self];
    }
    
    [_locationManager setDesiredAccuracy:accuracy];
    [_locationManager startUpdatingLocation];
    
}

#pragma mark - CLLocation Delegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    if (_failureBlock != nil) {
        _failureBlock();
    }

    [_locationManager stopUpdatingLocation];
    
//    _locationManager = nil;
//    _foundBlock = nil;
//    _failureBlock = nil;
}

// Delegate method from the CLLocationManagerDelegate protocol.
- (void)locationManager:(CLLocationManager *)manage didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    [_locationManager stopUpdatingLocation];
    
    if (_foundBlock != nil) {
        _foundBlock(newLocation);
    }
        
//    _locationManager = nil;
//    _foundBlock = nil;
//    _failureBlock = nil;
}

+ (void)setLastLocation:(CLLocation*)location completionHandler:(TellMeMyLocationCompletionHandler)completionHandler {
    // Saves location
    if (location != nil) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:location.coordinate.latitude] forKey:kLastLocationLat];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:location.coordinate.longitude] forKey:kLastLocationLng];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kLastLocationLat];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kLastLocationLng];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // Reverse geocodes
    [[[CLGeocoder alloc] init] reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        
        // Saves location name
        if (!error) {
            if (placemarks.count > 0) {
                CLPlacemark *placemark = [placemarks objectAtIndex:0];
                [TellMeMyLocation setLastLocationName:[placemark locality]];
            } else {
                [TellMeMyLocation setLastLocationName:nil];
            }
        }
        
        completionHandler();
    }];
}

+ (void)setLastLocationName:(NSString*)name {
    if (name != nil) {
        [[NSUserDefaults standardUserDefaults] setObject:name forKey:kLastLocationName];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kLastLocationName];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (CLLocation*)lastLocation {
    NSNumber *lat = [[NSUserDefaults standardUserDefaults] objectForKey:kLastLocationLat];
    NSNumber *lng = [[NSUserDefaults standardUserDefaults] objectForKey:kLastLocationLng];
    
    if (lat != nil && lng != nil) {
        return [[CLLocation alloc] initWithLatitude:lat.floatValue longitude:lng.floatValue];
    }
    return nil;
}

+ (NSString*)lastLocationName {
    return [[NSUserDefaults standardUserDefaults] objectForKey:kLastLocationName];
}

@end
