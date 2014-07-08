//
//  MenuTypeModel.h
//  SpotHopper
//
//  Created by Josh Holtz on 3/23/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "SHJSONAPIResource.h"

@class DrinkTypeModel, DrinkSubTypeModel;

@interface MenuTypeModel : SHJSONAPIResource

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) DrinkTypeModel *drinkType;
@property (nonatomic, strong) NSArray *drinkSubtypes;

@end
