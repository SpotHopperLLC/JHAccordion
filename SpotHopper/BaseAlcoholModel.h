//
//  BaseAlcoholModel.h
//  SpotHopper
//
//  Created by Josh Holtz on 3/21/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "SHJSONAPIResource.h"

@class ErrorModel;

#import <JSONAPI/JSONAPI.h>

@interface BaseAlcoholModel : SHJSONAPIResource

@property (nonatomic, strong) NSString *name;

+ (Promise *)getBaseAlcohols:(NSDictionary *)params success:(void (^)(NSArray *baseAlcohols, JSONAPI *jsonApi))successBlock failure:(void (^)(ErrorModel *errorModel))failureBlock;

#pragma mark - Revised Code for 2.0

+ (void)fetchBaseAlcohols:(void (^)(NSArray *baseAlcohols))successBlock failure:(void (^)(ErrorModel *errorModel))failureBlock;

+ (Promise *)fetchBaseAlcohols;

@end
