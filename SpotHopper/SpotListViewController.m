//
//  SpotListViewController.m
//  SpotHopper
//
//  Created by Josh Holtz on 3/5/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#define ITEM_SIZE_WIDTH 180.0f
#define ITEM_SIZE_HEIGHT 247.0f
#define ITEM_SIZE_HEIGHT_4_INCH 300.0f
#define kMeterToMile 0.000621371f

#import "SpotListViewController.h"

#import "UIAlertView+Block.h"
#import "UIView+ViewFromNib.h"
#import "UIViewController+Navigator.h"

#import "TellMeMyLocation.h"

#import "CardLayout.h"
#import "SHButtonLatoLightLocation.h"
#import "SHButtonLatoBold.h"
#import "SpotAnnotationCallout.h"

#import "SHNavigationController.h"

#import "SpotCardCollectionViewCell.h"

#import "MatchPercentAnnotation.h"
#import "MatchPercentAnnotationView.h"

#import "ClientSessionManager.h"
#import "ErrorModel.h"

#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface SpotListViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, MKMapViewDelegate, SHButtonLatoLightLocationDelegate, SpotAnnotationCalloutDelegate>

@property (weak, nonatomic) IBOutlet UILabel *lblMatchPercent;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet SHButtonLatoLightLocation *btnLocation;
@property (weak, nonatomic) IBOutlet SHButtonLatoBold *btnUpdateSearchResults;
@property (weak, nonatomic) IBOutlet UILabel *lblLocation;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (weak, nonatomic) IBOutlet UIView *viewEmpty;

@property (nonatomic, strong) CLLocation *selectedLocation;
@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, strong) TellMeMyLocation *tellMeMyLocation;

@property (nonatomic, assign) BOOL showMap;

@end

