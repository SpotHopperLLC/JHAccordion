//
//  SliderTemplateModel.h
//  SpotHopper
//
//  Created by Josh Holtz on 1/18/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "SHJSONAPIResource.h"

@interface SliderTemplateModel : SHJSONAPIResource

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *minLabel;
@property (nonatomic, strong) NSString *maxLabel;
@property (nonatomic, strong) NSNumber *defaultValue;
@property (nonatomic, assign) BOOL required;

@end
