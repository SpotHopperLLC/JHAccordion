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
#import "DrinkTypeModel.h"
#import "SpotListModel.h"
#import "DrinkListModel.h"
#import "SpotListRequest.h"
#import "DrinkListRequest.h"
#import "SpecialModel.h"
#import "CheckInModel.h"

#import "ClientSessionManager.h"

#import "Mixpanel.h"

@implementation Tracker (Events)

+ (void)trackAppLaunching {
    [self track:@"App Launching"];
}

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

#pragma mark - Activities
#pragma mark -

+ (void)trackActivity:(NSString *)activityName duration:(NSTimeInterval)duration {
    DebugLog(@"%@", NSStringFromSelector(_cmd));
    [self track:@"Activity" properties:@{
                                         @"Name" : activityName.length ? activityName : @"NULL",
                                         @"Duration" : [NSNumber numberWithFloat:duration]
                                         }];
}

#pragma mark - Global Search
#pragma mark -

+ (void)trackGlobalSearchStarted {
    [self track:@"GlobalSearch started"];
}

+ (void)trackGlobalSearchCancelled {
    [self track:@"GlobalSearch cancelled"];
}

+ (void)trackGlobalSearchResultTapped:(SHJSONAPIResource *)model searchText:(NSString *)searchText {
    NSString *selectedType = @"NULL";
    NSString *name = @"NULL";
    if ([model isKindOfClass:[SpotModel class]]) {
        SpotModel *spot = (SpotModel *)model;
        selectedType = @"Spot";
        name = spot.name;
    }
    else if ([model isKindOfClass:[DrinkModel class]]) {
        DrinkModel *drink = (DrinkModel *)model;
        selectedType = @"Drink";
        name = drink.name;
    }
    
    [self trackLocationPropertiesForEvent:@"GlobalSearch result selected" properties:@{
                                                                                       @"Selected type" : selectedType,
                                                                                       @"Name" : name.length ? name : [NSNull null],
                                                                                       @"Last query" : searchText.length ? searchText : [NSNull null]
                                                                                       }];
}

+ (void)trackGlobalSearchRequestCancelled {
    [self trackLocationPropertiesForEvent:@"GlobalSearch request cancelled" properties:@{}];
}

+ (void)trackGlobalSearchRequestStarted {
    [self trackLocationPropertiesForEvent:@"GlobalSearch request started" properties:@{}];
}

+ (void)trackGlobalSearchHappened:(NSString *)searchText {
    [self trackLocationPropertiesForEvent:@"Search with Query" properties:@{@"Search Text" : searchText.length ? searchText : @"NULL"}];
}

+ (void)trackLeavingGlobalSearch:(BOOL)selected {
    [self trackLocationPropertiesForEvent:@"Exiting GlobalSearch" properties:@{@"Selected a result" : [NSNumber numberWithBool:selected]}];
}

#pragma mark - Location
#pragma mark -

+ (void)trackFetchedLocationFromMapsUserLocation:(CLLocationDistance)distance {
    [Tracker track:@"Fetched Location" properties:@{@"Distance from User Location" : [NSNumber numberWithFloat:distance]}];
}

#pragma mark - Highest Rated
#pragma mark -

+ (void)trackSelectedHighestRatedForBeer {
    [self track:@"Selected Highest Rated: Beer"];
}

+ (void)trackSelectedHighestRatedForWine {
    [self track:@"Selected Highest Rated: Wine"];
}

+ (void)trackSelectedHighestRatedForCocktail {
    [self track:@"Selected Highest Rated: Cocktail"];
}

#pragma mark - Pullup UI
#pragma mark -

+ (void)trackTappedFullDrinkMenu {
    [self track:@"Tapped Full Drink Menu"];
}

+ (void)trackTappedMorePhotos {
    [self track:@"Tapped More Photos"];
}

+ (void)trackTappedAllSliders {
    [self track:@"Tapped All Sliders"];
}

+ (void)trackTappedPhoneNumber {
    [self track:@"Tapped Phone Number"];
}

+ (void)trackTappedWriteAReview {
    [self track:@"Tapped Write a Review"];
}

+ (void)trackTappedShare {
    [self track:@"Tapped Share"];
}

