//
//  SliderTemplateModel.h
//  SpotHopper
//
//  Created by Josh Holtz on 1/18/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#define kSliderTemplateModelParamPage @"page"
#define kSliderTemplateModelParamsPageSize @"page_size"
#define kSliderTemplateModelParamQuery @"query"

#define kSliderTemplateModelParamDrinkTypeId @"drink_type_id"
#define kSliderTemplateModelParamDrinkSubtypeId @"drink_subtype_id"
#define kSliderTemplateModelParamSpotTypeId @"spot_type_id"

#import "SHJSONAPIResource.h"

#import <JSONAPI/JSONAPI.h>

@class ErrorModel;

@interface SliderTemplateModel : SHJSONAPIResource

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *minLabel;
@property (nonatomic, strong) NSString *maxLabel;
@property (nonatomic, strong) NSNumber *defaultValue;
@property (nonatomic, assign) BOOL required;
@property (nonatomic, strong) NSArray *spotTypes;
@property (nonatomic, strong) NSArray *drinkTypes;
@property (nonatomic, strong) NSArray *drinkSubtypes;
@property (nonatomic, strong) NSNumber *order;

+ (Promise*)getSliderTemplates:(NSDictionary*)params success:(void(^)(NSArray *sliderTemplates, JSONAPI *jsonApi))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock;

@end