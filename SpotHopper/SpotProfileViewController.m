//
//  SpotProfileViewController.m
//  SpotHopper
//
//  Created by Josh Holtz on 2/20/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "SpotProfileViewController.h"

#import "UIView+ViewFromNib.h"
#import "UIViewController+Navigator.h"

#import "SpotAnnotation.h"

#import "ReviewSliderCell.h"
#import "SpotImageCollectViewCell.h"

#import "SpotListViewController.h"

#import "AverageReviewModel.h"
#import "ErrorModel.h"
#import "SpotTypeModel.h"
#import "SpotListModel.h"

#import <AFNetworking/UIImageView+AFNetworking.h>

#import <MapKit/MapKit.h>

@interface SpotProfileViewController ()<UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tblSliders;

// Static Header
@property (weak, nonatomic) IBOutlet UILabel *lblSpotType;
@property (weak, nonatomic) IBOutlet UILabel *lblPercentMatch;
@property (weak, nonatomic) IBOutlet UIButton *btnPhoneNumber;

// Header
@property (nonatomic, strong) UIView *headerContent;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *btnImagePrev;
@property (weak, nonatomic) IBOutlet UIButton *btnImageNext;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (nonatomic, strong) AverageReviewModel *averageReview;

@end

@implementation SpotProfileViewController

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

    // Set title
    [self setTitle:_spot.name];
    
    // Shows sidebar button in nav
    [self showSidebarButton:YES animated:YES];
    
    // Configure table header
    // Header content view
    _headerContent = [UIView viewFromNibNamed:@"SpotProfileHeaderView" withOwner:self];
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
    
    [self updateView];
    [self fetchSpot];
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

#pragma mark - UITableViewDelegate


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
    [self goToNewReviewForSpot:_spot];
}

- (IBAction)onClickDrinkMenu:(id)sender {
    
}

#pragma mark - Private

- (void)fetchSpot {
    [_spot getSpot:nil success:^(SpotModel *spotModel, JSONAPI *jsonApi) {
        _averageReview = spotModel.averageReview;
        [_tblSliders reloadData];
    } failure:^(ErrorModel *errorModel) {
        
    }];
}

- (void)updateView {
    
    // Spot type
    [_lblSpotType setText:_spot.spotType.name];
    
    [_lblPercentMatch setHidden:(_spot.match == nil)];
    if (_spot.match != nil) [_lblPercentMatch setText:[NSString stringWithFormat:@"%@ Match", [_spot matchPercent]]];
    
    // Update map
    if (_spot.latitude != nil && _spot.longitude != nil) {
        MKCoordinateRegion mapRegion;
        mapRegion.center = CLLocationCoordinate2DMake(_spot.latitude.floatValue, _spot.longitude.floatValue);
        mapRegion.span = MKCoordinateSpanMake(0.005, 0.005);
        [_mapView setRegion:mapRegion animated: NO];
        
        // Place pin
        SpotAnnotation *annotation = [[SpotAnnotation alloc] init];
        annotation.coordinate = CLLocationCoordinate2DMake(_spot.latitude.floatValue, _spot.longitude.floatValue);
        [_mapView addAnnotation:annotation];
    }
}

- (void)doFindSimilar {
    [self showHUD:@"Finding similar"];
    [SpotListModel postSpotList:_spot.name latitude:_spot.latitude longitude:_spot.longitude sliders:_averageReview.sliders successBlock:^(SpotListModel *spotListModel, JSONAPI *jsonApi) {
        [self hideHUD];
        
        SpotListViewController *viewController = [self.spotsStoryboard instantiateViewControllerWithIdentifier:@"SpotListViewController"];
        [viewController setSpotList:spotListModel];
        
        [self.navigationController pushViewController:viewController animated:YES];
        
    } failure:^(ErrorModel *errorModel) {
        [self hideHUD];
        [self showAlert:@"Oops" message:errorModel.human];
    }];
}

@end
