//
//  TellMeMyLocation.m
//  PatronApp
//
//  Created by Josh Holtz on 5/23/12.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#define kLastLocationLat @"last_location_lat"
#define kLastLocationLng @"last_location_lng"
#define kLastLocationName @"last_location_name"
#define kLastLocationDate @"last_location_date"
#define kLastLocationNameShort @"last_location_name_short"

#import "TellMeMyLocation.h"

#import <CoreLocation/CoreLocation.h>

NSString * const kTellMeMyLocationChangedNotification = @"TellMeMyLocationChangedNotification";

@interface TellMeMyLocation()

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, copy) FoundBlock foundBlock;
@property (nonatomic, copy) FailureBlock failureBlock;

@end

@implementation TellMeMyLocation

@synthesize locationManager = _locationManager;
@synthesize foundBlock = _foundBlock;
@synthesize failureBlock = _failureBlock;

- (void)findMe:(CLLocationAccuracy)accuracy found:(FoundBlock)foundBlock failure:(FailureBlock)failureBlock {

    if ([CLLocationManager locationServicesEnabled]) {
        
        if ([CLLocationManager authorizationStatus]==kCLAuthorizationStatusDenied){
            failureBlock([NSError errorWithDomain:kTellMeMyLocationDomain code:1 userInfo:@{
                                                                                              NSLocalizedDescriptionKey : @"App Permission Denied",
                                                                                              NSLocalizedRecoverySuggestionErrorKey : @"To re-enable, please go to Settings and turn on Location Service for this app."
                                                                                              }]);
            return;
        }
    } else {
        failureBlock([NSError errorWithDomain:kTellMeMyLocationDomain code:1 userInfo:@{
                                                                                          NSLocalizedDescriptionKey : @"Permission Denied",
                                                                                          NSLocalizedRecoverySuggestionErrorKey : @"To re-enable, please go to Settings and turn on Location Services"
                                                                                          }]);
        return;
    }
    
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

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"Error - %@", error);
    if (_failureBlock != nil) {
        _failureBlock(error);
    }

    [_locationManager stopUpdatingLocation];

}

// Delegate method from the CLLocationManagerDelegate protocol.
- (void)locationManager:(CLLocationManager *)manage didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    [_locationManager stopUpdatingLocation];
    
    if (_foundBlock != nil) {
        _foundBlock(newLocation);
    }

}

+ (void)setLastLocation:(CLLocation*)location completionHandler:(TellMeMyLocationCompletionHandler)completionHandler {
    // Saves location
    if (location != nil) {
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
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kTellMeMyLocationChangedNotification object:nil];
        }
        
        completionHandler();
    }];
}

+ (void)setLastLocationName:(NSString*)name {
    if (name != nil && name.length) {
        [[NSUserDefaults standardUserDefaults] setObject:name forKey:kLastLocationName];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kLastLocationName];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)setLastLocationNameShort:(NSString*)nameShort {
    if (nameShort != nil && nameShort.length) {
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
    
    if (lat != nil && lng != nil) {
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

@end
