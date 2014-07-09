//
//  MenuItemModel.h
//  SpotHopper
//
//  Created by Josh Holtz on 3/14/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#define kMenuItemParamsInStock @"in_stock"

#import "SHJSONAPIResource.h"

@class DrinkModel;
@class SpotModel;
@class MenuTypeModel;

@interface MenuItemModel : SHJSONAPIResource

@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) BOOL inStock;
@property (nonatomic, strong) DrinkModel *drink;
@property (nonatomic, strong) SpotModel *spot;
@property (nonatomic, strong) MenuTypeModel *menuType;
@property (nonatomic, strong) NSArray *prices;

@end