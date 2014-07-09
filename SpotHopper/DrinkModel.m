//
//  DrinkModel.m
//  SpotHopper
//
//  Created by Josh Holtz on 1/7/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "DrinkModel.h"

#import "ClientSessionManager.h"
#import "ErrorModel.h"
#import "SpotModel.h"
#import "DrinkTypeModel.h"
#import "DrinkSubTypeModel.h"
#import "SliderTemplateModel.h"

#import "DrinkListRequest.h"

#import <CoreLocation/CoreLocation.h>

#define kMinRadiusFloat 0.5f
#define kMaxRadiusFloat 5.0f
#define kMetersPerMile 1609.344

@interface DrinkModelCache : NSCache

+ (NSString *)spotsKeyForDrink:(DrinkModel *)drink coordinate:(CLLocationCoordinate2D)coordinate radius:(CGFloat)radius;

- (NSArray *)cachedSpotsForKey:(NSString *)key;
- (void)cacheSpots:(NSArray *)spots forKey:(NSString *)key;

- (NSArray *)cachedDrinkTypes;
- (void)cacheDrinkTypes:(NSArray *)drinkTypes;

@end

@implementation DrinkModel

#pragma mark - Debugging

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ - %@ [%@]", self.ID, self.name, NSStringFromClass([self class])];
}

- (id)debugQuickLookObject {
    return self.name;
}

#pragma mark - API

+ (void)cancelGetDrinks {
    [[ClientSessionManager sharedClient] cancelAllHTTPOperationsWithMethod:@"GET" path:@"/api/drinks" parameters:nil ignoreParams:YES];
}

+ (Promise*)getDrinks:(NSDictionary*)params success:(void(^)(NSArray *drinkModels, JSONAPI *jsonAPI))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock {
    // Creating deferred for promises
    Deferred *deferred = [Deferred deferred];

    [[ClientSessionManager sharedClient] GET:@"/api/drinks" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // Parses response with JSONAPI
        JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:responseObject];
        
        if (operation.response.statusCode == 200) {
            NSArray *models = [jsonApi resourcesForKey:@"drinks"];
            successBlock(models, jsonApi);
            
            // Resolves promise
            [deferred resolve];
        } else {
            ErrorModel *errorModel = [jsonApi resourceForKey:@"errors"];
            failureBlock(errorModel);
            
            // Rejects promise
            [deferred rejectWith:errorModel];
        }
    }];
    
    return deferred.promise;
}

+ (Promise*)postDrink:(NSDictionary*)params success:(void(^)(DrinkModel *drinkModel, JSONAPI *jsonAPI))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock {
    // Creating deferred for promises
    Deferred *deferred = [Deferred deferred];
    
    [[ClientSessionManager sharedClient] POST:@"/api/drinks" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // Parses response with JSONAPI
        JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:responseObject];
        
        if (operation.response.statusCode == 200) {
            DrinkModel *model = [jsonApi resourceForKey:@"drinks"];
            successBlock(model, jsonApi);
            
            // Resolves promise
            [deferred resolve];
        } else {
            ErrorModel *errorModel = [jsonApi resourceForKey:@"errors"];
            failureBlock(errorModel);
            
            // Rejects promise
            [deferred rejectWith:errorModel];
        }
    }];
    
    return deferred.promise;
}

- (Promise*)getDrink:(NSDictionary*)params success:(void(^)(DrinkModel *drinkModel, JSONAPI *jsonAPI))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock {
    // Creating deferred for promises
    Deferred *deferred = [Deferred deferred];
    
    [[ClientSessionManager sharedClient] GET:[NSString stringWithFormat:@"/api/drinks/%ld", (long)[self.ID integerValue] ] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // Parses response with JSONAPI
        JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:responseObject];
        
        if (operation.response.statusCode == 200) {
            DrinkModel *model = [jsonApi resourceForKey:@"drinks"];
            successBlock(model, jsonApi);
            
            // Resolves promise
            [deferred resolve];
        } else {
            ErrorModel *errorModel = [jsonApi resourceForKey:@"errors"];
            failureBlock(errorModel);
            
            // Rejects promise
            [deferred rejectWith:errorModel];
        }
    }];
    
    return deferred.promise;
}