+ (void)trackPulledUpCollectionViewForSpecialsSpots:(NSArray *)spots atIndex:(NSUInteger)index {
    if (index < spots.count) {
        SpotModel *spot = spots[index];
        SpecialModel *special = [spot specialForToday];
        [Tracker track:@"Pulled up Collection View" properties:@{@"Spot" : spot.name.length ? spot.name : @"N/A", @"Special" : @TRUE, @"Match" : spot.matchPercent.length ? spot.matchPercent : @"N/A", @"Likes" : [NSNumber numberWithInteger:special.likeCount], @"Position" : [NSNumber numberWithInteger:index+1], @"Total" : [NSNumber numberWithInteger:spots.count]}];
    }
}

+ (void)trackPulledUpCollectionViewForSpotlist:(SpotListModel *)spotlist atIndex:(NSUInteger)index {
    if (index < spotlist.spots.count) {
        SpotModel *spot = spotlist.spots[index];
        [Tracker track:@"Pulled up Collection View" properties:@{@"Spot" : spot.name.length ? spot.name : @"N/A", @"Special" : @FALSE, @"Match" : spot.matchPercent.length ? spot.matchPercent : @"N/A", @"Position" : [NSNumber numberWithInteger:index+1], @"Total" : [NSNumber numberWithInteger:spotlist.spots.count]}];
        
    }
}

+ (void)trackPulledUpCollectionViewForDrinklist:(DrinkListModel *)drinklist atIndex:(NSUInteger)index {
    if (index < drinklist.drinks.count) {
        DrinkModel *drink = drinklist.drinks[index];
        [Tracker track:@"Pulled up Collection View" properties:@{@"Drink" : drink.name.length ? drink.name : @"N/A", @"Match" : drink.matchPercent.length ? drink.matchPercent : @"N/A", @"Position" : [NSNumber numberWithInteger:index+1], @"Total" : [NSNumber numberWithInteger:drinklist.drinks.count]}];
    }
}

#pragma mark -

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

+ (void)trackAreYouHere:(BOOL)yesOrNo spot:(SpotModel *)spot {
    [self trackLocationPropertiesForEvent:@"Are you at this bar?" properties:@{@"yesOrNo" : [NSNumber numberWithBool:yesOrNo], @"Name" : spot.name.length ? spot.name : @"NULL"}];
}

+ (void)trackDeepLinkWithTargetURL:(NSURL *)targetURL sourceURL:(NSURL *)sourceURL sourceApplication:(NSString *)sourceApplication {
    NSString *targetPath = targetURL.path.length ? targetURL.path : @"NULL";
    NSString *source = sourceURL.host.length ? sourceURL.host : sourceURL.scheme.length ? sourceURL.scheme : @"NULL";

    [self trackUserAction:@"User Deep Link"];
    [self trackLocationPropertiesForEvent:@"Deep Link" properties:@{@"Target Path" : targetPath, @"Source" : source, @"Source Application" : sourceApplication.length ? sourceApplication : @"NULL" }];
}

+ (void)trackUserTappedLocationPickerButton {
    [self trackLocationPropertiesForEvent:@"User Clicks on Location Picker Button" properties:@{}];
}

+ (void)trackUserSetNewLocation {
    [self trackLocationPropertiesForEvent:@"User sets new location" properties:@{}];
}

