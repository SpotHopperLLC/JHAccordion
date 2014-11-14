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
#import "AverageReviewModel.h"
#import "BaseAlcoholModel.h"

#import "DrinkListRequest.h"

#import "Tracker.h"

#import <CoreLocation/CoreLocation.h>

#define kPageSize @15

#define kMinRadiusFloat 0.1f
#define kMaxRadiusFloat 10.0f
#define kMetersPerMile 1609.344

@interface DrinkModelCache : NSCache

+ (NSString *)spotsKeyForDrink:(DrinkModel *)drink coordinate:(CLLocationCoordinate2D)coordinate radius:(CGFloat)radius;

- (NSArray *)cachedSpotsForKey:(NSString *)key;
- (void)cacheSpots:(NSArray *)spots forKey:(NSString *)key;

- (NSArray *)cachedDrinkTypes;
- (void)cacheDrinkTypes:(NSArray *)drinkTypes;

- (DrinkModel *)cachedDrinkForKey:(NSString *)key;
- (void)cacheDrink:(DrinkModel *)drink withKey:(NSString *)key;

- (NSDictionary *)cachedForms;
- (void)cacheForms:(NSDictionary *)forms;

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

+ (Promise *)getDrinks:(NSDictionary*)params success:(void(^)(NSArray *drinkModels, JSONAPI *jsonAPI))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock {
    // Creating deferred for promises
    Deferred *deferred = [Deferred deferred];

    [[ClientSessionManager sharedClient] GET:@"/api/drinks" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // Parses response with JSONAPI
        JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:responseObject];
        
        if (operation.isCancelled || operation.response.statusCode == 204) {
            if (successBlock) {
                successBlock(nil, nil);
            }
            
            // Resolves promise
            [deferred resolve];
        }
        else if (operation.response.statusCode == 200) {
            NSArray *models = [jsonApi resourcesForKey:@"drinks"];
            if (successBlock) {
                successBlock(models, jsonApi);
            }
            
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

+ (Promise *)postDrink:(NSDictionary*)params success:(void(^)(DrinkModel *drinkModel, JSONAPI *jsonAPI))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock {
    // Creating deferred for promises
    Deferred *deferred = [Deferred deferred];
    
    [[ClientSessionManager sharedClient] POST:@"/api/drinks" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // Parses response with JSONAPI
        JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:responseObject];
        
        if (operation.isCancelled || operation.response.statusCode == 204) {
            if (successBlock) {
                successBlock(nil, nil);
            }
            
            // Resolves promise
            [deferred resolve];
        }
        else if (operation.response.statusCode == 200) {
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

- (Promise *)getDrink:(NSDictionary*)params success:(void(^)(DrinkModel *drinkModel, JSONAPI *jsonAPI))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock {
    // Creating deferred for promises
    Deferred *deferred = [Deferred deferred];
    
    [[ClientSessionManager sharedClient] GET:[NSString stringWithFormat:@"/api/drinks/%ld", (long)[self.ID integerValue]] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // Parses response with JSONAPI
        JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:responseObject];
        
        if (operation.isCancelled || operation.response.statusCode == 204) {
            if (successBlock) {
                successBlock(nil, nil);
            }
            
            // Resolves promise
            [deferred resolve];
        }
        else if (operation.response.statusCode == 200) {
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

- (Promise *)getSpots:(NSDictionary*)params success:(void(^)(NSArray *spotModels, JSONAPI *jsonApi))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock {
    // Creating deferred for promises
    Deferred *deferred = [Deferred deferred];
    
    [[ClientSessionManager sharedClient] GET:[NSString stringWithFormat:@"/api/drinks/%ld/spots", (long)[self.ID integerValue]] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // Parses response with JSONAPI
        JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:responseObject];
        
        if (operation.isCancelled || operation.response.statusCode == 204) {
            if (successBlock) {
                successBlock(nil, nil);
            }
            
            // Resolves promise
            [deferred resolve];
        }
        else if (operation.response.statusCode == 200) {
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

+ (void)fetchDrinksWithText:(NSString *)text page:(NSNumber *)page success:(void(^)(NSArray *drinks))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock {
    NSDictionary *params = @{
                             kDrinkModelParamQuery : text,
                             kDrinkModelParamPage : page,
                             kDrinkModelParamsPageSize : @5
                             };
    
    NSDate *startDate = [NSDate date];
    
    [[ClientSessionManager sharedClient] GET:@"/api/drinks" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // Parses response with JSONAPI
        JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:responseObject];
        
        NSTimeInterval duration = [[NSDate date] timeIntervalSinceDate:startDate];
        
        if (operation.isCancelled || operation.response.statusCode == 204) {
            if (successBlock) {
                successBlock(nil);
            }
        }
        else if (operation.response.statusCode == 200) {
            NSArray *drinks = [jsonApi resourcesForKey:@"drinks"];
            
            // only track a successful search
            [Tracker track:@"Drink Search Duration" properties:@{ @"Duration" : [NSNumber numberWithFloat:duration] }];
            
            if (successBlock) {
                successBlock(drinks);
            }
        } else {
            ErrorModel *errorModel = [jsonApi resourceForKey:@"errors"];
            
            if (failureBlock) {
                failureBlock(errorModel);
            }
        }
    }];
}

+ (Promise *)fetchDrinksWithText:(NSString *)text page:(NSNumber *)page {
    // Creating deferred for promises
    Deferred *deferred = [Deferred deferred];
    
    [self fetchDrinksWithText:text page:page success:^(NSArray *drinks) {
        // Resolves promise
        [deferred resolveWith:drinks];
    } failure:^(ErrorModel *errorModel) {
        // Rejects promise
        [deferred rejectWith:errorModel];
    }];
    
    return deferred.promise;
}

- (void)fetchDrink:(void(^)(DrinkModel *drinkModel))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock {
    NSString *key = [NSString stringWithFormat:@"Drink-%@", self.ID];
    DrinkModel *cachedDrink = [[DrinkModel sh_sharedCache] cachedDrinkForKey:key];
    if (cachedDrink && successBlock) {
        successBlock(cachedDrink);
        return;
    }
    
    [[ClientSessionManager sharedClient] GET:[NSString stringWithFormat:@"/api/drinks/%ld", (long)[self.ID integerValue]] parameters:@{} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // Parses response with JSONAPI
        JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:responseObject];
        
        if (operation.isCancelled || operation.response.statusCode == 204) {
            if (successBlock) {
                successBlock(nil);
            }
        }
        else if (operation.response.statusCode == 200) {
            DrinkModel *drinkModel = [jsonApi resourceForKey:@"drinks"];
            
            [[DrinkModel sh_sharedCache] cacheDrink:drinkModel withKey:key];
            
            if (successBlock) {
                successBlock(drinkModel);
            }
        } else {
            ErrorModel *errorModel = [jsonApi resourceForKey:@"errors"];
            if (failureBlock) {
                failureBlock(errorModel);
            }
        }
    }];
}

- (Promise *)fetchDrink {
    // Creating deferred for promises
    Deferred *deferred = [Deferred deferred];

    [self fetchDrink:^(DrinkModel *drinkModel) {
        // Resolves promise
        [deferred resolveWith:drinkModel];
    } failure:^(ErrorModel *errorModel) {
        // Rejects promise
        [deferred rejectWith:errorModel];
    }];
    
    return deferred.promise;
}

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
        successBlock(spots);
    }
    else {
        // assemble params internally to encapsulate implementation details
        
        NSNumber *radiusParam = [NSNumber numberWithFloat:MAX(MIN(kMaxRadiusFloat, request.radius), kMinRadiusFloat)];
        
        NSDictionary *params = @{
                                 kSpotModelParamPage : @1,
                                 kSpotModelParamsPageSize : @10,
                                 kSpotModelParamQueryLatitude : [NSNumber numberWithFloat:request.coordinate.latitude],
                                 kSpotModelParamQueryLongitude : [NSNumber numberWithFloat:request.coordinate.longitude],
                                 kSpotModelParamQueryRadius : radiusParam
                                 };
        
        DebugLog(@"params: %@", params);
        
        [[ClientSessionManager sharedClient] GET:[NSString stringWithFormat:@"/api/drinks/%ld/spots", (long)[self.ID integerValue]] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            // Parses response with JSONAPI
            JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:responseObject];
            
            if (operation.isCancelled || operation.response.statusCode == 204) {
                if (successBlock) {
                    successBlock(nil);
                }
            }
            else if (operation.response.statusCode == 200) {
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

- (Promise *)fetchSpotsForDrinkListRequest:(DrinkListRequest *)request {
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

- (Promise *)fetchSpotsForLocation:(CLLocation *)location {
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

+ (void)createPhotoForDrink:(NSString*)imagePath drink:(DrinkModel*)drink success:(void(^)(ImageModel *imageModel))successBlock failure:(void(^)(ErrorModel* error))failureBlock {
    NSDictionary *params = @{
                             @"path" : imagePath.length ? imagePath : @"",
                             @"drink_id" : drink ? drink.ID : @0
                             };
    
    //POST /api/images
    [[ClientSessionManager sharedClient] POST:@"/api/images" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:responseObject];
        
        if (operation.response.statusCode == 200) {
            ImageModel *imageModel = [jsonApi resourceForKey:@"images"];
            
            if (successBlock) {
                successBlock(imageModel);
            }
        }
        else {
            if (failureBlock) {
                ErrorModel *error = [jsonApi resourceForKey:@"errors"];
                failureBlock(error);
            }
        }
    }];
}

+ (void)createDrink:(DrinkModel *)drink success:(void (^)(DrinkModel *drinkModel))successBlock failure:(void (^)(ErrorModel *errorModel))failureBlock {
	if (!drink.name.length || !drink.drinkType.ID) {
		if (failureBlock) {
			ErrorModel *errorModel = [[ErrorModel alloc] init];
			errorModel.human = @"Drink model is not valid";
			errorModel.error = @"Invalid model";
			failureBlock(errorModel);
		}
		return;
	}

	NSMutableDictionary *params = @{
		kDrinkModelParamName: drink.name,
		kDrinkModelParamDrinkTypeId: drink.drinkType.ID
	}.mutableCopy;
    
    if (drink.drinkSubtype.ID) {
        params[kDrinkModelParamDrinkSubtypeId] = drink.drinkSubtype.ID;
    }
    if (drink.spot.ID) {
        params[kDrinkModelParamSpotId] = drink.spot.ID;
    }
    if (drink.style.length) {
        params[kDrinkModelParamStyle] = drink.style;
    }
    if (drink.varietal.length) {
        params[kDrinkModelParamVarietal] = drink.varietal;
    }
    if (drink.vintage) {
        params[kDrinkModelParamVintage] = drink.vintage;
    }
    if (drink.drinkSubtype.ID) {
        params[kDrinkModelParamDrinkSubtypeId] = drink.drinkSubtype.ID;
    }
    if (drink.baseAlochols.count) {
        NSMutableArray *baseAlcoholIds = @[].mutableCopy;
        for (BaseAlcoholModel *baseAlcohol in drink.baseAlochols) {
            if (baseAlcohol.ID) {
                [baseAlcoholIds addObject:baseAlcohol.ID];
            }
        }
        params[kDrinkModelParamBaseAlcohols] = baseAlcoholIds;
    }
    
    DebugLog(@"params: %@", params);

	[[ClientSessionManager sharedClient] POST:@"/api/drinks" parameters:params success: ^(AFHTTPRequestOperation *operation, id responseObject) {
	    JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:responseObject];

	    if (operation.isCancelled || operation.response.statusCode == 204) {
	        if (successBlock) {
	            successBlock(nil);
			}
		}
	    else if (operation.response.statusCode == 200) {
	        DrinkModel *model = [jsonApi resourceForKey:@"drinks"];
	        if (successBlock) {
	            successBlock(model);
			}
		}
	    else {
	        ErrorModel *errorModel = [jsonApi resourceForKey:@"errors"];
	        if (failureBlock) {
	            failureBlock(errorModel);
			}
		}
	}];
}

+ (Promise *)createDrink:(DrinkModel *)drink {
	Deferred *deferred = [Deferred deferred];

	[self createDrink:drink success: ^(DrinkModel *drinkModel) {
	    [deferred resolveWith:drink];
	} failure: ^(ErrorModel *errorModel) {
	    [deferred rejectWith:errorModel];
	}];

	return deferred.promise;
}

+ (void)fetchBeerStylesWithSuccess:(void (^)(NSArray *beerStyles))successBlock failure:(void (^)(ErrorModel *errorModel))failureBlock {
	[self fetchDrinkFormsWithSuccess: ^(NSDictionary *forms) {
	    NSArray *beerStyles = [forms[@"styles"] sortedArrayUsingSelector:@selector(compare:)];
	    if (successBlock) {
	        successBlock(beerStyles);
		}
	} failure:failureBlock];
}

+ (Promise *)fetchBeerStyles {
	Deferred *deferred = [Deferred deferred];

	[self fetchBeerStylesWithSuccess: ^(NSArray *beerStyles) {
	    [deferred resolveWith:beerStyles];
	} failure: ^(ErrorModel *errorModel) {
	    [deferred rejectWith:errorModel];
	}];

	return deferred.promise;
}

+ (void)fetchWineVarietalsWithSuccess:(void (^)(NSArray *varietals))successBlock failure:(void (^)(ErrorModel *errorModel))failureBlock {
	[self fetchDrinkFormsWithSuccess: ^(NSDictionary *forms) {
	    NSArray *allVarietals = [[forms objectForKey:@"varietals"] sortedArrayUsingSelector:@selector(compare:)];
        
        NSMutableArray *varietals = @[].mutableCopy;
        
        for (NSString *varietal in allVarietals) {
            if (varietal.length) {
                [varietals addObject:varietal];
            }
        }
        
	    if (successBlock) {
	        successBlock(varietals);
		}
	} failure:failureBlock];
}

+ (Promise *)fetchWineVarietals {
	Deferred *deferred = [Deferred deferred];

	[self fetchWineVarietalsWithSuccess: ^(NSArray *varietals) {
	    [deferred resolveWith:varietals];
	} failure: ^(ErrorModel *errorModel) {
	    [deferred rejectWith:errorModel];
	}];

	return deferred.promise;
}

+ (void)fetchCocktailTypesWithSuccess:(void (^)(NSArray *cocktailTypes))successBlock failure:(void (^)(ErrorModel *errorModel))failureBlock {
	[self fetchDrinkFormsWithSuccess: ^(NSDictionary *forms) {
	    NSArray *cocktailTypes = nil;
	    NSArray *drinkTypes = [forms objectForKey:@"drink_types"];
	    for (NSDictionary * drinkType in drinkTypes) {
	        if ([[drinkType[@"name"] lowercaseString] isEqualToString:@"cocktail"]) {
                cocktailTypes = [SHJSONAPIResource jsonAPIResources:drinkType[@"drink_subtypes"] withLinked:nil withClass:[DrinkSubTypeModel class]];
			}
		}

	    if (successBlock) {
	        successBlock(cocktailTypes);
		}
	} failure:failureBlock];
}

+ (Promise *)fetchCocktailTypes {
	Deferred *deferred = [Deferred deferred];

	[self fetchCocktailTypesWithSuccess: ^(NSArray *cocktailTypes) {
	    [deferred resolveWith:cocktailTypes];
	} failure: ^(ErrorModel *errorModel) {
	    [deferred rejectWith:errorModel];
	}];

	return deferred.promise;
}

+ (void)fetchWineTypesWithSuccess:(void (^)(NSArray *wineTypes))successBlock failure:(void (^)(ErrorModel *errorModel))failureBlock {
	[self fetchDrinkFormsWithSuccess: ^(NSDictionary *forms) {
	    NSArray *wineTypes = nil;
        
	    NSArray *drinkTypes = [forms objectForKey:@"drink_types"];
	    for (NSDictionary * drinkType in drinkTypes) {
	        if ([[drinkType[@"name"] lowercaseString] isEqualToString:@"wine"]) {
                wineTypes = [SHJSONAPIResource jsonAPIResources:drinkType[@"drink_subtypes"] withLinked:nil withClass:[DrinkSubTypeModel class]];
			}
		}

	    if (successBlock) {
	        successBlock(wineTypes);
		}
	} failure:failureBlock];
}

+ (Promise *)fetchWineTypes {
	Deferred *deferred = [Deferred deferred];

	[self fetchWineTypesWithSuccess: ^(NSArray *wineTypes) {
	    [deferred resolveWith:wineTypes];
	} failure: ^(ErrorModel *errorModel) {
	    [deferred rejectWith:errorModel];
	}];

	return deferred.promise;
}

+ (void)fetchDrinksForDrinkType:(DrinkTypeModel *)drinkType drinkSubType:(DrinkSubTypeModel *)drinkSubType query:(NSString *)query page:(NSNumber *)page pageSize:(NSNumber *)pageSize spot:(SpotModel *)spot success:(void(^)(NSArray *drinks))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock {

    // cancel API calls for drinks
    [[ClientSessionManager sharedClient] cancelAllHTTPOperationsWithMethod:@"GET" path:@"/api/drinks" parameters:nil ignoreParams:YES];
    
    NSMutableDictionary *params = [@{
                                     kDrinkModelParamPage : page ? page : @1,
                                     kDrinkModelParamsPageSize : pageSize ? pageSize : @20,
                                     } mutableCopy];

    if (drinkType.ID) {
        params[kDrinkModelParamDrinkTypeId] = drinkType.ID;
    }
    if (drinkSubType.ID) {
        params[kDrinkModelParamDrinkSubtypeId] = drinkSubType.ID;
    }
    if (query.length) {
        params[kDrinkModelParamQuery] = query;
    }
    if (spot.ID) {
        params[kDrinkModelParamManufacturer] = spot.ID;
    }
    
    [[ClientSessionManager sharedClient] GET:@"/api/drinks" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // Parses response with JSONAPI
        JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:responseObject];
        
        if (operation.isCancelled || operation.response.statusCode == 204) {
            if (successBlock) {
                successBlock(nil);
            }
        }
        else if (operation.response.statusCode == 200) {
            NSArray *models = [jsonApi resourcesForKey:@"drinks"];
            if (successBlock) {
                successBlock(models);
            }
        }
        else {
            ErrorModel *errorModel = [jsonApi resourceForKey:@"errors"];
            failureBlock(errorModel);
        }
    }];
}

+ (Promise *)fetchDrinksForDrinkType:(DrinkTypeModel *)drinkType drinkSubType:(DrinkSubTypeModel *)drinkSubType query:(NSString *)query page:(NSNumber *)page pageSize:(NSNumber *)pageSize spot:(SpotModel *)spot {
    // Creating deferred for promises
    Deferred *deferred = [Deferred deferred];
    
    [self fetchDrinksForDrinkType:drinkType drinkSubType:drinkSubType query:query page:page pageSize:pageSize spot:spot success:^(NSArray *drinks) {
        // Resolves promise
        [deferred resolveWith:drinks];
    } failure:^(ErrorModel *errorModel) {
        // Rejects promise
        [deferred rejectWith:errorModel];
    }];
    
    return deferred.promise;
}

#pragma mark - Private
#pragma mark -

+ (void)fetchDrinkFormsWithSuccess:(void(^)(NSDictionary *forms))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock {
    NSDictionary *forms = [[self sh_sharedCache] cachedForms];
    if (forms) {
        if (successBlock) {
            successBlock(forms);
        }
        return;
    }
    
    NSDictionary *params = @{kDrinkModelParamsPageSize:@0};
    
    [[ClientSessionManager sharedClient] GET:@"/api/drinks" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // Parses response with JSONAPI
        JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:responseObject];
        
        if (operation.isCancelled || operation.response.statusCode == 204) {
            if (successBlock) {
                successBlock(nil);
            }
        }
        else if (operation.response.statusCode == 200) {
            NSDictionary *forms = [jsonApi objectForKey:@"form"];
            [[self sh_sharedCache] cacheForms:forms];
            if (successBlock) {
                successBlock(forms);
            }
        }
        else {
            ErrorModel *errorModel = [jsonApi resourceForKey:@"errors"];
            if (failureBlock) {
                failureBlock(errorModel);
            }
        }
    }];
}

