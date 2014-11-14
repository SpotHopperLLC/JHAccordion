//
//  SHMenuAdminSearchViewController.h
//  SpotHopper
//
//  Created by Josh Holtz on 4/1/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "BaseViewController.h"

@class DrinkModel;
@class SearchModel;
@class DrinkTypeModel;
@class DrinkSubTypeModel;

@protocol SHMenuAdminSearchViewControllerDelegate;

@interface SHMenuAdminSearchViewController : BaseViewController

@property (nonatomic, weak) id<SHMenuAdminSearchViewControllerDelegate> delegate;

@property (nonatomic, assign) BOOL isHouseCocktail;

@property (nonatomic, strong) DrinkTypeModel *drinkType;
@property (nonatomic, strong) DrinkSubTypeModel *drinkSubType;
@property (nonatomic, strong) NSString *menuType;
@property (nonatomic, strong) SpotModel *spot;

@property (nonatomic, strong) NSArray *filteredMenuItems; 
@property (nonatomic, assign) BOOL isSpotSearch;

@end

@protocol SHMenuAdminSearchViewControllerDelegate <NSObject>

- (void)searchViewController:(SHMenuAdminSearchViewController *)viewController selectedDrink:(DrinkModel*)drink;
- (void)searchViewController:(SHMenuAdminSearchViewController*)viewController selectedSpot:(SpotModel*)spot;

@end
