//
//  SHAppConfiguration.h
//  SpotHopper
//
//  Created by Brennan Stehling on 8/14/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SHAppConfiguration : NSObject

+ (BOOL)isDebuggingEnabled;

+ (BOOL)isTrackingEnabled;

+ (NSString *)mixpanelToken;

+ (NSString *)bitlyUsername;

+ (NSString *)bitlyAPIKey;

+ (NSString *)bitlyShortURL;

+ (NSString *)twitterConsumerKey;

+ (NSString *)twitterConsumerSecret;

+ (NSString *)appURLScheme;

+ (NSString *)baseUrl;

+ (NSString *)websiteUrl;

+ (NSString *)parseApplicationID;

+ (NSString *)parseClientKey;

@end
