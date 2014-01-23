//
//  NSDictionary+NullRemoval.m
//  SpotHopper
//
//  Created by Josh Holtz on 1/23/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "NSDictionary+NullRemoval.h"

#import "NSArray+NullRemoval.h"

@implementation NSDictionary (NullRemoval)

- (NSDictionary *)dictionaryByRemovingNulls {
    const NSMutableDictionary *replaced = [self mutableCopy];
    const id nul = [NSNull null];
    for (NSString *key in self) {
        NSLog(@"Checking for null for %@", key);
        id object = [self objectForKey:key];
        if (object == nul) {
            NSLog(@"Removing null for %@", key);
            [replaced removeObjectForKey:key];
        }
        else if ([object isKindOfClass:[NSDictionary class]]) [replaced setObject:[object dictionaryByRemovingNulls] forKey:key];
        else if ([object isKindOfClass:[NSArray class]]) [replaced setObject:[object arrayByRemovingNulls] forKey:key];
    }
    return [NSDictionary dictionaryWithDictionary:[replaced copy]];
}

@end
