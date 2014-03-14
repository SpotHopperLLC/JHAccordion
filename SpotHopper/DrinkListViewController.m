//
//  DrinkListViewController.m
//  SpotHopper
//
//  Created by Josh Holtz on 3/13/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#define ITEM_SIZE_WIDTH 180.0f
#define ITEM_SIZE_HEIGHT 247.0f
#define ITEM_SIZE_HEIGHT_4_INCH 300.0f
#define kMeterToMile 0.000621371f

#import "DrinkListViewController.h"

#import "UIAlertView+Block.h"
#import "UIView+ViewFromNib.h"
#import "UIViewController+Navigator.h"

#import "TellMeMyLocation.h"

#import "CardLayout.h"
#import "SHButtonLatoLightLocation.h"
//#import "SpotAnnotationCallout.h"

#import "SHNavigationController.h"

#import "DrinkCardCollectionViewCell.h"

#import "MatchPercentAnnotation.h"
#import "MatchPercentAnnotationView.h"

#import "ClientSessionManager.h"
#import "ErrorModel.h"

#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface DrinkListViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, MKMapViewDelegate, SHButtonLatoLightLocationDelegate>

@property (weak, nonatomic) IBOutlet UILabel *lblMatchPercent;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet SHButtonLatoLightLocation *btnLocation;
@property (weak, nonatomic) IBOutlet UILabel *lblLocation;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (nonatomic, strong) CLLocation *selectedLocation;
@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, strong) TellMeMyLocation *tellMeMyLocation;

@property (nonatomic, assign) BOOL showMap;

@end

@implementation DrinkListViewController

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
    
    // Sets title
    [self setTitle:_drinkList.name];
    
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
    if (_drinkList.featured == NO) {
        [_btnLocation setDelegate:self];
        if (_drinkList.location != nil) {
            [_btnLocation updateWithLocation:_drinkList.location];
        } else {
            [_btnLocation updateWithLastLocation];
        }
    } else {
        [_lblLocation setHidden:YES];
        [_btnLocation setHidden:YES];
    }
    
    // Initialize stuff
    _showMap = NO;
    
    // Fetches drinklist
    [self fetchDrinkList];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    
    // Adds contextual footer view
    __block DrinkListViewController *this = self;
    [self addFooterViewController:^(FooterViewController *footerViewController) {
        [footerViewController showHome:YES];
        
        if (this.drinkList.featured == NO) {
            [footerViewController setLeftButton:@"Delete" image:[UIImage imageNamed:@"btn_context_delete"]];
        }
        
        [this updateFooterMapListButton:footerViewController];
        [footerViewController setRightButton:@"Info" image:[UIImage imageNamed:@"btn_context_info"]];
    }];
    
}

- (BOOL)footerViewController:(FooterViewController *)footerViewController clickedButton:(FooterViewButtonType)footerViewButtonType {
    if (FooterViewButtonLeft == footerViewButtonType) {
        [self deleteDrinkList];
        return YES;
    } else if (FooterViewButtonMiddle == footerViewButtonType) {
        _showMap = !_showMap;
        [self updateFooterMapListButton:footerViewController];
        return YES;
    } else if (FooterViewButtonRight == footerViewButtonType) {
        return YES;
    }
    
    return NO;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _drinkList.drinks.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    DrinkModel *drink = [_drinkList.drinks objectAtIndex:indexPath.row];
    
    DrinkCardCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SpotCardCollectionViewCell" forIndexPath:indexPath];
    [cell setDrink:drink];
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    DrinkModel *drink = [_drinkList.drinks objectAtIndex:indexPath.row];
//    [self goToDrinkProfile:spot];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self updateMatchPercent];
}

#pragma mark - SHButtonLatoLightLocationDelegate

