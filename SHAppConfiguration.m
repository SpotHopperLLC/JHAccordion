//
//  SHAppConfiguration.m
//  SpotHopper
//
//  Created by Brennan Stehling on 8/14/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "SHAppConfiguration.h"

@implementation SHAppConfiguration

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

+ (NSString *)bitlyShortURL {
    return [[NSBundle mainBundle] infoDictionary][@"SpotHopperSettings"][@"BitlyShortURL"];
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

+ (NSString *)parseApplicationID {
    return [[NSBundle mainBundle] infoDictionary][@"SpotHopperSettings"][@"ParseApplicationID"];
}

+ (NSString *)parseClientKey {
    return [[NSBundle mainBundle] infoDictionary][@"SpotHopperSettings"][@"ParseClientKey"];
}

@end
