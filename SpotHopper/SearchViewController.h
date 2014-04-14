//
//  SearchViewController.h
//  SpotHopper
//
//  Created by Josh Holtz on 4/1/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "BaseViewController.h"

@class DrinkModel;
@class SearchModel;

@protocol SearchViewControllerDelegate;

@interface SearchViewController : BaseViewController

@property (nonatomic, assign) id<SearchViewControllerDelegate> delegate;

@end

@protocol SearchViewControllerDelegate <NSObject>

- (void)searchViewController:(SearchViewController*)viewController selectedDrink:(DrinkModel*)drink;
- (void)searchViewController:(SearchViewController*)viewController selectedSpot:(SpotModel*)spot;

@end