- (void)locationRequestsUpdate:(SHButtonLatoLightLocation *)button location:(LocationChooserViewController *)viewController {
    SHNavigationController *navController = [[SHNavigationController alloc] initWithRootViewController:viewController];
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)locationUpdate:(SHButtonLatoLightLocation *)button location:(CLLocation *)location name:(NSString *)name {
    if (_selectedLocation != nil) {
        
        [self showHUD:@"Getting new drinks"];
        [_drinkList putDrinkList:nil latitude:[NSNumber numberWithFloat:location.coordinate.latitude] longitude:[NSNumber numberWithFloat:location.coordinate.longitude] sliders:nil success:^(DrinkListModel *drinkListModel, JSONAPI *jsonApi) {
            [self hideHUD];
            
            _drinkList = drinkListModel;
            [_collectionView reloadData];
            
            [self updateView];
            [self updateMatchPercent];
        } failure:^(ErrorModel *errorModel) {
            [self hideHUD];
            [self showAlert:@"Oops" message:errorModel.human];
        }];
        
    }
    
    _selectedLocation = location;
}

- (void)locationError:(SHButtonLatoLightLocation *)button error:(NSError *)error {
    [self showAlert:error.localizedDescription message:error.localizedRecoverySuggestion];
}

#pragma mark - Private

- (void)updateView {
    
    // Zoom map
//    if (_spotList.latitude != nil && _spotList.longitude != nil) {
//        MKCoordinateRegion mapRegion;
//        mapRegion.center = [[CLLocation alloc] initWithLatitude:_spotList.latitude.floatValue longitude:_spotList.longitude.floatValue].coordinate;
//        mapRegion.span = MKCoordinateSpanMake(0.1, 0.1);
//        [_mapView setRegion:mapRegion animated: YES];
//    }
    
    // Update map
//    [_mapView removeAnnotations:[_mapView annotations]];
//    for (SpotModel *spot in _spotList.spots) {
//        
//        // Place pin
//        if (spot.latitude != nil && spot.longitude != nil) {
//            MatchPercentAnnotation *annotation = [[MatchPercentAnnotation alloc] init];
//            [annotation setSpot:spot];
//            annotation.coordinate = CLLocationCoordinate2DMake(spot.latitude.floatValue, spot.longitude.floatValue);
//            [_mapView addAnnotation:annotation];
//        }
//        
//    }
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
        [_collectionView setHidden:NO];
        [_lblMatchPercent setHidden:NO];
    }
}

- (void)updateMatchPercent {
    CGPoint initialPinchPoint = CGPointMake(_collectionView.center.x + _collectionView.contentOffset.x,
                                            _collectionView.center.y + _collectionView.contentOffset.y);
    
    NSIndexPath *indexPath = [_collectionView indexPathForItemAtPoint:initialPinchPoint];
    
    DrinkModel *drink = nil;
    if (indexPath != nil && indexPath.row < _drinkList.drinks.count) {
        drink = [_drinkList.drinks objectAtIndex:indexPath.row];
    }
    
    if (drink != nil && drink.match != nil) {
        [_lblMatchPercent setText:[NSString stringWithFormat:@"%@ Match", [drink matchPercent]]];
    }
}

- (void)fetchDrinkList {
    
    [self showHUD:@"Getting drinks"];
    [_drinkList getDrinkList:nil success:^(DrinkListModel *drinkListModel, JSONAPI *jsonAPi) {
        [self hideHUD];
        
        _drinkList = drinkListModel;
        [_collectionView reloadData];
        
        [self updateView];
        [self updateMatchPercent];
    } failure:^(ErrorModel *errorModel) {
        [self hideHUD];
        [_collectionView reloadData];
        
        [self updateMatchPercent];
    }];
    
}

- (void)deleteDrinkList {
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Confirm Delete" message:@"Are you sure you want to delete this drinklist?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    [alertView showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            [self doDeleteDrinkList];
        }
    }];
    
}

- (void)doDeleteDrinkList {
    [self showHUD:@"Deleting"];
    [_drinkList deleteDrinkList:nil success:^(DrinkListModel *drinkListModel, JSONAPI *jsonApi) {
        [self hideHUD];
        [self.navigationController popViewControllerAnimated:YES];
    } failure:^(ErrorModel *errorModel) {
        [self hideHUD];
        [self showAlert:@"Oops" message:errorModel.human];
    }];
}

@end
