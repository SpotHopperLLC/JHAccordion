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

#import "SHSidebarViewController.h"
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

#import "SpotModel.h"
#import "ErrorModel.h"

#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <QuartzCore/QuartzCore.h>

#define kMeterToMile 0.000621371f
#define kDebugAnnotationViewPositions FALSE

#define kCollectionContainerViewHeight 200.0f
#define kCollectionViewHeight 150.0f
#define kFooterNavigationViewHeight 50.0f

typedef enum {
    SHHomeMapModeNone = 0,
    SHHomeMapModeSpots = 1,
    SHHomeMapModeSpecials = 2,
    SHHomeMapModeBeer = 3,
    SHHomeMapModeCocktail = 4,
    SHHomeMapModeWine = 5
} SHHomeMapMode;

@interface SHHomeMapViewController () <SHSidebarViewControllerDelegate, SHLocationMenuBarDelegate, SHHomeNavigationDelegate, SHMapOverlayCollectionDelegate, SHMapFooterNavigationDelegate, SHSpotsCollectionViewManagerDelegate, SHAdjustSliderListSliderDelegate, SpotAnnotationCalloutDelegate, MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *btnLeft;
@property (weak, nonatomic) IBOutlet UIButton *btnRight;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet SHButtonLatoBold *btnUpdateSearchResults;

@property (strong, nonatomic) SHSidebarViewController *sideBarViewController;
@property (strong, nonatomic) SHLocationMenuBarViewController *locationMenuBarViewController;
@property (strong, nonatomic) SHHomeNavigationViewController *homeNavigationViewController;
@property (strong, nonatomic) SHMapOverlayCollectionViewController *mapOverlayCollectionViewController;
@property (strong, nonatomic) SHMapFooterNavigationViewController *mapFooterNavigationViewController;

@property (weak, nonatomic) NSLayoutConstraint *sideBarRightEdgeConstraint;

@property (weak, nonatomic) UIView *collectionContainerView;

@property (assign, nonatomic) SHHomeMapMode mode;

