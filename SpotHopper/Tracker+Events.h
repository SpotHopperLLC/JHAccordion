//
//  Tracker+Events.h
//  SpotHopper
//
//  Created by Brennan Stehling on 7/28/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "Tracker.h"

@class SHJSONAPIResource, DrinkModel, SpotModel;

@interface Tracker (Events)

+ (void)trackDrinkProfileScreenViewed:(DrinkModel *)drink;

+ (void)trackSpotProfileScreenViewed:(SpotModel *)spot;

+ (void)trackGlobalSearchResultTapped:(SHJSONAPIResource *)model searchText:(NSString *)searchText;

+ (void)trackGlobalSearchRequestCompleted;

+ (void)trackGlobalSearchRequestCancelled;

+ (void)trackGlobalSearchRequestStarted;

+ (void)trackGlobalSearchHappened:(NSString *)searchText;

+ (void)trackLeavingGlobalSearch:(BOOL)selected;

+ (void)trackLeavingHomeToSpots;

+ (void)trackLeavingHomeToSpecials;

+ (void)trackLeavingHomeToBeer;

+ (void)trackLeavingHomeToCocktails;

+ (void)trackLeavingHomeToWine;

+ (void)trackSpotsMoodSelected:(NSString *)moodName;

+ (void)trackBeerStyleSelected:(NSString *)moodName;

+ (void)trackCocktailStyleSelected:(NSString *)moodName;

+ (void)trackWineStyleSelected:(NSString *)moodName;

+ (void)trackSliderSearchSubmitTapped;

+ (void)trackSpotlistViewed;

+ (void)trackDrinklistViewed;

+ (void)trackAreYouHere:(BOOL)yesOrNo;

+ (void)trackUserTappedLocationPickerButton;

+ (void)trackUserSetNewLocation;

@end
