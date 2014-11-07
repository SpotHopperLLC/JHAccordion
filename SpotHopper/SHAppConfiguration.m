//
//  SHAppConfiguration.m
//  SpotHopper
//
//  Created by Brennan Stehling on 8/14/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "SHAppConfiguration.h"

@implementation SHAppConfiguration

+ (NSString *)bundleIdentifier {
    return [[NSBundle mainBundle] infoDictionary][@"CFBundleIdentifier"];
}

+ (NSString *)bundleDisplayName {
    return [[NSBundle mainBundle] infoDictionary][@"CFBundleDisplayName"];
}

+ (NSString *)configuration {
    return [[NSBundle mainBundle] infoDictionary][@"SpotHopperSettings"][@"Configuration"];
}

+ (BOOL)isProduction {
    return[@"Production" caseInsensitiveCompare:[self configuration]] == NSOrderedSame;
}

+ (BOOL)isStaging {
    return[@"Staging" caseInsensitiveCompare:[self configuration]] == NSOrderedSame;
}

+ (BOOL)isDebuggingEnabled {
    return [[[NSBundle mainBundle] infoDictionary][@"SpotHopperSettings"][@"Debug"] boolValue];
}

+ (BOOL)isTrackingEnabled {
    return [[[NSBundle mainBundle] infoDictionary][@"SpotHopperSettings"][@"TrackingEnabled"] boolValue];
}

+ (NSString *)mixpanelToken {
    return [[NSBundle mainBundle] infoDictionary][@"SpotHopperSettings"][@"MixpanelToken"];
}

+ (NSString *)bitlyUsername {
    return [[NSBundle mainBundle] infoDictionary][@"SpotHopperSettings"][@"BitlyUsername"];
}

+ (NSString *)bitlyAPIKey {
    return [[NSBundle mainBundle] infoDictionary][@"SpotHopperSettings"][@"BitlyAPIKey"];
}

+ (NSString *)bitlyAccessToken {
    return [[NSBundle mainBundle] infoDictionary][@"SpotHopperSettings"][@"BitlyAccessToken"];
}

+ (NSString *)bitlyShortURL {
    return [[NSBundle mainBundle] infoDictionary][@"SpotHopperSettings"][@"BitlyShortURL"];
}

+ (NSString *)transloaditAPIKey {
    return [[NSBundle mainBundle] infoDictionary][@"SpotHopperSettings"][@"TransloaditAPIKey"];
}

+ (NSString *)transloaditSpotsTemplate {
    return [[NSBundle mainBundle] infoDictionary][@"SpotHopperSettings"][@"TransloaditSpotsTemplate"];
}

+ (NSString *)transloaditDrinksTemplate {
    return [[NSBundle mainBundle] infoDictionary][@"SpotHopperSettings"][@"TransloaditDrinksTemplate"];
}

+ (NSString *)transloaditUsersTemplate {
    return [[NSBundle mainBundle] infoDictionary][@"SpotHopperSettings"][@"TransloaditUsersTemplate"];
}

+ (NSString *)transloaditSpecialsTemplate {
    return [[NSBundle mainBundle] infoDictionary][@"SpotHopperSettings"][@"TransloaditSpecialsTemplate"];
}

+ (NSString *)twitterConsumerKey {
    return [[NSBundle mainBundle] infoDictionary][@"SpotHopperSettings"][@"TwitterConsumerKey"];
}

+ (NSString *)twitterConsumerSecret {
    return [[NSBundle mainBundle] infoDictionary][@"SpotHopperSettings"][@"TwitterConsumerSecret"];
}

+ (NSString *)appURLScheme {
    return [[NSBundle mainBundle] infoDictionary][@"SpotHopperSettings"][@"AppURLScheme"];
}

+ (NSString *)baseUrl {
    return [[NSBundle mainBundle] infoDictionary][@"SpotHopperSettings"][@"BaseUrl"];
}

+ (NSString *)websiteUrl {
    return [[NSBundle mainBundle] infoDictionary][@"SpotHopperSettings"][@"WebsiteUrl"];
}

+ (BOOL)isParseEnabled {
    return [[self parseApplicationID] length] > 0;
}

+ (NSString *)parseApplicationID {
    return [[NSBundle mainBundle] infoDictionary][@"SpotHopperSettings"][@"ParseApplicationID"];
}

+ (NSString *)parseClientKey {
    return [[NSBundle mainBundle] infoDictionary][@"SpotHopperSettings"][@"ParseClientKey"];
}

+ (BOOL)isCrashlyticsEnabled {
    return self.crashlyticsKey.length;
}

+ (NSString *)crashlyticsKey {
    return [[NSBundle mainBundle] infoDictionary][@"SpotHopperSettings"][@"CrashlyticsKey"];
}

@end
