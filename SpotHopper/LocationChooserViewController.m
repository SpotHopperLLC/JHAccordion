//
//  LocationChooserViewController.m
//  SpotHopper
//
//  Created by Josh Holtz on 2/19/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "LocationChooserViewController.h"

#import "TellMeMyLocation.h"

#import <MapKit/MapKit.h>

@interface LocationChooserViewController ()

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (nonatomic, strong) TellMeMyLocation *tellMeMyLocation;

@end

@implementation LocationChooserViewController

+ (LocationChooserViewController*)locationChooser {
    LocationChooserViewController *viewController = [[LocationChooserViewController alloc] initWithNibName:@"LocationChooserViewController" bundle:[NSBundle mainBundle]];
    return viewController;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _tellMeMyLocation = [[TellMeMyLocation alloc] init];
    
    // Navigation bar buttons
    UIBarButtonItem *barButtonLeft = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(onClickCancel:)];
    [self.navigationItem setLeftBarButtonItem:barButtonLeft];
    
    UIBarButtonItem *barButtonRight = [[UIBarButtonItem alloc] initWithTitle:@"Use" style:UIBarButtonItemStylePlain target:self action:@selector(onClickUse:)];
    [self.navigationItem setRightBarButtonItem:barButtonRight];
 
    MKCoordinateRegion mapRegion;
    mapRegion.center = _initialLocation.coordinate;
    mapRegion.span = MKCoordinateSpanMake(0.2, 0.2);
    [_mapView setRegion:mapRegion animated: YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

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
