//
//  Tracker.m
//  SpotHopper
//
//  Created by Brennan Stehling on 4/15/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "Tracker.h"

#import "Mixpanel.h"

@implementation Tracker

+ (void)track:(NSString *)event {
    if (kAnalyticsEnabled) {
        [[Mixpanel sharedInstance] track:event];
    }
}

+ (void)track:(NSString *)event properties:(NSDictionary *)properties {
    if (kAnalyticsEnabled) {
        [[Mixpanel sharedInstance] track:event properties:properties];
    }
}

@end
