//
//  DrinkListModel.h
//  SpotHopper
//
//  Created by Josh Holtz on 3/13/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#define kDrinkListModelDefaultName @"Custom Drinklist"

#define kDrinkListModelParamName @"name"
#define kDrinkListModelParamLatitude @"latitude"
#define kDrinkListModelParamLongitude @"longitude"
#define kDrinkListModelParamBasedOnSlider @"based_on_sliders"

#define kDrinkListModelQueryParamLat @"lat"
#define kDrinkListModelQueryParamLng @"lng"
#define kDrinkListModelQueryParamSpotId @"spot_id"

#import "SHJSONAPIResource.h"

#import <JSONAPI/JSONAPI.h>

@class ErrorModel, SpotModel, DrinkTypeModel, DrinkListRequest, DrinkTypeModel, DrinkSubTypeModel, CLLocation;

@interface DrinkListModel : SHJSONAPIResource

@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) BOOL featured;
@property (nonatomic, strong) NSArray *drinks;
@property (nonatomic, strong) NSNumber *latitude;
@property (nonatomic, strong) NSNumber *longitude;
@property (nonatomic, strong) SpotModel *spot;
@property (nonatomic, strong) NSArray *sliders;

@property (nonatomic, strong) DrinkTypeModel *drinkType;
@property (nonatomic, strong) DrinkSubTypeModel *drinkSubtype;

@property (nonatomic, readonly) CLLocation *location;

+ (Promise *)getFeaturedDrinkLists:(NSDictionary *)params success:(void (^)(NSArray *drinklists, JSONAPI *jsonApi))successBlock failure:(void (^)(ErrorModel *errorModel))failureBlock;
+ (Promise *)postDrinkList:(NSString*)name latitude:(NSNumber*)latitude longitude:(NSNumber*)longitude sliders:(NSArray*)sliders drinkId:(NSNumber*)drinkId drinkTypeId:(NSNumber*)drinkTypeId drinkSubtypeId:(NSNumber*)drinkSubtypeId baseAlcoholId:(NSNumber*)baseAlcoholId spotId:(NSNumber*)spotId successBlock:(void (^)(DrinkListModel *drinklist, JSONAPI *jsonApi))successBlock failure:(void (^)(ErrorModel *errorModel))failureBlock __attribute__ ((deprecated));

- (Promise *)getDrinkList:(NSDictionary *)params success:(void (^)(DrinkListModel *drinklist, JSONAPI *jsonApi))successBlock failure:(void (^)(ErrorModel *errorModel))failureBlock;
- (Promise *)putDrinkList:(NSString*)name latitude:(NSNumber*)latitude longitude:(NSNumber*)longitude spotId:(NSNumber*)spotId sliders:(NSArray*)sliders success:(void (^)(DrinkListModel *drinklist, JSONAPI *jsonApi))successBlock failure:(void (^)(ErrorModel *errorModel))failureBlock;
- (Promise *)deleteDrinkList:(NSDictionary *)params success:(void (^)(DrinkListModel *drinklist, JSONAPI *jsonApi))successBlock failure:(void (^)(ErrorModel *errorModel))failureBlock;

#pragma mark - Revised Code for 2.0

+ (void)fetchMyDrinkLists:(void (^)(NSArray *spotlists))successBlock failure:(void (^)(ErrorModel *errorModel))failureBlock;

+ (Promise *)fetchMyDrinkLists;

+ (void)fetchDrinkListWithRequest:(DrinkListRequest *)request success:(void (^)(DrinkListModel *drinkListModel))successBlock failure:(void (^)(ErrorModel *errorModel))failureBlock;

+ (Promise *)fetchDrinkListWithRequest:(DrinkListRequest *)request;

- (void)fetchDrinkList:(void (^)(DrinkListModel *spotlist))successBlock failure:(void (^)(ErrorModel *errorModel))failureBlock;

- (Promise *)fetchDrinkList;

#pragma mark -

@end
