//
//  UIViewController+Navigator.h
//  SpotHopper
//
//  Created by Josh Holtz on 1/3/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DrinkModel.h"
#import "DrinkListModel.h"
#import "ReviewModel.h"
#import "SpotModel.h"
#import "SpotListModel.h"

#import "FindSimilarViewController.h"
#import "FindSimilarDrinksViewController.h"

@interface UIViewController (Navigator)

// Main
- (void)goToLaunch:(BOOL)animated;

// Drinks
- (void)goToDrinksNearBy;
- (void)goToDrinkListMenu;
- (void)goToDrinkListMenuAtSpot:(SpotModel*)spot;
- (void)goToDrinkList:(DrinkListModel*)drinkList createdWithAdjustSliders:(BOOL)createdWithAdjustSliders;
- (void)goToFindDrinksAt:(DrinkModel*)drink;
- (void)goToDrinkProfile:(DrinkModel*)drink;

// Reviews
- (void)goToReviewMenu;
- (void)goToMyReviews;
- (void)goToReview:(ReviewModel*)review;
- (void)goToNewReviewForDrink:(DrinkModel*)drink;
- (void)goToNewReviewForSpot:(SpotModel*)spot;
- (void)goToSearchForNewReview:(BOOL)showSimilarLists notWhatLookingFor:(BOOL)showNotWhatLookingFor createReview:(BOOL)createReview;
- (void)goToNewReview;
- (void)goToNewReviewWithType:(NSString*)reviewType;
- (void)goToNewReview:(SpotModel*)spot;

// Spots
- (void)goToSpotListMenu;
- (void)goToSpotList:(SpotListModel*)spotList createdWithAdjustSliders:(BOOL)createdWithAdjustSliders;
- (void)goToSpotProfile:(SpotModel *)spot;

// Menu

- (void)goToMenu:(SpotModel*)spot;
- (void)goToMenuOfferings:(SpotModel *)spot drinkType:(DrinkTypeModel*)drinkType drinkSubtype:(DrinkSubtypeModel*)drinkSubtype menuItems:(NSArray*)menuItems;

// Common
- (void)goToFindSimilarSpots:(id<FindSimilarViewControllerDelegate>)delegate;
- (void)goToFindSimilarDrinks:(id<FindSimilarDrinksViewControllerDelegate>)delegate;

// Storyboards
- (UIStoryboard*)mainStoryboard;
- (UIStoryboard*)drinksStoryboard;
- (UIStoryboard*)reviewsStoryboard;
- (UIStoryboard*)spotsStoryboard;
- (UIStoryboard*)menuStoryboard;

@end
