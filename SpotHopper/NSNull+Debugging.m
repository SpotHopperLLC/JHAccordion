//
//  NSNull+Debugging.m
//  SpotHopper
//
//  Created by Brennan Stehling on 4/14/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "NSNull+Debugging.h"

@implementation NSNull (Debugging)

- (NSUInteger)count {
    NSString *message = [NSString stringWithFormat:@"NSNull issue - %@", (NSStringFromClass([self class]), NSStringFromSelector(_cmd))];
    [[RavenClient sharedClient] captureMessage:message level:kRavenLogLevelDebugError];
    
    NSLog(@"%@ - %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    return 0;
}

- (NSUInteger)length {
    NSString *message = [NSString stringWithFormat:@"NSNull issue - %@", (NSStringFromClass([self class]), NSStringFromSelector(_cmd))];
    [[RavenClient sharedClient] captureMessage:message level:kRavenLogLevelDebugError];
    
    NSLog(@"%@ - %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    return 0;
}

@end
