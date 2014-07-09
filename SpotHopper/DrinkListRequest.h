//
//  DrinkListRequest.h
//  SpotHopper
//
//  Created by Brennan Stehling on 6/4/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreLocation/CoreLocation.h>

@interface DrinkListRequest : NSObject <NSCopying>

@property (strong, nonatomic) NSNumber *drinkListId;
@property (copy, nonatomic) NSString *name;
@property (assign, nonatomic) BOOL isFeatured;
@property (assign, nonatomic) CLLocationCoordinate2D coordinate;
@property (assign, nonatomic) CGFloat radius;
@property (strong, nonatomic) NSArray *sliders;
@property (strong, nonatomic) NSNumber *drinkId;
@property (strong, nonatomic) NSNumber *drinkTypeId;
@property (strong, nonatomic) NSNumber *drinkSubTypeId;
@property (strong, nonatomic) NSNumber *baseAlcoholId;
@property (strong, nonatomic) NSNumber *spotId;

@end