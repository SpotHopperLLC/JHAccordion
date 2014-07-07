//
//  FindDrinksAtViewController.m
//  SpotHopper
//
//  Created by Josh Holtz on 3/14/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "FindDrinksAtViewController.h"

#import "UIViewController+Navigator.h"

#import "SHButtonLatoLightLocation.h"
#import "SpotAnnotationCallout.h"

#import "MatchPercentAnnotation.h"
#import "MatchPercentAnnotationView.h"

#import "SHNavigationController.h"

#import "SpotModel.h"
#import "ErrorModel.h"

#import "TellMeMyLocation.h"
#import "Tracker.h"

#import <MapKit/MapKit.h>

@interface FindDrinksAtViewController ()<MKMapViewDelegate, SHButtonLatoLightLocationDelegate, SpotAnnotationCalloutDelegate>

@property (weak, nonatomic) IBOutlet UILabel *lblNear;
@property (weak, nonatomic) IBOutlet SHButtonLatoLightLocation *btnLocation;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (nonatomic, strong) NSMutableArray *spots;
@property (nonatomic, strong) CLLocation *location;

@end

@implementation FindDrinksAtViewController {
    BOOL _updatedSearchNeeded;
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
    [self setTitle:[NSString stringWithFormat:@"Find %@", _drink.name]];
    
    // Shows sidebar button in nav
    [self showSidebarButton:YES animated:YES];

    // Locations
    [_btnLocation setDelegate:self];
    [_btnLocation updateWithLastLocation];
    
    // place the image after the text
    NSString *text = [_btnLocation titleForState:UIControlStateNormal];
    CGFloat textWidth = [self widthForString:text font:_btnLocation.titleLabel.font maxWidth:CGFLOAT_MAX];
    _btnLocation.imageEdgeInsets = UIEdgeInsetsMake(0, (textWidth + 15), 0, 0);
    _btnLocation.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    
    [_lblNear setFont:[UIFont fontWithName:@"Lato-Regular" size:_lblNear.font.pointSize]];
    
    // Initializes stuff
    _spots = [NSMutableArray array];
    
    _updatedSearchNeeded = TRUE;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    
    // Adds contextual footer view
    [self addFooterViewController:^(FooterViewController *footerViewController) {
        [footerViewController showHome:YES];
        [footerViewController setRightButton:@"Info" image:[UIImage imageNamed:@"btn_context_info"]];
    }];
    
    if (_updatedSearchNeeded) {
        _location = [TellMeMyLocation lastLocation];
        [self fetchSpots];
    }
}

- (BOOL)footerViewController:(FooterViewController *)footerViewController clickedButton:(FooterViewButtonType)footerViewButtonType {
    if (FooterViewButtonRight == footerViewButtonType) {
        [self showAlert:@"Info" message:kInfoDrinkAt];
        return YES;
    }
    
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Tracking

- (NSString *)screenName {
    return @"Find Drinks At Spot";
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
    [self goToSpotProfile:matchPercentAnnotationView.spot];
}

#pragma mark - SHButtonLatoLightLocationDelegate

- (void)locationRequestsUpdate:(SHButtonLatoLightLocation *)button location:(LocationChooserViewController *)viewController {
    SHNavigationController *navController = [[SHNavigationController alloc] initWithRootViewController:viewController];
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)locationUpdate:(SHButtonLatoLightLocation *)button location:(CLLocation *)location name:(NSString *)name {
    _updatedSearchNeeded = TRUE;
}

- (void)locationDidChooseLocation:(CLLocation *)location {
    _location = location;
    
    [_spots removeAllObjects];
    [self fetchSpots];
}

- (void)locationError:(SHButtonLatoLightLocation *)button error:(NSError *)error {
    [self showAlert:error.localizedDescription message:error.localizedRecoverySuggestion];
}

#pragma mark - Private

- (void)updateView {
    
    // Zoom map
    if (_location != nil) {
        MKCoordinateRegion mapRegion;
        mapRegion.center = _location.coordinate;
        mapRegion.span = MKCoordinateSpanMake(0.05, 0.05);
        [_mapView setRegion:mapRegion animated: YES];
    }
    
    // Update map
    [_mapView removeAnnotations:[_mapView annotations]];
    for (SpotModel *spot in _spots) {
        
        // Place pin
        if (spot.latitude != nil && spot.longitude != nil) {
            MatchPercentAnnotation *annotation = [[MatchPercentAnnotation alloc] init];
            [annotation setSpot:spot];
            annotation.coordinate = CLLocationCoordinate2DMake(spot.latitude.floatValue, spot.longitude.floatValue);
            [_mapView addAnnotation:annotation];
        }
        
    }
}

- (void)fetchSpots {
    _updatedSearchNeeded = FALSE;
    
    if (_location == nil) {
        [self showAlert:@"Oops" message:@"Please choose a location"];
        return;
    }
    
    [self showHUD:@"Finding spots"];
    [_drink fetchSpotsForLocation:_location success:^(NSArray *spotModels) {
        [self hideHUD];
        
        [_spots addObjectsFromArray:spotModels];
        [self updateView];
        
    } failure:^(ErrorModel *errorModel) {
        [self hideHUD];
        [self showAlert:@"Oops" message:errorModel.human];
        [Tracker logError:errorModel class:[self class] trace:NSStringFromSelector(_cmd)];
    }];
}

@end
