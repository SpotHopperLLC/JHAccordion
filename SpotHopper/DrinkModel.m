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
#import "DrinkTypeModel.h"
#import "SliderTemplateModel.h"

@implementation DrinkModel

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

- (DrinkSubtypeModel *)drinkSubtype {
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

- (NSString *)recipe {
    return [self objectForKey:@"receipe"];
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
