//
//  SpotTypeModel.m
//  SpotHopper
//
//  Created by Josh Holtz on 2/20/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "SpotTypeModel.h"

@implementation SpotTypeModel

#pragma mark -

- (NSDictionary *)mapKeysToProperties {
    // Maps values in JSON key 'name' to 'name' property
    // Maps values in JSON key 'created_at' to 'createdAt' property
    // Maps values in JSON key 'updated_at' to 'updatedAt' property
    return @{
             @"name" : @"name"
             };
    
}

#pragma mark - Debugging

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ - %@ [%@]", self.ID, self.name, NSStringFromClass([self class])];
}

- (NSDate *)createdAt {
    if (!_createdAt) {
        _createdAt = [self formatDateTimestamp:[self objectForKey:@"created_at"]];
    }
    return _createdAt;
}

- (NSDate *)updatedAt {
    return [self formatDateTimestamp:[self objectForKey:@"updated_at"]];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
	SpotTypeModel *copy = [[[self class] alloc] init];
    
    copy.ID = self.ID;
    copy.name = self.name;
    copy.createdAt = self.createdAt;
    copy.updateAt = self.updateAt;
    
    return copy;
}

@end
