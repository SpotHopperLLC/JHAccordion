//
//  SHPlacemark.h
//  SpotHopper
//
//  Created by Brennan Stehling on 8/11/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

@interface SHPlacemark : NSObject <NSCopying, NSCoding>

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) CLCircularRegion *region;
@property (strong, nonatomic) NSDate *lastUsedDate;

@property (readonly, nonatomic) CLLocation *location;

+ (SHPlacemark *)placemarkFromOtherPlacemark:(CLPlacemark *)otherPlacemark;

+ (NSArray *)placemarksFromOtherPlacemarks:(NSArray *)otherPlacemarks;

+ (NSArray *)sortedPlacemarks:(NSArray *)placemarks;

@end
