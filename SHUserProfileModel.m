//
//  SHUserProfile.m
//  SpotHopper
//
//  Created by Brennan Stehling on 11/25/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "SHUserProfileModel.h"

@implementation SHUserProfileModel

#pragma mark - Base Overrides
#pragma mark -

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ [%@]", self.name, NSStringFromClass([self class])];
}

#pragma mark - Equality
#pragma mark -

- (BOOL)isEqual:(id)other {
    if (other == self) {
        return YES;
    }
    else if ([other isKindOfClass:[SHUserProfileModel class]]) {
        return [self isEqualToUserProfileModel:other];
    }
    
    return NO;
}

- (BOOL)isEqualToUserProfileModel:(SHUserProfileModel *)other {
    return [self.objectId isEqualToString:other.objectId];
}

- (NSUInteger)hash {
    return self.objectId.hash;
}

#pragma mark - NSCopying
#pragma mark -

- (id)copyWithZone:(NSZone *)zone {
    SHUserProfileModel *copy = [super copyWithZone:zone];
    
    copy.name = self.name;
    copy.imageURL = self.imageURL;
    copy.facebookId = self.facebookId;
    copy.spotHopperUserId = self.spotHopperUserId;
    
    return copy;
}

#pragma mark - NSCoding
#pragma mark -

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.imageURL forKey:@"imageURL"];
    [aCoder encodeObject:self.facebookId forKey:@"facebookId"];
    [aCoder encodeObject:self.spotHopperUserId forKey:@"spotHopperUserId"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    self.name = [aDecoder decodeObjectForKey:@"name"];
    self.imageURL = [aDecoder decodeObjectForKey:@"imageURL"];
    self.facebookId = [aDecoder decodeObjectForKey:@"facebookId"];
    self.spotHopperUserId = [aDecoder decodeObjectForKey:@"spotHopperUserId"];
    
    return self;
}

@end
