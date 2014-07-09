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

@interface TellMeMyLocation : NSObject

- (void)findMe:(CLLocationAccuracy)accuracy found:(FoundBlock)foundBlock failure:(FailureBlock)failureBlock;
+ (CLLocation *)currentDeviceLocation;

+ (NSString *)locationNameFromPlacemark:(CLPlacemark *)placemark;
+ (NSString *)shortLocationNameFromPlacemark:(CLPlacemark *)placemark;

+ (void)setLastLocation:(CLLocation*)location completionHandler:(TellMeMyLocationCompletionHandler)completionHandler;
+ (void)setLastLocationName:(NSString*)name;

+ (CLLocation*)lastLocation;
+ (NSDate*)lastLocationDate;
+ (NSString*)lastLocationName;
+ (NSString*)lastLocationNameShort;

@end