@property (strong, nonatomic) SpotListModel *spotListModel;
@property (strong, nonatomic) NSArray *specialsSpotModels;

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
    
    UIImage *backgroundImage = [SHStyleKit gradientBackgroundWithSize:self.view.frame.size];
    UIColor *backgroundColor = [UIColor colorWithPatternImage:backgroundImage];
    
    self.navigationController.navigationBar.barTintColor = backgroundColor;
    self.navigationController.navigationBar.translucent = NO;
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [SHStyleKit myWhiteColor]};
    
    self.sideBarViewController = [[self spotHopperStoryboard] instantiateViewControllerWithIdentifier:@"SHSidebarViewController"];
    self.sideBarViewController.delegate = self;
    self.locationMenuBarViewController = [[self spotHopperStoryboard] instantiateViewControllerWithIdentifier:@"SHLocationMenuBarViewController"];
    self.locationMenuBarViewController.delegate = self;
    self.homeNavigationViewController = [[self spotHopperStoryboard] instantiateViewControllerWithIdentifier:@"SHHomeNavigationViewController"];
    self.homeNavigationViewController.delegate = self;
    
    self.mapOverlayCollectionViewController = [[self spotHopperStoryboard] instantiateViewControllerWithIdentifier:@"SHMapOverlayCollectionViewController"];
    self.mapOverlayCollectionViewController.delegate = self;
    self.mapFooterNavigationViewController = [[self spotHopperStoryboard] instantiateViewControllerWithIdentifier:@"SHMapFooterNavigationViewController"];
    self.mapFooterNavigationViewController.delegate = self;

    self.title = @"New Search";
    
    [self.locationMenuBarViewController updateLocationTitle:@"Locating..."];
    
    // when the Home Map is first loaded it will focus the map on the current device location
    _currentLocation = [TellMeMyLocation currentDeviceLocation];
    if (_currentLocation) {
        [self repositionMapOnCoordinate:_currentLocation.coordinate animated:NO];
    }
    else {
        TellMeMyLocation *tellMeMyLocation = [[TellMeMyLocation alloc] init];
        [tellMeMyLocation findMe:kCLLocationAccuracyHundredMeters found:^(CLLocation *newLocation) {
            _currentLocation = newLocation;
            [TellMeMyLocation setLastLocation:newLocation completionHandler:^{
                NSLog(@"lastLocationName: %@", [TellMeMyLocation lastLocationName]);
                [self.locationMenuBarViewController updateLocationTitle:[TellMeMyLocation lastLocationName]];
            }];
            [self repositionMapOnCoordinate:_currentLocation.coordinate animated:NO];
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
    }
    
    if (!self.homeNavigationViewController.view.superview) {
        [self embedViewController:self.homeNavigationViewController intoView:self.view placementBlock:^(UIView *view) {
            [view pinToSuperviewEdges:JRTViewPinBottomEdge inset:0.0f usingLayoutGuidesFrom:self];
            [view pinToSuperviewEdges:JRTViewPinLeftEdge | JRTViewPinRightEdge inset:0.0];
            [view constrainToHeight:180.0f];
        }];
    }
    
    if (!self.sideBarViewController.view.superview) {
        [self embedViewController:self.sideBarViewController intoView:self.view placementBlock:^(UIView *view) {
            [view pinToSuperviewEdges:JRTViewPinTopEdge | JRTViewPinBottomEdge  inset:0.0f usingLayoutGuidesFrom:self];
            NSArray *rightEdgesConstraints = [view pinToSuperviewEdges:JRTViewPinRightEdge inset:0.0];
            [view constrainToWidth:CGRectGetWidth(self.view.frame)];
            NSCAssert(rightEdgesConstraints.count == 1, @"There should only be 1 constraint for the right edge");
            if (rightEdgesConstraints.count) {
                self.sideBarRightEdgeConstraint = rightEdgesConstraints[0];
            }
            [self hideSideBar:FALSE withCompletionBlock:nil];
        }];
    }

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
        
        [self hideCollectionContainerView:FALSE withCompletionBlock:^{
            NSLog(@"Collection container view is hidden");
        }];
    }
    
    [self hideSearch:FALSE withCompletionBlock:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // TODO: ensure the user is logged in (just while testing)
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
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

- (void)toggleSideBar:(BOOL)animated withCompletionBlock:(void (^)())completionBlock {
    if (self.sideBarRightEdgeConstraint.constant == CGRectGetWidth(self.view.frame)) {
        [self showSideBar:animated withCompletionBlock:completionBlock];
    }
    else {
        [self hideSideBar:animated withCompletionBlock:completionBlock];
    }
}

- (void)hideSideBar:(BOOL)animated withCompletionBlock:(void (^)())completionBlock {
    NSLog(@"Hiding Side Bar");
    
    UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState;
    [UIView animateWithDuration:(animated ? 0.25 : 0.0) delay:0.0 options:options animations:^{
        self.sideBarRightEdgeConstraint.constant = CGRectGetWidth(self.view.frame);
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        if (completionBlock) {
            completionBlock();
        }
    }];
}

- (void)showSideBar:(BOOL)animated withCompletionBlock:(void (^)())completionBlock {
    NSLog(@"Showing Side Bar");

    [self.view bringSubviewToFront:self.sideBarViewController.view];
    [self.sideBarViewController viewWillAppear:FALSE];
    
    UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState;
    [UIView animateWithDuration:(animated ? 0.25 : 0.0) delay:0.0 options:options animations:^{
        self.sideBarRightEdgeConstraint.constant = CGRectGetWidth(self.view.frame) * 0.2;
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        if (completionBlock) {
            completionBlock();
        }
    }];
}

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

- (void)showSearch:(BOOL)animated withCompletionBlock:(void (^)())completionBlock {
    NSAssert(self.navigationItem, @"Navigation Item is required");
    
    UIButton *searchCancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [searchCancelButton addTarget:self action:@selector(searchCancelButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [searchCancelButton setTitle:@"cancel" forState:UIControlStateNormal];
    searchCancelButton.titleLabel.font = [UIFont fontWithName:@"Lato-Light" size:searchCancelButton.titleLabel.font.pointSize];
    [SHStyleKit setButton:searchCancelButton normalTextColor:SHStyleKitColorMyWhiteColor highlightedTextColor:SHStyleKitColorMyTintColor];
    UIBarButtonItem *searchCancelBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:searchCancelButton];
    
    CGFloat cancelButtonTextWidth = [self widthForString:searchCancelButton.titleLabel.text font:searchCancelButton.titleLabel.font maxWidth:150.0f];
    searchCancelButton.frame = CGRectMake(0, 0, cancelButtonTextWidth + 10, 32);
    
    // add 10 + (20 * 2) for padding
    CGFloat textFieldWidth = CGRectGetWidth(self.view.frame) - 50.0f - cancelButtonTextWidth;

    CGRect searchFrame = CGRectMake(0, 0, 30, 30);
    UITextField *searchTextField = [[UITextField alloc] initWithFrame:searchFrame];
    searchTextField.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.1f];
    UIBarButtonItem *searchTextFieldBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:searchTextField];
    [SHStyleKit setTextField:searchTextField textColor:SHStyleKitColorMyWhiteColor];
    searchTextField.alpha = 0.1f;
    searchTextField.font = [UIFont fontWithName:@"Lato-Light" size:14.0f];
    searchTextField.tintColor = [[SHStyleKit myWhiteColor] colorWithAlphaComponent:0.75f];
    searchTextField.autocapitalizationType = UITextAutocapitalizationTypeWords;

    // set the left view
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
    UIImageView *leftImageView = [[UIImageView alloc] initWithFrame:CGRectMake(4, 4, 20, 20)];
    [SHStyleKit setImageView:leftImageView withDrawing:SHStyleKitDrawingSearchIcon color:SHStyleKitColorMyWhiteColor];
    [leftView addSubview:leftImageView];
    
    searchTextField.leftView = leftView;
    searchTextField.leftViewMode = UITextFieldViewModeAlways;
    searchTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    searchTextField.layer.cornerRadius = 5.0f;
    searchTextField.clipsToBounds = TRUE;
    
    self.navigationItem.title = nil;
    
    [CATransaction begin];
    [CATransaction setAnimationDuration:(animated ? 0.25f : 0.0f)];
    [CATransaction setCompletionBlock:^{
        [searchTextField becomeFirstResponder];
        if (completionBlock) {
            completionBlock();
        }
    }];
    [self.navigationItem setLeftBarButtonItem:searchTextFieldBarButtonItem animated:animated];
    [self.navigationItem setRightBarButtonItem:searchCancelBarButtonItem animated:animated];
    [UIView animateWithDuration:0.35f animations:^{
        searchTextField.alpha = 1.0f;
        searchTextField.frame = CGRectMake(0, 0, textFieldWidth, 30);
    } completion:^(BOOL finished) {
        searchTextField.placeholder = @"Find spot/drink or similar...";
    }];
    [CATransaction commit];
}

- (void)hideSearch:(BOOL)animated withCompletionBlock:(void (^)())completionBlock {
    NSAssert(self.navigationItem, @"Navigation Item is required");
    
    self.navigationItem.title = self.title;
    
    UIButton *searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [searchButton addTarget:self action:@selector(searchButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    searchButton.frame = CGRectMake(0, 0, 30, 30);
    [SHStyleKit setButton:searchButton withDrawing:SHStyleKitDrawingSearchIcon normalColor:SHStyleKitColorMyWhiteColor highlightedColor:SHStyleKitColorMyTextColor];
    UIBarButtonItem *searchBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:searchButton];
    
    UIButton *sideBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [sideBarButton addTarget:self action:@selector(sideBarButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    sideBarButton.frame = CGRectMake(0, 0, 30, 30);
    [SHStyleKit setButton:sideBarButton withDrawing:SHStyleKitDrawingSpotSideBarIcon normalColor:SHStyleKitColorMyWhiteColor highlightedColor:SHStyleKitColorMyTextColor];
    UIBarButtonItem *sideBarBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:sideBarButton];

    [CATransaction begin];
    [CATransaction setAnimationDuration:(animated ? 0.25f : 0.0f)];
    [CATransaction setCompletionBlock:^{
        if (completionBlock) {
            completionBlock();
        }
    }];
    [self.view endEditing:YES];
    [self.navigationItem setLeftBarButtonItem:searchBarButtonItem animated:animated];
    [self.navigationItem setRightBarButtonItem:sideBarBarButtonItem animated:animated];
    [CATransaction commit];
    
}

- (void)showSliders:(BOOL)animated forMode:(SHHomeMapMode)mode withCompletionBlock:(void (^)())completionBlock {
    // 1) prepare the slider vc
    // 2) prepare blurred image view to place behind slider vc
    // 3)
}

- (void)hideSliders:(BOOL)animated forMode:(SHHomeMapMode)mode withCompletionBlock:(void (^)())completionBlock {
}

#pragma mark - User Actions
#pragma mark -

- (IBAction)sideBarButtonTapped:(id)sender {
    [self toggleSideBar:TRUE withCompletionBlock:^{
        NSLog(@"Toggled Side Bar");
    }];
}

- (IBAction)searchButtonTapped:(id)sender {
    [self showSearch:TRUE withCompletionBlock:nil];
}

- (IBAction)searchCancelButtonTapped:(id)sender {
    [self hideSearch:TRUE withCompletionBlock:nil];
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
        return;
    }
    
    [self populateMapWithSpots:self.spotListModel.spots mode:SHHomeMapModeSpots];
    
    [self hideHomeNavigation:FALSE withCompletionBlock:^{
        [self.mapOverlayCollectionViewController displaySpotList:spotListModel];
        [self showCollectionContainerView:FALSE withCompletionBlock:^{
            // do nothing
        }];
    }];
}

- (void)fetchSpecials {
    [self showHUD:@"Finding specials"];
    [SpotModel getSpotsWithSpecialsTodayForCoordinate:self.mapView.centerCoordinate success:^(NSArray *spotModels, JSONAPI *jsonApi) {
        [self hideHUD];
        [self displaySpecialsForSpots:spotModels];
    } failure:^(ErrorModel *errorModel) {
        [Tracker logError:errorModel.human class:[self class] trace:NSStringFromSelector(_cmd)];
    }];
}

- (void)displaySpecialsForSpots:(NSArray *)spots {
    NSLog(@"spots: %@", spots);
    
    self.specialsSpotModels = spots;
    [self populateMapWithSpots:spots mode:SHHomeMapModeSpecials];
    
    [self hideHomeNavigation:FALSE withCompletionBlock:^{
        [self.mapOverlayCollectionViewController displaySpecialsForSpots:spots];
        [self showCollectionContainerView:FALSE withCompletionBlock:^{
            // do nothing
        }];
    }];
}

- (void)populateMapWithSpots:(NSArray *)spots mode:(SHHomeMapMode)mode {
    self.mode = mode;
    
    NSAssert(self.mapView, @"Map View is required");
    
    // Update map
    [self.mapView removeAnnotations:[self.mapView annotations]];
    for (SpotModel *spot in spots) {
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
    
    [self repositionMapOnAnnotations:self.mapView.annotations animated:TRUE];
    
    if (spots.count) {
        [self selectSpot:spots[0]];
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

- (void)repositionMapOnCoordinate:(CLLocationCoordinate2D)coordinate animated:(BOOL)animated {
    MKMapPoint mapPoint = MKMapPointForCoordinate(coordinate);
    MKMapRect mapRect = MKMapRectMake(mapPoint.x, mapPoint.y, 0.25, 0.25);
    [self.mapView setVisibleMapRect:mapRect edgePadding:UIEdgeInsetsMake(105.0, 5.0, 180.0, 5.0) animated:animated];
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
                [self.mapView setVisibleMapRect:mapRect edgePadding:UIEdgeInsetsMake(CGRectGetHeight(topFrame) + 20, 15.0, CGRectGetHeight(bottomFrame) + 20, 15.0) animated:animated];
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

#pragma mark - SHSidebarViewControllerDelegate
#pragma mark -

- (void)sidebarViewController:(SHSidebarViewController*)vc didTapSearchTextField:(id)sender {
    // TODO: implement
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)sidebarViewController:(SHSidebarViewController*)vc closeButtonTapped:(id)sender {
    [self hideSideBar:TRUE withCompletionBlock:^{
        NSLog(@"Closed Side Bar");
    }];
}

- (void)sidebarViewController:(SHSidebarViewController*)vc spotsButtonTapped:(id)sender {
    [self hideSideBar:TRUE withCompletionBlock:^{
        [self goToSpots];
    }];
}

- (void)sidebarViewController:(SHSidebarViewController*)vc drinksButtonTapped:(id)sender {
    // TODO: implement
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)sidebarViewController:(SHSidebarViewController*)vc specialsButtonTapped:(id)sender {
    [self hideSideBar:true withCompletionBlock:^{
        [self fetchSpecials];
    }];
}

- (void)sidebarViewController:(SHSidebarViewController*)vc reviewButtonTapped:(id)sender {
    // TODO: implement
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)sidebarViewController:(SHSidebarViewController*)vc checkinButtonTapped:(id)sender {
    // TODO: implement
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)sidebarViewController:(SHSidebarViewController*)vc accountButtonTapped:(id)sender {
    [self hideSideBar:TRUE withCompletionBlock:^{
        [self goToAccountSettings:TRUE];
    }];
}

#pragma mark - SHLocationMenuBarDelegate
#pragma mark -

- (void)locationMenuBarViewControllerDidRequestLocationChange:(SHLocationMenuBarViewController *)vc {
    NSLog(@"Change Location!");
}

#pragma mark - SHHomeNavigationDelegate
#pragma mark -

- (void)homeNavigationViewController:(SHHomeNavigationViewController *)vc spotsButtonTapped:(id)sender {
    [self goToSpots];
}

- (void)homeNavigationViewController:(SHHomeNavigationViewController *)vc specialsButtonTapped:(id)sender {
    [self fetchSpecials];
}

- (void)homeNavigationViewController:(SHHomeNavigationViewController *)vc beersButtonTapped:(id)sender {
    NSLog(@"Beers!");
}

- (void)homeNavigationViewController:(SHHomeNavigationViewController *)vc cocktailsButtonTapped:(id)sender {
    NSLog(@"Cocktails!");
}

- (void)homeNavigationViewController:(SHHomeNavigationViewController *)vc winesButtonTapped:(id)sender {
    NSLog(@"Wines!");
}

#pragma mark - SHMapOverlayCollectionDelegate
#pragma mark -

- (void)mapOverlayCollectionViewController:(SHMapOverlayCollectionViewController *)vc didChangeToSpotAtIndex:(NSUInteger)index {
    
    if (self.mode == SHHomeMapModeSpots && index < self.spotListModel.spots.count) {
        SpotModel *spot = self.spotListModel.spots[index];
        NSLog(@"HomeMap: didChangeToSpotAtIndex: %@", spot.name);
        [self selectSpot:spot];
    }
    else if (self.mode == SHHomeMapModeSpecials && index < self.specialsSpotModels.count) {
        SpotModel *spot = self.specialsSpotModels[index];
        NSLog(@"HomeMap: didChangeToSpotAtIndex: %@", spot.name);
        [self selectSpot:spot];
    }
}

- (void)mapOverlayCollectionViewController:(SHMapOverlayCollectionViewController *)vc didSelectSpotAtIndex:(NSUInteger)index {
    // Do not focus on spot when spot is selected
//    if (index < self.spotListModel.spots.count) {
//        SpotModel *spot = self.spotListModel.spots[index];
//        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([spot.latitude floatValue], [spot.longitude floatValue]);
//        [self repositionMapOnCoordinate:coordinate animated:YES];
//    }
}

#pragma mark - SHMapFooterNavigationDelegate
#pragma mark -

- (void)footerNavigationViewController:(SHMapFooterNavigationViewController *)vc spotsButtonTapped:(id)sender {
    [self goToSpots];
}

- (void)footerNavigationViewController:(SHMapFooterNavigationViewController *)vc specialsButtonTapped:(id)sender {
    [self fetchSpecials];
}

- (void)footerNavigationViewController:(SHMapFooterNavigationViewController *)vc beersButtonTapped:(id)sender {
    NSLog(@"Beers!");
}

- (void)footerNavigationViewController:(SHMapFooterNavigationViewController *)vc cocktailsButtonTapped:(id)sender {
    NSLog(@"Cocktails!");
}

- (void)footerNavigationViewController:(SHMapFooterNavigationViewController *)vc winesButtonTapped:(id)sender {
    NSLog(@"Wines!");
}

#pragma mark - SHAdjustSliderListSliderDelegate
#pragma mark -

- (void)adjustSpotListSliderViewController:(SHAdjustSpotListSliderViewController*)vc didCreateSpotList:(SpotListModel*)spotList {
    // do nothing (handled by unwind segue)
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
            pin = [[MatchPercentAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:MatchPercentAnnotationIdentifier];
        }
        
        if (self.mode == SHHomeMapModeSpots) {
            pin.drawing = SHStyleKitDrawingNone;
        }
        else if (self.mode == SHHomeMapModeSpecials) {
            pin.drawing = SHStyleKitDrawingSpecialsIcon;
        }
        [pin setSpot:matchPercentAnnotation.spot];
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
