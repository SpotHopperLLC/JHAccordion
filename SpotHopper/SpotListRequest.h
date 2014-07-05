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

@property (copy, nonatomic) NSString *name;
@property (assign, nonatomic) CLLocationCoordinate2D coordinate;
@property (assign, nonatomic) CGFloat radius;
@property (strong, nonatomic) NSArray *sliders;
@property (strong, nonatomic) NSNumber *spotListId;
@property (strong, nonatomic) NSNumber *spotId;
@property (strong, nonatomic) NSNumber *spotTypeId;

@end
