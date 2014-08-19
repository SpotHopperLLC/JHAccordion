//
//  DrinkTypeModel.m
//  SpotHopper
//
//  Created by Josh Holtz on 2/6/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "DrinkTypeModel.h"

@implementation DrinkTypeModel

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
    // Maps values in JSON key 'created_at' to 'Date:createdAt' property
    // Maps values in JSON key 'updated_at' to 'Date:updatedAt' property
    return @{
             @"name" : @"name",
             @"created_at" : @"Date:createdAt",
             @"updated_at" : @"Date:updatedAt"
             };
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
	DrinkTypeModel *copy = [super copyWithZone:zone];
    
    copy.name = self.name;
    copy.createdAt = self.createdAt;
    copy.updatedAt = self.updatedAt;
    
    copy.subtypes = self.subtypes;
    
    return copy;
}

@end
