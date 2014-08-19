//
//  Tracker+Events.m
//  SpotHopper
//
//  Created by Brennan Stehling on 7/28/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "Tracker+Events.h"

#import "SpotModel.h"
#import "DrinkModel.h"
#import "SpotListModel.h"
#import "DrinkListModel.h"
#import "SpotListRequest.h"
#import "DrinkListRequest.h"

#import "TellMeMyLocation.h"

#import "Mixpanel.h"

@implementation Tracker (Events)

+ (void)trackFirstUse {
    [self track:@"First Use"];
}

+ (void)trackDrinkProfileScreenViewed:(DrinkModel *)drink {
    NSString *eventName = @"View Drink";
    
    if (drink.isBeer) {
        eventName = @"View Beer";
    }
    else if (drink.isCocktail) {
        eventName = @"View Cocktail";
    }
    else if (drink.isWine) {
        eventName = @"View Wine";
    }
    
    NSDictionary *properties = @{
                                 @"Drink name" : drink.name.length ? drink.name : @"Undefined",
                                 @"Drink id" : drink.ID ? drink.ID : [NSNull null]
                                 };
    
    [self trackLocationPropertiesForEvent:eventName properties:properties];
}

+ (void)trackSpotProfileScreenViewed:(SpotModel *)spot {
    [self trackLocationPropertiesForEvent:@"View Spot" properties:@{
                                                                    @"Spot name" : spot.name.length ? spot.name : @"Undefined",
                                                                    @"Spot id" : spot.ID ? spot.ID : [NSNull null]
                                                                    }];
}

+ (void)trackGlobalSearchResultTapped:(SHJSONAPIResource *)model searchText:(NSString *)searchText {
    NSString *selectedType = @"Undefined";
    if ([model isKindOfClass:[SpotModel class]]) {
        selectedType = @"Spot";
    }
    else if ([model isKindOfClass:[DrinkModel class]]) {
        selectedType = @"Drink";
    }
    
    [self trackLocationPropertiesForEvent:@"GlobalSearch result selected" properties:@{
                                                                                       @"Selected type" : selectedType,
                                                                                       @"Last query" : searchText.length ? searchText : [NSNull null]
                                                                                       }];
}

+ (void)trackGlobalSearchRequestCompleted {
    [self trackLocationPropertiesForEvent:@"GlobalSearch request completed" properties:@{}];
}

+ (void)trackGlobalSearchRequestCancelled {
    [self trackLocationPropertiesForEvent:@"GlobalSearch request cancelled" properties:@{}];
}

+ (void)trackGlobalSearchRequestStarted {
    [self trackLocationPropertiesForEvent:@"GlobalSearch request started" properties:@{}];
}

+ (void)trackGlobalSearchHappened:(NSString *)searchText {
    if (!searchText.length) {
        [self trackLocationPropertiesForEvent:@"Search with Query" properties:@{}];
    }
    else {
        [self trackLocationPropertiesForEvent:@"Search without Query" properties:@{}];
    }
}

+ (void)trackLeavingGlobalSearch:(BOOL)selected {
    [self trackLocationPropertiesForEvent:@"Exiting GlobalSearch" properties:@{@"Selected a result" : [NSNumber numberWithBool:selected]}];
}

+ (void)trackViewedHome {
    [self track:@"Viewed Home"];
}

+ (void)trackLeavingHomeToSpots:(BOOL)isSecondary actionButtonTapCount:(NSInteger)actionButtonTapCount {
    [self trackLocationPropertiesForEvent:@"Home to Spots" properties:@{@"Number of clicks this session" : [NSNumber numberWithInteger:actionButtonTapCount], @"Is secondary search"  : [NSNumber numberWithBool:isSecondary]}];
}

+ (void)trackLeavingHomeToSpecials:(BOOL)isSecondary actionButtonTapCount:(NSInteger)actionButtonTapCount {
    [self trackLocationPropertiesForEvent:@"Home to Specials" properties:@{@"Number of clicks this session" : [NSNumber numberWithInteger:actionButtonTapCount], @"Is secondary search"  : [NSNumber numberWithBool:isSecondary]}];
}

