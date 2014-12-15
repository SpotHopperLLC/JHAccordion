//
//  TellMeMyLocation.h
//  PatronApp
//
//  Created by Josh Holtz on 5/23/12.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#define kTellMeMyLocationDomain @"TellMeMyLocationDomain"

#import <Foundation/Foundation.h>

#import <CoreLocation/CoreLocation.h>

extern NSString * const kTellMeMyLocationChangedNotification;

typedef void(^FoundBlock)(CLLocation *newLocation);
typedef void(^FailureBlock)(NSError *error);

typedef void (^TellMeMyLocationCompletionHandler)();

@protocol TellMeMyLocationDelegate;

@interface TellMeMyLocation : NSObject

@property (weak, nonatomic) id <TellMeMyLocationDelegate> delegate;

- (void)findMe:(CLLocationAccuracy)accuracy __deprecated;
- (void)findMe:(CLLocationAccuracy)accuracy found:(FoundBlock)foundBlock failure:(FailureBlock)failureBlock __deprecated;

+ (BOOL)needsLocationServicesPermissions __deprecated;

+ (CLLocation *)currentLocation __deprecated;
+ (NSString *)currentLocationName __deprecated;
+ (NSString *)currentLocationZip __deprecated;

// Current Device Location
+ (void)setCurrentDeviceLocation:(CLLocation *)deviceLocation __deprecated;
+ (CLLocation *)currentDeviceLocation __deprecated;
+ (NSString *)currentDeviceLocationName __deprecated;
+ (NSString *)currentDeviceLocationZip __deprecated;

// Current Selected Location
+ (void)setCurrentSelectedLocation:(CLLocation *)selectedLocation __deprecated;
+ (CLLocation *)currentSelectedLocation __deprecated;
+ (NSString *)currentSelectedLocationName __deprecated;
+ (NSString *)currentSelectedLocationZip __deprecated;

// Map Center Location
+ (void)setMapCenterLocation:(CLLocation *)mapCenterLocation __deprecated;
+ (CLLocation *)mapCenterLocation __deprecated;
+ (NSString *)mapCenterLocationName __deprecated;
+ (NSString *)mapCenterLocationZip __deprecated;

+ (NSString *)locationNameFromPlacemark:(CLPlacemark *)placemark __deprecated;
+ (NSString *)shortLocationNameFromPlacemark:(CLPlacemark *)placemark __deprecated;

+ (void)setLastLocation:(CLLocation*)location completionHandler:(TellMeMyLocationCompletionHandler)completionHandler __deprecated;
+ (void)setLastLocationName:(NSString*)name __deprecated;

+ (CLLocation*)lastLocation __deprecated;
+ (NSDate*)lastLocationDate __deprecated;
+ (NSString*)lastLocationName __deprecated;
+ (NSString*)lastLocationNameShort __deprecated;

@end

@protocol TellMeMyLocationDelegate <NSObject>

@optional

- (void)tellMeMyLocation:(TellMeMyLocation *)tmml didFindLocation:(CLLocation *)newLocation;
- (void)tellMeMyLocation:(TellMeMyLocation *)tmml didFailWithError:(NSError *)error;

@end
