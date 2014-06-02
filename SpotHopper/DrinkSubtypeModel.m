//
//  DrinkSubtypeModel.m
//  SpotHopper
//
//  Created by Josh Holtz on 3/14/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "DrinkSubtypeModel.h"

@implementation DrinkSubtypeModel

#pragma mark - Debugging

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ - %@ [%@]", self.ID, self.name, NSStringFromClass([self class])];
}

- (id)debugQuickLookObject {
    return self.name;
}

#pragma mark - Getters

- (NSString *)name {
    return [self objectForKey:@"name"];
}

- (NSDate *)createdAt {
    return [self formatDateTimestamp:[self objectForKey:@"created_at"]];
}

- (NSDate *)updatedAt {
    return [self formatDateTimestamp:[self objectForKey:@"updated_at"]];
}

@end
