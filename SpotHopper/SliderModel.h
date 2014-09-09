//
//  SliderModel.h
//  SpotHopper
//
//  Created by Josh Holtz on 1/18/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "SHJSONAPIResource.h"

@class SliderTemplateModel;

@interface SliderModel : SHJSONAPIResource<NSCopying>

@property (readonly) NSString *name;

@property (nonatomic, strong) NSNumber *value;
@property (nonatomic, assign) BOOL starred;
@property (nonatomic, strong) SliderTemplateModel *sliderTemplate;

@end
