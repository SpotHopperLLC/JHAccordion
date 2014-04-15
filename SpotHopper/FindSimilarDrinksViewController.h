//
//  FindSimilarDrinksViewController.h
//  SpotHopper
//
//  Created by Josh Holtz on 3/13/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "BaseViewController.h"

@class DrinkModel;

@protocol FindSimilarDrinksViewControllerDelegate;

@interface FindSimilarDrinksViewController : BaseViewController

@property (nonatomic, assign) id <FindSimilarDrinksViewControllerDelegate> delegate;

@end

@protocol FindSimilarDrinksViewControllerDelegate <NSObject>

- (void)findSimilarDrinksViewController:(FindSimilarDrinksViewController*)viewController selectedDrink:(DrinkModel*)drink;

@end
