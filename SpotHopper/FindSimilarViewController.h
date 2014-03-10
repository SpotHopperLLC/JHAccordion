//
//  FindSimilarViewController.h
//  SpotHopper
//
//  Created by Josh Holtz on 3/5/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "BaseViewController.h"

@class DrinkModel, SpotModel;

@protocol FindSimilarViewControllerDelegate;

@interface FindSimilarViewController : BaseViewController

@property (nonatomic, assign) BOOL searchDrinks;
@property (nonatomic, assign) id<FindSimilarViewControllerDelegate> delegate;

@end

@protocol FindSimilarViewControllerDelegate <NSObject>

- (void)findSimilarViewController:(FindSimilarViewController*)viewController selectedDrink:(DrinkModel*)drink;
- (void)findSimilarViewController:(FindSimilarViewController*)viewController selectedSpot:(SpotModel*)spot;

@end