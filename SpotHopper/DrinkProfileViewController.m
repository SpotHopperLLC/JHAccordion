//
//  DrinkProfileViewController.m
//  SpotHopper
//
//  Created by Josh Holtz on 3/14/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "DrinkProfileViewController.h"

#import "UIView+ViewFromNib.h"
#import "UIViewController+Navigator.h"

#import "SpotAnnotation.h"
#import "SHLabelLatoLight.h"

#import "TellMeMyLocation.h"

#import "ReviewSliderCell.h"
#import "SpotImageCollectViewCell.h"

#import "DrinkListViewController.h"

#import "AverageReviewModel.h"
#import "ErrorModel.h"
#import "SpotModel.h"
#import "DrinkTypeModel.h"
#import "DrinkListModel.h"


#import <AFNetworking/UIImageView+AFNetworking.h>

#import <MapKit/MapKit.h>

@interface DrinkProfileViewController ()<UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tblSliders;

// Static Header
@property (weak, nonatomic) IBOutlet UILabel *lblSpotName;
@property (weak, nonatomic) IBOutlet SHLabelLatoLight *lblInfo;
@property (weak, nonatomic) IBOutlet UILabel *lblPercentMatch;
@property (weak, nonatomic) IBOutlet SHLabelLatoLight *lblABV;
@property (weak, nonatomic) IBOutlet UIButton *btnPhoneNumber;

// Header
@property (nonatomic, strong) UIView *headerContent;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *btnImagePrev;
@property (weak, nonatomic) IBOutlet UIButton *btnImageNext;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (nonatomic, strong) TellMeMyLocation *tellMeMyLocation;
@property (nonatomic, strong) CLLocation *location;

@property (nonatomic, strong) NSString *matchPercent;
@property (nonatomic, strong) AverageReviewModel *averageReview;
@property (nonatomic, strong) NSArray *spots;

@end

@implementation DrinkProfileViewController

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
    
    _matchPercent = [_drink matchPercent];
    
    // Set title
    [self setTitle:_drink.name];
    
    // Shows sidebar button in nav
    [self showSidebarButton:YES animated:YES];
    
    // Configure table header
    // Header content view
    _headerContent = [UIView viewFromNibNamed:@"DrinkProfileHeaderView" withOwner:self];
    [_tblSliders setTableHeaderView:_headerContent];
    
    // COnfigure table
    [_tblSliders registerNib:[UINib nibWithNibName:@"ReviewSliderCellView" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"ReviewSliderCell"];
    
    // Custom collection view layout
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [layout setItemSize:CGSizeMake(320.0f, 165.0f)];
    [layout setMinimumInteritemSpacing:0.0f];
    [layout setMinimumLineSpacing:0.0f];
    [_collectionView setCollectionViewLayout:layout];
    [_collectionView setPagingEnabled:YES];
    
    // Configure collection cell
    [_collectionView registerNib:[UINib nibWithNibName:@"SpotImageCollectionViewCellView" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"SpotImageCollectViewCell"];
    
    // Get my location
    _tellMeMyLocation = [[TellMeMyLocation alloc] init];
    [_tellMeMyLocation findMe:kCLLocationAccuracyThreeKilometers found:^(CLLocation *newLocation) {
        _location = newLocation;
        [self fetchSpots];
    } failure:^(NSError *error) {
        
    }];
    
    [self updateView];
    [self fetchDrink];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Adds contextual footer view
    [self addFooterViewController:^(FooterViewController *footerViewController) {
        [footerViewController showHome:YES];
        [footerViewController setMiddleButton:@"Check-in" image:[UIImage imageNamed:@"btn_context_checkin"]];
        [footerViewController setRightButton:@"Info" image:[UIImage imageNamed:@"btn_context_info"]];
    }];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionViewDataSource

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 3;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    SpotImageCollectViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SpotImageCollectViewCell" forIndexPath:indexPath];
    [cell.imgSpot setImageWithURL:[NSURL URLWithString:@"http://placekitten.com/320/165"]];
    
    return cell;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _averageReview.sliders.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SliderModel *slider = [_averageReview.sliders objectAtIndex:indexPath.row];
    
    ReviewSliderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ReviewSliderCell" forIndexPath:indexPath];
    [cell setSliderTemplate:slider.sliderTemplate withSlider:slider showSliderValue:NO];
    [cell setVibeFeel:YES slider:slider];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 77.0f;
    }
    return 0.0f;
}

#pragma mark - Footer

- (BOOL)footerViewController:(FooterViewController *)footerViewController clickedButton:(FooterViewButtonType)footerViewButtonType {
    if (FooterViewButtonHome == footerViewButtonType) {
        return NO;
    }
    
    return YES;
}

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    MKPinAnnotationView *pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"current"];
    pin.highlighted = NO;
    pin.image = [UIImage imageNamed:@"map_marker_spot"];
    
    return pin;
}

#pragma mark - Actions

- (IBAction)onClickImagePrevious:(id)sender {
    NSArray *indexPaths = [_collectionView indexPathsForVisibleItems];
    
    // Makes sure we have an index path
    if (indexPaths.count > 0) {
        
        NSIndexPath *indexPath = [indexPaths objectAtIndex:0];
        // Makes sure we can go back
        if (indexPath.row > 0) {
            [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:(indexPath.row - 1) inSection:indexPath.section] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
        }
    }
}

