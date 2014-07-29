//
//  Tracker+Events.m
//  SpotHopper
//
//  Created by Brennan Stehling on 7/28/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "Tracker+Events.h"

#import "DrinkModel.h"
#import "SpotModel.h"

@implementation Tracker (Events)

+ (void)trackDrinkProfileScreenViewed:(DrinkModel *)drink {
    [Tracker track:@"View Drink" properties:@{
                                              @"Drink name" : drink.name.length ? drink.name : @"Undefined",
                                              @"Drink id" : drink.ID ? drink.ID : [NSNull null]
                                              }];
}

+ (void)trackSpotProfileScreenViewed:(SpotModel *)spot {
    [Tracker track:@"View Spot" properties:@{
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
    
    [Tracker track:@"GlobalSearch result selected" properties:@{
                                             @"Selected type" : selectedType,
                                             @"Last query" : searchText.length ? searchText : [NSNull null]
                                             }];
}

+ (void)trackGlobalSearchRequestCompleted {
    [Tracker track:@"GlobalSearch request completed"];
}

+ (void)trackGlobalSearchRequestCancelled {
    [Tracker track:@"GlobalSearch request cancelled"];
}

+ (void)trackGlobalSearchRequestStarted {
    [Tracker track:@"GlobalSearch request started"];
}

+ (void)trackGlobalSearchHappened:(NSString *)searchText {
    if (!searchText.length) {
        [Tracker track:@"Search with Query"];
    }
    else {
        [Tracker track:@"Search without Query"];
    }
}

+ (void)trackLeavingGlobalSearch:(BOOL)selected {
    [Tracker track:@"Exiting GlobalSearch" properties:@{@"Selected a result" : [NSNumber numberWithBool:selected]}];
}

+ (void)trackLeavingHomeToSpots {
    [Tracker track:@"Home to Spots"];
}

+ (void)trackLeavingHomeToSpecials {
    [Tracker track:@"Home to Specials"];
}

+ (void)trackLeavingHomeToBeer {
    [Tracker track:@"Home to Beer"];
}

+ (void)trackLeavingHomeToCocktails {
    [Tracker track:@"Home to Cocktails"];
}

+ (void)trackLeavingHomeToWine {
    [Tracker track:@"Home to Wine"];
}

+ (void)trackSpotsMoodSelected:(NSString *)moodName {
    [Tracker track:@"Spots Mood Selected" properties:@{@"Mood name" : moodName.length ? moodName : [NSNull null]}];
}

+ (void)trackBeerStyleSelected:(NSString *)moodName {
    [Tracker track:@"Beer Style Selected" properties:@{@"Mood name" : moodName.length ? moodName : [NSNull null]}];
}

+ (void)trackCocktailStyleSelected:(NSString *)moodName {
    [Tracker track:@"Cocktail Style Selected" properties:@{@"Mood name" : moodName.length ? moodName : [NSNull null]}];
}

//Pass property mood name
+ (void)trackWineStyleSelected:(NSString *)moodName {
    [Tracker track:@"Wine Style Selected" properties:@{@"Mood name" : moodName.length ? moodName : [NSNull null]}];
}

+ (void)trackSliderSearchSubmitTapped {
    [Tracker track:@"Slider Search Submit Clicked"];
}

+ (void)trackSpotlistViewed {
    [Tracker track:@"View Spotlist"];
}

+ (void)trackDrinklistViewed {
    [Tracker track:@"View Drinklist"];
}

+ (void)trackAreYouHere:(BOOL)yesOrNo {
    [Tracker track:@"Are you at this bar?" properties:@{@"yesOrNo" : [NSNumber numberWithBool:yesOrNo]}];
}

+ (void)trackUserTappedLocationPickerButton {
    [Tracker track:@"User Clicks on Location Picker Button"];
}

+ (void)trackUserSetNewLocation {
    [Tracker track:@"User sets new location"];
}

@end
