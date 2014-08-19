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

- (void)findMe:(CLLocationAccuracy)accuracy;
- (void)findMe:(CLLocationAccuracy)accuracy found:(FoundBlock)foundBlock failure:(FailureBlock)failureBlock;

+ (CLLocation *)currentLocation;
+ (NSString *)currentLocationName;
+ (NSString *)currentLocationZip;

// Current Device Location
+ (void)setCurrentDeviceLocation:(CLLocation *)deviceLocation;
+ (CLLocation *)currentDeviceLocation;
+ (NSString *)currentDeviceLocationName;
+ (NSString *)currentDeviceLocationZip;

// Current Selected Location
+ (void)setCurrentSelectedLocation:(CLLocation *)selectedLocation;
+ (CLLocation *)currentSelectedLocation;
+ (NSString *)currentSelectedLocationName;
+ (NSString *)currentSelectedLocationZip;

// Map Center Location
+ (void)setMapCenterLocation:(CLLocation *)mapCenterLocation;
+ (CLLocation *)mapCenterLocation;
+ (NSString *)mapCenterLocationName;
+ (NSString *)mapCenterLocationZip;

+ (NSString *)locationNameFromPlacemark:(CLPlacemark *)placemark;
+ (NSString *)shortLocationNameFromPlacemark:(CLPlacemark *)placemark;

+ (void)setLastLocation:(CLLocation*)location completionHandler:(TellMeMyLocationCompletionHandler)completionHandler;
+ (void)setLastLocationName:(NSString*)name;

+ (CLLocation*)lastLocation;
+ (NSDate*)lastLocationDate;
+ (NSString*)lastLocationName;
+ (NSString*)lastLocationNameShort;

@end

@protocol TellMeMyLocationDelegate <NSObject>

@optional

- (void)tellMeMyLocation:(TellMeMyLocation *)tmml didFindLocation:(CLLocation *)newLocation;
- (void)tellMeMyLocation:(TellMeMyLocation *)tmml didFailWithError:(NSError *)error;

@end
