//
//  SHPlacemark.m
//  SpotHopper
//
//  Created by Brennan Stehling on 8/11/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "SHPlacemark.h"

@implementation SHPlacemark

#pragma mark - Public
#pragma mark -

+ (SHPlacemark *)placemarkFromOtherPlacemark:(CLPlacemark *)otherPlacemark {
    SHPlacemark *placemark = [[SHPlacemark alloc] init];
    NSAssert([otherPlacemark.region isKindOfClass:[CLCircularRegion class]], @"Region must be Circular Region");
    
    placemark.name = [placemark nameForPlacemark:otherPlacemark];
    if ([otherPlacemark.region isKindOfClass:[CLCircularRegion class]]) {
        placemark.region = (CLCircularRegion *)otherPlacemark.region;
    }
    placemark.lastUsedDate = [NSDate date];
    return placemark;
}

+ (NSArray *)placemarksFromOtherPlacemarks:(NSArray *)otherPlacemarks {
    NSMutableArray *placemarks = @[].mutableCopy;
    for (CLPlacemark *otherPlacemark in otherPlacemarks) {
        SHPlacemark *placemark = [SHPlacemark placemarkFromOtherPlacemark:otherPlacemark];
        if (placemark.name.length) {
            [placemarks addObject:placemark];
        }
    }
    
    return placemarks;
}

+ (NSArray *)sortedPlacemarks:(NSArray *)placemarks {
    NSArray *sorted = [placemarks sortedArrayUsingComparator:^NSComparisonResult(SHPlacemark *obj1, SHPlacemark *obj2) {
        return [obj2.lastUsedDate compare:obj1.lastUsedDate];
    }];
    
    return sorted;
}

- (CLLocation *)location {
    CLLocation *location = [[CLLocation alloc] initWithLatitude:self.region.center.latitude longitude:self.region.center.longitude];
    return location;
}

#pragma mark - Private
#pragma mark -

- (NSString *)nameForPlacemark:(CLPlacemark *)placemark {
    if (placemark.name.length && placemark.locality.length && placemark.administrativeArea.length) {
        return [NSString stringWithFormat:@"%@, %@, %@", placemark.name, placemark.locality, placemark.administrativeArea];
    }
    else if (placemark.subLocality.length && placemark.locality.length && placemark.administrativeArea.length) {
        return [NSString stringWithFormat:@"%@, %@, %@", placemark.subLocality, placemark.locality, placemark.administrativeArea];
    }
    else if (placemark.locality.length && placemark.administrativeArea.length) {
        return [NSString stringWithFormat:@"%@, %@", placemark.locality, placemark.administrativeArea];
    }
    else if (placemark.name.length) {
        return placemark.name;
    }
    else {
        return nil;
    }
}

#pragma mark - NSObject Overrides
#pragma mark -

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ (%f, %f)", self.name, self.region.center.latitude, self.region.center.longitude];
}

- (id)debugQuickLookObject {
    return self.location;
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[SHPlacemark class]]) {
        SHPlacemark *other = (SHPlacemark *)object;
        return [self.region isEqual:other.region] && [self.name isEqualToString:other.name];
    }
         
    return FALSE;
}

#pragma mark - NSCopying
#pragma mark -

- (id)copyWithZone:(NSZone *)zone {
    SHPlacemark *copy = [[SHPlacemark alloc] init];
    
    copy.name = self.name;
    copy.region = self.region;
    copy.lastUsedDate = self.lastUsedDate;
    
    return copy;
}

#pragma mark - NSCoding
#pragma mark -

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.region forKey:@"region"];
    [aCoder encodeObject:self.lastUsedDate forKey:@"lastUsedDate"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    SHPlacemark *placemark = [[SHPlacemark alloc] init];
    
    placemark.name = [aDecoder decodeObjectForKey:@"name"];
    placemark.region = [aDecoder decodeObjectForKey:@"region"];
    placemark.lastUsedDate = [aDecoder decodeObjectForKey:@"lastUsedDate"];
    
    return placemark;
}

@end
