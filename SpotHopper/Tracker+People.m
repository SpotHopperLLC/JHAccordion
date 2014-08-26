//
//  Tracker+People.m
//  SpotHopper
//
//  Created by Brennan Stehling on 8/15/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "Tracker+People.h"

#import "SHAppConfiguration.h"
#import "Mixpanel.h"
#import "ClientSessionManager.h"

@implementation Tracker (People)

#pragma mark - Launch
#pragma mark -

+ (void)trackUserFirstUse {
    [self trackUserAction:@"User First Use"];
}

+ (void)trackLastLogin {
    [self trackUserWithProperties:@{ @"Last Login" : [NSDate date] }];
}

+ (void)trackUserViewedHome {
    [self trackUserAction:@"User Viewed Home"];
}

#pragma mark - Logging In
#pragma mark -

+ (void)trackUserLeavingLoginLoggedIn {
    [self trackUserAction:@"User Leaving Login View (Logged In)"];
}

+ (void)trackUserLeavingLoginNotLoggedIn {
    [self trackUserAction:@"User Leaving Login View (Not Logged In)"];
}

#pragma mark - Search Results
#pragma mark -

+ (void)trackUserNoBeerResults {
    [self trackUserAction:@"User No Beer Results"];
}

+ (void)trackUserNoCocktailResults {
    [self trackUserAction:@"User No Cocktail Results"];
}

+ (void)trackUserNoWineResults {
    [self trackUserAction:@"User No Wine Results"];
}

+ (void)trackUserNoSpotResults {
    [self trackUserAction:@"User No Spot Results"];
}

+ (void)trackUserNoSpecialsResults {
    [self trackUserAction:@"User No Specials Results"];
}

+ (void)trackUserGoodBeerResults {
    [self trackUserAction:@"User Good Beer Results"];
}

+ (void)trackUserGoodCocktailResults {
    [self trackUserAction:@"User Good Cocktail Results"];
}

+ (void)trackUserGoodWineResults {
    [self trackUserAction:@"User Good Wine Results"];
}

+ (void)trackUserGoodSpotsResults {
    [self trackUserAction:@"User Good Spots Results"];
}

+ (void)trackUserGoodSpecialsResults {
    [self trackUserAction:@"User Good Specials Results"];
}

#pragma mark - Home Map Actions
#pragma mark -

+ (void)trackUserSearchedBeers {
    [self trackUserAction:@"User Searched Beers"];
}

+ (void)trackUserSearchedCocktails {
    [self trackUserAction:@"User Searched Cocktails"];
}

+ (void)trackUserSearchedWine {
    [self trackUserAction:@"User Searched Wine"];
}

+ (void)trackUserSearchedSpots {
    [self trackUserAction:@"User Searched Spots"];
}

+ (void)trackUserSearchedSpecials {
    [self trackUserAction:@"User Searched Specials"];
}

@end
