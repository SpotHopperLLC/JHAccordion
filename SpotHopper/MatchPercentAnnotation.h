//
//  MatchPercentAnnotation.h
//  SpotHopper
//
//  Created by Josh Holtz on 3/10/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <MapKit/MapKit.h>

@class DrinkModel, SpotModel;

@interface MatchPercentAnnotation : NSObject <MKAnnotation>

@property(nonatomic, assign) CLLocationCoordinate2D coordinate;
@property(nonatomic, copy) NSString *title;
@property(nonatomic, copy) NSString *subtitle;

@property (nonatomic, strong) DrinkModel *drink;
@property (nonatomic, strong) SpotModel *spot;

@end
