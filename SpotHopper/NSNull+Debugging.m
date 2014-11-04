//
//  NSNull+Debugging.m
//  SpotHopper
//
//  Created by Brennan Stehling on 4/14/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "NSNull+Debugging.h"

#import "Tracker.h"

@implementation NSNull (Debugging)

- (NSUInteger)count {
    NSString *caller = [[NSThread callStackSymbols] objectAtIndex:1];
    NSString *message = [NSString stringWithFormat:@"NSNull issue - %@ - %@ - %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), caller];
    [Tracker logError:message class:[self class] trace:NSStringFromSelector(_cmd)];
    
    DebugLog(@"%@ - %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    return 0;
}

- (NSUInteger)length {
    NSString *caller = [[NSThread callStackSymbols] objectAtIndex:1];
    NSString *message = [NSString stringWithFormat:@"NSNull issue - %@ - %@ - %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), caller];
    [Tracker logError:message class:[self class] trace:NSStringFromSelector(_cmd)];
    
    DebugLog(@"%@ - %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    return 0;
}

@end