- (Promise*)getSpots:(NSDictionary*)params success:(void(^)(NSArray *spotModels, JSONAPI *jsonApi))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock {
    // Creating deferred for promises
    Deferred *deferred = [Deferred deferred];
    
    [[ClientSessionManager sharedClient] GET:[NSString stringWithFormat:@"/api/drinks/%ld/spots", (long)[self.ID integerValue]] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // Parses response with JSONAPI
        JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:responseObject];
        
        if (operation.response.statusCode == 200) {
            NSArray *models = [jsonApi resourcesForKey:@"spots"];
            successBlock(models, jsonApi);
            
            // Resolves promise
            [deferred resolve];
        } else {
            ErrorModel *errorModel = [jsonApi resourceForKey:@"errors"];
            failureBlock(errorModel);
            
            // Rejects promise
            [deferred rejectWith:errorModel];
        }
    }];
    
    return deferred.promise;
}

#pragma mark - Revised Code for 2.0

- (void)fetchSpotsForDrinkListRequest:(DrinkListRequest *)request success:(void(^)(NSArray *spotModels))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock {
    if (!CLLocationCoordinate2DIsValid(request.coordinate)) {
        if (failureBlock) {
            ErrorModel *errorModel = [[ErrorModel alloc] init];
            errorModel.error = @"Coordinate is not valid";
            errorModel.human = @"Please select a location";
            failureBlock(errorModel);
        }
        return;
    }
    
    // look for cached spots
    NSString *cacheKey = [DrinkModelCache spotsKeyForDrink:self coordinate:request.coordinate radius:request.radius];
    NSArray *spots = [[DrinkModel sh_sharedCache] cachedSpotsForKey:cacheKey];
    if (spots && successBlock) {
        NSLog(@"Returning %lu cached spots", (unsigned long)spots.count);
        successBlock(spots);
    }
    else {
        // assemble params internally to encapsulate implementation details
        
        CGFloat miles = request.radius / kMetersPerMile;
        NSNumber *radiusParam = [NSNumber numberWithFloat:MAX(MIN(kMaxRadiusFloat, miles), kMinRadiusFloat)];
        DebugLog(@"radiusParam: %@", radiusParam);
        
        NSDictionary *params = @{
                                 kSpotModelParamPage : @1,
                                 kSpotModelParamsPageSize : @10,
                                 kSpotModelParamQueryLatitude : [NSNumber numberWithFloat:request.coordinate.latitude],
                                 kSpotModelParamQueryLongitude : [NSNumber numberWithFloat:request.coordinate.longitude],
                                 kSpotModelParamQueryRadius : radiusParam
                                 };
        
        [[ClientSessionManager sharedClient] GET:[NSString stringWithFormat:@"/api/drinks/%ld/spots", (long)[self.ID integerValue]] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            // Parses response with JSONAPI
            JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:responseObject];
            
            if (operation.response.statusCode == 200) {
                NSArray *spotModels = [jsonApi resourcesForKey:@"spots"];
                
                if (spotModels.count) {
                    [[DrinkModel sh_sharedCache] cacheSpots:spotModels forKey:cacheKey];
                }
                
                // always check that the block is defined because running it an undefined block will cause a crash
                if (successBlock) {
                    successBlock(spotModels);
                }
            } else {
                ErrorModel *errorModel = [jsonApi resourceForKey:@"errors"];
                // always check that the block is defined because running it an undefined block will cause a crash
                if (failureBlock) {
                    failureBlock(errorModel);
                }
            }
        }];
    }
}

- (Promise*)fetchSpotsForDrinkListRequest:(DrinkListRequest *)request {
    // Creating deferred for promises
    Deferred *deferred = [Deferred deferred];
    
    [self fetchSpotsForDrinkListRequest:request success:^(NSArray *spotModels) {
        // Resolves promise
        [deferred resolveWith:spotModels];
    } failure:^(ErrorModel *errorModel) {
        // Rejects promise
        [deferred rejectWith:errorModel];
    }];
    
    return deferred.promise;
}

