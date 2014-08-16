//
//  Tracker+People.h
//  SpotHopper
//
//  Created by Brennan Stehling on 8/15/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "Tracker.h"

#import "UserModel.h"

@interface Tracker (People)

+ (void)trackUserFirstUse;

+ (void)trackUserViewedHome;

@end
