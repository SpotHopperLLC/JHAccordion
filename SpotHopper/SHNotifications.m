//
//  SHNotifications.m
//  SpotHopper
//
//  Created by Brennan Stehling on 7/11/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "SHNotifications.h"

NSString * const SHGoToHomeMapNotificationName = @"SHGoToHomeMapNotificationName";

NSString * const SHFetchDrinklistRequestNotificationName = @"SHFetchDrinklistRequestNotificationName";
NSString * const SHFetchDrinklistRequestNotificationKey = @"SHFetchDrinklistRequestNotificationKey";

NSString * const SHFetchSpotlistRequestNotificationName = @"SHFetchSpotlistRequestNotificationName";
NSString * const SHFetchSpotlistRequestNotificationKey = @"SHFetchSpotlistRequestNotificationKey";

NSString * const SHDisplayDrinkNotificationName = @"SHDisplayDrinkNotificationName";
NSString * const SHDisplayDrinkNotificationKey = @"SHDisplayDrinkNotificationKey";

NSString * const SHDisplaySpotNotificationName = @"SHDisplaySpotNotificationName";
NSString * const SHDisplaySpotNotificationKey = @"SHDisplaySpotNotificationKey";

NSString * const SHPushToDrinkNotificationName = @"SHPushToDrinkNotificationName";
NSString * const SHPushToDrinkNotificationKey = @"SHPushToDrinkNotificationKey";

NSString * const SHPushToSpotNotificationName = @"SHPushToSpotNotificationName";
NSString * const SHPushToSpotNotificationKey = @"SHPushToSpotNotificationKey";

NSString * const SHFindSimilarToDrinkNotificationName = @"SHFindSimilarToDrinkNotificationName";
NSString * const SHFindSimilarToDrinkNotificationKey = @"SHFindSimilarToDrinkNotificationKey";

NSString * const SHReviewDrinkNotificationName = @"SHReviewDrinkNotificationName";
NSString * const SHReviewDrinkNotificationKey = @"SHReviewDrinkNotificationKey";

NSString * const SHFindSimilarToSpotNotificationName = @"SHFindSimilarToSpotNotificationName";
NSString * const SHFindSimilarToSpotNotificationKey = @"SHFindSimilarToSpotNotificationKey";

NSString * const SHReviewSpotNotificationName = @"SHReviewSpotNotificationName";
NSString * const SHReviewSpotNotificationKey =  @"SHReviewSpotNotificationKey";

NSString * const SHShowSpotPhotosNotificationName = @"SHShowSpotPhotosNotificationName";
NSString * const SHShowSpotPhotosNotificationKey = @"SHShowSpotPhotosNotificationKey";

NSString * const SHShowDrinkPhotosNotificationName = @"SHShowDrinkPhotosNotificationName";
NSString * const SHShowDrinkPhotosNotificationKey = @"SHShowDrinkPhotosNotificationKey";

NSString * const SHShowPhotoNotificationName = @"SHShowPhotoNotificationName";
NSString * const SHShowPhotoNotificationKey = @"SHShowPhotoNotificationKey";

NSString * const SHOpenMenuForSpotNotificationName = @"SHOpenMenuForSpotNotificationName";
NSString * const SHOpenMenuForSpotNotificationKey = @"SHOpenMenuForSpotNotificationKey";

NSString * const SHUserDidLogInNotificationName = @"SHUserDidLogInNotificationName";
NSString * const SHUserDidLogOutNotificationName = @"SHUserDidLogOutNotificationName";

NSString * const SHAppOpenedWithURLNotificationName = @"SHAppOpenedWithURLNotificationName";
NSString * const SHAppOpenedWithURLNotificationKey = @"SHAppOpenedWithURLNotificationKey";

NSString * const SHAppShareNotificationName = @"SHAppShareNotificationName";
NSString * const SHAppSpotNotificationKey = @"SHAppSpotNotificationKey";
NSString * const SHAppSpecialNotificationKey = @"SHAppSpecialNotificationKey";
NSString * const SHAppDrinkNotificationKey = @"SHAppDrinkNotificationKey";
NSString * const SHAppCheckinNotificationKey = @"SHAppCheckinNotificationKey";

NSString * const SHAppShowSpecialsNotificationName = @"SHAppShowSpecialsNotificationName";
NSString * const SHAppShowSpecialsNotificationLocationKey = @"location";
NSString * const SHAppShowSpecialsNotificationRadiusKey = @"radius";

NSString * const SHAppShowSpotlistNotificationName = @"SHAppShowSpotlistNotificationName";
NSString * const SHAppShowSpotlistNotificationSpotlistKey = @"spotlist";
NSString * const SHAppShowSpotlistNotificationLocationKey = @"location";
NSString * const SHAppShowSpotlistNotificationRadiusKey = @"radius";

NSString * const SHAppShowDrinklistNotificationName = @"SHAppShowDrinklistNotificationName";
NSString * const SHAppShowDrinklistNotificationDrinklistKey = @"drinklist";
NSString * const SHAppShowDrinklistNotificationLocationKey = @"location";
NSString * const SHAppShowDrinklistNotificationRadiusKey = @"radius";

