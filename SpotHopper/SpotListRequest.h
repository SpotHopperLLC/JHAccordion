//
//  SpotListRequest.h
//  SpotHopper
//
//  Created by Brennan Stehling on 6/13/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreLocation/CoreLocation.h>

@interface SpotListRequest : NSObject<NSCopying>

@property (strong, nonatomic) NSNumber *spotListId;
@property (copy, nonatomic) NSString *name;
@property (assign, nonatomic, getter = isFeatured) BOOL featured;
@property (assign, nonatomic, getter = isBasedOnSliders) BOOL basedOnSliders;
@property (assign, nonatomic, getter = isTransient) BOOL transient;
@property (assign, nonatomic) CLLocationCoordinate2D coordinate;
@property (assign, nonatomic) CGFloat radius; // miles
@property (strong, nonatomic) NSArray *sliders;
@property (strong, nonatomic) NSNumber *spotId;
@property (strong, nonatomic) NSNumber *spotTypeId;

@end
