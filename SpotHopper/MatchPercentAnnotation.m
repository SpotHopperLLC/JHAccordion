//
//  MatchPercentAnnotation.m
//  SpotHopper
//
//  Created by Josh Holtz on 3/10/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "MatchPercentAnnotation.h"

#import "SpotModel.h"

#pragma mark - Class Extension
#pragma mark -

@interface MatchPercentAnnotation ()

@property(nonatomic, assign) CLLocationCoordinate2D coordinate;
@property(nonatomic, copy) NSString *title;
@property(nonatomic, copy) NSString *subtitle;

@end

@implementation MatchPercentAnnotation

- (void)setSpot:(SpotModel *)spot {
    if (![spot isEqual:_spot]) {
        _spot = spot;
//        self.title = spot.name;
//        self.subtitle = @"HERE 1\nHERE 2";
        self.title = @" "; // a title must be set to something in order for the short the callout
        self.coordinate = CLLocationCoordinate2DMake([spot.latitude floatValue], [spot.longitude floatValue]);
    }
}

@end
