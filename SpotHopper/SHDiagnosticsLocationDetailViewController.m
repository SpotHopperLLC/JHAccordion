//
//  SHDiagnosticsLocationDetailViewController.m
//  SpotHopper
//
//  Created by Brennan Stehling on 12/16/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "SHDiagnosticsLocationDetailViewController.h"

#import <MapKit/MapKit.h>

#import "SHStyleKit+Additions.h"
#import "SVPulsingAnnotationView.h"
#import "MatchPercentAnnotation.h"

@interface SHDiagnosticsLocationDetailViewController ()

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@end

@implementation SHDiagnosticsLocationDetailViewController {
    NSDateFormatter *_dateFormatter;
}

#pragma mark - View Lifecycle
#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (NSArray *)viewOptions {
    return @[kDidLoadOptionsNoBackground];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.obj) {
        PFGeoPoint *point = [self.obj objectForKey:@"location"];
        CLLocation *location = [[CLLocation alloc] initWithLatitude:point.latitude longitude:point.longitude];
        CLLocationDistance radius = 100.0;
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(location.coordinate, radius, radius);
        [self.mapView setRegion:region animated:FALSE];
        
        MKPointAnnotation *pointAnnotation = [[MKPointAnnotation alloc] init];
        pointAnnotation.coordinate = location.coordinate;
        [self.mapView addAnnotation:pointAnnotation];
        
        MKCircle *circleOverlay = [MKCircle circleWithCenterCoordinate:location.coordinate radius:radius/4];
        [self.mapView addOverlay:circleOverlay];
        
        self.timeLabel.text = [self stringFromDate:self.obj.createdAt];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - Formatting
#pragma mark -

- (NSString *)stringFromDate:(NSDate *)date {
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"MM/dd h:mm a"];
    }
    
    return [_dateFormatter stringFromDate:date];
}

#pragma mark - MKMapViewDelegate
#pragma mark -

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    static NSString *identifier = @"Location";
    SVPulsingAnnotationView *pulsingView = (SVPulsingAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    
    if (!pulsingView) {
        pulsingView = [[SVPulsingAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        pulsingView.annotationColor = [SHStyleKit color:SHStyleKitColorMyTintColor];
    }

    return pulsingView;
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    if ([overlay isKindOfClass:[MKCircle class]]) {
        MKCircleRenderer *circleView = [[MKCircleRenderer alloc] initWithCircle:overlay];
        
        circleView.strokeColor = [[SHStyleKit color:SHStyleKitColorMyTintColor] colorWithAlphaComponent:0.25f];
        circleView.fillColor = [[UIColor grayColor] colorWithAlphaComponent:0.1];
        circleView.lineWidth = 1.0f;
        circleView.alpha = 1.0f;
        
        return circleView;
    }
    
    return nil;
}

@end
