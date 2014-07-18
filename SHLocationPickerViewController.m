//
//  SHLocationPickerViewController.m
//  SpotHopper
//
//  Created by Brennan Stehling on 7/8/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "SHLocationPickerViewController.h"

#import "TellMeMyLocation.h"
#import "SVPulsingAnnotationView.h"

#import "SHStyleKit+Additions.h"
#import "ErrorModel.h"
#import "Tracker.h"

#import <QuartzCore/QuartzCore.h>

#define kMapPadding 10000.0f

@interface SHLocationPickerViewController ()<UITextFieldDelegate, MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;

@property (weak, nonatomic) IBOutlet UIView *selectThisLocationView;
@property (weak, nonatomic) IBOutlet UIButton *selectThisLocationButton;

@property (nonatomic, strong) TellMeMyLocation *tellMeMyLocation;

@end

@implementation SHLocationPickerViewController

#pragma mark - View Lifecycle
#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSAssert(self.searchTextField, @"Outlet is required");
    
    self.title = @"Select a Location";
    
    self.tellMeMyLocation = [[TellMeMyLocation alloc] init];
    
    // set the left view in search text field
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
    UIImageView *leftImageView = [[UIImageView alloc] initWithFrame:CGRectMake(8, 6, 16, 16)];
    leftImageView.alpha = 0.5f;
    [SHStyleKit setImageView:leftImageView withDrawing:SHStyleKitDrawingSearchIcon color:SHStyleKitColorMyTextColor];
    [leftView addSubview:leftImageView];
    
    self.searchTextField.leftView = leftView;
    self.searchTextField.leftViewMode = UITextFieldViewModeAlways;
    
    self.mapView.showsUserLocation = YES;
    
    [self styleSelectThisLocation];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    UIBarButtonItem *barButtonLeft = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonTapped:)];
    [self.navigationItem setLeftBarButtonItem:barButtonLeft];
    UIBarButtonItem *barButtonRight = [[UIBarButtonItem alloc] initWithTitle:@"Select" style:UIBarButtonItemStylePlain target:self action:@selector(selectButtonTapped:)];
    [self.navigationItem setRightBarButtonItem:barButtonRight];
    
    [self.mapView setRegion:self.initialRegion animated:FALSE];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - Tracking

- (NSString *)screenName {
    return @"Location Picker";
}

#pragma mark - User Actions
#pragma mark -

- (IBAction)cancelButtonTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:TRUE];
}

- (IBAction)selectButtonTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(locationPickerViewController:didSelectRegion:)]) {
        [self.delegate locationPickerViewController:self didSelectRegion:self.mapView.region];
    }
}

- (IBAction)compassButtonTapped:(id)sender {
    [self.tellMeMyLocation findMe:kCLLocationAccuracyKilometer found:^(CLLocation *newLocation) {
        [self repositionMapViewOnLocation:newLocation animated:FALSE];
    } failure:^(NSError *error){
        if ([error.domain isEqualToString:kTellMeMyLocationDomain]) {
            [self showAlert:error.localizedDescription message:error.localizedRecoverySuggestion];
        }
    }];
}

#pragma mark - Private
#pragma mark -

- (void)styleSelectThisLocation {
    UIColor *tintColor = [SHStyleKit color:SHStyleKitColorMyTintColor];
    self.selectThisLocationButton.titleLabel.font = [UIFont fontWithName:@"Lato-Bold" size:self.selectThisLocationButton.titleLabel.font.pointSize];
    self.selectThisLocationButton.tintColor = tintColor;
    [self.selectThisLocationButton setTitleColor:tintColor forState:UIControlStateNormal];
    
    self.selectThisLocationView.layer.cornerRadius = 5.0f;
}

- (void)repositionMapViewOnLocation:(CLLocation *)location animated:(BOOL)animated {
    MKMapRect mapRect = MKMapRectNull;
    MKMapPoint mapPoint = MKMapPointForCoordinate(location.coordinate);
    
    CGFloat padding = kMapPadding;
    mapRect.origin.x = mapPoint.x - padding/2;
    mapRect.origin.y = mapPoint.y - padding/2;
    mapRect.size = MKMapSizeMake(MKMapRectGetWidth(mapRect) + padding, MKMapRectGetHeight(mapRect) + padding);
    
    [self.mapView setVisibleMapRect:mapRect edgePadding:UIEdgeInsetsMake(5.0f, 5.0f, 5.0f, 5.0f) animated:TRUE];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    if (textField.text.length > 0) {
        
        // Reverse geocodes search text
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        
        [self showHUD:@"Locating..."];
        [geocoder geocodeAddressString:textField.text completionHandler:^(NSArray *placemarks, NSError *error) {
            [self hideHUD];
            if (error || placemarks.count == 0) {
                [self showAlert:@"Oops" message:@"Could not find the location you are looking for"];
            } else {
                CLPlacemark *placemark = [placemarks objectAtIndex:0];
                [self repositionMapViewOnLocation:placemark.location animated:FALSE];
            }
        }];
    }
    
    return NO;
}

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    MKAnnotationView *annotationView = nil;

    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        static NSString *identifier = @"CurrentLocation";
        SVPulsingAnnotationView *pulsingView = (SVPulsingAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        
        if (!pulsingView) {
            pulsingView = [[SVPulsingAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            pulsingView.annotationColor = [SHStyleKit color:SHStyleKitColorMyTintColor];
        }
        
        pulsingView.canShowCallout = YES;
        
        annotationView = pulsingView;
    }
    
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    [self.searchTextField resignFirstResponder];
    
    CLLocation *boundaryLocation = [[CLLocation alloc] initWithLatitude:(mapView.region.center.latitude + mapView.region.span.latitudeDelta) longitude:mapView.region.center.longitude];
    CLLocation *centerLocation = [[CLLocation alloc] initWithLatitude:mapView.region.center.latitude longitude:mapView.region.center.longitude];
    CLLocationDistance distance = [centerLocation distanceFromLocation:boundaryLocation];

    if (distance > 10000) {
        self.navigationItem.title = @"Location";
    }
    else {
        CLLocationCoordinate2D coordinate = self.mapView.centerCoordinate;
        CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
        
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
            if (placemarks.count) {
                CLPlacemark *placemark = placemarks[0];
                self.navigationItem.title = [TellMeMyLocation locationNameFromPlacemark:placemark];
            }
        }];
    }
}

@end