- (void)fetchSpotsForLocation:(CLLocation *)location success:(void(^)(NSArray *spotModels))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock {
    DrinkListRequest *request = [[DrinkListRequest alloc] init];
    request.coordinate = location.coordinate;
    request.radius = kMaxRadiusFloat;
    
    [self fetchSpotsForDrinkListRequest:request success:successBlock failure:failureBlock];
}

- (Promise*)fetchSpotsForLocation:(CLLocation *)location {
    // Creating deferred for promises
    Deferred *deferred = [Deferred deferred];

    [self fetchSpotsForLocation:location success:^(NSArray *spotModels) {
        // Resolves promise
        [deferred resolveWith:spotModels];
    } failure:^(ErrorModel *errorModel) {
        // Rejects promise
        [deferred rejectWith:errorModel];
    }];
    
    return deferred.promise;
}

+ (void)fetchDrinkTypes:(void (^)(NSArray *drinkTypes))successBlock failure:(void (^)(ErrorModel *errorModel))failureBlock {
    NSArray *drinkTypes = [[DrinkModel sh_sharedCache] cachedDrinkTypes];
    if (drinkTypes.count && successBlock) {
        successBlock(drinkTypes);
        return;
    }
    
    // Gets drink form data (Beer, Wine and Cocktail)
    [DrinkModel getDrinks:@{kDrinkModelParamsPageSize:@0} success:^(NSArray *spotModels, JSONAPI *jsonApi) {
        NSDictionary *forms = [jsonApi objectForKey:@"form"];
        if (forms != nil) {
            NSArray *drinkTypes = [forms objectForKey:@"drink_types"];
            NSMutableArray *mappedDrinkTypes = @[].mutableCopy;
            for (NSDictionary *drinkTypeDictionary in drinkTypes) {
                DrinkTypeModel *drinkType = [SHJSONAPIResource jsonAPIResource:drinkTypeDictionary withLinked:jsonApi.linked withClass:[DrinkTypeModel class]];
                
                NSArray *subtypes = [SHJSONAPIResource jsonAPIResources:drinkTypeDictionary[@"drink_subtypes"] withLinked:jsonApi.linked withClass:[DrinkSubTypeModel class]];
                drinkType.subtypes = subtypes;
                [mappedDrinkTypes addObject:drinkType];
            }
            
            if (mappedDrinkTypes.count) {
                [[DrinkModel sh_sharedCache] cacheDrinkTypes:mappedDrinkTypes];
            }
            
            if (successBlock) {
                successBlock(mappedDrinkTypes);
            }
        }
    } failure:^(ErrorModel *errorModel) {
        if (failureBlock) {
            failureBlock(errorModel);
        }
    }];
}

+ (Promise *)fetchDrinkTypes {
    Deferred *deferred = [Deferred deferred];
    
    [DrinkModel fetchDrinkTypes:^(NSArray *drinkTypes) {
        [deferred resolveWith:drinkTypes];
    } failure:^(ErrorModel *errorModel) {
        [deferred rejectWith:errorModel];
    }];
    
    return deferred.promise;
}

#pragma mark - Caching

+ (DrinkModelCache *)sh_sharedCache {
    static DrinkModelCache *_sh_Cache = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sh_Cache = [[DrinkModelCache alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidReceiveMemoryWarningNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * __unused notification) {
            [_sh_Cache removeAllObjects];
        }];
    });
    
    return _sh_Cache;
}

#pragma mark - Getters

- (NSString *)name {
    return [self objectForKey:@"name"];
}

- (NSString *)imageUrl {
    return [self objectForKey:@"image_url"];
}

- (DrinkTypeModel *)drinkType {
    return [self linkedResourceForKey:@"drink_type"];
}

- (DrinkSubTypeModel *)drinkSubtype {
    return [self linkedResourceForKey:@"drink_subtype"];
}

