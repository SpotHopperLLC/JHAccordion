//
//  SHHomeMapViewController.m
//  SpotHopper
//
//  Created by Brennan Stehling on 5/13/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "SHHomeMapViewController.h"

#import "UIViewController+Navigator.h"
#import "UIView+AutoLayout.h"
#import "SHStyleKit.h"

#import "SHLocationMenuBarViewController.h"
#import "SHHomeNavigationViewController.h"

#import "TellMeMyLocation.h"

#import <MapKit/MapKit.h>

@interface SHHomeMapViewController () <SHLocationMenuBarDelegate, SHHomeNavigationDelegate, MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (strong, nonatomic) IBOutlet UIView *statusBarBackgroundView;
@property (strong, nonatomic) SHLocationMenuBarViewController *locationMenuBarViewController;
@property (strong, nonatomic) SHHomeNavigationViewController *homeNavigationViewController;

@end

@implementation SHHomeMapViewController {
    TellMeMyLocation *_tellMeMyLocation;
}

#pragma mark - View Lifecyle
#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad:@[kDidLoadOptionsNoBackground]];
    
    self.locationMenuBarViewController = [[self spotHopperStoryboard] instantiateViewControllerWithIdentifier:@"SHLocationMenuBarViewController"];
    self.locationMenuBarViewController.delegate = self;
    self.homeNavigationViewController = [[self spotHopperStoryboard] instantiateViewControllerWithIdentifier:@"SHHomeNavigationViewController"];
    self.homeNavigationViewController.delegate = self;

    self.statusBarBackgroundView.backgroundColor = [SHStyleKit mainColorTransparent];
    self.title = @"New Search";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSLog(@"topLayoutGuide: %f", self.topLayoutGuide.length);
    
    if (!self.locationMenuBarViewController.view.superview) {
        [self embedViewController:self.locationMenuBarViewController intoView:self.view placementBlock:^(UIView *view) {
            [view pinToSuperviewEdges:JRTViewPinTopEdge inset:0.0f usingLayoutGuidesFrom:self];
            [view pinToSuperviewEdges:JRTViewPinLeftEdge | JRTViewPinRightEdge inset:0.0];
            [view constrainToHeight:40.0f];
        }];
        
        [self.view bringSubviewToFront:self.locationMenuBarViewController.view];
    }
    
    if (!self.homeNavigationViewController.view.superview) {
        [self embedViewController:self.homeNavigationViewController intoView:self.view placementBlock:^(UIView *view) {
            [view pinToSuperviewEdges:JRTViewPinBottomEdge inset:0.0f usingLayoutGuidesFrom:self];
            [view pinToSuperviewEdges:JRTViewPinLeftEdge | JRTViewPinRightEdge inset:0.0];
            [view constrainToHeight:180.0f];
        }];
        
        [self.view bringSubviewToFront:self.homeNavigationViewController.view];
    }
    
    if (!_tellMeMyLocation) {
        _tellMeMyLocation = [[TellMeMyLocation alloc] init];
    }
    [self.locationMenuBarViewController updateLocationTitle:@"Locating..."];
    [_tellMeMyLocation findMe:kCLLocationAccuracyHundredMeters found:^(CLLocation *newLocation) {
        [self.locationMenuBarViewController updateLocationTitle:[TellMeMyLocation lastLocationName]];
        
        self.mapView.showsUserLocation = TRUE;
        
        MKMapPoint mapPoint = MKMapPointForCoordinate(newLocation.coordinate);
        MKMapRect mapRect = MKMapRectMake(mapPoint.x, mapPoint.y, 0.25, 0.25);
        [self.mapView setVisibleMapRect:mapRect edgePadding:UIEdgeInsetsMake(105.0, 5.0, 180.0, 5.0) animated:NO];
    } failure:^(NSError *error) {
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

#pragma mark - Private
#pragma mark -

#pragma mark - SHLocationMenuBarDelegate
#pragma mark -

- (void)locationMenuBarViewControllerDidRequestLocationChange:(SHLocationMenuBarViewController *)vc {
    NSLog(@"Change Location!");
}

#pragma mark - SHHomeNavigationDelegate
#pragma mark -

- (void)homeNavigationViewControllerDidRequestSpots:(SHHomeNavigationViewController *)vc {
    [self goToSpotListMenu];
}

- (void)homeNavigationViewControllerDidRequestSpecials:(SHHomeNavigationViewController *)vc {
    [self goToTonightsSpecials];
}

- (void)homeNavigationViewControllerDidRequestBeers:(SHHomeNavigationViewController *)vc {
    NSLog(@"Beers!");
}

- (void)homeNavigationViewControllerDidRequestCocktails:(SHHomeNavigationViewController *)vc {
    NSLog(@"Cocktails!");
}

- (void)homeNavigationViewControllerDidRequestWines:(SHHomeNavigationViewController *)vc {
    NSLog(@"Wines!");
}

#pragma mark - MKMapViewDelegate
#pragma mark -

@end