@implementation SpotListViewController {
    BOOL _isRepositioningMap;
    BOOL _doNotMoveMap;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Sets title
    [self setTitle:_spotList.name];
    
    // Shows sidebar button in nav
    [self showSidebarButton:YES animated:YES];
    
    // Collection view
    [self.collectionView setBackgroundColor:[UIColor clearColor]];
    [self.collectionView setCollectionViewLayout:[[CardLayout alloc] initWithItemSize:CGSizeMake(ITEM_SIZE_WIDTH, (IS_FOUR_INCH ? ITEM_SIZE_HEIGHT_4_INCH : ITEM_SIZE_HEIGHT) )]];
    
    // Current location
    _tellMeMyLocation = [[TellMeMyLocation alloc] init];
    [_tellMeMyLocation findMe:kCLLocationAccuracyThreeKilometers found:^(CLLocation *newLocation) {
        _currentLocation = newLocation;
    } failure:^(NSError *error) {
        
    }];
    
    // Locations
    if (_spotList.featured == NO) {
        [_btnLocation setDelegate:self];
        [_btnLocation updateWithLastLocation];
    } else {
        [_lblLocation setHidden:YES];
        [_btnLocation setHidden:YES];
    }
    
    // Initialize stuff
    _showMap = YES;
    
    // Fetches spotlist
    if (_spotList.spots != nil) {
        [_collectionView reloadData];
        [self updateView];
        [self updateMatchPercent];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    
    // Adds contextual footer view
    __block SpotListViewController *this = self;
    [self addFooterViewController:^(FooterViewController *footerViewController) {
        [footerViewController showHome:YES];
        
        if (this.spotList.featured == NO) {
            [footerViewController setLeftButton:@"Delete" image:[UIImage imageNamed:@"btn_context_delete"]];
        }
        
        [this updateFooterMapListButton:footerViewController];
        [footerViewController setRightButton:@"Info" image:[UIImage imageNamed:@"btn_context_info"]];
    }];

}

- (BOOL)footerViewController:(FooterViewController *)footerViewController clickedButton:(FooterViewButtonType)footerViewButtonType {
    if (FooterViewButtonLeft == footerViewButtonType) {
        [self deleteSpotList];
        return YES;
    } else if (FooterViewButtonMiddle == footerViewButtonType) {
        _showMap = !_showMap;
        [self updateFooterMapListButton:footerViewController];
        return YES;
    } else if (FooterViewButtonRight == footerViewButtonType) {
        [self showAlert:@"Info" message:kInfoSpotList];
        return YES;
    }
    
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _spotList.spots.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    SpotModel *spot = [_spotList.spots objectAtIndex:indexPath.row];
    
    SpotCardCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SpotCardCollectionViewCell" forIndexPath:indexPath];
    [cell setSpot:spot];

    if (_currentLocation != nil && spot.latitude != nil && spot.longitude != nil) {
        CLLocationDistance distance = [_currentLocation distanceFromLocation:[[CLLocation alloc] initWithLatitude:spot.latitude.floatValue longitude:spot.longitude.floatValue]];
        [cell.lblHowFar setText:[NSString stringWithFormat:@"%.1f Miles From You", ( distance * kMeterToMile )]];
    } else {
        [cell.lblHowFar setText:@""];
    }
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    SpotModel *spot = [_spotList.spots objectAtIndex:indexPath.row];
    [self goToSpotProfile:spot];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self updateMatchPercent];
}

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    MKAnnotationView *annotationView = nil;
    
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        // do nothing
    }
    else if ([annotation isKindOfClass:[MatchPercentAnnotation class]] == YES) {
        MatchPercentAnnotation *matchAnnotation = (MatchPercentAnnotation*) annotation;
        
        MatchPercentAnnotationView *pin = [[MatchPercentAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"current"];
        [pin setSpot:matchAnnotation.spot];
        [pin setNeedsDisplay];
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
            
            SpotAnnotationCallout *callout = [SpotAnnotationCallout viewFromNib];
            [callout setMatchPercentAnnotationView:pin];
            [callout setDelegate:self];
            [callout setFrame:CGRectMake(0.0f, -CGRectGetHeight(callout.frame), CGRectGetWidth(callout.frame), CGRectGetHeight(callout.frame))];
            
            [pin setCalloutView:callout];
            
            if (_currentLocation != nil && pin.spot.latitude != nil && pin.spot.longitude != nil) {
                CLLocationDistance distance = [_currentLocation distanceFromLocation:[[CLLocation alloc] initWithLatitude:pin.spot.latitude.floatValue longitude:pin.spot.longitude.floatValue]];
                [pin.calloutView.lblDistanceAway setText:[NSString stringWithFormat:@"%.1f Miles", ( distance * kMeterToMile )]];
            } else {
                [pin.calloutView.lblDistanceAway setText:@""];
            }
            
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

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    if (_mapView.hidden || _isRepositioningMap) {
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

#pragma mark - SpotAnnotationCalloutDelegate

- (void)spotAnnotationCallout:(SpotAnnotationCallout *)spotAnnotationCallout clicked:(MatchPercentAnnotationView *)matchPercentAnnotationView {
    [_mapView deselectAnnotation:matchPercentAnnotationView.annotation animated:YES];
    [self goToSpotProfile:matchPercentAnnotationView.spot];
}

#pragma mark - SHButtonLatoLightLocationDelegate

- (void)locationRequestsUpdate:(SHButtonLatoLightLocation *)button location:(LocationChooserViewController *)viewController {
    SHNavigationController *navController = [[SHNavigationController alloc] initWithRootViewController:viewController];
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)locationUpdate:(SHButtonLatoLightLocation *)button location:(CLLocation *)location name:(NSString *)name {
    
    [self showHUD:@"Getting new spots"];
    [_spotList putSpotList:nil latitude:[NSNumber numberWithFloat:location.coordinate.latitude] longitude:[NSNumber numberWithFloat:location.coordinate.longitude] sliders:nil success:^(SpotListModel *spotListModel, JSONAPI *jsonApi) {
        [self hideHUD];
        
        _spotList = spotListModel;
        [_collectionView reloadData];
        
        [self updateView];
        [self updateMatchPercent];
    } failure:^(ErrorModel *errorModel) {
        [self hideHUD];
        [self showAlert:@"Oops" message:errorModel.human];
    }];
    
    _selectedLocation = location;
}

- (void)locationError:(SHButtonLatoLightLocation *)button error:(NSError *)error {
    [self hideHUD];
    [self showAlert:error.localizedDescription message:error.localizedRecoverySuggestion];
}

#pragma mark - Actions

- (void)onClickBack:(id)sender {
    if (_createdWithAdjustSliders == NO) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Save Custom Spotlist as..." message:nil delegate:self cancelButtonTitle:@"Discard" otherButtonTitles:@"Save", nil];
        [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
        [[alertView textFieldAtIndex:0] setPlaceholder:kSpotListModelDefaultName];
        [alertView showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                NSString *name = [alertView textFieldAtIndex:0].text;
                if (name.length == 0) {
                    name = kSpotListModelDefaultName;
                }
                
                [self showHUD:@"Updating name"];
                [_spotList putSpotList:name latitude:nil longitude:nil sliders:nil success:^(SpotListModel *spotListModel, JSONAPI *jsonApi) {
                    [self hideHUD];
                    [self.navigationController popViewControllerAnimated:YES];
                } failure:^(ErrorModel *errorModel) {
                    [self hideHUD];
                    [self showAlert:@"Oops" message:errorModel.human];
                }];
                
            } else {
                [self doDeleteSpotList];
            }
        }];
        
    }
}

- (IBAction)onFoursquareButton:(id)sender {
    // do nothing (for now)
}

- (IBAction)onUpdateSearchResults:(id)sender {
    _doNotMoveMap = TRUE;
    CLLocation *location = [[CLLocation alloc] initWithLatitude:_mapView.centerCoordinate.latitude longitude:_mapView.centerCoordinate.longitude];
    
    [TellMeMyLocation setLastLocation:location completionHandler:^{
        // do nothing
    }];
    
    UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState;
    [UIView animateWithDuration:0.75 delay:0.0 options:options animations:^{
        _btnUpdateSearchResults.alpha = 0.0;
    } completion:^(BOOL finished) {
        [_btnUpdateSearchResults setHidden:YES];
    }];
}

#pragma mark - Private

- (void)updateView {
    if (!_spotList.spots.count) {
        [self showAlert:@"Oops" message:@"There are no spots which match in this location. Please try another search area."];
    }
    
    // We can pass in nil here because we only need to worry about correct showing/hiding of
    // collection view and mapview (not about the changing of the text and iamge of the middle button
    [self updateFooterMapListButton:nil];
    
    // Update map
    [_mapView removeAnnotations:[_mapView annotations]];
    for (SpotModel *spot in _spotList.spots) {
        
        // Place pin
        if (spot.latitude != nil && spot.longitude != nil) {
            MatchPercentAnnotation *annotation = [[MatchPercentAnnotation alloc] init];
            [annotation setSpot:spot];
            annotation.coordinate = CLLocationCoordinate2DMake(spot.latitude.floatValue, spot.longitude.floatValue);
            [_mapView addAnnotation:annotation];
        }
        
    }
    
    if (!_doNotMoveMap) {
        [self repositionMapOnAnnotations:_mapView.annotations animated:FALSE];
    }
    _doNotMoveMap= FALSE;
}

- (void)updateFooterMapListButton:(FooterViewController*)footerViewController {
    if (_showMap == YES) {
        [footerViewController setMiddleButton:@"List" image:[UIImage imageNamed:@"btn_context_list"]];
        
        [_mapView setHidden:NO];
        [_collectionView setHidden:YES];
        [_lblMatchPercent setHidden:YES];
    } else {
        [footerViewController setMiddleButton:@"Map" image:[UIImage imageNamed:@"btn_context_map"]];
        
        [_mapView setHidden:YES];
        [_btnUpdateSearchResults setHidden:YES];
        
        [_btnUpdateSearchResults setHidden:YES];
        [_collectionView setHidden:NO];
        [_lblMatchPercent setHidden:NO];
        
        if (!_spotList.spots.count) {
            _lblMatchPercent.text = @"No Matches";
        }
    }
}

- (void)updateMatchPercent {
    
    if (_spotList.spots.count == 0) {
        [_lblMatchPercent setText:@""];
        return;
    }
    
    CGPoint initialPinchPoint = CGPointMake(_collectionView.center.x + _collectionView.contentOffset.x,
                                            _collectionView.center.y + _collectionView.contentOffset.y);
    
    NSIndexPath *indexPath = [_collectionView indexPathForItemAtPoint:initialPinchPoint];
    
    SpotModel *spot = nil;
    if (indexPath != nil && indexPath.row < _spotList.spots.count) {
        spot = [_spotList.spots objectAtIndex:indexPath.row];
    }
    
    if (spot != nil && spot.match != nil) {
        [_lblMatchPercent setText:[NSString stringWithFormat:@"%@ Match", [spot matchPercent]]];
    }
}

- (void)deleteSpotList {
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Confirm Delete" message:@"Are you sure you want to delete this spotlist?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    [alertView showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            [self doDeleteSpotList];
        }
    }];
    
}