NSString * const SHLocationChangedNotificationName = @"SHLocationChangedNotificationName";

NSString * const SHPromptForCheckInNotificationName = @"SHPromptForCheckInNotificationName";

NSString * const SHDisplayDiagnosticsNotificationName = @"SHDisplayDiagnosticsNotificationName";

@implementation SHNotifications

+ (void)goToHomeMap {
    [[NSNotificationCenter defaultCenter] postNotificationName:SHGoToHomeMapNotificationName object:nil];
}

+ (void)appOpenedWithURL:(NSURL *)url {
    NSDictionary *userInfo = @{ SHAppOpenedWithURLNotificationKey : url };
    [[NSNotificationCenter defaultCenter] postNotificationName:SHAppOpenedWithURLNotificationName
                                                        object:nil
                                                      userInfo:userInfo];
}

+ (void)fetchDrinklistWithRequest:(DrinkListRequest *)request {
    NSDictionary *userInfo = @{ SHFetchDrinklistRequestNotificationKey : request };
    [[NSNotificationCenter defaultCenter] postNotificationName:SHFetchDrinklistRequestNotificationName
                                                        object:nil
                                                      userInfo:userInfo];
}

+ (void)fetchSpotlistWithRequest:(SpotListRequest *)request {
    NSDictionary *userInfo = @{ SHFetchSpotlistRequestNotificationKey : request };
    [[NSNotificationCenter defaultCenter] postNotificationName:SHFetchSpotlistRequestNotificationName
                                                        object:nil
                                                      userInfo:userInfo];
}

+ (void)displayDrink:(DrinkModel *)drink {
    NSDictionary *userInfo = @{ SHDisplayDrinkNotificationKey : drink };
    [[NSNotificationCenter defaultCenter] postNotificationName:SHDisplayDrinkNotificationName
                                                        object:nil
                                                      userInfo:userInfo];
}

+ (void)displaySpot:(SpotModel *)spot {
    NSDictionary *userInfo = @{ SHDisplaySpotNotificationKey : spot };
    [[NSNotificationCenter defaultCenter] postNotificationName:SHDisplaySpotNotificationName
                                                        object:nil
                                                      userInfo:userInfo];
}

+ (void)pushToDrink:(DrinkModel *)drink {
    NSDictionary *userInfo = @{ SHPushToDrinkNotificationKey : drink };
    [[NSNotificationCenter defaultCenter] postNotificationName:SHPushToDrinkNotificationName
                                                        object:nil
                                                      userInfo:userInfo];
}

+ (void)pushToSpot:(SpotModel *)spot {
    NSDictionary *userInfo = @{ SHPushToSpotNotificationKey : spot };
    [[NSNotificationCenter defaultCenter] postNotificationName:SHPushToSpotNotificationName
                                                        object:nil
                                                      userInfo:userInfo];
}

+ (void)findSimilarToDrink:(DrinkModel *)drink {
    NSDictionary *userInfo = @{ SHFindSimilarToDrinkNotificationKey : drink };
    [[NSNotificationCenter defaultCenter] postNotificationName:SHFindSimilarToDrinkNotificationName
                                                        object:nil
                                                      userInfo:userInfo];
}

+ (void)reviewDrink:(DrinkModel *)drink {
    NSDictionary *userInfo = drink ? @{ SHReviewDrinkNotificationKey : drink} : @{};
    [[NSNotificationCenter defaultCenter] postNotificationName:SHReviewDrinkNotificationName
                                                        object:nil
                                                      userInfo:userInfo];
}

+ (void)findSimilarToSpot:(SpotModel *)spot {
    NSDictionary *userInfo = @{ SHFindSimilarToSpotNotificationKey : spot };
    [[NSNotificationCenter defaultCenter] postNotificationName:SHFindSimilarToSpotNotificationName
                                                        object:nil
                                                      userInfo:userInfo];
}

+ (void)reviewSpot:(SpotModel *)spot {
    NSDictionary *userInfo = spot ? @{ SHReviewSpotNotificationKey : spot} : @{};
    [[NSNotificationCenter defaultCenter] postNotificationName:SHReviewSpotNotificationName
                                                        object:nil
                                                      userInfo:userInfo];
}

+ (void)openMenuForSpot:(SpotModel *)spot {
    NSDictionary *userInfo = @{ SHOpenMenuForSpotNotificationKey : spot };
    [[NSNotificationCenter defaultCenter] postNotificationName:SHOpenMenuForSpotNotificationName
                                                        object:nil
                                                      userInfo:userInfo];
}

+ (void)showPhotosForSpot:(SpotModel *)spot {
    NSDictionary *userInfo = @{ SHShowSpotPhotosNotificationKey : spot };
    [[NSNotificationCenter defaultCenter] postNotificationName:SHShowSpotPhotosNotificationName
                                                        object:nil
                                                      userInfo:userInfo];
}

+ (void)showPhotosForDrink:(DrinkModel *)drink {
    NSDictionary *userInfo = @{ SHShowDrinkPhotosNotificationKey : drink };
    [[NSNotificationCenter defaultCenter] postNotificationName:SHShowDrinkPhotosNotificationName
                                                        object:nil
                                                      userInfo:userInfo];
}

