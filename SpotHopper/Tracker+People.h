//
//  Tracker+People.h
//  SpotHopper
//
//  Created by Brennan Stehling on 8/15/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "Tracker.h"

#import "UserModel.h"
#import "SpotModel.h"
#import "SpecialModel.h"
#import "DrinkModel.h"

@interface Tracker (People)

#pragma mark - Launch
#pragma mark -

+ (void)trackUserFirstUse;

+ (void)trackLastLogin;

#pragma mark - Logging In
#pragma mark -

+ (void)trackUserViewedHome;

+ (void)trackUserLeavingLoginLoggedIn;

+ (void)trackUserLeavingLoginNotLoggedIn;

+ (void)trackFacebookFriendsList:(NSArray *)friendsList;

#pragma mark - Search Results
#pragma mark -

+ (void)trackUserNoBeerResults;

+ (void)trackUserNoCocktailResults;

+ (void)trackUserNoWineResults;

+ (void)trackUserNoSpotResults;

+ (void)trackUserNoSpecialsResults;

+ (void)trackUserGoodBeerResults;

+ (void)trackUserGoodCocktailResults;

+ (void)trackUserGoodWineResults;

+ (void)trackUserGoodSpotsResults;

+ (void)trackUserGoodSpecialsResults;

#pragma mark - Highest Rated
#pragma mark -

+ (void)trackUserSelectedHighestRatedForBeer;

+ (void)trackUserSelectedHighestRatedForWine;

+ (void)trackUserSelectedHighestRatedForCocktail;

#pragma mark - Pullup UI
#pragma mark -

+ (void)trackUserTappedFullDrinkMenu;

+ (void)trackUserTappedMorePhotos;

+ (void)trackUserTappedAllSliders;

+ (void)trackUserTappedPhoneNumber;

+ (void)trackUserTappedWriteAReview;

+ (void)trackUserTappedShare;

#pragma mark - Home Map Actions
#pragma mark -

+ (void)trackUserSearchedBeers;

+ (void)trackUserSearchedCocktails;

+ (void)trackUserSearchedWine;

+ (void)trackUserSearchedSpots;

+ (void)trackUserSearchedSpecials;

+ (void)trackUserCheckedIn;

#pragma mark - Likes
#pragma mark -

+ (void)trackUserLikedSpecial:(SpecialModel *)special;

+ (void)trackUserUnlikedSpecial:(SpecialModel *)special;

#pragma mark - Starred Sliders
#pragma mark -

+ (void)trackStarredSlider:(NSString *)type sliderName:(NSString *)sliderName;

+ (void)trackUnstarredSlider:(NSString *)type sliderName:(NSString *)sliderName;

@end
