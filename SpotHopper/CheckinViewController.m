//
//  CheckinViewController.m
//  SpotHopper
//
//  Created by Josh Holtz on 3/27/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "CheckinViewController.h"

#import "NSNumber+Helpers.h"
#import "UIViewController+Navigator.h"

#import "SpotAnnotationCallout.h"

#import "MatchPercentAnnotation.h"
#import "MatchPercentAnnotationView.h"

#import "SpotModel.h"
#import "UserModel.h"
#import "CheckInModel.h"
#import "ErrorModel.h"

#import "SearchCell.h"

#import "TellMeMyLocation.h"
#import "ClientSessionManager.h"
#import "Tracker.h"

#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

#define kPageSize @15

@interface CheckinViewController () <UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate, SpotAnnotationCalloutDelegate>

@property (weak, nonatomic) IBOutlet UITextField *txtSearch;
@property (weak, nonatomic) IBOutlet UITableView *tblSpots;
@property (weak, nonatomic) IBOutlet UIButton *btnCheckIn;

@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, assign) CGRect tblSpotsInitialFrame;

@property (nonatomic, strong) TellMeMyLocation *tellMeMyLocation;
@property (nonatomic, strong) CLLocation *currentLocation;

@property (nonatomic, strong) NSTimer *searchTimer;
@property (nonatomic, strong) NSNumber *page;

@property (nonatomic, strong) NSMutableArray *spots;
@property (nonatomic, weak) SpotModel *selectedSpot;

@end

@implementation CheckinViewController

#pragma mark - View Lifecyle

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
    [self setTitle:@"Check In"];
    
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
        [Tracker logError:error class:[self class] trace:NSStringFromSelector(_cmd)];
    }];
    
    // Initializes stuff
    _page = @1;
    _spots = [NSMutableArray array];
    
    _tblSpots.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 65.0, 0.0f);
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
    
    _selectedSpot = nil;
    
    [self hideCheckInButton:FALSE];

    // Adds contextual footer view
    [self addFooterViewController:^(FooterViewController *footerViewController) {
        [footerViewController showHome:YES];
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    // Configures text search
    [_txtSearch removeTarget:self action:@selector(onEditingChangeSearch:) forControlEvents:UIControlEventEditingChanged];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super viewWillDisappear:animated];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _spots.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SpotModel *spot = [_spots objectAtIndex:indexPath.row];
    
    SearchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchCell" forIndexPath:indexPath];
    [cell setSpot:spot];
    
    UIView *selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    selectedBackgroundView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.1];
    cell.selectedBackgroundView = selectedBackgroundView;
    
    cell.clipsToBounds = TRUE;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SpotModel *spot = [_spots objectAtIndex:indexPath.row];
    
    if ([spot isEqual:_selectedSpot]) {
        [_tblSpots deselectRowAtIndexPath:indexPath animated:TRUE];
        _selectedSpot = nil;
        [self hideCheckInButton:TRUE];
    }
    else {
        self.selectedSpot = spot;
        [self showCheckInButton:TRUE];
        [_tblSpots selectRowAtIndexPath:indexPath animated:TRUE scrollPosition:UITableViewScrollPositionNone];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    _selectedSpot = nil;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.25 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        if (!_selectedSpot) {
            [self hideCheckInButton:TRUE];
        }
    });
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
        static NSString *MatchPercentAnnotationIdentifier = @"MatchPercentAnnotationView";
        MatchPercentAnnotation *matchPercentAnnotation = (MatchPercentAnnotation *)annotation;
        MatchPercentAnnotationView *pin = (MatchPercentAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:MatchPercentAnnotationIdentifier];
        if (!pin) {
            pin = [[MatchPercentAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:MatchPercentAnnotationIdentifier calloutView:nil];
        }
        [pin setSpot:matchPercentAnnotation.spot];
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
    NSUInteger index = [_spots indexOfObject:matchPercentAnnotationView.spot];

    if (index != NSNotFound) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        
        [_tblSpots selectRowAtIndexPath:indexPath animated:TRUE scrollPosition:UITableViewScrollPositionMiddle];
        _selectedSpot = matchPercentAnnotationView.spot;
        [self showCheckInButton:TRUE];
    }
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

- (IBAction)onCheckIn:(id)sender {
    [self checkinAtSpot:_selectedSpot];
}

