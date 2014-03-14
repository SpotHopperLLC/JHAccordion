//
//  DrinkListModel.h
//  SpotHopper
//
//  Created by Josh Holtz on 3/13/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#define kDrinkListModelDefaultName @"Custom Spotlist"

#define kDrinkListModelParamName @"name"
#define kDrinkListModelParamLatitude @"latitude"
#define kDrinkListModelParamLongitude @"longitude"
#define kDrinkListModelParamBasedOnSlider @"based_on_sliders"

#define kDrinkListModelQueryParamLat @"lat"
#define kDrinkListModelQueryParamLng @"lng"

#import "SHJSONAPIResource.h"

#import <JSONAPI/JSONAPI.h>

@class ErrorModel, SpotModel, DrinkTypeModel, CLLocation;

@interface DrinkListModel : SHJSONAPIResource

@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) BOOL featured;
@property (nonatomic, strong) NSArray *drinks;
@property (nonatomic, strong) NSNumber *latitude;
@property (nonatomic, strong) NSNumber *longitude;

- (CLLocation*)location;

+ (Promise *)getFeaturedDrinkLists:(NSDictionary *)params success:(void (^)(NSArray *, JSONAPI *))successBlock failure:(void (^)(ErrorModel *))failureBlock;
+ (Promise *)postDrinkList:(NSString*)name latitude:(NSNumber*)latitude longitude:(NSNumber*)longitude sliders:(NSArray*)sliders drinkId:(NSNumber*)drinkId drinkTypeId:(NSNumber*)drinkTypeId spotId:(NSNumber*)spotId successBlock:(void (^)(DrinkListModel *, JSONAPI *))successBlock failure:(void (^)(ErrorModel *))failureBlock;

- (Promise *)getDrinkList:(NSDictionary *)params success:(void (^)(DrinkListModel *, JSONAPI *))successBlock failure:(void (^)(ErrorModel *))failureBlock;
- (Promise *)putDrinkList:(NSString*)name latitude:(NSNumber*)latitude longitude:(NSNumber*)longitude sliders:(NSArray*)sliders success:(void (^)(DrinkListModel *, JSONAPI *))successBlock failure:(void (^)(ErrorModel *))failureBlock;
- (Promise *)deleteDrinkList:(NSDictionary *)params success:(void (^)(DrinkListModel *, JSONAPI *))successBlock failure:(void (^)(ErrorModel *))failureBlock;

@end
