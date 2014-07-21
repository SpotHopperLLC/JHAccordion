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

NSString * const SHFindSimilarToDrinkNotificationName = @"SHFindSimilarToDrinkNotificationName";
NSString * const SHFindSimilarToDrinkNotificationKey = @"SHFindSimilarToDrinkNotificationKey";

NSString * const SHFindSimilarToSpotNotificationName = @"SHFindSimilarToSpotNotificationName";
NSString * const SHFindSimilarToSpotNotificationKey = @"SHFindSimilarToSpotNotificationKey";

NSString * const SHUserDidLogInNotificationKey = @"SHUserDidLogInNotificationKey";
NSString * const SHUserDidLogOutNotificationKey = @"SHUserDidLogOutNotificationKey";

@implementation SHNotifications

+ (void)goToHomeMap {
    [[NSNotificationCenter defaultCenter] postNotificationName:SHGoToHomeMapNotificationName object:nil];
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

+ (void)findSimilarToDrink:(DrinkModel *)drink {
    NSDictionary *userInfo = @{ SHFindSimilarToDrinkNotificationKey : drink };
    [[NSNotificationCenter defaultCenter] postNotificationName:SHFindSimilarToDrinkNotificationName
                                                        object:nil
                                                      userInfo:userInfo];
}

+ (void)findSimilarToSpot:(SpotModel *)spot {
    NSDictionary *userInfo = @{ SHFindSimilarToSpotNotificationKey : spot };
    [[NSNotificationCenter defaultCenter] postNotificationName:SHFindSimilarToSpotNotificationName
                                                        object:nil
                                                      userInfo:userInfo];
}

+ (void)userDidLoginIn {
    [[NSNotificationCenter defaultCenter] postNotificationName:SHUserDidLogInNotificationKey
                                                        object:nil
                                                      userInfo:nil];
}

+ (void)userDidLoginOut {
    [[NSNotificationCenter defaultCenter] postNotificationName:SHUserDidLogOutNotificationKey
                                                        object:nil
                                                      userInfo:nil];
}

@end