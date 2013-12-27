//
//  Constants.h
//  SpotHopper
//
//  Created by Josh Holtz on 12/26/13.
//  Copyright (c) 2013 RokkinCat. All rights reserved.
//

#ifndef SpotHopper_Constants_h
#define SpotHopper_Constants_h

//#define kEnvEnableTest TRUE
#define kEnvEnableProd TRUE

#if kEnvEnableTest

    #define kDebug TRUE

    #define kBaseUrl @"https://"

    #define kTwitterConsumerKey @"FeB6rg5yUFu7aL9InVmxQ"
    #define kTwitterConsumerSecret @"diroak8ksZoZu1BMA5U6lp5WBgJWAAGkoJsYGnjGwrI"

#elif kEnvEnableProd

    #define kDebug FALSE

    #define kBaseUrl @"https://"

    #define kTwitterConsumerKey @""
    #define kTwitterConsumerSecret @""

#endif

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#endif
