//
//  SpotListModel.h
//  SpotHopper
//
//  Created by Josh Holtz on 3/4/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#define kSpotListModelDefaultName @"Custom Spotlist"

#define kSpotListModelParamName @"name"
#define kSpotListModelParamLatitude @"latitude"
#define kSpotListModelParamLongitude @"longitude"
#define kSpotListModelParamRadius @"radius"
#define kSpotListModelParamBasedOnSlider @"based_on_sliders"

#define kSpotListModelQueryParamLat @"lat"
#define kSpotListModelQueryParamLng @"lng"

#import "SHJSONAPIResource.h"

#import <JSONAPI/JSONAPI.h>
#import <Promises/Promise.h>

@class ErrorModel, SpotModel, SpotListRequest, CLLocation;

@interface SpotListModel : SHJSONAPIResource

@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) BOOL featured;
@property (nonatomic, strong) NSArray *spots;
@property (nonatomic, strong) NSNumber *latitude;
@property (nonatomic, strong) NSNumber *longitude;
@property (nonatomic, strong) NSNumber *radius;

- (CLLocation*)location;

+ (Promise *)getFeaturedSpotLists:(NSDictionary*)params success:(void(^)(NSArray *spotListModels, JSONAPI *jsonApi))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock;
+ (Promise *)postSpotList:(NSString*)name spotId:(NSNumber*)spotId spotTypeId:(NSNumber*)spotTypeId latitude:(NSNumber*)latitude longitude:(NSNumber*)longitude sliders:(NSArray*)sliders successBlock:(void (^)(SpotListModel *, JSONAPI *))successBlock failure:(void (^)(ErrorModel *))failureBlock;

- (Promise *)getSpotList:(NSDictionary *)params success:(void (^)(SpotListModel *, JSONAPI *))successBlock failure:(void (^)(ErrorModel *))failureBlock;
- (Promise *)putSpotList:(NSString*)name latitude:(NSNumber*)latitude longitude:(NSNumber*)longitude radius:(NSNumber*)radius sliders:(NSArray*)sliders success:(void (^)(SpotListModel *, JSONAPI *))successBlock failure:(void (^)(ErrorModel *))failureBlock;
- (Promise *)deleteSpotList:(NSDictionary *)params success:(void (^)(SpotListModel *, JSONAPI *))successBlock failure:(void (^)(ErrorModel *))failureBlock;

#pragma mark - Revised Code for 2.0

+ (void)fetchSpotListWithRequest:(SpotListRequest *)request success:(void (^)(SpotListModel *spotListModel, JSONAPI *jsonApi))successBlock failure:(void (^)(ErrorModel *errorModel))failureBlock;

+ (Promise *)fetchSpotListWithRequest:(SpotListRequest *)request;

@end
