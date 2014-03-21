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

+ (Promise *)getBaseAlcohols:(NSDictionary *)params success:(void (^)(NSArray *, JSONAPI *))successBlock failure:(void (^)(ErrorModel *))failureBlock;

@end
