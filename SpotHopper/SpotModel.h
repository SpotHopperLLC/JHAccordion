//
//  SpotModel.h
//  SpotHopper
//
//  Created by Josh Holtz on 1/7/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#define kSpotModelParamPage @"page_number"
#define kSpotModelParamsPageSize @"page_size"
#define kSpotModelParamQuery @"query"
#define kSpotModelParamQueryLatitude @"lat"
#define kSpotModelParamQueryLongitude @"lng"
#define kSpotModelParamQuerySpotTypeId @"spot_type_id"
#define kSpotModelParamQueryDayOfWeek @"day_of_week"
#define kSpotModelParamQueryVisibleToUsers @"visible_to_users"

#define kSpotModelParamName @"name"
#define kSpotModelParamAddress @"address"
#define kSpotModelParamCity @"city"
#define kSpotModelParamState @"state"
#define kSpotModelParamZip @"zip"
#define kSpotModelParamSpotTypeId @"spot_type_id"
#define kSpotModelParamLatitude @"latitude"
#define kSpotModelParamLongitude @"longitude"
#define kSpotModelParamFoursquareId @"foursquare_id"

#define kSpotModelParamSources @"sources"
#define kSpotModelParamSourcesSpotHopper @"spothopper"
#define kSpotModelParamSourcesFoursquare @"foursquare"

#define kSpotModelMetaPage @"page"
#define kSpotModelMetaTotalRecords @"total_records"

#import "SHJSONAPIResource.h"

#import "NSArray+HoursOfOperation.h"

#import <JSONAPI/JSONAPI.h>
#import <Promises/Promise.h>

#import <CoreLocation/CoreLocation.h>

@class ErrorModel, AverageReviewModel, SpotTypeModel, LiveSpecialModel, CLLocation;

@interface SpotModel : SHJSONAPIResource

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSString *zip;
@property (nonatomic, strong) NSString *phoneNumber;
@property (nonatomic, strong) NSArray *hoursOfOperation; // Returns array (7 in size, SMTWTFS) of arrays (2 in size, open to close)
@property (nonatomic, strong) NSNumber *latitude;
@property (nonatomic, strong) NSNumber *longitude;
@property (nonatomic, strong) NSArray *sliderTemplates;
@property (nonatomic, strong) NSString *foursquareId;
@property (nonatomic, strong) SpotTypeModel *spotType;
@property (nonatomic, strong) AverageReviewModel *averageReview;
@property (nonatomic, strong) NSNumber *match;
@property (nonatomic, strong) NSArray *images;
@property (nonatomic, strong) NSArray *dailySpecials;
@property (nonatomic, strong) NSArray *liveSpecials;
@property (nonatomic, strong) NSNumber *relevance;

- (NSString*)addressCityState;
- (NSString*)fullAddress;
- (NSString*)cityState;
- (NSString*)matchPercent;
- (UIImage*)placeholderImage;
- (LiveSpecialModel*)currentLiveSpecial;

+ (void)cancelGetSpots;

+ (Promise*)getSpots:(NSDictionary*)params success:(void(^)(NSArray *spotModels, JSONAPI *jsonApi))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock;

+ (Promise*)getSpotsWithSpecialsTodayForCoordinate:(CLLocationCoordinate2D)coordinate success:(void(^)(NSArray *spotModels, JSONAPI *jsonApi))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock;

+ (Promise*)getSpotsWithSpecials:(NSDictionary*)params success:(void(^)(NSArray *spotModels, JSONAPI *jsonApi))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock;

+ (Promise*)postSpot:(NSDictionary*)params success:(void(^)(SpotModel *spotModel, JSONAPI *jsonApi))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock;

- (Promise*)getSpot:(NSDictionary*)params success:(void(^)(SpotModel *spotModel, JSONAPI *jsonApi))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock;

- (Promise *)getMenuItems:(NSDictionary *)params success:(void (^)(NSArray *, JSONAPI *))successBlock failure:(void (^)(ErrorModel *))failureBlock;

#pragma mark - Revised Code for 2.0

+ (void)fetchSpotsNearLocation:(CLLocation *)location success:(void (^)(NSArray *spots))successBlock failure:(void (^)(ErrorModel *errorModel))failureBlock;

+ (Promise *)fetchSpotsNearLocation:(CLLocation *)location;

+ (void)fetchSpotTypes:(void (^)(NSArray *spotTypes))successBlock failure:(void (^)(ErrorModel *errorModel))failureBlock;

+ (Promise *)fetchSpotTypes;

@end
