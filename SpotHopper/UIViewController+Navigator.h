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
#import "MenuTypeModel.h"
#import "ReviewModel.h"
#import "SpotModel.h"
#import "SpotListModel.h"

#import "NewReviewViewController.h"
#import "ReviewViewController.h"

#import "CheckinViewController.h"

#import "FindSimilarViewController.h"
#import "FindSimilarDrinksViewController.h"

#import "PhotoAlbumViewController.h"

@interface UIViewController (Navigator)

// Main
- (void)goToAgeVerification:(BOOL)animated;
- (void)goToTutorial:(BOOL)animated;
- (void)goToLaunch:(BOOL)animated;
- (void)goToAccountSettings:(BOOL)animated;

// Drinks
- (void)goToDrinks;
- (void)goToDrinksNearBy;
- (void)goToDrinkListMenu;
- (void)goToDrinkListMenuAtSpot:(SpotModel*)spot;
- (void)goToDrinkList:(DrinkListModel*)drinkList createdWithAdjustSliders:(BOOL)createdWithAdjustSliders atSpot:(SpotModel*)spot;
- (void)goToFindDrinksAt:(DrinkModel*)drink;
- (void)goToDrinkProfile:(DrinkModel*)drink;

// Reviews
- (void)goToReviewMenu;
- (void)goToMyReviews;
- (void)goToReview:(ReviewModel*)review;
- (void)goToNewReviewForDrink:(DrinkModel*)drink;
- (void)goToNewReviewForDrink:(DrinkModel*)drink delegate:(id<ReviewViewControllerDelegate>)delegate;
- (void)goToNewReviewForSpot:(SpotModel*)spot;
- (void)goToNewReviewForSpot:(SpotModel *)spot delegate:(id<ReviewViewControllerDelegate>)delegate;
- (void)goToSearchForNewReview:(BOOL)showSimilarLists notWhatLookingFor:(BOOL)showNotWhatLookingFor createReview:(BOOL)createReview;
- (void)goToNewReview;
- (void)goToNewReviewWithType:(NSString*)reviewType;
- (void)goToNewReviewWithType:(NSString*)reviewType delegate:(id<NewReviewViewControllerDelegate>)delegate;
- (void)goToNewReview:(SpotModel*)spot;
- (void)goToNewReview:(SpotModel*)spot delegate:(id<NewReviewViewControllerDelegate>)delegate;

// Spots
- (void)goToSpotListMenu;
- (void)goToSpotList:(SpotListModel*)spotList createdWithAdjustSliders:(BOOL)createdWithAdjustSliders;
- (void)goToSpotProfile:(SpotModel *)spot;

// Menu
- (void)goToMenu:(SpotModel*)spot;
- (void)goToMenuOfferings:(SpotModel *)spot drinkType:(DrinkTypeModel*)drinkType menuType:(MenuTypeModel*)drinkSubtype menuItems:(NSArray*)menuItems;

// Specials
- (void)goToTonightsSpecials;

// Checkin
- (void)goToCheckin:(id<CheckinViewControllerDelegate>)delegate;
- (void)goToCheckIn:(CheckInModel*)checkIn;

// Common
- (void)goToFindSimilarSpots:(id<FindSimilarViewControllerDelegate>)delegate;
- (void)goToFindSimilarDrinks:(id<FindSimilarDrinksViewControllerDelegate>)delegate;
- (void)goToPhotoAlbum:(NSArray *)images atIndex:(NSUInteger)index;
- (void)goToPhotoViewer:(NSArray *)images atIndex:(NSUInteger)index fromPhotoAlbum:(PhotoAlbumViewController *)photoAlbum;

// Storyboards
- (UIStoryboard*)mainStoryboard;
- (UIStoryboard*)drinksStoryboard;
- (UIStoryboard*)reviewsStoryboard;
- (UIStoryboard*)spotsStoryboard;
- (UIStoryboard*)specialsStoryboard;
- (UIStoryboard*)menuStoryboard;
- (UIStoryboard*)checkinStoryboard;
- (UIStoryboard*)shareStoryboard;
- (UIStoryboard*)userStoryboard;

// Redesign 2.0
- (UIStoryboard*)spotHopperStoryboard;

@end
