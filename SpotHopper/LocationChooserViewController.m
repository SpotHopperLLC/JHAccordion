//
//  LocationChooserViewController.m
//  SpotHopper
//
//  Created by Josh Holtz on 2/19/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "LocationChooserViewController.h"

#import "TellMeMyLocation.h"

#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface LocationChooserViewController ()<UITextFieldDelegate, MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *txtSearch;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (nonatomic, strong) TellMeMyLocation *tellMeMyLocation;

@end

@implementation LocationChooserViewController

+ (LocationChooserViewController*)locationChooser {
    LocationChooserViewController *viewController = [[LocationChooserViewController alloc] initWithNibName:@"LocationChooserViewController" bundle:[NSBundle mainBundle]];
    return viewController;
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
    [self setTitle:@"Select a Location"];
    
    _tellMeMyLocation = [[TellMeMyLocation alloc] init];
    
    // Navigation bar buttons
    UIBarButtonItem *barButtonLeft = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(onClickCancel:)];
    [self.navigationItem setLeftBarButtonItem:barButtonLeft];
    
    UIBarButtonItem *barButtonRight = [[UIBarButtonItem alloc] initWithTitle:@"Use" style:UIBarButtonItemStylePlain target:self action:@selector(onClickUse:)];
    [self.navigationItem setRightBarButtonItem:barButtonRight];
 
    // Sets initial location
    MKCoordinateRegion mapRegion;
    mapRegion.center = _initialLocation.coordinate;
    mapRegion.span = MKCoordinateSpanMake(0.2, 0.2);
    [_mapView setRegion:mapRegion animated: YES];
    
    // Shows users current spot
    [_mapView setShowsUserLocation:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

#pragma mark - Tracking

- (NSString *)screenName {
    return @"Location Chooser";
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
                
                MKCoordinateRegion mapRegion;
                mapRegion.center = placemark.location.coordinate;
                mapRegion.span = MKCoordinateSpanMake(0.2, 0.2);
                [_mapView setRegion:mapRegion animated: YES];
            }
        }];
        
    }
    
    return NO;
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    [_txtSearch resignFirstResponder];
}

#pragma mark - Actions

- (void)onClickCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onClickUse:(id)sender {
    if ([_delegate respondsToSelector:@selector(locationChooserViewController:updateLocation:)]) {
        [_delegate locationChooserViewController:self updateLocation:[[CLLocation alloc] initWithLatitude:_mapView.centerCoordinate.latitude longitude:_mapView.centerCoordinate.longitude]];
    }
}

- (IBAction)onClickUseCurrentLocation:(id)sender {
    [_tellMeMyLocation findMe:kCLLocationAccuracyThreeKilometers found:^(CLLocation *newLocation) {
        MKCoordinateRegion mapRegion;
        mapRegion.center = newLocation.coordinate;
        mapRegion.span = MKCoordinateSpanMake(0.2, 0.2);
        [_mapView setRegion:mapRegion animated: YES];
    } failure:^(NSError *error){
        if ([error.domain isEqualToString:kTellMeMyLocationDomain]) {
            [self showAlert:error.localizedDescription message:error.localizedRecoverySuggestion];
        }
    }];
}

@end