- (IBAction)onClickImageNext:(id)sender {
    NSArray *indexPaths = [_collectionView indexPathsForVisibleItems];
    
    // Makes sure we have an index path
    if (indexPaths.count > 0) {
        
        NSIndexPath *indexPath = [indexPaths objectAtIndex:0];
        // Makes sure we can go forward
        if (indexPath.row < ( [self collectionView:_collectionView numberOfItemsInSection:indexPath.section] - 1) ) {
            [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:(indexPath.row + 1) inSection:indexPath.section] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
        }
    }
}

- (IBAction)onClickFindSimilar:(id)sender {
    [self doFindSimilar];
}

- (IBAction)onClickReviewIt:(id)sender {
    [self goToNewReviewForDrink:_drink];
}

- (IBAction)onClickDescription:(id)sender {
    
}

- (IBAction)onClickFindIt:(id)sender {
    [self goToFindDrinksAt:_drink];
}

#pragma mark - Private

- (void)fetchDrink {
    [_drink getDrink:nil success:^(DrinkModel *drinkModel, JSONAPI *jsonApi) {
        _drink = drinkModel;
        _averageReview = drinkModel.averageReview;
        [_tblSliders reloadData];
    } failure:^(ErrorModel *errorModel) {
        
    }];
}

- (void)fetchSpots {
    
    if (_location == nil) {
        return;
    }
    
    NSDictionary *params = @{
                             kSpotModelParamQueryLatitude : [NSNumber numberWithFloat:_location.coordinate.latitude],
                             kSpotModelParamQueryLongitude : [NSNumber numberWithFloat:_location.coordinate.longitude]
                             };
    
    [_drink getSpots:params success:^(NSArray *spotModels, JSONAPI *jsonApi) {
        
        _spots = spotModels;
        [self updateViewMap];
        
    } failure:^(ErrorModel *errorModel) {
    }];
    
}

#pragma mark -

- (void)updateView {
    
    // Spot type
    [_lblSpotName setText:_drink.spot.name];
    
    [_lblPercentMatch setHidden:(_drink.match == nil)];
    if (_drink.match != nil) [_lblPercentMatch setText:[NSString stringWithFormat:@"%@ Match", [_drink matchPercent]]];
    
    // Sets Rating and stuff
    if (_drink.style.length > 0 && _drink.averageReview != nil) {
        [_lblInfo setText:[NSString stringWithFormat:@"%@ - %.1f/10", _drink.style, _drink.averageReview.rating.floatValue]];
    } else if (_drink.style.length > 0) {
        [_lblInfo setText:_drink.style];
    } else if (_drink.averageReview != nil) {
        [_lblInfo setText:[NSString stringWithFormat:@"%.1f/10", _drink.averageReview.rating.floatValue]];
    } else {
        [_lblInfo italic:YES];
        [_lblInfo setText:@"No style or rating"];
    }
    
    // ABV
    if (_drink.abvPercentString.length > 0) {
        [_lblABV setText:_drink.abvPercentString];
    } else {
        [_lblABV setText:@""];
    }
    
}

- (void)updateViewMap {
    
    // Zoom map
    if (_location != nil) {
        MKCoordinateRegion mapRegion;
        mapRegion.center = _location.coordinate;
        mapRegion.span = MKCoordinateSpanMake(0.025, 0.025);
        [_mapView setRegion:mapRegion animated: YES];
    }
    
    // Update map
    [_mapView removeAnnotations:[_mapView annotations]];
    for (SpotModel *spot in _spots) {
        
        // Place pin
        if (spot.latitude != nil && spot.longitude != nil) {
            SpotAnnotation *annotation = [[SpotAnnotation alloc] init];
            annotation.coordinate = CLLocationCoordinate2DMake(spot.latitude.floatValue, spot.longitude.floatValue);
            [_mapView addAnnotation:annotation];
        }
        
    }
    
}

- (void)doFindSimilar {
    
    if (_location == nil) {
        [self showAlert:@"Oops" message:@"Please choose a location"];
        return;
    }
    
    [self showHUD:@"Finding similar"];
    NSString *name = [NSString stringWithFormat:@"Similar to %@", _drink.name];
    [DrinkListModel postDrinkList:name latitude:[NSNumber numberWithFloat:_location.coordinate.latitude] longitude:[NSNumber numberWithFloat:_location.coordinate.longitude] sliders:_averageReview.sliders drinkId:_drink.ID drinkTypeId:_drink.drinkType.ID spotId:nil successBlock:^(DrinkListModel *drinkListModel, JSONAPI *jsonApi) {
        [self hideHUD];
        
        DrinkListViewController *viewController = [self.drinksStoryboard instantiateViewControllerWithIdentifier:@"DrinkListViewController"];
        [viewController setDrinkList:drinkListModel];
        
        [self.navigationController pushViewController:viewController animated:YES];
        
    } failure:^(ErrorModel *errorModel) {
        [self hideHUD];
        [self showAlert:@"Oops" message:errorModel.human];
    }];
}

@end
