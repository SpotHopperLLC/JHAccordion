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
#import "SHStyleKit+Additions.h"

#import "SHLocationMenuBarViewController.h"
#import "SHHomeNavigationViewController.h"
#import "SHAdjustSpotListSliderViewController.h"

#import "TellMeMyLocation.h"
#import "Tracker.h"

#import <MapKit/MapKit.h>

@interface SHHomeMapViewController () <SHLocationMenuBarDelegate, SHHomeNavigationDelegate, SHAdjustSliderListSliderDelegate, MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *btnLeft;
@property (weak, nonatomic) IBOutlet UIButton *btnRight;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (strong, nonatomic) IBOutlet UIView *statusBarBackgroundView;
@property (strong, nonatomic) SHLocationMenuBarViewController *locationMenuBarViewController;
@property (strong, nonatomic) SHHomeNavigationViewController *homeNavigationViewController;

@end

@implementation SHHomeMapViewController {
    TellMeMyLocation *_tellMeMyLocation;
    CLLocation *_location;
}

#pragma mark - View Lifecyle
#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad:@[kDidLoadOptionsNoBackground]];
    
    TellMeMyLocation *tellMeMyLocation = [[TellMeMyLocation alloc] init];
    [tellMeMyLocation findMe:kCLLocationAccuracyHundredMeters found:^(CLLocation *newLocation) {
        _location = newLocation;
    } failure:^(NSError *error) {
        [Tracker logError:error.description class:[self class] trace:NSStringFromSelector(_cmd)];
    }];
    
    UIImage *backgroundImage = [SHStyleKit gradientBackgroundWithWidth:CGRectGetWidth(self.view.frame) height:CGRectGetHeight(self.navigationController.navigationBar.frame)];
    UIColor *backgroundColor = [UIColor colorWithPatternImage:backgroundImage];
//    [self.navigationController.navigationBar setBackgroundImage:backgroundImage forBarMetrics:UIBarMetricsDefault];
//    [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
//    [[UINavigationBar appearance] setBackgroundColor:backgroundColor];
    
    UIImage *searchIcon = [SHStyleKit searchIconWithColor:SHStyleKitColorMyWhiteColor size:self.btnLeft.frame.size];
    [self.btnLeft setImage:searchIcon forState:UIControlStateNormal];
    UIImage *spotIcon = [SHStyleKit spotIconWithColor:SHStyleKitColorMyWhiteColor size:self.btnRight.frame.size];
    [self.btnRight setImage:spotIcon forState:UIControlStateNormal];

    self.navigationController.navigationBar.barTintColor = backgroundColor;
    self.navigationController.navigationBar.translucent = NO;
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [SHStyleKit myWhiteColor]};
    
    self.locationMenuBarViewController = [[self spotHopperStoryboard] instantiateViewControllerWithIdentifier:@"SHLocationMenuBarViewController"];
    self.locationMenuBarViewController.delegate = self;
    self.homeNavigationViewController = [[self spotHopperStoryboard] instantiateViewControllerWithIdentifier:@"SHHomeNavigationViewController"];
    self.homeNavigationViewController.delegate = self;

    self.statusBarBackgroundView.backgroundColor = [SHStyleKit myTintColorTransparent];
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nc = (UINavigationController *)segue.destinationViewController;
        if ([nc.topViewController isKindOfClass:[SHAdjustSpotListSliderViewController class]]) {
            SHAdjustSpotListSliderViewController *vc = (SHAdjustSpotListSliderViewController *)nc.topViewController;
            CLLocation *location = [TellMeMyLocation currentDeviceLocation];
            vc.location = location;
            vc.delegate = self;
        }
    }
}

#pragma mark - Navgiation
#pragma mark -

- (void)goToSpots {
    // updating the location is redundant, but necessary to ensure it is current
    TellMeMyLocation *tellMeMyLocation = [[TellMeMyLocation alloc] init];
    [tellMeMyLocation findMe:kCLLocationAccuracyHundredMeters found:^(CLLocation *newLocation) {
        _location = newLocation;
        [self performSegueWithIdentifier:@"HomeMapToSpots" sender:self];
    } failure:^(NSError *error) {
        [Tracker logError:error.description class:[self class] trace:NSStringFromSelector(_cmd)];
    }];
}

#pragma mark - Private
#pragma mark -

- (IBAction)goToHomeMap:(UIStoryboardSegue *)segue {
    // TODO: get back to the home map view
}

- (IBAction)cancelBackToHomeMap:(UIStoryboardSegue *)segue {
    // TODO: get back to the home map view
}

- (IBAction)finishCreatingSpotListForHomeMap:(UIStoryboardSegue *)segue {
    // TODO: get back to the home map view and get spotlist model
    
    // TODO: hide the home navigation and display the collection view of the spots and add the map annotations
    
    
}

#pragma mark - SHLocationMenuBarDelegate
#pragma mark -

- (void)locationMenuBarViewControllerDidRequestLocationChange:(SHLocationMenuBarViewController *)vc {
    NSLog(@"Change Location!");
}

#pragma mark - SHHomeNavigationDelegate
#pragma mark -

- (void)homeNavigationViewControllerDidRequestSpots:(SHHomeNavigationViewController *)vc {
    [self goToSpots];
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

#pragma mark - SHAdjustSliderListSliderDelegate
#pragma mark -

-(void)adjustSpotListSliderViewController:(SHAdjustSpotListSliderViewController*)vc didCreateSpotList:(SpotListModel*)spotList {
    NSLog(@"spots: %@", spotList.spots);
}

#pragma mark - MKMapViewDelegate
#pragma mark -

@end
