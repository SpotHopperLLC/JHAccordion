//
//  MatchPercentAnnotationView.h
//  SpotHopper
//
//  Created by Josh Holtz on 3/10/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import <MapKit/MapKit.h>

@class DrinkModel;
@class SpotAnnotationCallout, SpotModel;

@interface MatchPercentAnnotationView : MKAnnotationView

@property (nonatomic, strong) DrinkModel *drink;

@property (nonatomic, strong) SpotModel *spot;
@property (nonatomic, strong) SpotAnnotationCallout *calloutView;

@end
