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

@interface SliderTemplateModel : SHJSONAPIResource<NSCopying>

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *minLabel;
@property (nonatomic, strong) NSString *maxLabel;
@property (nonatomic, strong) NSString *minLabelShort;
@property (nonatomic, strong) NSString *maxLabelShort;
@property (nonatomic, strong) NSNumber *defaultValue;
@property (nonatomic, assign) BOOL required;
@property (nonatomic, assign) BOOL showInSummary;
@property (nonatomic, strong) NSArray *spotTypes;
@property (nonatomic, strong) NSArray *drinkTypes;
@property (nonatomic, strong) NSArray *drinkSubtypes;
@property (nonatomic, strong) NSNumber *order;
@property (nonatomic, strong) NSNumber *importance;

@property (readonly, nonatomic) NSString *minLabelShortDisplayed;
@property (readonly, nonatomic) NSString *maxLabelShortDisplayed;

@property (readonly) BOOL isAdvanced;

+ (Promise*)getSliderTemplates:(NSDictionary*)params success:(void(^)(NSArray *sliderTemplates, JSONAPI *jsonApi))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock;

#pragma mark - Revised Code for 2.0

+ (void)fetchSliderTemplates:(void(^)(NSArray *sliderTemplates))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock;
+ (Promise*)fetchSliderTemplates;

@end