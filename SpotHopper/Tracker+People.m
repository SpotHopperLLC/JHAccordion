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
#import "SHAppContext.h"
#import "TellMeMyLocation.h"

@implementation Tracker (People)

#pragma mark - Debugging
#pragma mark -

+ (void)trackUserDebugMode:(BOOL)debugMode {
    [self trackUserPropertyForKey:@"DebugMode" withValue:debugMode ? @"YES" : @"NO"];
}

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

#pragma mark - Notifications
#pragma mark -

+ (void)trackUserNotification:(NSDictionary *)userInfo {
    NSString *action = userInfo[@"action"];
    NSString *key = userInfo[@"key"];
    
    if (action.length) {
        NSString *trackedAction;
        if (key.length) {
            trackedAction = [NSString stringWithFormat:@"User Notification %@ - %@", action, key];
        }
        else {
            trackedAction = [NSString stringWithFormat:@"User Notification %@", action];
        }
        [self trackUserAction:trackedAction];
    }
}

#pragma mark - Logging In
#pragma mark -

+ (void)trackUserLeavingLoginLoggedIn {
    [self trackUserAction:@"User Leaving Login View (Logged In)"];
}

+ (void)trackUserLeavingLoginNotLoggedIn {
    [self trackUserAction:@"User Leaving Login View (Not Logged In)"];
}

+ (void)trackFacebookFriendsList:(NSArray *)friendsList {
    if (!friendsList) {
        return;
    }
    
    [self trackUserWithProperties:@{ @"Facebook Friends List" : friendsList, @"Facebook Friends Count" : [NSNumber numberWithInteger:friendsList.count] }];
}

#pragma mark - Searching
#pragma mark -

+ (void)trackUserSearchedSpotlist:(SpotListModel *)spotlist {
    if (spotlist.name.length) {
        NSString *action = [NSString stringWithFormat:@"User Searched Spotlist: %@", spotlist.name];
        [Tracker trackUserAction:action];
    }
    [self trackUserSearchLocation];
}

+ (void)trackUserSearchedDrinklist:(DrinkListModel *)drinklist {
    if (drinklist.name.length) {
        NSString *action = [NSString stringWithFormat:@"User Searched Drinklist: %@", drinklist.name];
        [Tracker trackUserAction:action];
    }
    [self trackUserSearchLocation];
}

+ (void)trackUserSearchLocation {
    NSString *locationName = [TellMeMyLocation currentLocationName];
    NSString *zip = [TellMeMyLocation currentLocationZip];
    
    if (locationName.length) {
        NSString *action = [NSString stringWithFormat:@"User Searched City: %@", locationName];
        [Tracker trackUserAction:action];
    }
    if (zip.length) {
        NSString *action = [NSString stringWithFormat:@"User Searched Zip: %@", zip];
        [Tracker trackUserAction:action];
    }
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

#pragma mark - Location
#pragma mark -

+ (void)trackUserFrequentLocation {
    NSString *locationName = [TellMeMyLocation currentLocationName];
    NSString *zip = [TellMeMyLocation currentLocationZip];
    
    if (locationName.length) {
        NSString *action = [NSString stringWithFormat:@"User Frequent City: %@", locationName];
        [Tracker trackUserAction:action];
    }
    if (zip.length) {
        NSString *action = [NSString stringWithFormat:@"User Frequent Zip: %@", zip];
        [Tracker trackUserAction:action];
    }
}

+ (void)trackUserLocation:(CLPlacemark *)placemark forKey:(NSString *)key {
    NSString *city = [TellMeMyLocation shortLocationNameFromPlacemark:placemark];
    
    if (city.length && placemark.postalCode.length && key.length) {
        NSString *locationName = [NSString stringWithFormat:@"User Last %@ City:", key];
        NSString *zipName = [NSString stringWithFormat:@"User Last %@ Zip:", key];
        NSDictionary *properties = @{
                                     locationName : city,
                                     zipName : placemark.postalCode
                                     };
        [self trackUserWithProperties:properties];
    }
}

+ (void)trackUserZip:(CLPlacemark *)placemark forKey:(NSString *)key {
    if (placemark.postalCode.length && key.length) {
        NSString *action = [NSString stringWithFormat:@"User Updated Location for %@: %@", key, placemark.postalCode];
        [self trackUserAction:action];
    }
}

#pragma mark - Highest Rated
#pragma mark -

+ (void)trackUserSelectedHighestRatedForBeer {
    [self trackUserAction:@"User Selected Highest Rated: Beer"];
}

+ (void)trackUserSelectedHighestRatedForWine {
    [self trackUserAction:@"User Selected Highest Rated: Wine"];
}

+ (void)trackUserSelectedHighestRatedForCocktail {
    [self trackUserAction:@"User Selected Highest Rated: Cocktail"];
}

#pragma mark - Pullup UI
#pragma mark -

+ (void)trackUserTappedFullDrinkMenu {
    [self trackUserAction:@"User Tapped Full Drink Menu"];
}

+ (void)trackUserTappedMorePhotos {
    [self trackUserAction:@"User Tapped More Photos"];
}

+ (void)trackUserTappedAllSliders {
    [self trackUserAction:@"User Tapped All Sliders"];
}

+ (void)trackUserTappedPhoneNumber {
    [self trackUserAction:@"User Tapped Phone Number"];
}

+ (void)trackUserTappedWriteAReview {
    [self trackUserAction:@"User Tapped Write a Review"];
}

+ (void)trackUserTappedShare {
    [self trackUserAction:@"User Tapped Share"];
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

+ (void)trackUserCheckedInAtSpot:(SpotModel *)spot {
    [self trackUserAction:@"User Checked In"];
    if (spot.name.length) {
        NSString *action = [NSString stringWithFormat:@"User Checked In: %@", spot.name];
        [self trackUserAction:action];
    }
}

#pragma mark - Likes
#pragma mark -

+ (void)trackUserLikedSpecial:(SpecialModel *)special {
    [Tracker trackUserAction:@"User Liked Special"];
    
    NSString *weekday = special.weekdayString.length ? special.weekdayString : @"NULL";
    [Tracker trackLocationPropertiesForEvent:@"Liked Special" properties:@{@"Name" : special.spot.name.length ? special.spot.name : @"NULL", @"Weekday" : weekday}];
}

+ (void)trackUserUnlikedSpecial:(SpecialModel *)special {
    [Tracker trackUserAction:@"User Unliked Special"];
    
    NSString *weekday = special.weekdayString.length ? special.weekdayString : @"NULL";
    [Tracker trackLocationPropertiesForEvent:@"Unliked Special" properties:@{@"Name" : special.spot.name.length ? special.spot.name : @"NULL", @"Weekday" : weekday}];
}

#pragma mark - Starred Sliders
#pragma mark -

+ (void)trackStarredSlider:(NSString *)type sliderName:(NSString *)sliderName {
    [Tracker trackLocationPropertiesForEvent:@"Starred Slider" properties:@{
                                                                            @"Type" : type.length ? type : @"NULL",
                                                                            @"Slider Name" : sliderName.length ? sliderName : @"NULL"
                                                                            }];
    [Tracker trackUserAction:@"Starred Slider"];
}

+ (void)trackUnstarredSlider:(NSString *)type sliderName:(NSString *)sliderName {
    [Tracker trackLocationPropertiesForEvent:@"Unstarred Slider" properties:@{
                                                                              @"Type" : type.length ? type : @"NULL",
                                                                              @"Slider Name" : sliderName.length ? sliderName : @"NULL"
                                                                              }];
    [Tracker trackUserAction:@"Unstarred Slider"];
}

@end
