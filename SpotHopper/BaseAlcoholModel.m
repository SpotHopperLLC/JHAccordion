//
//  BaseAlcoholModel.m
//  SpotHopper
//
//  Created by Josh Holtz on 3/21/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "BaseAlcoholModel.h"

#import "ClientSessionManager.h"
#import "ErrorModel.h"

@interface BaseAlcoholCache : NSCache

- (NSArray *)cachedBaseAlcohols;
- (void)cacheBaseAlcohols:(NSArray *)baseAlcohols;

@end

@implementation BaseAlcoholModel

#pragma mark - Debugging

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ - %@", self.ID, self.href];
}

#pragma mark -

- (NSDictionary *)mapKeysToProperties {
    // Maps values in JSON key 'name' to 'name' property
    return @{
             @"name" : @"name"
             };
}

#pragma mark - API

+ (Promise *)getBaseAlcohols:(NSDictionary *)params success:(void (^)(NSArray *baseAlcohols, JSONAPI *jsonApi))successBlock failure:(void (^)(ErrorModel *errorModel))failureBlock {
    
    // Creating deferred for promises
    Deferred *deferred = [Deferred deferred];
    
    [[ClientSessionManager sharedClient] GET:@"/api/base_alcohols" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // Parses response with JSONAPI
        JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:responseObject];
        
        if (operation.isCancelled || operation.response.statusCode == 204) {
            if (successBlock) {
                successBlock(nil, nil);
            }
        }
        else if (operation.response.statusCode == 200) {
            NSArray *models = [jsonApi resourcesForKey:@"base_alcohols"];
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

#pragma mark - Caching

+ (BaseAlcoholCache *)sh_sharedCache {
    static BaseAlcoholCache *_sh_Cache = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sh_Cache = [[BaseAlcoholCache alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidReceiveMemoryWarningNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * __unused notification) {
            [_sh_Cache removeAllObjects];
        }];
    });
    
    return _sh_Cache;
}

#pragma mark - Revised Code for 2.0

+ (void)fetchBaseAlcohols:(void (^)(NSArray *baseAlcohols))successBlock failure:(void (^)(ErrorModel *errorModel))failureBlock {
    NSArray *baseAlcohols = [[BaseAlcoholModel sh_sharedCache] cachedBaseAlcohols];
    if (baseAlcohols.count) {
        if (successBlock) {
            successBlock(baseAlcohols);
        }
        return;
    }
    
    [[ClientSessionManager sharedClient] GET:@"/api/base_alcohols" parameters:@{} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // Parses response with JSONAPI
        JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:responseObject];
        
        if (operation.isCancelled || operation.response.statusCode == 204) {
            if (successBlock) {
                successBlock(nil);
            }
        }
        else if (operation.response.statusCode == 200) {
            NSArray *models = [jsonApi resourcesForKey:@"base_alcohols"];
            
            if (models.count) {
                [[BaseAlcoholModel sh_sharedCache] cacheBaseAlcohols:models];
            }
            
            if (successBlock) {
                successBlock(models);
            }
        } else {
            ErrorModel *errorModel = [jsonApi resourceForKey:@"errors"];
            if (failureBlock) {
                failureBlock(errorModel);
            }
        }
    }];
}

+ (Promise *)fetchBaseAlcohols {
    // Creating deferred for promises
    Deferred *deferred = [Deferred deferred];
    
    [self fetchBaseAlcohols:^(NSArray *baseAlcohols) {
        // Resolves promise
        [deferred resolveWith:baseAlcohols];
    } failure:^(ErrorModel *errorModel) {
        // Rejects promise
        [deferred rejectWith:errorModel];
    }];
    
    return deferred.promise;
}

@end

@implementation BaseAlcoholCache

NSString * const BaseAlcoholsKey = @"BaseAlcohols";

- (NSArray *)cachedBaseAlcohols {
    return [self objectForKey:BaseAlcoholsKey];
}

- (void)cacheBaseAlcohols:(NSArray *)baseAlcohols {
    if (baseAlcohols.count) {
        [self setObject:baseAlcohols forKey:BaseAlcoholsKey];
    }
    else {
        [self removeObjectForKey:BaseAlcoholsKey];
    }
}

@end
