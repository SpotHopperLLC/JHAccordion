//
//  Constants.h
//  SpotHopper
//
//  Created by Josh Holtz on 12/26/13.
//  Copyright (c) 2013 RokkinCat. All rights reserved.
//

#ifndef SpotHopper_Constants_h
#define SpotHopper_Constants_h

#define kSpotHopperIconURL @"http://static.spotapps.co/spothopper-icon.png"
#define kSpotHopperTagline @"SpotHopper is a local search engine, built to answer \"where should I go?\" and \"what drink will I love?\""

#define kNotificationPushReceived @"push_notification_received"
#define kUrlPushReceived @"url_received"

// InfoText
#define kInfoSpotList @"Want to find matches somewhere else? Change the location in the subheader!"
#define kInfoSpotProfile @"Like this spot? Click \"Find Similar\" to search for similar spots wherever you want!"
#define kInfoDrinklistNearby @"Wrong spot? Try clicking \"I'm at a different spot\". If that still fails, yell at the bar owner and tell 'em to sign up already!"
#define kInfoDrinklist @"Here are all the best matching drinks available near you. Click \"Find It\" or change the location in the header"
#define kInfoDrinkAt @"Want to find this item somewhere else? Change the location in the header!"
#define kInfoDrinkProfile @"Like this drink? Click \"Find Similar\" to search for similar drinks nearby!"
#define kInfoMenu @"Looking for a personalized check-in drinklist instead? Go to the Home Screen then Drinks > Check-In"
#define kInfoTonightsSpecials @"These are all the specials for today near you. Change the location in the header for new results"

// Colors
#define kColorOrange [UIColor colorWithRed:(221.0f/255.0f) green:(106.0f/255.0f) blue:(51.0f/255.0f) alpha:1.0f]
#define kColorOrangeLight [UIColor colorWithRed:(238.0f/255.0f) green:(160.0f/255.0f) blue:(109.0f/255.0f) alpha:1.0f]
#define kColorOrangeDark [UIColor colorWithRed:(229.0f/255.0f) green:(134.0f/255.0f) blue:(78.0f/255.0f) alpha:1.0f]

#define kReviewTypesSpot @"Spot"
#define kReviewTypesBeer @"Beer"
#define kReviewTypesCocktail @"Cocktail"
#define kReviewTypesWine @"Wine"
#define kReviewTypes @[kReviewTypesSpot, kReviewTypesBeer, kReviewTypesCocktail, kReviewTypesWine]

#define kDrinkTypeNameBeer @"Beer"
#define kDrinkTypeNameCocktail @"Cocktail"
#define kDrinkTypeNameWine @"Wine"
#define kDrinkTypeNameLiquor @"Liquor"

#define kStateList @[@"AL",@"AK",@"AZ",@"AR",@"CA",@"CO",@"CT",@"DE",@"FL",@"GA",@"HI",@"ID",@"IL",@"IN",@"IA",@"KS",@"KY",@"LA",@"ME",@"MD",@"MA",@"MI",@"MN",@"MS",@"MO",@"MT",@"NE",@"NV",@"NH",@"NJ",@"NM",@"NY",@"NC",@"ND",@"OH",@"OK",@"OR",@"PA",@"RI",@"SC",@"SD",@"TN",@"TX",@"UT",@"VT",@"VA",@"WA",@"WV",@"WI",@"WY"]

#define kNationalMapCenterLatitude 38.8729021
#define kNationalMapCenterLongitude -96.1645192

// Service configurations
#define kSentryDSN @"https://6e7d0ff70d3e4f05a2ae8c53f70c55b1:8bdf476db4344ddaad89108cbd871562@app.getsentry.com/17343"

#define IS_FOUR_INCH  (([[UIScreen mainScreen] bounds].size.height == 568)?YES:NO)

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

#define isiOS7OrLater floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1

#define LOG_FRAME(label, frame) DebugLog(@"%@: %f, %f, %f, %f", label, frame.origin.x, frame.origin.y, frame.size.width, frame.size.height)
#define LOG_SIZE(label, size) DebugLog(@"%@, %f, %f", label, size.width, size.height)
#define LOG_POINT(label, point) DebugLog(@"%@: %f, %f", label, point.x, point.y)
#define LOG_OFFSET(label, offset) DebugLog(@"%@: %f, %f", label, offset.x, offset.y)
#define LOG_INSET(label, inset) DebugLog(@"%@: %f, %f, %f, %f", label, inset.top, inset.left, inset.bottom, inset.right)
#define LOG_INDEXPATH(label, indexPath) DebugLog(@"%@: %li, %li", label, indexPath.section, indexPath.row)
#define LOG_INDEXPATH2(label, indexPath) DebugLog(@"%@: %li, %li", label, indexPath.section, indexPath.item)

typedef enum {
    SHModeNone = 0,
    SHModeSpots,
    SHModeSpecials,
    SHModeBeer,
    SHModeCocktail,
    SHModeWine
} SHMode;

#endif
