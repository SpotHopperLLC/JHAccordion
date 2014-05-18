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
#import "SHMapOverlayCollectionViewController.h"
#import "SHMapFooterNavigationViewController.h"

#import "SpotAnnotationCallout.h"
#import "MatchPercentAnnotation.h"
#import "MatchPercentAnnotationView.h"

#import "SHButtonLatoBold.h"

#import "TellMeMyLocation.h"
#import "Tracker.h"

#import <MapKit/MapKit.h>

#define kMeterToMile 0.000621371f
#define kDebugAnnotationViewPositions FALSE

@interface SHHomeMapViewController () <SHLocationMenuBarDelegate, SHHomeNavigationDelegate, SHMapOverlayCollectionDelegate, SHMapFooterNavigationDelegate, SHSpotsCollectionViewManagerDelegate, SHAdjustSliderListSliderDelegate, SpotAnnotationCalloutDelegate, MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *btnLeft;
@property (weak, nonatomic) IBOutlet UIButton *btnRight;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet SHButtonLatoBold *btnUpdateSearchResults;

@property (strong, nonatomic) IBOutlet UIView *statusBarBackgroundView;
@property (strong, nonatomic) SHLocationMenuBarViewController *locationMenuBarViewController;
@property (strong, nonatomic) SHHomeNavigationViewController *homeNavigationViewController;
@property (strong, nonatomic) SHMapOverlayCollectionViewController *mapOverlayCollectionViewController;
@property (strong, nonatomic) SHMapFooterNavigationViewController *mapFooterNavigationViewController;

@property (weak, nonatomic) UIView *collectionContainerView;

@property (strong, nonatomic) SpotListModel *spotListModel;

@end

@implementation SHHomeMapViewController {
    CLLocation *_currentLocation;
    BOOL _isRepositioningMap;
    BOOL _doNotMoveMap;
}

#pragma mark - View Lifecyle
#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad:@[kDidLoadOptionsNoBackground]];
    
    TellMeMyLocation *tellMeMyLocation = [[TellMeMyLocation alloc] init];
    [tellMeMyLocation findMe:kCLLocationAccuracyHundredMeters found:^(CLLocation *newLocation) {
        _currentLocation = newLocation;
    } failure:^(NSError *error) {
        [Tracker logError:error.description class:[self class] trace:NSStringFromSelector(_cmd)];
    }];
    
    UIImage *backgroundImage = [SHStyleKit gradientBackgroundWithSize:self.view.frame.size];
    UIColor *backgroundColor = [UIColor colorWithPatternImage:backgroundImage];
//    [self.navigationController.navigationBar setBackgroundImage:backgroundImage forBarMetrics:UIBarMetricsDefault];
//    [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
//    [[UINavigationBar appearance] setBackgroundColor:backgroundColor];
    
    UIImage *image __unused = [SHStyleKit drawImage:SHStyleKitDrawingSearchIcon color:SHStyleKitColorMyTintColor size:CGSizeMake(40, 40)];
    
    [SHStyleKit setButton:self.btnLeft withDrawing:SHStyleKitDrawingSearchIcon normalColor:SHStyleKitColorMyWhiteColor highlightedColor:SHStyleKitColorMyTextColor];
    [SHStyleKit setButton:self.btnRight withDrawing:SHStyleKitDrawingFeaturedListIcon normalColor:SHStyleKitColorMyWhiteColor highlightedColor:SHStyleKitColorMyTextColor];
    
    self.navigationController.navigationBar.barTintColor = backgroundColor;
    self.navigationController.navigationBar.translucent = NO;
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [SHStyleKit myWhiteColor]};
    
    self.locationMenuBarViewController = [[self spotHopperStoryboard] instantiateViewControllerWithIdentifier:@"SHLocationMenuBarViewController"];
    self.locationMenuBarViewController.delegate = self;
    self.homeNavigationViewController = [[self spotHopperStoryboard] instantiateViewControllerWithIdentifier:@"SHHomeNavigationViewController"];
    self.homeNavigationViewController.delegate = self;
    
    self.mapOverlayCollectionViewController = [[self spotHopperStoryboard] instantiateViewControllerWithIdentifier:@"SHMapOverlayCollectionViewController"];
    self.mapOverlayCollectionViewController.delegate = self;
    self.mapFooterNavigationViewController = [[self spotHopperStoryboard] instantiateViewControllerWithIdentifier:@"SHMapFooterNavigationViewController"];
    self.mapFooterNavigationViewController.delegate = self;

    self.statusBarBackgroundView.backgroundColor = [SHStyleKit myTintColorTransparent];
    self.title = @"New Search";
    
    _currentLocation = [TellMeMyLocation currentDeviceLocation];
    if (_currentLocation) {
        [self repositionMapOnLocation:_currentLocation];
    }
    else {
        TellMeMyLocation *tellMeMyLocation = [[TellMeMyLocation alloc] init];
        [tellMeMyLocation findMe:kCLLocationAccuracyHundredMeters found:^(CLLocation *newLocation) {
            _currentLocation = newLocation;
            [self repositionMapOnLocation:_currentLocation];
        } failure:^(NSError *error) {
            [Tracker logError:error.description class:[self class] trace:NSStringFromSelector(_cmd)];
        }];
    }
    
    self.mapView.showsUserLocation = TRUE;
    
    self.view.backgroundColor = [UIColor clearColor];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setNeedsStatusBarAppearanceUpdate];
    
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
    
