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

NSString * const SHOpenMenuForSpotNotificationName = @"SHOpenMenuForSpotNotificationName";
NSString * const SHOpenMenuForSpotNotificationKey = @"SHOpenMenuForSpotNotificationKey";

NSString * const SHUserDidLogInNotificationName = @"SHUserDidLogInNotificationName";
NSString * const SHUserDidLogOutNotificationName = @"SHUserDidLogOutNotificationName";

NSString * const SHAppOpenedWithURLNotificationName = @"SHAppOpenedWithURLNotificationName";
NSString * const SHAppOpenedWithURLNotificationKey = @"SHAppOpenedWithURLNotificationKey";

@implementation SHNotifications

+ (void)goToHomeMap {
    [[NSNotificationCenter defaultCenter] postNotificationName:SHGoToHomeMapNotificationName object:nil];
}

+ (void)appOpenedWithURL:(NSURL *)url {
    NSDictionary *userInfo = @{ SHAppOpenedWithURLNotificationKey : url };
    DebugLog(@"userInfo: %@", userInfo);
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
    NSDictionary *userInfo = @{ SHReviewDrinkNotificationKey : drink };
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
    NSDictionary *userInfo = @{ SHReviewSpotNotificationKey : spot };
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

+ (void)userDidLoginIn {
    [[NSNotificationCenter defaultCenter] postNotificationName:SHUserDidLogInNotificationName
                                                        object:nil
                                                      userInfo:nil];
}

+ (void)userDidLoginOut {
    [[NSNotificationCenter defaultCenter] postNotificationName:SHUserDidLogOutNotificationName
                                                        object:nil
                                                      userInfo:nil];
}

@end