+ (void)trackDrinkSpecials:(SpotListModel *)spotlists {
    NSMutableDictionary *properties = @{
                                        @"Spots count" : [NSNumber numberWithInteger:spotlists.spots.count]
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

+ (void)trackTotalContentLength {
    NSUInteger totalContentLength = [[ClientSessionManager sharedClient] totalContentLength];
    [self track:@"Total Content Length" properties:@{
                                                     @"Bytes" : [NSNumber numberWithUnsignedLong:totalContentLength],
                                                     @"KB" : [NSNumber numberWithUnsignedLong:totalContentLength / 1024],
                                                     @"MB" : [NSNumber numberWithUnsignedLong:totalContentLength / 1024 / 1024]}];
    [[ClientSessionManager sharedClient] resetContentLength];
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
    
    [[[Mixpanel sharedInstance] people] set:@{ @"Last Login" : [NSDate date] }];
    
    
}

#pragma mark - Search Results
#pragma mark -

+ (void)trackNoBeerResults {
    [self track:@"No Beer Results"];
}

+ (void)trackNoCocktailResults {
    [self track:@"No Cocktail Results"];
}

+ (void)trackNoWineResults {
    [self track:@"No Wine Results"];
}

+ (void)trackNoSpotResults {
    [self track:@"No Spot Results"];
}

+ (void)trackNoSpecialsResults {
    [self track:@"No Specials Results"];
}

+ (void)trackGoodBeerResultsWithName:(NSString *)name match:(NSNumber *)match {
    NSUInteger percentage = (NSUInteger)([match floatValue] * 100);
    [self track:@"Good Beer Results" properties:@{@"name" : name.length ? name : @"NULL", @"percentage" : [NSNumber numberWithInteger:percentage]}];
}

+ (void)trackGoodCocktailResultsWithName:(NSString *)name match:(NSNumber *)match {
    NSUInteger percentage = (NSUInteger)([match floatValue] * 100);
    [self track:@"Good Cocktail Results" properties:@{@"name" : name.length ? name : @"NULL", @"percentage" : [NSNumber numberWithInteger:percentage]}];
}

+ (void)trackGoodWineResultsWithName:(NSString *)name match:(NSNumber *)match {
    NSUInteger percentage = (NSUInteger)([match floatValue] * 100);
    [self track:@"Good Wine Results" properties:@{@"name" : name.length ? name : @"NULL", @"percentage" : [NSNumber numberWithInteger:percentage]}];
}

+ (void)trackGoodSpotsResultsWithName:(NSString *)name match:(NSNumber *)match {
    NSUInteger percentage = (NSUInteger)([match floatValue] * 100);
    [self track:@"Good Spots Results" properties:@{@"name" : name.length ? name : @"NULL", @"percentage" : [NSNumber numberWithInteger:percentage]}];
}

+ (void)trackGoodSpecialsResultsWithLikes:(NSUInteger)likesCount {
    [self track:@"Good Specials Results" properties:@{@"Likes" : [NSNumber numberWithInteger:likesCount]}];
}

#pragma mark - Home Map Actions
#pragma mark -

+ (void)trackSpotsButtonTapped {
    [self track:@"Spots Button Tapped"];
}

+ (void)trackSpecialsButtonTapped {
    [self track:@"Specials Button Tapped"];
}

+ (void)trackBeerButtonTapped {
    [self track:@"Beer Button Tapped"];
}

+ (void)trackCocktailButtonTapped {
    [self track:@"Cocktail Button Tapped"];
}

+ (void)trackWineButtonTapped {
    [self track:@"Wine Button Tapped"];
}

#pragma mark - Checkins
#pragma mark -

+ (void)trackWentToSpot:(SpotModel *)spot {
    if (spot.ID && spot.name.length) {
        [self track:@"Went to Spot" properties:@{ @"spot" : spot.name, @"spotId" : spot.ID }];
    }
}

+ (void)trackCheckinButtonTapped {
    [self track:@"Checkin Button Tapped"];
}

+ (void)trackCheckinCancelButtonTapped {
    [self track:@"Checkin Cancel Button Tapped"];
}

+ (void)trackPromptedToCheckInAtSpot:(SpotModel *)spot {
    if (spot.ID && spot.name.length) {
        [self track:@"Checkin Prompt" properties:@{ @"spot" : spot.name, @"spotId" : spot.ID }];
    }
}

+ (void)trackCheckedInAtSpot:(SpotModel *)spot position:(NSUInteger)position count:(NSUInteger)count distance:(CLLocationDistance)distance {
    
    [self track:@"Checking In" properties:@{
                                            @"Spot ID" : spot.ID ? spot.ID : [NSNull null],
                                            @"Spot Name" : spot.name.length ? spot.name : [NSNull null],
                                            @"Position" : [NSNumber numberWithInteger:position],
                                            @"Count" : [NSNumber numberWithInteger:count],
                                            @"Position" : [NSNumber numberWithFloat:distance]
                                 }];
    
    [self trackUserAction:@"Checking In"];
}

#pragma mark - Notifications
#pragma mark -

+ (void)trackNotification:(NSDictionary *)userInfo {
    NSString *action = userInfo[@"action"];
    NSString *key = userInfo[@"key"];
    
    if (action.length) {
        NSString *trackedAction;
        if (key.length) {
            trackedAction = [NSString stringWithFormat:@"Notification %@ - %@", action, key];
        }
        else {
            trackedAction = [NSString stringWithFormat:@"Notification %@", action];
        }
        [self track:trackedAction];
    }
}

#pragma mark - Sharing
#pragma mark -

+ (void)trackSharingSpot:(SpotModel *)spot {
    [Tracker track:@"Sharing Spot" properties:@{@"Spot ID" : spot.ID ? spot.ID : [NSNull null], @"Spot Name" : spot.name.length ? spot.name : [NSNull null]}];
}

+ (void)trackSharingDrink:(DrinkModel *)drink {
    [Tracker track:@"Sharing Drink" properties:@{@"Drink ID" : drink.ID ? drink.ID : [NSNull null], @"Drink Name" : drink.name.length ? drink.name : [NSNull null]}];
}

+ (void)trackSharingSpecial:(SpecialModel *)special atSpot:(SpotModel *)spot {
    [Tracker track:@"Sharing Special" properties:@{@"Spot ID" : spot.ID ? spot.ID : [NSNull null], @"Weekday" : special.weekdayString.length ? special.weekdayString : [NSNull null], @"Likes Count" : [NSNumber numberWithInteger:special.likeCount]}];
}

+ (void)trackSharingCheckin:(CheckInModel *)checkin {
    [Tracker track:@"Sharing Checkin" properties:@{@"Checkin ID" : checkin.ID ? checkin.ID : [NSNull null], @"Spot ID" : checkin.spot.ID ? checkin.spot.ID : [NSNull null], @"Spot Name" : checkin.spot.name.length ? checkin.spot.name : [NSNull null]}];
}

#pragma mark - List View
#pragma mark -

+ (void)trackListViewDidDisplaySpot:(SpotModel *)spot  position:(NSUInteger)position isSpecials:(BOOL)isSpecials {
    [self trackLocationPropertiesForEvent:@"List View Displayed Spot" properties:@{
                                                                                   @"Name" : spot.name.length ? spot.name : @"NULL",
                                                                                   @"Spot ID" : spot.ID ? spot.ID : @"NULL",
                                                                                   @"Position" : [NSNumber numberWithInteger:position],
                                                                                   @"Is Specials" : [NSNumber numberWithBool:isSpecials] }];
}

+ (void)trackListViewDidDisplayDrink:(DrinkModel *)drink  position:(NSUInteger)position {
    [self trackLocationPropertiesForEvent:@"List View Displayed Drink" properties:@{
                                                                                    @"Name" : drink.name.length ? drink.name : @"NULL",
                                                                                    @"Drink ID" : drink.ID ? drink.ID : @"NULL",
                                                                                    @"Type" : drink.drinkType.name.length ? drink.drinkType.name : @"NULL",
                                                                                    @"Position" : [NSNumber numberWithInteger:position] }];
}

#pragma mark - Location
#pragma mark -

+ (void)trackUpdatedWithLocation:(CLLocation *)location {
    NSDictionary *properties = @{
                                 @"Location Latitude" : [NSNumber numberWithDouble:location.coordinate.latitude],
                                 @"Location Longitude" : [NSNumber numberWithDouble:location.coordinate.longitude],
                                 @"Location Accuracy" : [NSNumber numberWithDouble:location.horizontalAccuracy]
                                 };

    [self trackLocationPropertiesForEvent:@"Updated with Location" properties:properties];
}

+ (void)trackFoundLocation:(CLLocation *)location duration:(NSTimeInterval)duration {
    NSDictionary *properties = @{
                                 @"Location Latitude" : [NSNumber numberWithDouble:location.coordinate.latitude],
                                 @"Location Longitude" : [NSNumber numberWithDouble:location.coordinate.longitude],
                                 @"Location Accuracy" : [NSNumber numberWithDouble:location.horizontalAccuracy],
                                 @"Location Duration" : [NSString stringWithFormat:@"%.2f", duration]
                                 };
    
    [self trackLocationPropertiesForEvent:@"Found Location" properties:properties];
}

+ (void)trackTimingOutBeforeLocationFound {
    [self trackLocationPropertiesForEvent:@"Timeout Before Location Found" properties:@{}];
}

@end