#define kCollectionContainerViewHeight 200.0f
#define kCollectionViewHeight 150.0f
#define kFooterNavigationViewHeight 50.0f

    if (!self.collectionContainerView && !self.mapOverlayCollectionViewController.view.superview && !self.mapFooterNavigationViewController.view.superview) {
        UIView *collectionContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), kCollectionContainerViewHeight)];
        collectionContainerView.translatesAutoresizingMaskIntoConstraints = NO;
        collectionContainerView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:collectionContainerView];
        [collectionContainerView pinToSuperviewEdges:JRTViewPinBottomEdge inset:0.0f usingLayoutGuidesFrom:self];
        [collectionContainerView pinToSuperviewEdges:JRTViewPinLeftEdge | JRTViewPinRightEdge inset:0.0];
        [collectionContainerView constrainToHeight:kCollectionContainerViewHeight];
        self.collectionContainerView = collectionContainerView;
        
        [self embedViewController:self.mapOverlayCollectionViewController intoView:self.collectionContainerView placementBlock:^(UIView *view) {
            [view pinToSuperviewEdges:JRTViewPinBottomEdge inset:kFooterNavigationViewHeight];
            [view pinToSuperviewEdges:JRTViewPinLeftEdge | JRTViewPinRightEdge inset:0.0];
            [view constrainToHeight:kCollectionViewHeight];
        }];
    
        [self embedViewController:self.mapFooterNavigationViewController intoView:self.collectionContainerView placementBlock:^(UIView *view) {
            [view pinToSuperviewEdges:JRTViewPinBottomEdge inset:0.0f];
            [view pinToSuperviewEdges:JRTViewPinLeftEdge | JRTViewPinRightEdge inset:0.0];
            [view constrainToHeight:kFooterNavigationViewHeight];
        }];
        
//        [self hideHomeNavigation:FALSE withCompletionBlock:nil];
        [self hideCollectionContainerView:false withCompletionBlock:^{
            NSLog(@"Collection container view is hidden");
        }];
    }
    
    [self.locationMenuBarViewController updateLocationTitle:[TellMeMyLocation lastLocationName]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // TODO: ensure the user is logged in (just while testing)
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nc = (UINavigationController *)segue.destinationViewController;
        if ([nc.topViewController isKindOfClass:[SHAdjustSpotListSliderViewController class]]) {
            SHAdjustSpotListSliderViewController *vc = (SHAdjustSpotListSliderViewController *)nc.topViewController;
            CLLocation *location = _currentLocation;
            vc.location = location;
            vc.delegate = self;
        }
    }
}

#pragma mark - View Management
#pragma mark -

- (void)hideHomeNavigation:(BOOL)animated withCompletionBlock:(void (^)())completionBlock {
    self.homeNavigationViewController.view.hidden = TRUE;
    
    if (completionBlock) {
        completionBlock();
    }
}

- (void)showHomeNavigation:(BOOL)animated withCompletionBlock:(void (^)())completionBlock {
    self.homeNavigationViewController.view.hidden = FALSE;
    
    if (completionBlock) {
        completionBlock();
    }
}

- (void)hideCollectionContainerView:(BOOL)animated withCompletionBlock:(void (^)())completionBlock {
    self.collectionContainerView.hidden = TRUE;
    
    if (completionBlock) {
        completionBlock();
    }
}

- (void)showCollectionContainerView:(BOOL)animated withCompletionBlock:(void (^)())completionBlock {
    self.collectionContainerView.hidden = FALSE;
    
    if (completionBlock) {
        completionBlock();
    }
}


