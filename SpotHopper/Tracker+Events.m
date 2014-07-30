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

@implementation Tracker (Events)

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
    [self trackLocationPropertiesForEvent:@"Viewed Home" properties:@{}];
}

+ (void)trackLeavingHomeToSpots {
    [self trackLocationPropertiesForEvent:@"Home to Spots" properties:@{}];
}

+ (void)trackLeavingHomeToSpecials {
    [self trackLocationPropertiesForEvent:@"Home to Specials" properties:@{}];
}

+ (void)trackLeavingHomeToBeer {
    [self trackLocationPropertiesForEvent:@"Home to Beer" properties:@{}];
}

+ (void)trackLeavingHomeToCocktails {
    [self trackLocationPropertiesForEvent:@"Home to Cocktails" properties:@{}];
}

+ (void)trackLeavingHomeToWine {
    [self trackLocationPropertiesForEvent:@"Home to Wine" properties:@{}];
}

+ (void)trackSpotsMoodSelected:(NSString *)moodName {
    [self trackLocationPropertiesForEvent:@"Spots Mood Selected" properties:@{@"Mood name" : moodName.length ? moodName : [NSNull null]}];
}

+ (void)trackBeerStyleSelected:(NSString *)styleName {
    [self trackLocationPropertiesForEvent:@"Beer Style Selected" properties:@{@"Style name" : styleName.length ? styleName : [NSNull null]}];
}

+ (void)trackCocktailStyleSelected:(NSString *)styleName {
    [self trackLocationPropertiesForEvent:@"Cocktail Style Selected" properties:@{@"Style name" : styleName.length ? styleName : [NSNull null]}];
}

+ (void)trackWineStyleSelected:(NSString *)styleName {
    [self trackLocationPropertiesForEvent:@"Wine Style Selected" properties:@{@"Style name" : styleName.length ? styleName : [NSNull null]}];
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

+ (void)trackDrinkSpecials:(NSArray *)spots centerCoordinate:(CLLocationCoordinate2D)centerCoordinate currentLocation:(CLLocation *)currentLocation {
    CLLocation *location = [[CLLocation alloc] initWithLatitude:centerCoordinate.latitude longitude:centerCoordinate.longitude];
    CLLocationDistance distance = [location distanceFromLocation:currentLocation];
    
    NSMutableDictionary *properties = @{
                                        @"Spots count" : [NSNumber numberWithInteger:spots.count],
                                        @"Distance in meters" : [NSNumber numberWithFloat:distance]
                                        }.mutableCopy;
    
    [self getPropertiesForLocation:location prefix:@"Center" withCompletionBlock:^(NSDictionary *centerProperties, NSError *error) {
        if (centerProperties) {
            [properties addEntriesFromDictionary:centerProperties];
            [self getPropertiesForLocation:location prefix:@"Current" withCompletionBlock:^(NSDictionary *currentProperties, NSError *error) {
                if (currentProperties) {
                    [properties addEntriesFromDictionary:currentProperties];
                }
                
                [Tracker track:@"Drink specials fetched" properties:properties];
            }];
        }
    }];
}

+ (void)trackSpotlist:(SpotListModel *)spotlist request:(SpotListRequest *)request currentLocation:(CLLocation *)currentLocation {
    CLLocation *location = [[CLLocation alloc] initWithLatitude:request.coordinate.latitude longitude:request.coordinate.longitude];
    CLLocationDistance distance = [location distanceFromLocation:currentLocation];
    
    NSMutableDictionary *properties = @{
                                        @"Spotlist name" : spotlist.name.length ? spotlist.name : @"Unknown",
                                        @"Spotlist ID" : spotlist.ID ? spotlist.ID : [NSNull null],
                                        @"Spots count" : [NSNumber numberWithInteger:spotlist.spots.count],
                                        @"Distance in meters" : [NSNumber numberWithFloat:distance]
                                        }.mutableCopy;
    
    [self getPropertiesForLocation:location prefix:@"Center" withCompletionBlock:^(NSDictionary *centerProperties, NSError *error) {
        if (centerProperties) {
            [properties addEntriesFromDictionary:centerProperties];
        }
        [self getPropertiesForLocation:location prefix:@"Current" withCompletionBlock:^(NSDictionary *currentProperties, NSError *error) {
            if (currentProperties) {
                [properties addEntriesFromDictionary:currentProperties];
            }
            
            [Tracker track:@"Spotlist fetched" properties:properties];
        }];
    }];
}

+ (void)trackDrinklist:(DrinkListModel *)drinklist mode:(SHMode)mode request:(DrinkListRequest *)request currentLocation:(CLLocation *)currentLocation {
    CLLocation *location = [[CLLocation alloc] initWithLatitude:request.coordinate.latitude longitude:request.coordinate.longitude];
    CLLocationDistance distance = [location distanceFromLocation:currentLocation];
    
    NSMutableDictionary *properties = @{
                                        @"Drinklist name" : drinklist.name.length ? drinklist.name : @"Unknown",
                                        @"Drinklist ID" : drinklist.ID ? drinklist.ID : [NSNull null],
                                        @"Spot ID" : request.spotId ? request.spotId : [NSNull null],
                                        @"Drinks count" : [NSNumber numberWithInteger:drinklist.drinks.count],
                                        @"Distance in meters" : [NSNumber numberWithFloat:distance]
                                        }.mutableCopy;
    
    [self getPropertiesForLocation:location prefix:@"Center" withCompletionBlock:^(NSDictionary *centerProperties, NSError *error) {
        if (centerProperties) {
            [properties addEntriesFromDictionary:centerProperties];
        }
        [self getPropertiesForLocation:location prefix:@"Current" withCompletionBlock:^(NSDictionary *currentProperties, NSError *error) {
            if (currentProperties) {
                [properties addEntriesFromDictionary:currentProperties];
            }
            
            if (SHModeBeer == mode) {
                [self track:@"Drinklist fetched (Beer)" properties:properties];
            }
            else if (SHModeCocktail == mode) {
                [self track:@"Drinklist fetched (Cocktail)" properties:properties];
            }
            else if (SHModeWine == mode) {
                [self track:@"Drinklist fetched (Wine)" properties:properties];
            }
            else  {
                [self track:@"Drinklist fetched" properties:properties];
            }
        }];
    }];
}

@end