- (NSString *)type {
    return [self objectForKey:@"type"];
}

- (NSString *)subtype {
    return [self objectForKey:@"subtype"];
}

- (NSString *)descriptionOfDrink {
    return [self objectForKey:@"description"];
}

- (NSString *)recipeOfDrink {
    return [self objectForKey:@"recipe"];
}

- (NSNumber *)abv {
    return [self objectForKey:@"abv"];
}

- (NSString*)abvPercentString {
    return [NSString stringWithFormat:@"%.02f %%", (self.abv.floatValue * 100.0f)];
}

- (NSString *)style {
    return [self objectForKey:@"style"];
}

- (NSString *)varietal {
    return [self objectForKey:@"varietal"];
}

- (NSNumber *)vintage {
    return [self objectForKey:@"vintage"];
}

- (NSNumber *)region {
    return [self objectForKey:@"region"];
}

- (SpotModel *)spot {
    return [self linkedResourceForKey:@"spot"];
}

- (NSNumber *)spotId {
    return [self objectForKey:@"spot_id"];
}

- (NSArray *)sliderTemplates {
    return [[self linkedResourceForKey:@"slider_templates"] sortedArrayUsingComparator:^NSComparisonResult(SliderTemplateModel *obj1, SliderTemplateModel *obj2) {
        return [obj1.order compare:obj2.order];
    }];
}

- (AverageReviewModel *)averageReview {
    return [self linkedResourceForKey:@"average_review"];
}

- (NSNumber *)match {
    return [self objectForKey:@"match"];
}

- (NSString *)matchPercent {
    if ([self match] == nil) {
        return nil;
    }
    return [NSString stringWithFormat:@"%d%%", (int)([self match].floatValue * 100)];
}

- (NSNumber *)relevance {
    NSNumber *rel = [self objectForKey:@"relevance"];
    return ( rel == nil ? @0 : rel );
}

- (NSArray *)baseAlochols {
    return [self linkedResourceForKey:@"base_alcohols"];
}

- (NSArray *)images {
    return [self linkedResourceForKey:@"images"];
}

#pragma mark - Helpers

- (BOOL)isBeer {
    return [[self drinkType].name isEqualToString:kDrinkTypeNameBeer];
}

- (BOOL)isCocktail {
    return [[self drinkType].name isEqualToString:kDrinkTypeNameCocktail];
}

- (BOOL)isWine {
    return [[self drinkType].name isEqualToString:kDrinkTypeNameWine];
}

- (UIImage *)placeholderImage {
    if ([self isBeer] == YES) {
        return [UIImage imageNamed:@"beer_placeholder"];
    } else if ([self isCocktail] == YES) {
        return [UIImage imageNamed:@"cocktail_placeholder"];
    } else if ([self isWine] == YES) {
        return [UIImage imageNamed:@"wine_placeholder"];
    }
    
    return nil;
}

@end

@implementation DrinkModelCache

NSString * const DrinkTypesKey = @"DrinkTypes";

+ (NSString *)spotsKeyForDrink:(DrinkModel *)drink coordinate:(CLLocationCoordinate2D)coordinate radius:(CGFloat)radius {
    return [NSString stringWithFormat:@"key-spots-%@-%f-%f-%f", drink.ID, coordinate.latitude, coordinate.longitude, radius];
}

- (NSArray *)cachedSpotsForKey:(NSString *)key {
    return [self objectForKey:key];
}

- (void)cacheSpots:(NSArray *)spots forKey:(NSString *)key {
    if (spots.count) {
        [self setObject:spots forKey:key];
    }
    else {
        [self removeObjectForKey:key];
    }
}

- (NSArray *)cachedDrinkTypes {
    return [self objectForKey:DrinkTypesKey];
}

- (void)cacheDrinkTypes:(NSArray *)drinkTypes {
    if (drinkTypes.count) {
        [self setObject:drinkTypes forKey:DrinkTypesKey];
    }
    else {
        [self removeObjectForKey:DrinkTypesKey];
    }
    
}

@end