#pragma mark - User Actions
#pragma mark -

- (IBAction)leftTopButtonTapped:(id)sender {
    NSLog(@"Search!");
}

- (IBAction)rightTopButtonTapped:(id)sender {
    [self hideCollectionContainerView:TRUE withCompletionBlock:^{
        [self showHomeNavigation:TRUE withCompletionBlock:^{
            NSLog(@"Showing navigation!");
        }];
    }];
}

#pragma mark - Navigation
#pragma mark -

- (void)goToSpots {
    // updating the location is redundant, but necessary to ensure it is current
    
    if ([self promptLoginNeeded:@"Please log in before creating a Spotlist"] == NO) {
        TellMeMyLocation *tellMeMyLocation = [[TellMeMyLocation alloc] init];
        [tellMeMyLocation findMe:kCLLocationAccuracyHundredMeters found:^(CLLocation *newLocation) {
            _currentLocation = newLocation;
            [self performSegueWithIdentifier:@"HomeMapToSpots" sender:self];
        } failure:^(NSError *error) {
            [Tracker logError:error.description class:[self class] trace:NSStringFromSelector(_cmd)];
        }];
    }
}

#pragma mark - Private
#pragma mark -

- (IBAction)cancelBackToHomeMap:(UIStoryboardSegue *)segue {
    // TODO: get back to the home map view
}

- (IBAction)finishCreatingSpotListForHomeMap:(UIStoryboardSegue *)segue {
    // TODO: get back to the home map view and get spotlist model
    
    // TODO: hide the home navigation and display the collection view of the spots and add the map annotations
    
    NSLog(@"source: %@", NSStringFromClass([segue.sourceViewController class]));
    NSLog(@"destination: %@", NSStringFromClass([segue.destinationViewController class]));
    
    if ([segue.sourceViewController isKindOfClass:[SHAdjustSpotListSliderViewController class]]) {
        SHAdjustSpotListSliderViewController *vc = (SHAdjustSpotListSliderViewController *)segue.sourceViewController;
        [self displaySpotlist:vc.spotListModel];
    }
}

- (void)displaySpotlist:(SpotListModel *)spotListModel {
    // hold onto the spotlist
    self.spotListModel = spotListModel;
    
    if (!self.spotListModel.spots.count) {
        [self showAlert:@"Oops" message:@"There are no spots which match in this location. Please try another search area."];
    }

    NSAssert(self.mapView, @"Map View is required");
    
    // Update map
    [self.mapView removeAnnotations:[self.mapView annotations]];
    for (SpotModel *spot in self.spotListModel.spots) {
        // Place pin
        if (spot.latitude != nil && spot.longitude != nil) {
            CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(spot.latitude.floatValue, spot.longitude.floatValue);

            MatchPercentAnnotation *annotation = [[MatchPercentAnnotation alloc] init];
            [annotation setSpot:spot];
            annotation.coordinate = coordinate;
            [self.mapView addAnnotation:annotation];
          
            if (kDebugAnnotationViewPositions) {
                MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
                point.coordinate = coordinate;
                [self.mapView addAnnotation:point];
            }
        }
    }
    
    [self hideHomeNavigation:FALSE withCompletionBlock:^{
        NSLog(@"Home navigation is now hidden");
        
        [self.mapOverlayCollectionViewController displaySpotList:spotListModel];
        [self showCollectionContainerView:FALSE withCompletionBlock:^{
            NSLog(@"Spotlist should now be displayed");
        }];
    }];
    
    [self repositionMapOnAnnotations:self.mapView.annotations animated:TRUE];

    if (self.spotListModel.spots.count) {
        [self selectSpot:self.spotListModel.spots[0]];
    }
}

- (void)selectSpot:(SpotModel *)spot {
    for (id<MKAnnotation>annotation in self.mapView.annotations) {
        if ([annotation isKindOfClass:[MatchPercentAnnotation class]]) {
            MatchPercentAnnotation *matchAnnotation = (MatchPercentAnnotation *)annotation;
            if ([spot isEqual:matchAnnotation.spot]) {
                [self.mapView selectAnnotation:annotation animated:TRUE];
            }
        }
    }
}

- (void)repositionMapOnLocation:(CLLocation *)location {
    MKMapPoint mapPoint = MKMapPointForCoordinate(location.coordinate);
    MKMapRect mapRect = MKMapRectMake(mapPoint.x, mapPoint.y, 0.25, 0.25);
    [self.mapView setVisibleMapRect:mapRect edgePadding:UIEdgeInsetsMake(105.0, 5.0, 180.0, 5.0) animated:NO];
}

