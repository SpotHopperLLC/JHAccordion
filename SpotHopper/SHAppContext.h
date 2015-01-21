//
//  SHAppContext.h
//  SpotHopper
//
//  Created by Brennan Stehling on 9/18/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#import "Constants.h"

#import "SpotListRequest.h"
#import "DrinkListRequest.h"
#import "SpotListModel.h"
#import "DrinkListModel.h"
#import "CheckInModel.h"

#import "SHUserProfileModel.h"

@interface SHAppContext : NSObject

@property (assign, nonatomic) SHMode mode;

@property (readonly, nonatomic) SpotListRequest *spotlistRequest;
@property (readonly, nonatomic) DrinkListRequest *drinkListRequest;
@property (readonly, nonatomic) SpotListModel *spotlist;
@property (readonly, nonatomic) DrinkListModel *drinklist;
@property (readonly, nonatomic) CLLocationCoordinate2D mapCoordinate;
@property (readonly, nonatomic) CLLocationDistance radius;
@property (readonly, nonatomic) CGFloat radiusInMiles;

@property (readonly, nonatomic) CLLocation *mapLocation;

@property (readonly, nonatomic) CLLocation *deviceLocation;
@property (readonly, nonatomic) CheckInModel *checkin;

@property (strong, nonatomic) SHUserProfileModel *currentUserProfile;

@property (readonly, nonatomic) NSString *activityName;
@property (readonly, nonatomic) NSDate *activityStartDate;

+ (instancetype)defaultInstance;

- (void)changeContextToMode:(SHMode)mode specialsSpotlist:(SpotListModel *)spotlist;

- (void)changeContextToMode:(SHMode)mode spotlistRequest:(SpotListRequest *)spotlistRequest spotlist:(SpotListModel *)spotlist;

- (void)changeContextToMode:(SHMode)mode drinklistRequest:(DrinkListRequest *)drinklistRequest drinklist:(DrinkListModel *)drinklist;

- (void)changeMapCoordinate:(CLLocationCoordinate2D)coordinate andRadius:(CLLocationDistance)radius;

- (void)changeDeviceLocation:(CLLocation *)deviceLocation;

- (void)changeCheckin:(CheckInModel *)checkin;

- (void)startActivity:(NSString *)activityName;

- (void)endActivity:(NSString *)activityName;

#pragma mark - Location Context
#pragma mark -

+ (CLLocation *)currentLocation;
+ (NSString *)currentLocationName;
+ (NSString *)currentLocationZip;

+ (void)setCurrentDeviceLocation:(CLLocation *)deviceLocation;
+ (CLLocation *)currentDeviceLocation;
+ (NSString *)currentDeviceLocationName;
+ (NSString *)currentDeviceLocationZip;

+ (void)setCurrentSelectedLocation:(CLLocation *)selectedLocation;
+ (CLLocation *)currentSelectedLocation;
+ (NSString *)currentSelectedLocationName;
+ (NSString *)currentSelectedLocationZip;

+ (void)setMapCenterLocation:(CLLocation *)mapCenterLocation;
+ (CLLocation *)mapCenterLocation;
+ (NSString *)mapCenterLocationName;
+ (NSString *)mapCenterLocationZip;

+ (NSString *)locationNameFromPlacemark:(CLPlacemark *)placemark;
+ (NSString *)shortLocationNameFromPlacemark:(CLPlacemark *)placemark;

+ (void)setLastLocation:(CLLocation*)location withCompletionBlock:(void (^)())completionBlock;
+ (void)setLastLocationName:(NSString*)name;

+ (CLLocation*)lastLocation;
+ (NSDate*)lastLocationDate;
+ (NSString*)lastLocationName;
+ (NSString*)lastLocationNameShort;

+ (void)updateLocation:(CLLocation *)location withCompletionBlock:(void (^)(NSError *error))completionBlock;

@end