+ (void)showPhoto:(ImageModel *)image {
    NSDictionary *userInfo = @{ SHShowPhotoNotificationKey : image };
    [[NSNotificationCenter defaultCenter] postNotificationName:SHShowPhotoNotificationName
                                                        object:nil
                                                      userInfo:userInfo];
}

+ (void)userDidLogIn {
    [[NSNotificationCenter defaultCenter] postNotificationName:SHUserDidLogInNotificationName
                                                        object:nil
                                                      userInfo:nil];
}

+ (void)userDidLogOut {
    [[NSNotificationCenter defaultCenter] postNotificationName:SHUserDidLogOutNotificationName
                                                        object:nil
                                                      userInfo:nil];
}

+ (void)shareSpecial:(SpecialModel *)special atSpot:(SpotModel *)spot {
    NSAssert(special, @"Parameter is required");
    NSAssert(spot, @"Parameter is required");
    
    if (!special || !spot) {
        // do nothing (this condition should not happen normally)
        return;
    }
    
    NSDictionary *userInfo = @{SHAppSpecialNotificationKey : special, SHAppSpotNotificationKey : spot};
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SHAppShareNotificationName
                                                        object:nil
                                                      userInfo:userInfo];
}

+ (void)shareSpot:(SpotModel *)spot {
    NSAssert(spot, @"Parameter is required");
    
    if (!spot) {
        // do nothing (this condition should not happen normally)
        return;
    }
    
    NSDictionary *userInfo = @{SHAppSpotNotificationKey : spot};
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SHAppShareNotificationName
                                                        object:nil
                                                      userInfo:userInfo];
}

+ (void)shareDrink:(DrinkModel *)drink {
    NSAssert(drink, @"Parameter is required");
    
    if (!drink) {
        // do nothing (this condition should not happen normally)
        return;
    }
    
    NSDictionary *userInfo = @{SHAppDrinkNotificationKey : drink};
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SHAppShareNotificationName
                                                        object:nil
                                                      userInfo:userInfo];
}

+ (void)shareCheckin:(CheckInModel *)checkin {
    NSAssert(checkin, @"Parameter is required");
    
    if (!checkin) {
        // do nothing (this condition should not happen normally)
        return;
    }
    NSDictionary *userInfo = @{SHAppCheckinNotificationKey : checkin};
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SHAppShareNotificationName
                                                        object:nil
                                                      userInfo:userInfo];
}

#pragma mark - Push Notifications
#pragma mark -

+ (void)showSpecialsAtLocation:(CLLocation *)location withRadius:(CLLocationDegrees)radius {
    if (!location || !radius) {
        return;
    }
    
    NSDictionary *userInfo = @{
                               SHAppShowSpecialsNotificationLocationKey : location,
                               SHAppShowSpecialsNotificationRadiusKey : [NSNumber numberWithDouble:radius]
                               };
    [[NSNotificationCenter defaultCenter] postNotificationName:SHAppShowSpecialsNotificationName
                                                        object:nil
                                                      userInfo:userInfo];
}

+ (void)showSpotlist:(SpotListModel *)spotlist atLocation:(CLLocation *)location withRadius:(CLLocationDegrees)radius {
    if (!spotlist || !location || !radius) {
        return;
    }
    
    NSDictionary *userInfo = @{
                               SHAppShowSpotlistNotificationSpotlistKey : spotlist,
                               SHAppShowSpotlistNotificationLocationKey : location,
                               SHAppShowSpotlistNotificationRadiusKey : [NSNumber numberWithDouble:radius]
                               };
    [[NSNotificationCenter defaultCenter] postNotificationName:SHAppShowSpotlistNotificationName
                                                        object:nil
                                                      userInfo:userInfo];
}

+ (void)showDrinklist:(DrinkListModel *)drinklist atLocation:(CLLocation *)location withRadius:(CLLocationDegrees)radius {
    if (!drinklist || !location || !radius) {
        return;
    }
    
    NSDictionary *userInfo = @{
                               SHAppShowDrinklistNotificationDrinklistKey : drinklist,
                               SHAppShowDrinklistNotificationLocationKey : location,
                               SHAppShowDrinklistNotificationRadiusKey : [NSNumber numberWithDouble:radius]
                               };
    [[NSNotificationCenter defaultCenter] postNotificationName:SHAppShowDrinklistNotificationName
                                                        object:nil
                                                      userInfo:userInfo];
}

#pragma mark - Local Notifications
#pragma mark -

+ (void)promptForCheckIn:(NSDictionary *)userInfo {
    [[NSNotificationCenter defaultCenter] postNotificationName:SHPromptForCheckInNotificationName object:userInfo];
}

#pragma mark - Location
#pragma mark -

+ (void)locationChanged {
    [[NSNotificationCenter defaultCenter] postNotificationName:SHLocationChangedNotificationName object:nil];
}

#pragma mark - Diagnostics
#pragma mark -

+ (void)displayDiagnostics {
    [[NSNotificationCenter defaultCenter] postNotificationName:SHDisplayDiagnosticsNotificationName object:nil];
}


@end