- (void)doDeleteSpotList {
    [self showHUD:@"Deleting"];
    [_spotList deleteSpotList:nil success:^(SpotListModel *spotListModel, JSONAPI *jsonApi) {
        [self hideHUD];
        [self.navigationController popViewControllerAnimated:YES];
    } failure:^(ErrorModel *errorModel) {
        [self hideHUD];
        [self showAlert:@"Oops" message:errorModel.human];
    }];
}

- (void)repositionMapOnAnnotations:(NSArray *)annotations animated:(BOOL)animated {
    _isRepositioningMap = TRUE;
    MKMapRect mapRect = MKMapRectNull;
    
    // do not include the user location
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
    
    if (!MKMapRectIsNull(mapRect)) {
        // ensure points are not positioned below the header by setting the edge padding
        
        // give it a little extra space
        if (MKMapRectGetWidth(mapRect) == 0.0 && MKMapRectGetHeight(mapRect) == 0.0) {
            mapRect.size = MKMapSizeMake(MKMapRectGetWidth(mapRect) + 150.0, MKMapRectGetHeight(mapRect) + 150.0);
        }
        
        [_mapView setVisibleMapRect:mapRect edgePadding:UIEdgeInsetsMake(40.0, 15.0, 90.0, 15.0) animated:animated];
    }
    
    // HACK a bug somehow sets isUserInteractionEnabled to false when a map view animates
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.35 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        _mapView.userInteractionEnabled = TRUE;
        _isRepositioningMap = FALSE;
    });
}

@end
