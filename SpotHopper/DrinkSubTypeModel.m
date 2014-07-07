//
//  DrinkSubTypeModel.m
//  SpotHopper
//
//  Created by Josh Holtz on 3/14/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "DrinkSubTypeModel.h"

@implementation DrinkSubTypeModel

#pragma mark - Debugging

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ - %@ [%@]", self.ID, self.name, NSStringFromClass([self class])];
}

- (id)debugQuickLookObject {
    return self.name;
}

#pragma mark -

- (NSDictionary *)mapKeysToProperties {
    // Maps linked resource in JSON key 'name' to 'name' property
    return @{
             @"name" : @"name",
             @"createdAt" : @"createdAt",
             @"updatedAt" : @"updatedAt"
             };
}

// TODO: test that values are being mapped

#pragma mark - Getters

//- (NSString *)name {
//    return [self objectForKey:@"name"];
//}
//
//- (NSDate *)createdAt {
//    return [self formatDateTimestamp:[self objectForKey:@"created_at"]];
//}
//
//- (NSDate *)updatedAt {
//    return [self formatDateTimestamp:[self objectForKey:@"updated_at"]];
//}

#pragma mark - DrinkSubTypeModel

- (id)copyWithZone:(NSZone *)zone {
	DrinkSubTypeModel *copy = [[[self class] alloc] init];
    
    copy.name = self.name;
    copy.createdAt = self.createdAt;
    copy.updateAt = self.updateAt;
    
    return copy;
}


@end
