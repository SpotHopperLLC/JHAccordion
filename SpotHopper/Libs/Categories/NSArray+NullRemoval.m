//
//  NSArray+NullRemoval.m
//  SpotHopper
//
//  Created by Josh Holtz on 1/23/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "NSArray+NullRemoval.h"

#import "NSDictionary+NullRemoval.h"

@implementation NSArray (NullRemoval)

- (NSArray *)arrayByRemovingNulls  {
    NSMutableArray *replaced = [self mutableCopy];
    const id nul = [NSNull null];
    for (int idx = 0; idx < [replaced count]; idx++) {
        id object = [replaced objectAtIndex:idx];
        if ([object isKindOfClass:[NSDictionary class]]) [replaced replaceObjectAtIndex:idx withObject:[object dictionaryByRemovingNulls]];
        else if ([object isKindOfClass:[NSArray class]]) [replaced replaceObjectAtIndex:idx withObject:[object arrayByRemovingNulls]];
    }
    [replaced enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
        if (object == nul) [replaced removeObjectAtIndex:idx];
    }];
    
    return [replaced copy];
}


@end