- (void)repositionMapOnAnnotations:(NSArray *)annotations animated:(BOOL)animated {
    MKMapRect mapRect = MKMapRectNull;
    
    if (annotations.count) {
        for (id <MKAnnotation> annotation in annotations) {
            if (![annotation isKindOfClass:[MKUserLocation class]]) {
                
                MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
                MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0, 0);
                if (MKMapRectIsNull(mapRect)) {
                    mapRect = pointRect;
                } else {
                    mapRect = MKMapRectUnion(mapRect, pointRect);
                }
            }
        }
    }
    else {
        // use map center to zoom in closer
        MKMapPoint annotationPoint = MKMapPointForCoordinate(self.mapView.centerCoordinate);
        MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0, 0);
        if (MKMapRectIsNull(mapRect)) {
            mapRect = pointRect;
        } else {
            mapRect = MKMapRectUnion(mapRect, pointRect);
        }
    }
    
    if (!MKMapRectIsNull(mapRect)) {
        // ensure points are not positioned below the header by setting the edge padding
        
        // give it a little extra space
        if (MKMapRectGetWidth(mapRect) == 0.0 && MKMapRectGetHeight(mapRect) == 0.0) {
            mapRect.size = MKMapSizeMake(MKMapRectGetWidth(mapRect) + 20.0, MKMapRectGetHeight(mapRect) + 20.0);
        }
        
//        convertRegion:toRectToView
//        CGRect regionRect = [self.mapView convertRegion:self.mapView.region toRectToView:self.mapView];
//        CGRect visibleFrame = [self visibleMapFrame];
//        NSLog(@"visibleFrame: %f, %f", visibleFrame.size.width, visibleFrame.size.height);
//        MKCoordinateRegion mapRegion = [self.mapView convertRect:visibleFrame toRegionFromView:self.mapView];
        
        CGRect topFrame = [self topFrame];
        CGRect bottomFrame = [self bottomFrame];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.25 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState;
            [UIView animateWithDuration:0.5 delay:0.0 options:options animations:^{
                // edgePadding must also account for the size and position of the annotation view
                [self.mapView setVisibleMapRect:mapRect edgePadding:UIEdgeInsetsMake(CGRectGetHeight(topFrame) + 40, 15.0, CGRectGetHeight(bottomFrame) + 40, 15.0) animated:animated];
            } completion:^(BOOL finished) {
            }];
        });
    }
    
    // HACK a bug somehow sets isUserInteractionEnabled to false when a map view animates
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.35 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        self.mapView.userInteractionEnabled = TRUE;
    });
}

- (CGRect)topFrame {
    return self.locationMenuBarViewController.view.frame;
}

- (CGRect)bottomFrame {
    return self.homeNavigationViewController.view.frame; // bottom frame will change
}

