//
//  SHAppConfiguration.h
//  SpotHopper
//
//  Created by Brennan Stehling on 8/14/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import <Foundation/Foundation.h>

// Note: The following ID values are from the database which are PKs which are auto-incremented
// These values will not change. The Staging and Dev copies of the datbase are made from
// backup copies of the Production system. Going toward these important values should be scripted
// to be known values when the database is created, meaning auto-incrementing must be disabled
// while the database records are created.

#define kBeerEmphasisSliderID @19
#define kWineEmphasisSliderID @20
#define kCocktailEmphasisSliderID @21

#define kBeerDrinkTypeID @1
#define kWineDrinkTypeID @2
#define kCocktailDrinkTypeID @3

@interface SHAppConfiguration : NSObject

+ (NSString *)configuration;

+ (BOOL)isProduction;

+ (BOOL)isStaging;

+ (BOOL)isDebuggingEnabled;

+ (BOOL)isTrackingEnabled;

+ (NSString *)mixpanelToken;

+ (NSString *)bitlyUsername;

+ (NSString *)bitlyAPIKey;

+ (NSString *)bitlyAccessToken;

+ (NSString *)bitlyShortURL;

+ (NSString *)transloaditAPIKey;

+ (NSString *)transloaditSpotsTemplate;

+ (NSString *)transloaditDrinksTemplate;

+ (NSString *)transloaditUsersTemplate;

+ (NSString *)transloaditSpecialsTemplate;

+ (NSString *)twitterConsumerKey;

+ (NSString *)twitterConsumerSecret;

+ (NSString *)appURLScheme;

+ (NSString *)baseUrl;

+ (NSString *)websiteUrl;

+ (NSString *)parseApplicationID;

+ (NSString *)parseClientKey;

+ (BOOL)isCrashlyticsEnabled;

+ (NSString *)crashlyticsKey;

@end
