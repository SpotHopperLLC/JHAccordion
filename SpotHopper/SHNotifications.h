//
//  SHNotifications.h
//  SpotHopper
//
//  Created by Brennan Stehling on 7/11/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "DrinkListRequest.h"
#import "SpotListRequest.h"
#import "DrinkModel.h"
#import "SpotModel.h"

extern NSString * const SHGoToHomeMapNotificationName;

extern NSString * const SHFetchDrinklistRequestNotificationName;
extern NSString * const SHFetchDrinklistRequestNotificationKey;

extern NSString * const SHFetchSpotlistRequestNotificationName;
extern NSString * const SHFetchSpotlistRequestNotificationKey;

extern NSString * const SHDisplayDrinkNotificationName;
extern NSString * const SHDisplayDrinkNotificationKey;

extern NSString * const SHDisplaySpotNotificationName;
extern NSString * const SHDisplaySpotNotificationKey;

extern NSString * const SHPushToDrinkNotificationName;
extern NSString * const SHPushToDrinkNotificationKey;

extern NSString * const SHPushToSpotNotificationName;
extern NSString * const SHPushToSpotNotificationKey;

extern NSString * const SHFindSimilarToDrinkNotificationName;
extern NSString * const SHFindSimilarToDrinkNotificationKey;

extern NSString * const SHReviewDrinkNotificationName;
extern NSString * const SHReviewDrinkNotificationKey;

extern NSString * const SHFindSimilarToSpotNotificationName;
extern NSString * const SHFindSimilarToSpotNotificationKey;

extern NSString * const SHReviewSpotNotificationName;
extern NSString * const SHReviewSpotNotificationKey;

extern NSString * const SHShowSpotPhotosNotificationName;
extern NSString * const SHShowSpotPhotosNotificationKey;

extern NSString * const SHShowDrinkPhotosNotificationName;
extern NSString * const SHShowDrinkPhotosNotificationKey;

extern NSString * const SHOpenMenuForSpotNotificationName;
extern NSString * const SHOpenMenuForSpotNotificationKey;

extern NSString * const SHUserDidLogInNotificationName;
extern NSString * const SHUserDidLogOutNotificationName;

extern NSString * const SHAppOpenedWithURLNotificationName;
extern NSString * const SHAppOpenedWithURLNotificationKey;

@interface SHNotifications : NSObject

+ (void)goToHomeMap;

+ (void)appOpenedWithURL:(NSURL *)url;

+ (void)fetchDrinklistWithRequest:(DrinkListRequest *)request;

+ (void)fetchSpotlistWithRequest:(SpotListRequest *)request;

+ (void)displayDrink:(DrinkModel *)drink;

+ (void)displaySpot:(SpotModel *)spot;

+ (void)pushToDrink:(DrinkModel *)drink;

+ (void)pushToSpot:(SpotModel *)spot;

+ (void)findSimilarToDrink:(DrinkModel *)drink;

+ (void)reviewDrink:(DrinkModel *)drink;

+ (void)findSimilarToSpot:(SpotModel *)spot;

+ (void)reviewSpot:(SpotModel *)spot;

+ (void)openMenuForSpot:(SpotModel *)spot;

+ (void)showPhotosForSpot:(SpotModel *)spot;

+ (void)showPhotosForDrink:(DrinkModel *)drink;

+ (void)userDidLoginIn;

+ (void)userDidLoginOut;

@end
