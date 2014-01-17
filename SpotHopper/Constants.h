//
//  Constants.h
//  SpotHopper
//
//  Created by Josh Holtz on 12/26/13.
//  Copyright (c) 2013 RokkinCat. All rights reserved.
//

#ifndef SpotHopper_Constants_h
#define SpotHopper_Constants_h

#define kEnvEnableDev TRUE
//#define kEnvEnableProd TRUE

#if kEnvEnableDev

    #define kDebug TRUE
    #define kMock FALSE
    #if kMock
        #define kBaseUrl @"mockery://app"
    #else
//        #define kBaseUrl @"http://192.168.1.8:9292"
        #define kBaseUrl @"http://spothopper-dev.herokuapp.com"
    #endif

    #define kTwitterConsumerKey @"FeB6rg5yUFu7aL9InVmxQ"
    #define kTwitterConsumerSecret @"diroak8ksZoZu1BMA5U6lp5WBgJWAAGkoJsYGnjGwrI"

#elif kEnvEnableProd

    #define kDebug FALSE

    #define kBaseUrl @"https://"

    #define kTwitterConsumerKey @""
    #define kTwitterConsumerSecret @""

#endif

#define kColorOrange [UIColor colorWithRed:(221.0f/255.0f) green:(106.0f/255.0f) blue:(51.0f/255.0f) alpha:1.0f]
#define kColorOrangeLight [UIColor colorWithRed:(238.0f/255.0f) green:(160.0f/255.0f) blue:(109.0f/255.0f) alpha:1.0f]

#define kSentryDSN @"https://6e7d0ff70d3e4f05a2ae8c53f70c55b1:8bdf476db4344ddaad89108cbd871562@app.getsentry.com/17343"

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#endif
