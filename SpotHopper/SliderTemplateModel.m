//
//  SliderTemplateModel.m
//  SpotHopper
//
//  Created by Josh Holtz on 1/18/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#define kSomePageSize @300

#import "SliderTemplateModel.h"

#import "ClientSessionManager.h"
#import "ErrorModel.h"

@interface SliderTemplateModelCache : NSCache

- (NSArray *)cachedSliderTemplates;
- (void)cacheSliderTemplates:(NSArray *)sliderTemplates;

@end

@implementation SliderTemplateModel

#pragma mark - Debugging

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ - %@ (%@, %@, %@) [%@]", self.ID, self.name,
            self.minLabel.length ? self.minLabel : @"NULL",
            self.maxLabel.length ? self.maxLabel : @"NULL",
            self.order,
            NSStringFromClass([self class])];
}

- (id)debugQuickLookObject {
    return self.name;
}

#pragma mark - Mappings

- (NSDictionary *)mapKeysToProperties {
    return @{
             @"name" : @"name",
             @"min_label" : @"minLabel",
             @"max_label" : @"maxLabel",
             @"max_label_short" : @"maxLabelShort",
             @"min_label_short" : @"minLabelShort",
             @"show_in_summary" : @"showInSummary",
             @"default_value" : @"defaultValue",
             @"required" : @"required",
             @"order" : @"order",
             @"importance" : @"importance",
             @"links.spot_types" : @"spotTypes",
             @"links.drink_types" : @"drinkTypes",
             @"links.drink_subtypes" : @"drinkSubtypes"
             };
}

#pragma mark - Getters

- (NSString *)minLabelShortDisplayed {
    if (self.minLabelShort.length) {
        return self.minLabelShort;
    }
    
    return self.minLabel;
}

- (NSString *)maxLabelShortDisplayed {
    if (self.maxLabelShort.length) {
        return self.maxLabelShort;
    }
    
    return self.maxLabel;
}

- (BOOL)isAdvanced {
    return !self.required;
}

#pragma mark - API

+ (Promise*)getSliderTemplates:(NSDictionary*)params success:(void(^)(NSArray *sliderTemplates, JSONAPI *jsonApi))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock {
    // Creating deferred for promises
    Deferred *deferred = [Deferred deferred];
    
    // Makes page size 300 so we get all slider templates
    if (params == nil) params = @{};
    
    NSMutableDictionary *mutaParams = params.mutableCopy;
    [mutaParams setObject:kSomePageSize forKey:kSliderTemplateModelParamsPageSize];
    
    [[ClientSessionManager sharedClient] GET:@"/api/slider_templates" parameters:mutaParams success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
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
            NSArray *models = [jsonApi resourcesForKey:@"slider_templates"];
            models = [models sortedArrayUsingComparator:^NSComparisonResult(SliderTemplateModel *obj1, SliderTemplateModel *obj2) {
                return [obj1.order compare:obj2.order];
            }];
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

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
	SliderTemplateModel *copy = [super copyWithZone:zone];
    
    copy.name = self.name;
    copy.minLabel = self.minLabel;
    copy.maxLabel = self.maxLabel;
    copy.defaultValue = self.defaultValue;
    copy.required = self.required;
    copy.spotTypes = self.spotTypes;
    copy.drinkTypes = self.drinkTypes;
    copy.drinkSubtypes = self.drinkSubtypes;
    copy.order = self.order;
    
    return copy;
}

#pragma mark - Revised Code for 2.0

+ (void)fetchSliderTemplates:(void(^)(NSArray *sliderTemplates))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock {
    NSArray *sliderTemplates = [[SliderTemplateModel sh_sharedCache] cachedSliderTemplates];
    if (sliderTemplates.count && successBlock) {
        successBlock([sliderTemplates copy]);
        return;
    }
    
    NSDictionary *params = @{
               kSliderTemplateModelParamsPageSize: kSomePageSize,
               kSliderTemplateModelParamPage: @1
               };
    
    [[ClientSessionManager sharedClient] GET:@"/api/slider_templates" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // Parses response with JSONAPI
        JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:responseObject];
        
        if (operation.isCancelled || operation.response.statusCode == 204) {
            if (successBlock) {
                successBlock(nil);
            }
        }
        else if (operation.response.statusCode == 200) {
            NSArray *models = [jsonApi resourcesForKey:@"slider_templates"];
            models = [models sortedArrayUsingComparator:^NSComparisonResult(SliderTemplateModel *obj1, SliderTemplateModel *obj2) {
                return [obj1.order compare:obj2.order];
            }];
            
            if (models.count) {
                [[SliderTemplateModel sh_sharedCache] cacheSliderTemplates:models];
            }
            
            if (successBlock) {
                successBlock([models copy]);
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

+ (Promise*)fetchSliderTemplates {
    // Creating deferred for promises
    Deferred *deferred = [Deferred deferred];

    [self fetchSliderTemplates:^(NSArray *sliderTemplates) {
        // Resolves promise
        [deferred resolveWith:sliderTemplates];
    } failure:^(ErrorModel *errorModel) {
        // Rejects promise
        [deferred rejectWith:errorModel];
    }];
    
    return deferred.promise;
}

#pragma mark - Caching

+ (SliderTemplateModelCache *)sh_sharedCache {
    static SliderTemplateModelCache *_sh_Cache = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sh_Cache = [[SliderTemplateModelCache alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidReceiveMemoryWarningNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * __unused notification) {
            [_sh_Cache removeAllObjects];
        }];
    });
    
    return _sh_Cache;
}

@end

@implementation SliderTemplateModelCache

NSString * const SliderTemplatesKey = @"SliderTemplatesKey";

- (NSArray *)cachedSliderTemplates {
    return [self objectForKey:SliderTemplatesKey];
}

- (void)cacheSliderTemplates:(NSArray *)sliderTemplates {
    if (sliderTemplates.count) {
        [self setObject:sliderTemplates forKey:SliderTemplatesKey];
    }
    else {
        [self removeObjectForKey:SliderTemplatesKey];
    }
}

@end
