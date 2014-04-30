//
//  DrinksViewController.m
//  SpotHopper
//
//  Created by Brennan Stehling on 4/29/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "DrinksViewController.h"

#import "NSNumber+Helpers.h"
#import "UIViewController+Navigator.h"

#import "SpotAnnotationCallout.h"

#import "MatchPercentAnnotation.h"
#import "MatchPercentAnnotationView.h"

#import "SpotModel.h"

#import "SearchCell.h"

#import "TellMeMyLocation.h"

#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

#define kPageSize @15

@interface DrinksViewController () <UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate, SpotAnnotationCalloutDelegate>

@property (weak, nonatomic) IBOutlet UITextField *txtSearch;
@property (weak, nonatomic) IBOutlet UITableView *tblSpots;

@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, assign) CGRect tblSpotsInitialFrame;

@property (nonatomic, strong) TellMeMyLocation *tellMeMyLocation;
@property (nonatomic, strong) CLLocation *currentLocation;

@property (nonatomic, strong) NSTimer *searchTimer;
@property (nonatomic, strong) NSNumber *page;

@property (nonatomic, strong) NSMutableArray *spots;

@end

@implementation DrinksViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad:@[kDidLoadOptionsBlurredBackground,kDidLoadOptionsDontAdjustForIOS6]];
    
    // Sets title
    [self setTitle:@"Where?"];
    
    // Shows sidebar button in nav
    [self showSidebarButton:YES animated:YES];
    
    // Create mapview
    _mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_tblSpots.frame), 120.0f)];
    [_mapView setShowsUserLocation:YES];
    [_mapView setDelegate:self];
    
    // Configures table
    [_tblSpots setTableHeaderView:_mapView];
    [_tblSpots setTableFooterView:[[UIView alloc] init]];
    [_tblSpots registerNib:[UINib nibWithNibName:@"SearchCellView" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"SearchCell"];
    [_tblSpots registerNib:[UINib nibWithNibName:@"DrinksNearbyViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"DrinksNearbyViewCell"];
    
    // Register pull to refresh
    [self registerRefreshTableView:_tblSpots withReloadType:kPullRefreshTypeBoth];
    
    // Find me
    [self showHUD:@"Locating"];
    _tellMeMyLocation = [[TellMeMyLocation alloc] init];
    [_tellMeMyLocation findMe:kCLLocationAccuracyNearestTenMeters found:^(CLLocation *newLocation) {
        
        [self hideHUD];
        _currentLocation = newLocation;
        
        [self doSearch];
    } failure:^(NSError *error) {
        [self hideHUD];
        [self doSearch];
    }];
    
    // Initializes stuff
    _page = @1;
    _spots = [NSMutableArray array];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    
    // Configures text search
    [_txtSearch addTarget:self action:@selector(onEditingChangeSearch:) forControlEvents:UIControlEventEditingChanged];
    
    // Gets table frame
    if (CGRectEqualToRect(_tblSpotsInitialFrame, CGRectZero)) {
        _tblSpotsInitialFrame = _tblSpots.frame;
    }
    
    // Keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];

}

- (void)viewDidAppear:(BOOL)animated {
//    [[TellMeMyLocation instance] findMe:kCLLocationAccuracyHundredMeters found:^(CLLocation *newLocation) {
//        [self repositionMapOnAnnotations:_mapView.annotations animated:TRUE];
//    } failure:^(NSError *error) {
//    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    // Configures text search
    [_txtSearch removeTarget:self action:@selector(onEditingChangeSearch:) forControlEvents:UIControlEventEditingChanged];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super viewWillDisappear:animated];
}

#pragma mark - Tracking

- (NSString *)screenName {
    return @"Check In";
}

#pragma mark - Keyboard

- (NSArray *)textfieldToHideKeyboard {
    return @[_txtSearch];
}

- (void)keyboardWillShow:(NSNotification*)notification {
    [self keyboardWillHideOrShow:notification show:YES];
    
    [_tblSpots setContentOffset:CGPointMake(0, CGRectGetHeight(_mapView.frame))];
}

- (void)keyboardWillHide:(NSNotification*)notification {
    [self keyboardWillHideOrShow:notification show:NO];
}

- (void)keyboardWillHideOrShow:(NSNotification*)notification show:(BOOL)show {
    NSDictionary *userInfo = notification.userInfo;
    NSTimeInterval duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    
    CGRect keyboardFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGRect frame = _tblSpots.frame;
    if (show == YES) {
        frame.size.height = CGRectGetHeight(self.view.frame) - CGRectGetMinY(frame) - CGRectGetHeight(keyboardFrame);
        if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
            frame.size.height -= 20.0f;
        }
    } else {
        frame = _tblSpotsInitialFrame;
    }
    
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionBeginFromCurrentState | curve animations:^{
        [_tblSpots setFrame:frame];
    } completion:^(BOOL finished) {
        [self dataDidFinishRefreshing];
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _spots.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DrinksNearbyViewCell" forIndexPath:indexPath];
        
        return cell;
    }
    else {
        SpotModel *spot = [_spots objectAtIndex:indexPath.row - 1];
        SearchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchCell" forIndexPath:indexPath];
        [cell setSpot:spot];
        
        return cell;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        // TODO: implement
        //[self goToDrinksNearBy];
        [self goToDrinkListMenu];
    }
    else {
        SpotModel *spot = [_spots objectAtIndex:indexPath.row - 1];
        [self goToSpot:spot];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55.0f;
}

#pragma mark - JHPullToRefresh

- (void)reloadTableViewDataPullDown {
    // Starts search over
    [self startSearch];
}

- (void)reloadTableViewDataPullUp {
    // Increments pages
    _page = [_page increment];
    
    // Does search
    [self doSearch];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if ([annotation isKindOfClass:[MatchPercentAnnotation class]] == YES) {
        MatchPercentAnnotation *matchAnnotation = (MatchPercentAnnotation*) annotation;
        
        MatchPercentAnnotationView *pin = [[MatchPercentAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"current"];
        [pin setSpot:matchAnnotation.spot];
        [pin setNeedsDisplay];
        
        return pin;
    }
    
    return nil;
}

- (void)mapView:(MKMapView *)aMapView didAddAnnotationViews:(NSArray *)views {
    for (MKAnnotationView *view in views) {
        if ([view.annotation isKindOfClass:[MKUserLocation class]]) {
            [view.superview bringSubviewToFront:view];
        }
        else {
            [view.superview sendSubviewToBack:view];
        }
    }
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    if ([view isKindOfClass:[MatchPercentAnnotationView class]] == YES) {
        MatchPercentAnnotationView *pin = (MatchPercentAnnotationView*) view;
        
        if (pin.isHighlighted == NO) {
            [pin setHighlighted:YES];
            [pin setNeedsDisplay];
            
            SpotAnnotationCallout *callout = [SpotAnnotationCallout viewFromNib];
            [callout setMatchPercentAnnotationView:pin];
            [callout setDelegate:self];
            [callout setFrame:CGRectMake(0.0f, -CGRectGetHeight(callout.frame), CGRectGetWidth(callout.frame), CGRectGetHeight(callout.frame))];
            
            [pin setCalloutView:callout];
            
            [pin setUserInteractionEnabled:YES];
            [pin addSubview:callout];
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

#pragma mark - SpotAnnotationCalloutDelegate

- (void)spotAnnotationCallout:(SpotAnnotationCallout *)spotAnnotationCallout clicked:(MatchPercentAnnotationView *)matchPercentAnnotationView {
    [_mapView deselectAnnotation:matchPercentAnnotationView.annotation animated:YES];
    [self goToSpot:matchPercentAnnotationView.spot];
}

#pragma mark - Actions

- (void)onEditingChangeSearch:(id)sender {
    // Cancel and nil
    [_searchTimer invalidate];
    _searchTimer = nil;
    
    // Schedule timer
    _searchTimer = [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(startSearch) userInfo:nil repeats:NO];
}

- (IBAction)onClickPop:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Private

- (void)goToSpot:(SpotModel*)spot {
    [self goToDrinkListMenuAtSpot:spot];
}

- (void)updateViewMap {
    // Update map
    [_mapView removeAnnotations:[_mapView annotations]];
    NSMutableArray *annotations = [@[] mutableCopy];
    for (SpotModel *spot in _spots) {
        // Place pin
        if (spot.latitude != nil && spot.longitude != nil) {
            MatchPercentAnnotation *annotation = [[MatchPercentAnnotation alloc] init];
            annotation.coordinate = CLLocationCoordinate2DMake(spot.latitude.floatValue, spot.longitude.floatValue);
            [annotation setSpot:spot];
            [annotations addObject:annotation];
        }
    }
    
    [_mapView addAnnotations:annotations];
    [self repositionMapOnAnnotations:_mapView.annotations animated:FALSE];
}

- (void)startSearch {
    // Resets pages and clears results
    _page = @1;
    
    [self doSearch];
}

- (void)doSearch {
    
    [self showHUD:@"Searching"];
    
    /*
     * Searches spots
     */
    NSMutableDictionary *paramsSpots = @{
                                         kSpotModelParamQuery : _txtSearch.text,
                                         kSpotModelParamQueryVisibleToUsers : @"true",
                                         kSpotModelParamPage : _page,
                                         kSpotModelParamsPageSize : kPageSize,
                                         }.mutableCopy;
    
    [paramsSpots setObject:kSpotModelParamSourcesSpotHopper forKey:kSpotModelParamSources];
    
    if (_currentLocation != nil) {
        [paramsSpots setObject:[NSNumber numberWithFloat:_currentLocation.coordinate.latitude] forKey:kSpotModelParamQueryLatitude];
        [paramsSpots setObject:[NSNumber numberWithFloat:_currentLocation.coordinate.longitude] forKey:kSpotModelParamQueryLongitude];
    }
    
    [SpotModel getSpots:paramsSpots success:^(NSArray *spotModels, JSONAPI *jsonApi) {
        [self hideHUD];
        
        if ([_page isEqualToNumber:@1] == YES) {
            [_spots removeAllObjects];
        }
        // Adds spots to results
        [_spots addObjectsFromArray:spotModels];
        [self dataDidFinishRefreshing];
        
        [self updateViewMap];
        
    } failure:^(ErrorModel *errorModel) {
        [self dataDidFinishRefreshing];
        [self hideHUD];
    }];
    
}

- (void)repositionMapOnAnnotations:(NSArray *)annotations animated:(BOOL)animated {
    MKMapRect mapRect = MKMapRectNull;
    
    BOOL foundUserLocation = FALSE;
    
    if (annotations.count) {
        for (id <MKAnnotation> annotation in annotations) {
            if ([annotation isKindOfClass:[MKUserLocation class]]) {
                foundUserLocation = TRUE;
                
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
        MKMapPoint annotationPoint = MKMapPointForCoordinate(_mapView.centerCoordinate);
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
            mapRect.size = MKMapSizeMake(MKMapRectGetWidth(mapRect) + 50.0, MKMapRectGetHeight(mapRect) + 50.0);
        }
        
        [_mapView setVisibleMapRect:mapRect edgePadding:UIEdgeInsetsMake(40.0, 15.0, 90.0, 15.0) animated:animated];
    }
    
    // HACK a bug somehow sets isUserInteractionEnabled to false when a map view animates
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.35 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        _mapView.userInteractionEnabled = TRUE;
    });
}

@end
