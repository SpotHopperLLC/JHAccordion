//
//  Tracker+Events.h
//  SpotHopper
//
//  Created by Brennan Stehling on 7/28/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "Tracker.h"

#import <CoreLocation/CoreLocation.h>

@class SHJSONAPIResource, SpotModel, DrinkModel, SpotListModel, DrinkListModel, SpotListRequest, DrinkListRequest, SpecialModel, CheckInModel;

@interface Tracker (Events)

+ (void)trackAppLaunching;

+ (void)trackFirstUse;

+ (void)trackDrinkProfileScreenViewed:(DrinkModel *)drink;

+ (void)trackSpotProfileScreenViewed:(SpotModel *)spot;

#pragma mark - Activities
#pragma mark -

+ (void)trackActivity:(NSString *)activityName duration:(NSTimeInterval)duration;

#pragma mark - Global Search
#pragma mark -

+ (void)trackGlobalSearchStarted;

+ (void)trackGlobalSearchCancelled;

+ (void)trackGlobalSearchResultTapped:(SHJSONAPIResource *)model searchText:(NSString *)searchText;

+ (void)trackGlobalSearchRequestCancelled;

+ (void)trackGlobalSearchRequestStarted;

+ (void)trackGlobalSearchHappened:(NSString *)searchText;

+ (void)trackLeavingGlobalSearch:(BOOL)selected;

#pragma mark - Highest Rated
#pragma mark -

+ (void)trackSelectedHighestRatedForBeer;

+ (void)trackSelectedHighestRatedForWine;

+ (void)trackSelectedHighestRatedForCocktail;

#pragma mark - Pullup UI
#pragma mark -

+ (void)trackTappedFullDrinkMenu;

+ (void)trackTappedMorePhotos;

+ (void)trackTappedAllSliders;

+ (void)trackTappedPhoneNumber;

+ (void)trackTappedWriteAReview;

+ (void)trackTappedShare;

+ (void)trackPulledUpCollectionViewForSpecialsSpots:(NSArray *)spots atIndex:(NSUInteger)index;

+ (void)trackPulledUpCollectionViewForSpotlist:(SpotListModel *)spotlist atIndex:(NSUInteger)index;

+ (void)trackPulledUpCollectionViewForDrinklist:(DrinkListModel *)drinklist atIndex:(NSUInteger)index;

#pragma mark - Location
#pragma mark -

+ (void)trackFetchedLocationFromMapsUserLocation:(CLLocationDistance)distance;

#pragma mark -

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

+ (void)trackDrinkSpecials:(SpotListModel *)spotlist;

+ (void)trackSpotlist:(SpotListModel *)spotlist request:(SpotListRequest *)request;

+ (void)trackDrinklist:(DrinkListModel *)drinklist mode:(SHMode)mode request:(DrinkListRequest *)request;

+ (void)trackTotalContentLength;

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

#pragma mark - Checkins
#pragma mark -

+ (void)trackWentToSpot:(SpotModel *)spot;

+ (void)trackCheckinButtonTapped;

+ (void)trackCheckinCancelButtonTapped;

+ (void)trackPromptedToCheckInAtSpot:(SpotModel *)spot;

+ (void)trackCheckedInAtSpot:(SpotModel *)spot position:(NSUInteger)position count:(NSUInteger)count distance:(CLLocationDistance)distance;

#pragma mark - Notifications
#pragma mark -

+ (void)trackNotification:(NSDictionary *)userInfo;

#pragma mark - Sharing
#pragma mark -

+ (void)trackSharingSpot:(SpotModel *)spot;

+ (void)trackSharingDrink:(DrinkModel *)drink;

+ (void)trackSharingSpecial:(SpecialModel *)special atSpot:(SpotModel *)spot;

+ (void)trackSharingCheckin:(CheckInModel *)checkin;

#pragma mark - List View
#pragma mark -

+ (void)trackListViewDidDisplaySpot:(SpotModel *)spot position:(NSUInteger)position isSpecials:(BOOL)isSpecials;

+ (void)trackListViewDidDisplayDrink:(DrinkModel *)drink position:(NSUInteger)position;

#pragma mark - Location
#pragma mark -

+ (void)trackUpdatedWithLocation:(CLLocation *)location;

+ (void)trackFoundLocation:(CLLocation *)location duration:(NSTimeInterval)duration;

+ (void)trackTimingOutBeforeLocationFound;

@end