+ (void)trackLeavingHomeToBeer:(BOOL)isSecondary actionButtonTapCount:(NSInteger)actionButtonTapCount {
    [self trackLocationPropertiesForEvent:@"Home to Beer" properties:@{@"Number of clicks this session" : [NSNumber numberWithInteger:actionButtonTapCount], @"Is secondary search"  : [NSNumber numberWithBool:isSecondary]}];
}

+ (void)trackLeavingHomeToCocktails:(BOOL)isSecondary actionButtonTapCount:(NSInteger)actionButtonTapCount {
    [self trackLocationPropertiesForEvent:@"Home to Cocktails" properties:@{@"Number of clicks this session" : [NSNumber numberWithInteger:actionButtonTapCount], @"Is secondary search"  : [NSNumber numberWithBool:isSecondary]}];
}

+ (void)trackLeavingHomeToWine:(BOOL)isSecondary actionButtonTapCount:(NSInteger)actionButtonTapCount {
    [self trackLocationPropertiesForEvent:@"Home to Wine" properties:@{@"Number of clicks this session" : [NSNumber numberWithInteger:actionButtonTapCount], @"Is secondary search"  : [NSNumber numberWithBool:isSecondary]}];
}

+ (void)trackDrinkStylesDidLoad:(SHMode)mode numberOfStyles:(NSInteger)numberOfStyles duration:(NSTimeInterval)duration {
    NSString *eventName = nil;
    
    switch (mode) {
        case SHModeBeer:
            eventName = @"Beer styles loaded";
            break;
        case SHModeCocktail:
            eventName = @"Cocktail styles loaded";
            break;
        case SHModeWine:
            eventName = @"Wine styles loaded";
            break;
            
        default:
            NSAssert(FALSE, @"Mode should always be a drink mode");
            break;
    }
    
    NSDictionary *properties = @{
                                 @"Number of styles" : [NSNumber numberWithInteger:numberOfStyles],
                                 @"Duration" : [NSNumber numberWithDouble:duration]
                                };
    
    [self trackLocationPropertiesForEvent:eventName properties:properties];
}

+ (void)trackSpotMoodsDidLoad:(SHMode)mode numberOfMoods:(NSInteger)numberOfMoods duration:(NSTimeInterval)duration {
    NSDictionary *properties = @{
                                 @"Number of moods" : [NSNumber numberWithInteger:numberOfMoods],
                                 @"Duration" : [NSNumber numberWithDouble:duration]
                               };
    
    [self trackLocationPropertiesForEvent:@"Spot Moods Loaded" properties:properties];
}

+ (void)trackSpotsMoodSelected:(NSString *)moodName moodsCount:(NSUInteger)moodsCount position:(NSUInteger)position {
    NSDictionary *properties = @{ @"Mood Name" : moodName.length ? moodName : @"", @"Moods Count" : [NSNumber numberWithInteger:moodsCount], @"Position" : [NSNumber numberWithInteger:position] };
    
    [self trackLocationPropertiesForEvent:@"Moods Selected" properties:properties];
}

+ (void)trackSpotsMoodSelected:(NSString *)moodName {
    [self trackLocationPropertiesForEvent:@"Spots Mood Selected" properties:@{@"Mood name" : moodName.length ? moodName : [NSNull null]}];
}

+ (void)trackBeerStyleSelected:(DrinkListModel *)style stylesCount:(NSUInteger)stylesCount position:(NSUInteger)position {
    [self trackLocationPropertiesForEvent:@"Beer Style Selected" properties:@{
                                                                              @"Style name" : style.name.length ? style.name : [NSNull null],
                                                                              @"Style id" : style.ID ? style.ID : [NSNull null],
                                                                              @"Number of styles" : [NSNumber numberWithInteger:stylesCount],
                                                                              @"Position in styles list" : [NSNumber numberWithInteger:position]
                                                                              }];
}

