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
#define kDrinkModelParamRecipe @"recipe"
#define kDrinkModelParamRegion @"region"
#define kDrinkModelParamVarietal @"varietal"
#define kDrinkModelParamSpotId @"spot_id"
#define kDrinkModelParamDrinkTypeId @"drink_type_id"
#define kDrinkModelParamDrinkSubtypeId @"drink_subtype_id"
#define kDrinkModelParamBaseAlcohols @"base_alcohols"
#define kDrinkModelParamManufacturer @"manufacturer_id"

#define kDrinkModelMetaPage @"page"
#define kDrinkModelMetaTotalRecords @"total_records"

#import "SHJSONAPIResource.h"

#import <JSONAPI/JSONAPI.h>

@class AverageReviewModel;
@class ErrorModel;
@class DrinkTypeModel;
@class DrinkSubTypeModel;
@class SpotModel;
@class DrinkListRequest;
@class ImageModel;
@class CLLocation;

@interface DrinkModel : SHJSONAPIResource

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, strong) DrinkTypeModel *drinkType;
@property (nonatomic, strong) DrinkSubTypeModel *drinkSubtype;
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
@property (nonatomic, strong) NSArray *highlightImages;
@property (nonatomic, strong) NSNumber *relevance;

@property (nonatomic, readonly) BOOL isBeer;
@property (nonatomic, readonly) BOOL isCocktail;
@property (nonatomic, readonly) BOOL isWine;

@property (nonatomic, readonly) ImageModel *highlightImage;
@property (nonatomic, readonly) NSString *rating;
@property (nonatomic, readonly) NSString *ratingShort;
@property (nonatomic, readonly) NSString *drinkStyle;
@property (nonatomic, readonly) UIImage *placeholderImage;

- (NSString *)matchPercent;

+ (void)cancelGetDrinks;

+ (Promise*)getDrinks:(NSDictionary*)params success:(void(^)(NSArray *drinkModels, JSONAPI *jsonApi))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock;

+ (Promise*)postDrink:(NSDictionary*)params success:(void(^)(DrinkModel *drinkModel, JSONAPI *jsonAPI))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock;

- (Promise*)getDrink:(NSDictionary*)params success:(void(^)(DrinkModel *drinkModel, JSONAPI *jsonAPI))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock;

- (Promise*)getSpots:(NSDictionary*)params success:(void(^)(NSArray *spotModels, JSONAPI *jsonApi))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock __attribute__ ((deprecated));

#pragma mark - Revised Code for 2.0

+ (void)fetchDrinksWithText:(NSString *)text page:(NSNumber *)page success:(void(^)(NSArray *drinks))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock;

+ (Promise*)fetchDrinksWithText:(NSString *)text page:(NSNumber *)page;

- (void)fetchDrink:(void(^)(DrinkModel *drinkModel))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock;

- (Promise*)fetchDrink;

- (void)fetchSpotsForDrinkListRequest:(DrinkListRequest *)request success:(void(^)(NSArray *spotModels))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock;

- (Promise*)fetchSpotsForDrinkListRequest:(DrinkListRequest *)request;

- (void)fetchSpotsForLocation:(CLLocation *)location success:(void(^)(NSArray *spotModels))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock;

- (Promise*)fetchSpotsForLocation:(CLLocation *)location;

+ (void)fetchDrinkTypes:(void (^)(NSArray *drinkTypes))successBlock failure:(void (^)(ErrorModel *errorModel))failureBlock;

+ (Promise *)fetchDrinkTypes;

+ (void)createPhotoForDrink:(NSString*)imagePath drink:(DrinkModel*)drink success:(void(^)(ImageModel *imageModel))success failure:(void(^)(ErrorModel* error))failure;

+ (void)createDrink:(DrinkModel *)drink success:(void(^)(DrinkModel *drinkModel))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock;

+ (Promise *)createDrink:(DrinkModel *)drink;

+ (void)fetchBeerStylesWithSuccess:(void(^)(NSArray *beerStyles))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock;

+ (Promise *)fetchBeerStyles;

+ (void)fetchWineVarietalsWithSuccess:(void(^)(NSArray *varietals))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock;

+ (Promise *)fetchWineVarietals;

+ (void)fetchCocktailTypesWithSuccess:(void(^)(NSArray *cocktailTypes))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock;

+ (Promise *)fetchCocktailTypes;

+ (void)fetchWineTypesWithSuccess:(void(^)(NSArray *wineTypes))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock;

+ (Promise *)fetchWineTypes;

+ (void)fetchDrinksForDrinkType:(DrinkTypeModel *)drinkType query:(NSString *)query page:(NSNumber *)page pageSize:(NSNumber *)pageSize spot:(SpotModel *)spot success:(void(^)(NSArray *drinks))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock;

+ (Promise *)fetchDrinksForDrinkType:(DrinkTypeModel *)drinkType query:(NSString *)query page:(NSNumber *)page pageSize:(NSNumber *)pageSize spot:(SpotModel *)spot;

#pragma mark -

- (NSString*)abvPercentString;

@end
