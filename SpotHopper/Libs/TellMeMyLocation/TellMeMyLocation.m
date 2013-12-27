//
//  TellMeMyLocation.m
//  PatronApp
//
//  Created by Josh Holtz on 5/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

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
        [_locationManager setDesiredAccuracy:accuracy];
        
        [_locationManager startUpdatingLocation];
        
    }
    
}

#pragma mark - CLLocation Delegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    if (_failureBlock != nil) {
        _failureBlock();
    }
    
    _locationManager = nil;
    _foundBlock = nil;
    _failureBlock = nil;
}

// Delegate method from the CLLocationManagerDelegate protocol.
- (void)locationManager:(CLLocationManager *)manage didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    [_locationManager stopUpdatingLocation];
    
    if (_foundBlock != nil) {
        _foundBlock(newLocation);
    }
        
    _locationManager = nil;
    _foundBlock = nil;
    _failureBlock = nil;
}

@end
