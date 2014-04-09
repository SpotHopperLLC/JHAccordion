//
//  DrinkModel.h
//  SpotHopper
//
//  Created by Josh Holtz on 1/7/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#define kDrinkModelParamPage @"page_number"
#define kDrinkModelParamsPageSize @"page_size"
#define kDrinkModelParamQuery @"query"

#define kDrinkModelParamName @"name"
#define kDrinkModelParamDescription @"description"
#define kDrinkModelParamABV @"abv"
#define kDrinkModelParamStyle @"style"
#define kDrinkModelParamVintage @"vintage"
#define kDrinkModelParamReceipe @"receipe"
#define kDrinkModelParamRegion @"region"
#define kDrinkModelParamVarietal @"varietal"
#define kDrinkModelParamSpotId @"spot_id"
#define kDrinkModelParamDrinkTypeId @"drink_type_id"
#define kDrinkModelParamDrinkSubtypeId @"drink_subtype_id"
#define kDrinkModelParamBaseAlcohols @"base_alcohols"

#define kDrinkModelMetaPage @"page"
#define kDrinkModelMetaTotalRecords @"total_records"

#import "SHJSONAPIResource.h"

#import <JSONAPI/JSONAPI.h>

@class AverageReviewModel;
@class ErrorModel;
@class DrinkTypeModel;
@class DrinkSubtypeModel;
@class SpotModel;

@interface DrinkModel : SHJSONAPIResource

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, strong) DrinkTypeModel *drinkType;
@property (nonatomic, strong) DrinkSubtypeModel *drinkSubtype;
@property (nonatomic, strong) NSString *descriptionOfDrink;
@property (nonatomic, strong) NSString *recipeOfDrink;
@property (nonatomic, strong) NSNumber *abv;
@property (nonatomic, strong) NSString *style;
@property (nonatomic, strong) NSString *varietal;
@property (nonatomic, strong) NSNumber *vintage;
@property (nonatomic, strong) NSString *region;
@property (nonatomic, strong) SpotModel *spot;
@property (nonatomic, strong) NSNumber *spotId;
@property (nonatomic, strong) NSArray *sliderTemplates;
@property (nonatomic, strong) AverageReviewModel *averageReview;
@property (nonatomic, strong) NSNumber *match;
@property (nonatomic, strong) NSArray *baseAlochols;
@property (nonatomic, strong) NSArray *images;
@property (nonatomic, strong) NSNumber *relevance;

- (NSString *)matchPercent;

+ (Promise*)getDrinks:(NSDictionary*)params success:(void(^)(NSArray *drinkModels, JSONAPI *jsonApi))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock;

+ (Promise*)postDrink:(NSDictionary*)params success:(void(^)(DrinkModel *drinkModel, JSONAPI *jsonAPI))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock;

- (Promise*)getDrink:(NSDictionary*)params success:(void(^)(DrinkModel *drinkModel, JSONAPI *jsonAPI))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock;

- (Promise*)getSpots:(NSDictionary*)params success:(void(^)(NSArray *spotModels, JSONAPI *jsonApi))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock;

- (NSString*)abvPercentString;

#pragma mark - Helpers

- (BOOL)isBeer;
- (BOOL)isCocktail;
- (BOOL)isWine;
- (UIImage *)placeholderImage;

@end
