//
//  Tracker+People.h
//  SpotHopper
//
//  Created by Brennan Stehling on 8/15/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "Tracker.h"

#import "UserModel.h"

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

#pragma mark - Home Map Actions
#pragma mark -

+ (void)trackUserSearchedBeers;

+ (void)trackUserSearchedCocktails;

+ (void)trackUserSearchedWine;

+ (void)trackUserSearchedSpots;

+ (void)trackUserSearchedSpecials;

@end
