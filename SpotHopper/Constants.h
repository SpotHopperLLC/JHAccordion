//
//  Constants.h
//  SpotHopper
//
//  Created by Josh Holtz on 12/26/13.
//  Copyright (c) 2013 RokkinCat. All rights reserved.
//

#ifndef SpotHopper_Constants_h
#define SpotHopper_Constants_h

#ifdef LOCAL

    #define kDebug YES

    #define kTwitterConsumerKey @"FeB6rg5yUFu7aL9InVmxQ"
    #define kTwitterConsumerSecret @"diroak8ksZoZu1BMA5U6lp5WBgJWAAGkoJsYGnjGwrI"

//    #define kBaseUrl @"http://192.168.1.123:9292"
    #define kBaseUrl @"http://192.168.1.2:9292"
//    #define kBaseUrl @"http://192.168.1.110:9292"

    #define kRefreshLocationTime 60.0f

    #define kAnalyticsEnabled   FALSE

#elif defined(DEV)

    #define kDebug YES

    #define kTwitterConsumerKey @"fIx6bzfnIohTiQuqOvHqaw"
    #define kTwitterConsumerSecret @"TT0nyrGy2xdpfWiBMrkGKoFjjiNhJW4atoInhlv7I"

    #define kBaseUrl @"http://spothopper-dev.herokuapp.com"

    #define kRefreshLocationTime 60.0f

    #define kAnalyticsEnabled   FALSE

#elif defined(STAGING)

    #define kDebug YES

    #define kTwitterConsumerKey @"enlXFrFlBlOPkaBoOJunQ"
    #define kTwitterConsumerSecret @"UHRcQ8WXs13Iug7VpliivDxwQuGtoMg5KsaoIF3jWbM"

    #define kBaseUrl @"http://spothopper-staging.herokuapp.com"

    #define kRefreshLocationTime 3600.0f

    // Temporarily turn on analytics while testing
    #define kAnalyticsEnabled   TRUE

#elif defined(PRODUCTION)

    #define kDebug YES

    #define kTwitterConsumerKey @"FeB6rg5yUFu7aL9InVmxQ"
    #define kTwitterConsumerSecret @"diroak8ksZoZu1BMA5U6lp5WBgJWAAGkoJsYGnjGwrI"

    // MUST BE SSL
    #define kBaseUrl @"http://spothopper.herokuapp.com"

    #define kRefreshLocationTime 3600.0f

    #define kAnalyticsEnabled   TRUE

#endif

// Mixpanel - https://mixpanel.com/help/reference/ios

#define kMixPanelToken @"b7cdce62dcc827c0955766058d7696c4"

// Google Analytics - https://developers.google.com/analytics/devguides/collection/ios/v3/

#define kGoogleAnalyticsTrackingId @"UA-49583937-2"

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

// Service configurations
#define kSentryDSN @"https://6e7d0ff70d3e4f05a2ae8c53f70c55b1:8bdf476db4344ddaad89108cbd871562@app.getsentry.com/17343"

#define IS_FOUR_INCH  (([[UIScreen mainScreen] bounds].size.height == 568)?YES:NO)

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#endif
