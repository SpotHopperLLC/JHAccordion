//
//  DrinkMenuOfferingsViewController.h
//  SpotHopper
//
//  Created by Josh Holtz on 3/14/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "BaseViewController.h"

@class DrinkTypeModel;
@class DrinkSubtypeModel;
@class SpotModel;

@interface DrinkMenuOfferingsViewController : BaseViewController

@property (nonatomic, strong) DrinkTypeModel *drinkType;
@property (nonatomic, strong) DrinkSubtypeModel *drinkSubtype;
@property (nonatomic, strong) SpotModel *spot;
@property (nonatomic, strong) NSArray *menuItems;

@end
