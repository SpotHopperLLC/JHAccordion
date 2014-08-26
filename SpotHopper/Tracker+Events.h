//
//  Tracker+Events.h
//  SpotHopper
//
//  Created by Brennan Stehling on 7/28/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "Tracker.h"

#import <CoreLocation/CoreLocation.h>

@class SHJSONAPIResource, SpotModel, DrinkModel, SpotListModel, DrinkListModel, SpotListRequest, DrinkListRequest;

@interface Tracker (Events)

+ (void)trackAppLaunching;

+ (void)trackFirstUse;

+ (void)trackDrinkProfileScreenViewed:(DrinkModel *)drink;

+ (void)trackSpotProfileScreenViewed:(SpotModel *)spot;

+ (void)trackGlobalSearchStarted;

+ (void)trackGlobalSearchCancelled;

+ (void)trackGlobalSearchResultTapped:(SHJSONAPIResource *)model searchText:(NSString *)searchText;

+ (void)trackGlobalSearchRequestCompleted;

+ (void)trackGlobalSearchRequestCancelled;

+ (void)trackGlobalSearchRequestStarted;

+ (void)trackGlobalSearchHappened:(NSString *)searchText;

+ (void)trackLeavingGlobalSearch:(BOOL)selected;

+ (void)trackViewedHome;

+ (void)trackLeavingHomeToSpots:(BOOL)isSecondary actionButtonTapCount:(NSInteger)actionButtonTapCount;

+ (void)trackLeavingHomeToSpecials:(BOOL)isSecondary actionButtonTapCount:(NSInteger)actionButtonTapCount;

+ (void)trackLeavingHomeToBeer:(BOOL)isSecondary actionButtonTapCount:(NSInteger)actionButtonTapCount;

+ (void)trackLeavingHomeToCocktails:(BOOL)isSecondary actionButtonTapCount:(NSInteger)actionButtonTapCount;

+ (void)trackLeavingHomeToWine:(BOOL)isSecondary actionButtonTapCount:(NSInteger)actionButtonTapCount;

+ (void)trackDrinkStylesDidLoad:(SHMode)mode numberOfStyles:(NSInteger)numberOfStyles duration:(NSTimeInterval)duration;

+ (void)trackSpotMoodsDidLoad:(SHMode)mode numberOfMoods:(NSInteger)numberOfMoods duration:(NSTimeInterval)duration;

+ (void)trackSpotsMoodSelected:(NSString *)moodName moodsCount:(NSUInteger)moodsCount position:(NSUInteger)position;

+ (void)trackBeerStyleSelected:(DrinkListModel *)style stylesCount:(NSUInteger)stylesCount position:(NSUInteger)position;

+ (void)trackCocktailStyleSelected:(DrinkListModel *)style stylesCount:(NSUInteger)stylesCount position:(NSUInteger)position;

+ (void)trackWineStyleSelected:(DrinkListModel *)style stylesCount:(NSUInteger)stylesCount position:(NSUInteger)position;

+ (void)trackSliderSearchButtonTapped:(SHMode)mode;

+ (void)trackCreatingDrinkList;

+ (void)trackCreatedDrinkList:(BOOL)success drinkTypeID:(NSNumber *)drinkTypeID drinkSubTypeID:(NSNumber *)drinkSubTypeID duration:(NSTimeInterval)duration createdWithSliders:(BOOL)createdWithSliders;

+ (void)trackCreatingSpotList;

+ (void)trackCreatedSpotList:(BOOL)success spotId:(NSNumber *)spotID spotTypeID:(NSNumber *)spotTypeID duration:(NSTimeInterval)duration createdWithSliders:(BOOL)createdWithSliders;

+ (void)trackSpotlistViewed;

+ (void)trackDrinklistViewed:(SHMode)mode;

+ (void)trackAreYouHere:(BOOL)yesOrNo spot:(SpotModel *)spot;

+ (void)trackDeepLinkWithTargetURL:(NSURL *)targetURL sourceURL:(NSURL *)sourceURL sourceApplication:(NSString *)sourceApplication;

+ (void)trackUserTappedLocationPickerButton;

+ (void)trackUserSetNewLocation;

+ (void)trackDrinkSpecials:(NSArray *)spots;

+ (void)trackSpotlist:(SpotListModel *)spotlist request:(SpotListRequest *)request;

+ (void)trackDrinklist:(DrinkListModel *)drinklist mode:(SHMode)mode request:(DrinkListRequest *)request;

#pragma mark - Logins
#pragma mark -

+ (void)trackLoginViewed;

+ (void)trackerLeavingLoginViewLoggedIn;

+ (void)trackerLeavingLoginViewNotLoggedIn;

+ (void)trackCreatingAccount;

+ (void)trackCreatedUser:(BOOL)success;

+ (void)trackLoggingInWithFacebook;

+ (void)trackLoggingInWithTwitter;

+ (void)trackLoggingInWithSpotHopper;

+ (void)trackLoggedIn:(BOOL)success;

#pragma mark - Search Results
#pragma mark -

+ (void)trackNoBeerResults;

+ (void)trackNoCocktailResults;

+ (void)trackNoWineResults;

+ (void)trackNoSpotResults;

+ (void)trackNoSpecialsResults;

+ (void)trackGoodBeerResultsWithName:(NSString *)name match:(NSNumber *)match;

+ (void)trackGoodCocktailResultsWithName:(NSString *)name match:(NSNumber *)match;

+ (void)trackGoodWineResultsWithName:(NSString *)name match:(NSNumber *)match;

+ (void)trackGoodSpotsResultsWithName:(NSString *)name match:(NSNumber *)match;

+ (void)trackGoodSpecialsResultsWithLikes:(NSUInteger)likesCount;

#pragma mark - Home Map Actions
#pragma mark -

+ (void)trackSpotsButtonTapped;

+ (void)trackSpecialsButtonTapped;

+ (void)trackBeerButtonTapped;

+ (void)trackCocktailButtonTapped;

+ (void)trackWineButtonTapped;

#pragma mark - List View
#pragma mark -

+ (void)trackListViewDidDisplaySpot:(SpotModel *)spot;

+ (void)trackListViewDidDisplayDrink:(DrinkModel *)drink;

@end
