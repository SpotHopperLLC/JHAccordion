//
//  DrinkListViewController.h
//  SpotHopper
//
//  Created by Josh Holtz on 3/13/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "BaseViewController.h"

#import "DrinkListModel.h"

@interface DrinkListViewController : BaseViewController

@property (nonatomic, strong) DrinkListModel *drinkList;
@property (nonatomic, assign) BOOL createdWithAdjustSliders;

@end
