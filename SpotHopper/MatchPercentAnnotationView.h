//
//  MatchPercentAnnotationView.h
//  SpotHopper
//
//  Created by Josh Holtz on 3/10/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import <MapKit/MapKit.h>

#import "SHStyleKit+Additions.h"

@class SpotAnnotationCallout, SpotModel;

@interface MatchPercentAnnotationView : MKAnnotationView

@property (nonatomic, strong) SpotModel *spot;
@property (nonatomic, assign) SHStyleKitDrawing drawing;
@property (nonatomic, strong) SpotAnnotationCallout *calloutView;

- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier calloutView:(SpotAnnotationCallout *)calloutView;

- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier calloutView:(SpotAnnotationCallout *)calloutView drawing:(SHStyleKitDrawing)drawing;

@end
