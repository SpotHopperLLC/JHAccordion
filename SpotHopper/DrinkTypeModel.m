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
    return @{
             @"name" : @"name",
             @"createdAt" : @"createdAt",
             @"updatedAt" : @"updatedAt"
             };
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
	DrinkTypeModel *copy = [[[self class] alloc] init];
    
    copy.name = self.name;
    copy.createdAt = self.createdAt;
    copy.updateAt = self.updateAt;
    
    copy.subtypes = self.subtypes;
    
    return copy;
}

@end