+ (void)trackCocktailStyleSelected:(DrinkListModel *)style stylesCount:(NSUInteger)stylesCount position:(NSUInteger)position {
    [self trackLocationPropertiesForEvent:@"Cocktail Style Selected" properties:@{
                                                                              @"Style name" : style.name.length ? style.name : [NSNull null],
                                                                              @"Style id" : style.ID ? style.ID : [NSNull null],
                                                                              @"Number of styles" : [NSNumber numberWithInteger:stylesCount],
                                                                              @"Position in styles list" : [NSNumber numberWithInteger:position]
                                                                              }];
}

+ (void)trackWineStyleSelected:(DrinkListModel *)style stylesCount:(NSUInteger)stylesCount position:(NSUInteger)position {
    [self trackLocationPropertiesForEvent:@"Wine Style Selected" properties:@{
                                                                              @"Style name" : style.name.length ? style.name : [NSNull null],
                                                                              @"Style id" : style.ID ? style.ID : [NSNull null],
                                                                              @"Number of styles" : [NSNumber numberWithInteger:stylesCount],
                                                                              @"Position in styles list" : [NSNumber numberWithInteger:position]
                                                                              }];
}

+ (void)trackSliderSearchButtonTapped:(SHMode)mode {
    if (SHModeSpots == mode) {
        [Tracker track:@"Slider Search Spots Button Tapped"];
    }
    else if (SHModeBeer == mode) {
        [Tracker track:@"Slider Search Beer Button Tapped"];
    }
    else if (SHModeCocktail == mode) {
        [Tracker track:@"Slider Search Cocktail Button Tapped"];
    }
    else if (SHModeWine == mode) {
        [Tracker track:@"Slider Search Wine Button Tapped"];
    }
    else  {
        [Tracker track:@"Slider Search Button Tapped"];
    }
}

+ (void)trackCreatingDrinkList {
    [self trackLocationPropertiesForEvent:@"Creating DrinkList" properties:@{}];
}

+ (void)trackCreatedDrinkList:(BOOL)success drinkTypeID:(NSNumber *)drinkTypeID drinkSubTypeID:(NSNumber *)drinkSubTypeID duration:(NSTimeInterval)duration createdWithSliders:(BOOL)createdWithSliders {
    [self trackLocationPropertiesForEvent:@"Created Drinklist" properties:@{@"Success" : [NSNumber numberWithBool:success], @"Drink Type ID" : drinkTypeID ?: @0, @"Drink Sub Type ID" : drinkSubTypeID ?: @0, @"Duration" : [NSNumber numberWithDouble:duration], @"Created With Sliders" : [NSNumber numberWithBool:createdWithSliders] }];
}

+ (void)trackCreatingSpotList {
    [self trackLocationPropertiesForEvent:@"Creating SpotList" properties:@{}];
}

+ (void)trackCreatedSpotList:(BOOL)success spotId:(NSNumber *)spotID spotTypeID:(NSNumber *)spotTypeID duration:(NSTimeInterval)duration createdWithSliders:(BOOL)createdWithSliders {
    [self trackLocationPropertiesForEvent:@"Created SpotList" properties:@{@"Success" : [NSNumber numberWithBool:success], @"Spot ID" : spotID ?: @0, @"Spot Type ID" : spotTypeID ?: @0, @"Duration" : [NSNumber numberWithDouble:duration], @"Created With Sliders" : [NSNumber numberWithBool:createdWithSliders] }];
}

+ (void)trackSpotlistViewed {
    [self trackLocationPropertiesForEvent:@"Viewed Spotlist" properties:@{}];
}

+ (void)trackDrinklistViewed:(SHMode)mode {
    if (SHModeBeer == mode) {
        [self trackLocationPropertiesForEvent:@"Viewed Drinklist (Beer)" properties:@{}];
    }
    else if (SHModeCocktail == mode) {
        [self trackLocationPropertiesForEvent:@"Viewed Drinklist (Cocktail)" properties:@{}];
    }
    else if (SHModeWine == mode) {
        [self trackLocationPropertiesForEvent:@"Viewed Drinklist (Wine)" properties:@{}];
    }
    else  {
        [self trackLocationPropertiesForEvent:@"Viewed Drinklist" properties:@{}];
    }
}

