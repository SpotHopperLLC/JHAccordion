//
//  SHBaseModel.m
//  SpotHopper
//
//  Created by Brennan Stehling on 11/25/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "SHBaseModel.h"

@implementation SHBaseModel

#pragma mark - Equality
#pragma mark -

- (BOOL)isEqual:(id)other {
    if (other == self) {
        return YES;
    }
    else if ([other isKindOfClass:[SHBaseModel class]]) {
        return [self isEqualToBaseModel:other];
    }
    
    return NO;
}

- (BOOL)isEqualToBaseModel:(SHBaseModel *)other {
    return [self.objectId isEqualToString:other.objectId];
}

- (NSUInteger)hash {
    return self.objectId.hash;
}

#pragma mark - NSCopying
#pragma mark -

- (id)copyWithZone:(NSZone *)zone {
    SHBaseModel *copy = [[[self class] alloc] init];
    
    copy.objectId = self.objectId;
    copy.createdAt = self.createdAt;
    copy.updatedAt = self.updatedAt;
    
    return copy;
}

#pragma mark - NSCoding
#pragma mark -

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.objectId forKey:@"objectId"];
    [aCoder encodeObject:self.createdAt forKey:@"createdAt"];
    [aCoder encodeObject:self.updatedAt forKey:@"updatedAt"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    
    self.objectId = [aDecoder decodeObjectForKey:@"objectId"];
    self.createdAt = [aDecoder decodeObjectForKey:@"createdAt"];
    self.updatedAt = [aDecoder decodeObjectForKey:@"updatedAt"];
    
    return self;
}

@end