#pragma mark - Private

- (void)hideCheckInButton:(BOOL)animated {
    // 1) slide the button down and out of view
    // 2) set hidden to TRUE
    
    CGFloat footerHeight = CGRectGetHeight(self.footerViewController.view.frame);
    CGFloat viewHeight = CGRectGetHeight(self.view.frame);
    
    CGRect hiddenFrame = _btnCheckIn.frame;
    hiddenFrame.origin.y = viewHeight;
    
    [UIView animateWithDuration:(animated ? 0.5 : 0.0) animations:^{
        _btnCheckIn.frame = hiddenFrame;
        _tblSpots.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, footerHeight, 0.0f);
        _tblSpots.scrollIndicatorInsets = UIEdgeInsetsMake(0.0f, 0.0f, footerHeight, 0.0f);
    } completion:^(BOOL finished) {
        [_btnCheckIn setHidden:TRUE];
    }];
}

- (void)showCheckInButton:(BOOL)animated {
    if (_btnCheckIn.hidden == FALSE) return;
    
    // 1) position it below the superview (out of view)
    // 2) set to hidden = false
    // 3) animate it up into position
    // 4) update the table with insets so it will not cover table cells
    
    CGFloat footerHeight = CGRectGetHeight(self.footerViewController.view.frame);
    CGFloat buttonHeight = CGRectGetHeight(_btnCheckIn.frame);
    CGFloat viewHeight = CGRectGetHeight(self.view.frame);
    
    CGRect hiddenFrame = _btnCheckIn.frame;
    hiddenFrame.origin.y = viewHeight;
    _btnCheckIn.frame = hiddenFrame;
    _btnCheckIn.hidden = FALSE;
    [self.view bringSubviewToFront:_btnCheckIn];
    
    [UIView animateWithDuration:(animated ? 0.5 : 0.0) animations:^{
        CGRect visibleFrame = _btnCheckIn.frame;
        visibleFrame.origin.y = viewHeight - buttonHeight;
        _btnCheckIn.frame = visibleFrame;
        _tblSpots.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, MAX(buttonHeight, footerHeight), 0.0f);
        _tblSpots.scrollIndicatorInsets = UIEdgeInsetsMake(0.0f, 0.0f, MAX(buttonHeight, footerHeight), 0.0f);
    } completion:^(BOOL finished) {
    }];
}

- (void)checkinAtSpot:(SpotModel*)spot {
    if ([self promptLoginNeeded:@"Cannot checkin without logging in"] == NO) {
        UserModel *user = [ClientSessionManager sharedClient].currentUser;
        NSCAssert(user, @"user is required");
        NSCAssert(spot, @"spot is required");
        [Tracker track:@"Check In" properties:@{@"user_id" : user.ID, @"spot_id" : spot.ID}];
        
        CheckInModel *checkInModel = [[CheckInModel alloc] init];
        [checkInModel postCheckIn:@{@"spot_id" : spot.ID} success:^(CheckInModel *checkInModel, JSONAPI *jsonAPI) {
            if ([_delegate respondsToSelector:@selector(checkinViewController:checkedIn:)]) {
                [_delegate checkinViewController:self checkedIn:checkInModel];
            } else {
                [self goToCheckIn:checkInModel];
            }
        } failure:^(ErrorModel *errorModel) {
            [self showAlert:@"Oops" message:@"You are not able to check in at this time. Please try again later."];
            [Tracker logError:errorModel class:[self class] trace:NSStringFromSelector(_cmd)];
        }];
    }
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
    [self repositionMapOnAnnotations:_mapView.annotations animated:TRUE];
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
        [self hideCheckInButton:FALSE];
    } failure:^(ErrorModel *errorModel) {
        [self dataDidFinishRefreshing];
        [self hideHUD];
        [Tracker logError:errorModel class:[self class] trace:NSStringFromSelector(_cmd)];
    }];
    
}

- (void)repositionMapOnAnnotations:(NSArray *)annotations animated:(BOOL)animated {
    MKMapRect mapRect = MKMapRectNull;
    
    if (annotations.count) {
        for (id <MKAnnotation> annotation in annotations) {
            if ([annotation isKindOfClass:[MKUserLocation class]]) {
                // if the user's location is within a half mile of the current map view center then include it
//                MKUserLocation *userLocation = (MKUserLocation *)annotation;

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
