//
//  SpotModel.h
//  SpotHopper
//
//  Created by Josh Holtz on 1/7/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#define kSpotModelParamPage @"page"
#define kSpotModelParamsPageSize @"page_size"
#define kSpotModelParamQuery @"query"
#define kSpotModelParamLatitude @"latitude"
#define kSpotModelParamLongitude @"longitude"

#define kSpotModelParamName @"name"
#define kSpotModelParamAddress @"address"
#define kSpotModelParamCity @"city"
#define kSpotModelParamState @"state"
#define kSpotModelParamSpotTypeId @"spot_type_id"

#define kSpotModelMetaPage @"page"
#define kSpotModelMetaTotalRecords @"total_records"

#import "SHJSONAPIResource.h"

#import "NSArray+HoursOfOperation.h"

#import <JSONAPI/JSONAPI.h>

@class ErrorModel;

@interface SpotModel : SHJSONAPIResource

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *phoneNumber;
@property (nonatomic, strong) NSArray *hoursOfOperation; // Returns array (7 in size, SMTWTFS) of arrays (2 in size, open to close)
@property (nonatomic, strong) NSNumber *latitude;
@property (nonatomic, strong) NSNumber *longitude;
@property (nonatomic, strong) NSArray *sliderTemplates;

+ (Promise*)getSpots:(NSDictionary*)params success:(void(^)(NSArray *spotModels, JSONAPI *jsonApi))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock;

+ (Promise*)postSpot:(NSDictionary*)params success:(void(^)(SpotModel *spotModel, JSONAPI *jsonApi))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock;

@end
