//
//  MatchPercentAnnotation.h
//  SpotHopper
//
//  Created by Josh Holtz on 3/10/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <MapKit/MapKit.h>

@class SpotModel;

@interface MatchPercentAnnotation : NSObject <MKAnnotation>

@property (nonatomic, strong) SpotModel *spot;

@end