+ (void)trackAreYouHere:(BOOL)yesOrNo {
    [self trackLocationPropertiesForEvent:@"Are you at this bar?" properties:@{@"yesOrNo" : [NSNumber numberWithBool:yesOrNo]}];
}

+ (void)trackUserTappedLocationPickerButton {
    [self trackLocationPropertiesForEvent:@"User Clicks on Location Picker Button" properties:@{}];
}

+ (void)trackUserSetNewLocation {
    [self trackLocationPropertiesForEvent:@"User sets new location" properties:@{}];
}

+ (void)trackDrinkSpecials:(NSArray *)spots {
    NSMutableDictionary *properties = @{
                                        @"Spots count" : [NSNumber numberWithInteger:spots.count]
                                        }.mutableCopy;
    
    [self trackLocationPropertiesForEvent:@"Drink specials fetched" properties:properties];
}

+ (void)trackSpotlist:(SpotListModel *)spotlist request:(SpotListRequest *)request {
    NSMutableDictionary *properties = @{
                                        @"Spotlist name" : spotlist.name.length ? spotlist.name : @"Unknown",
                                        @"Spotlist ID" : spotlist.ID ? spotlist.ID : [NSNull null],
                                        @"Spots count" : [NSNumber numberWithInteger:spotlist.spots.count]
                                        }.mutableCopy;
    
    [self trackLocationPropertiesForEvent:@"Spotlist fetched" properties:properties];
}

+ (void)trackDrinklist:(DrinkListModel *)drinklist mode:(SHMode)mode request:(DrinkListRequest *)request {
    NSMutableDictionary *properties = @{
                                        @"Drinklist name" : drinklist.name.length ? drinklist.name : @"Unknown",
                                        @"Drinklist ID" : drinklist.ID ? drinklist.ID : [NSNull null],
                                        @"Spot ID" : request.spotId ? request.spotId : [NSNull null],
                                        @"Drinks count" : [NSNumber numberWithInteger:drinklist.drinks.count]
                                        }.mutableCopy;
    
    if (SHModeBeer == mode) {
        [self trackLocationPropertiesForEvent:@"Drinklist fetched (Beer)" properties:properties];
    }
    else if (SHModeCocktail == mode) {
        [self trackLocationPropertiesForEvent:@"Drinklist fetched (Cocktail)" properties:properties];
    }
    else if (SHModeWine == mode) {
        [self trackLocationPropertiesForEvent:@"Drinklist fetched (Wine)" properties:properties];
    }
    else  {
        [self trackLocationPropertiesForEvent:@"Drinklist fetched" properties:properties];
    }
}

#pragma mark - Navigation
#pragma mark -

+ (void)trackHomeNavigationButtonTapped:(BOOL)insideBounds {
    [Tracker track:@"Home Navigation Button Tapped" properties:@{ @"Inside Bounds" : [NSNumber numberWithBool:insideBounds]}];
}

#pragma mark - Logins
#pragma mark -

+ (void)trackLoginViewed {
    [Tracker track:@"Login Viewed"];
}

+ (void)trackerLeavingLoginViewLoggedIn {
    [Tracker track:@"Leaving Login View (Logged In)"];
}

+ (void)trackerLeavingLoginViewNotLoggedIn {
    [Tracker track:@"Leaving Login View (Not Logged In)"];
}

+ (void)trackCreatingAccount {
    [Tracker track:@"Creating Account"];
}

+ (void)trackCreatedUser:(BOOL)success {
    [Tracker track:@"Created User" properties:@{@"Success" : [NSNumber numberWithBool:success]}];
}

+ (void)trackLoggingInWithFacebook {
    [Tracker track:@"Logging In" properties:@{@"Service" : @"Facebook"}];
}

+ (void)trackLoggingInWithTwitter {
    [Tracker track:@"Logging In" properties:@{@"Service" : @"Twitter"}];
}

+ (void)trackLoggingInWithSpotHopper {
    [Tracker track:@"Logging In" properties:@{@"Service" : @"SpotHopper"}];
}

+ (void)trackLoggedIn:(BOOL)success {
    [Tracker track:@"Logged In" properties:@{@"Success" : [NSNumber numberWithBool:success]}];
}

@end
