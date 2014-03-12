//
//  SpotListMoodModel.h
//  SpotHopper
//
//  Created by Josh Holtz on 3/12/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "SHJSONAPIResource.h"

#import <JSONAPI/JSONAPI.h>

@class ErrorModel;

@interface SpotListMoodModel : SHJSONAPIResource

@property (nonatomic, strong) NSNumber *name;
@property (nonatomic, strong) NSArray *sliders;

+ (Promise *)getSpotListMoods:(NSDictionary *)params success:(void (^)(NSArray *, JSONAPI *))successBlock failure:(void (^)(ErrorModel *))failureBlock;

@end
