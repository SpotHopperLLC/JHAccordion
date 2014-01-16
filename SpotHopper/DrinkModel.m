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

@implementation DrinkModel

#pragma mark - API

+ (void)getDrinks:(NSDictionary*)params success:(void(^)(NSArray *drinkModels, JSONAPI *jsonAPI))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock {
    
    [[ClientSessionManager sharedClient] GET:@"/api/drinks" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (operation.response.statusCode == 200) {
            JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:responseObject];
            
            NSArray *models = [jsonApi resourcesForKey:@"drinks"];
            successBlock(models, jsonApi);
            
        } else {
            JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:responseObject];
            
            ErrorModel *errorModel = [jsonApi resourceForKey:@"errors"];
            failureBlock(errorModel);
        }
    }];
    
}

#pragma mark - Getters

- (NSString *)name {
    return [self objectForKey:@"name"];
}

- (NSString *)imageUrl {
    return [self objectForKey:@"image_url"];
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

- (NSNumber *)alcoholByVolume {
    return [self objectForKey:@"alcohol_by_volume"];
}

- (NSString *)style {
    return [self objectForKey:@"style"];
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

@end
