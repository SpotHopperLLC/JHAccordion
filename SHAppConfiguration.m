//
//  SHAppConfiguration.m
//  SpotHopper
//
//  Created by Brennan Stehling on 8/14/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "SHAppConfiguration.h"

@implementation SHAppConfiguration

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

@end