+ (Promise *)fetchDrinkForms {
    Deferred *deferred = [Deferred deferred];
    
    [self fetchDrinkFormsWithSuccess:^(NSDictionary *forms) {
        [deferred resolveWith:forms];
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

#pragma mark - Mappings

- (NSDictionary *)mapKeysToProperties {
    return @{
             @"name" : @"name",
             @"image_url" : @"imageUrl",
             @"links.drink_type" : @"drinkType",
             @"links.drink_subtype" : @"drinkSubtype",
             @"type" : @"type",
             @"subtype" : @"subtype",
             @"description" : @"descriptionOfDrink",
             @"recipe" : @"recipeOfDrink",
             @"abv" : @"abv",
             @"style" : @"style",
             @"varietal" : @"varietal",
             @"vintage" : @"vintage",
             @"region" : @"region",
             @"links.spot" : @"spot",
             @"links.spot_id" : @"spotId",
             @"links.average_review" : @"averageReview",
             @"match" : @"match",
             @"links.base_alcohols" : @"baseAlochols",
             @"links.images" : @"images",
             @"links.highlight_images" : @"highlightImages"
             };
}

#pragma mark - Getters

- (NSString*)abvPercentString {
    return [NSString stringWithFormat:@"%.02f %%", (self.abv.floatValue * 100.0f)];
}

- (NSArray *)sliderTemplates {
    return [[self linkedResourceForKey:@"slider_templates"] sortedArrayUsingComparator:^NSComparisonResult(SliderTemplateModel *obj1, SliderTemplateModel *obj2) {
        return [obj1.order compare:obj2.order];
    }];
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

#pragma mark - Helpers

- (BOOL)isBeer {
    return [kDrinkTypeNameBeer isEqualToString:self.drinkType.name];
}

- (BOOL)isCocktail {
    return [kDrinkTypeNameCocktail isEqualToString:self.drinkType.name];
}

- (BOOL)isWine {
    return [kDrinkTypeNameWine isEqualToString:self.drinkType.name];
}

- (ImageModel *)highlightImage {
    if (self.highlightImages.count) {
        return self.highlightImages[0];
    }
    else if (self.images.count) {
        return self.images[0];
    }
    
    return nil;
}

- (NSString *)rating {
    if (self.isWine && ![@"Sparkling" isEqualToString:self.drinkSubtype.name]) {
        if (self.drinkSubtype.name.length) {
            return [NSString stringWithFormat:@"%@ - Rating %.0f/10", self.drinkSubtype.name, self.averageReview.rating.floatValue];
        }
        else {
            return [NSString stringWithFormat:@"Rating %.0f/10", self.averageReview.rating.floatValue];
        }
    }
    else {
        return [NSString stringWithFormat:@"Rating %.0f/10", self.averageReview.rating.floatValue];
    }
}

- (NSString *)ratingShort {
    return [NSString stringWithFormat:@"%.0f/10", self.averageReview.rating.floatValue];
}

- (NSString *)drinkStyle {
    if (self.isBeer) {
        return self.style;
    }
    else if (self.isCocktail && self.baseAlochols.count) {
        BaseAlcoholModel *baseAlcohol = self.baseAlochols[0];
        return baseAlcohol.name;
    }
    else if (self.isWine && self.varietal) {
        return self.varietal;
    }
    else {
        return nil;
    }
}

- (UIImage *)placeholderImage {
    if (self.isBeer) {
        return [UIImage imageNamed:@"beer_placeholder"];
    } else if (self.isCocktail) {
        return [UIImage imageNamed:@"cocktail_placeholder"];
    } else if (self.isWine) {
        return [UIImage imageNamed:@"wine_placeholder"];
    }
    
    return nil;
}

@end

@implementation DrinkModelCache

NSString * const DrinkTypesKey = @"DrinkTypes";
NSString * const DrinkFormsKey = @"DrinkForms";

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

- (DrinkModel *)cachedDrinkForKey:(NSString *)key {
    return [self objectForKey:key];
}

- (void)cacheDrink:(DrinkModel *)drink withKey:(NSString *)key {
    if (drink) {
        [self setObject:drink forKey:key];
    }
    else {
        [self removeObjectForKey:key];
    }
}

- (NSDictionary *)cachedForms {
    return [self objectForKey:DrinkFormsKey];
}

- (void)cacheForms:(NSDictionary *)forms {
    if (forms) {
        [self setObject:forms forKey:DrinkFormsKey];
    }
    else {
        [self removeObjectForKey:DrinkFormsKey];
    }
}

@end
