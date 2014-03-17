//
//  MenuItemModel.h
//  SpotHopper
//
//  Created by Josh Holtz on 3/14/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "SHJSONAPIResource.h"

@class DrinkModel;
@class SpotModel;

@interface MenuItemModel : SHJSONAPIResource

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSNumber *price;
@property (nonatomic, assign) BOOL inStock;
@property (nonatomic, strong) DrinkModel *drink;
@property (nonatomic, strong) SpotModel *spot;

@end
