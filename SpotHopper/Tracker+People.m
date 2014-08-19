//
//  Tracker+People.m
//  SpotHopper
//
//  Created by Brennan Stehling on 8/15/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "Tracker+People.h"

#import "SHAppConfiguration.h"
#import "Mixpanel.h"
#import "ClientSessionManager.h"

@implementation Tracker (People)

+ (void)trackUserFirstUse {
    [self trackUserAction:@"User First Use"];
}

+ (void)trackUserViewedHome {
    [self trackUserAction:@"User Viewed Home"];
}

@end