- (CGRect)visibleMapFrame {
    // visible frame is the bottom of the overlay to the top of the bottom overlay
    
    CGRect topFrame = [self topFrame];
    CGRect bottomFrame = [self bottomFrame];
    CGFloat xPos = 0;
    CGFloat yPos = CGRectGetHeight(topFrame);
    
    CGFloat height = CGRectGetHeight(self.mapView.frame) - CGRectGetHeight(topFrame) - CGRectGetHeight(bottomFrame);
    CGRect visibleFrame = CGRectMake(xPos, yPos, CGRectGetWidth(self.mapView.frame), height);

    return visibleFrame;
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

#pragma mark - SHMapOverlayCollectionDelegate
#pragma mark -

- (void)mapOverlayCollectionViewController:(SHMapOverlayCollectionViewController *)vc didChangeToSpotAtIndex:(NSUInteger)index {
    if (index < self.spotListModel.spots.count) {
        SpotModel *spot = self.spotListModel.spots[index];
        NSLog(@"HomeMap: didChangeToSpotAtIndex: %@", spot.name);
        [self selectSpot:spot];
    }
}

#pragma mark - SHMapFooterNavigationDelegate
#pragma mark -

- (void)footerNavigationViewControllerDidRequestSpots:(SHMapFooterNavigationViewController *)vc {
    [self goToSpots];
}

- (void)footerNavigationViewControllerDidRequestSpecials:(SHMapFooterNavigationViewController *)vc {
    NSLog(@"Specials!");
}

- (void)footerNavigationViewControllerDidRequestBeers:(SHMapFooterNavigationViewController *)vc {
    NSLog(@"Beers!");
}

- (void)footerNavigationViewControllerDidRequestCocktails:(SHMapFooterNavigationViewController *)vc {
    NSLog(@"Cocktails!");
}

- (void)footerNavigationViewControllerDidRequestWines:(SHMapFooterNavigationViewController *)vc {
    NSLog(@"Wines!");
}

#pragma mark - SHAdjustSliderListSliderDelegate
#pragma mark -

-(void)adjustSpotListSliderViewController:(SHAdjustSpotListSliderViewController*)vc didCreateSpotList:(SpotListModel*)spotList {
    NSLog(@"spots: %@", spotList.spots);
}

#pragma mark - SpotAnnotationCalloutDelegate
#pragma mark -

- (void)spotAnnotationCallout:(SpotAnnotationCallout*)spotAnnotationCallout clicked:(MatchPercentAnnotationView*)matchPercentAnnotationView {
    NSLog(@"Clicked?!");
}

#pragma mark - MKMapViewDelegate
#pragma mark -

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    MKAnnotationView *annotationView = nil;
    
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        // do nothing
    }
    else if ([annotation isKindOfClass:[MatchPercentAnnotation class]] == YES) {
        static NSString *MatchPercentAnnotationIdentifier = @"MatchPercentAnnotationView";
        MatchPercentAnnotation *matchPercentAnnotation = (MatchPercentAnnotation *)annotation;
        MatchPercentAnnotationView *pin = (MatchPercentAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:MatchPercentAnnotationIdentifier];
        
        if (!pin) {
            pin = [[MatchPercentAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:MatchPercentAnnotationIdentifier spot:matchPercentAnnotation.spot calloutView:nil];
        }
        else {
            [pin setSpot:matchPercentAnnotation.spot];
        }

        [pin setNeedsDisplay];
        annotationView = pin;
    }
    else if ([annotation isKindOfClass:[MKPointAnnotation class]] == YES) {
        static NSString *PinIdentifier = @"Pin";
        MKPinAnnotationView *pin = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:PinIdentifier];
        if (!pin) {
            pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:PinIdentifier];
        }
        
        annotationView = pin;
    }
    
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    if ([view isKindOfClass:[MatchPercentAnnotationView class]] == YES) {
        MatchPercentAnnotationView *pin = (MatchPercentAnnotationView*) view;
        
        if (pin.isHighlighted == NO) {
            [pin setHighlighted:YES];
            [pin setNeedsDisplay];
            
            NSLog(@"HomeMap - Did select spot on map: %@", pin.spot.name);
            [self.mapOverlayCollectionViewController displaySpot:pin.spot];
            
//            SpotAnnotationCallout *callout = [SpotAnnotationCallout viewFromNib];
//            [callout setMatchPercentAnnotationView:pin];
//            [callout setDelegate:self];
//            [callout setFrame:CGRectMake(-80, -CGRectGetHeight(callout.frame), CGRectGetWidth(callout.frame), CGRectGetHeight(callout.frame))];
//            
//            [pin setCalloutView:callout];
//            
//            if (_currentLocation != nil && pin.spot.latitude != nil && pin.spot.longitude != nil) {
//                CLLocationDistance distance = [_currentLocation distanceFromLocation:[[CLLocation alloc] initWithLatitude:pin.spot.latitude.floatValue longitude:pin.spot.longitude.floatValue]];
//                [pin.calloutView.lblDistanceAway setText:[NSString stringWithFormat:@"%.1f Miles", ( distance * kMeterToMile )]];
//            } else {
//                [pin.calloutView.lblDistanceAway setText:@""];
//            }
//            
//            [pin setUserInteractionEnabled:YES];
//            [pin addSubview:callout];
        }
    }
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    if ([view isKindOfClass:[MatchPercentAnnotationView class]] == YES) {
        MatchPercentAnnotationView *pin = (MatchPercentAnnotationView*) view;
        [pin setHighlighted:NO];
        [pin setNeedsDisplay];
        
        [pin.calloutView removeFromSuperview];
        [pin setCalloutView:nil];
    }
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    if (self.mapView.hidden || _isRepositioningMap) {
        return;
    }
    
    _btnUpdateSearchResults.alpha = 0.0;
    [_btnUpdateSearchResults setHidden:NO];
    
    UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState;
    [UIView animateWithDuration:0.25 delay:0.0 options:options animations:^{
        _btnUpdateSearchResults.alpha = 1.0;
    } completion:^(BOOL finished) {
    }];
}

@end
