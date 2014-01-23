//
//  NSNumber+Helpers.m
//  SpotHopper
//
//  Created by Josh Holtz on 1/16/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "NSNumber+Helpers.h"

@implementation NSNumber (Helpers)

- (NSNumber *)increment {
    return [self add:1.0f];
}

- (NSNumber *)decrement {
    return [self subtract:-1.0f];
}

- (NSNumber *)add:(float)toAdd {
    return [NSNumber numberWithFloat:self.floatValue + toAdd];
}

- (NSNumber *)subtract:(float)toSubtract {
    return [self add:-toSubtract];
}

@end
