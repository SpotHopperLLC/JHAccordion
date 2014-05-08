//
//  SpotProfileViewController.m
//  SpotHopper
//
//  Created by Josh Holtz on 2/20/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#define kSpecialsClosedHeight 51.0f
#define kSpecialsOpenedHeight 113.0f

#import "SpotProfileViewController.h"

#import "NSArray+DailySpecials.h"
#import "NSDate+Globalize.h"
#import "UIButton+Block.h"
#import "UIView+ViewFromNib.h"
#import "UIViewController+Navigator.h"
#import "NSNull+Debugging.h"
#import "NetworkHelper.h"

#import "SpotAnnotation.h"
#import "SHLabelLatoLight.h"

#import "ReviewSliderCell.h"
#import "SpotImageCollectViewCell.h"

#import "CheckinConfirmationViewController.h"
#import "SpotListViewController.h"

#import "AverageReviewModel.h"
#import "ErrorModel.h"
#import "ImageModel.h"
#import "LiveSpecialModel.h"
#import "SpotTypeModel.h"
#import "SpotListModel.h"

#import <AFNetworking/UIImageView+AFNetworking.h>
#import "JHAccordion.h"

#import <MapKit/MapKit.h>

@interface SpotProfileViewController () <UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate, MKMapViewDelegate, JHAccordionDelegate, CheckinConfirmationViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tblSliders;

// Static Header
@property (weak, nonatomic) IBOutlet UILabel *lblSpotType;
@property (weak, nonatomic) IBOutlet UILabel *lblPercentMatch;
@property (weak, nonatomic) IBOutlet UIButton *btnPhoneNumber;
@property (weak, nonatomic) IBOutlet UILabel *lblHoursOpen;

// Specials
@property (weak, nonatomic) IBOutlet UIView *viewSpecials;
@property (weak, nonatomic) IBOutlet UILabel *lblSpecialTitle;
@property (weak, nonatomic) IBOutlet SHLabelLatoLight *lblSpecialInfo;
@property (weak, nonatomic) IBOutlet UIImageView *imgExpand;
@property (weak, nonatomic) IBOutlet UIView *viewSpecialInfo;
@property (weak, nonatomic) IBOutlet UIButton *btnShareLiveSpecial;
@property (nonatomic, assign) BOOL specialsOpen;

// Header
@property (nonatomic, strong) UIView *headerContent;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *btnImagePrev;
@property (weak, nonatomic) IBOutlet UIButton *btnImageNext;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *lblAddress;
@property (weak, nonatomic) IBOutlet UIButton *btnDirections;

@property (nonatomic, strong) NSString *matchPercent;
@property (nonatomic, strong) AverageReviewModel *averageReview;
@property (nonatomic, strong) NSMutableArray *sliders;
@property (nonatomic, strong) NSMutableArray *advancedSliders;

@property (nonatomic, strong) JHAccordion *accordion;
@property (nonatomic, strong) UIView *sectionHeaderAdvanced;

@property (nonatomic, strong) CheckinConfirmationViewController *checkinConfirmationViewController;

@property (nonatomic, weak) UIButton *btnSeeAll;

@end

@implementation SpotProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    _matchPercent = [_spot matchPercent];
    
    // Shows sidebar button in nav
    [self showSidebarButton:YES animated:YES];
    
    // Configures accordion
    _accordion = [[JHAccordion alloc] initWithTableView:_tblSliders];
    [_accordion setDelegate:self];
    [_accordion openSection:0];
    
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
    
    // Initialize stuff
    _specialsOpen = NO;
    [_lblSpecialInfo italic:YES];
    
    [self updateView];
    [self fetchSpot];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    
    // Adds contextual footer view
    [self addFooterViewController:^(FooterViewController *footerViewController) {
        [footerViewController showHome:YES];
        [footerViewController setMiddleButton:@"Check-in" image:[UIImage imageNamed:@"btn_context_checkin"]];
        [footerViewController setRightButton:@"Info" image:[UIImage imageNamed:@"btn_context_info"]];
    }];
    
    [self updateImageArrows];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Show checkin view
    if (_isCheckin == YES) {
        
        // Setting to NO so we don't do this ever, ever, ever again
        _isCheckin = NO;
        
        // Showing checkin
        [self showShareViewControllerWithCheckIn:_checkIn];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Tracking

- (NSString *)screenName {
    return @"Spot Profile";
}

#pragma mark - UICollectionViewDataSource

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    // Alwas should show one image (the once being the placeholder if spot has no images)
    return MAX( 1 , [_spot images].count );
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SpotImageCollectViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SpotImageCollectViewCell" forIndexPath:indexPath];
    
    // Uses placeholder if spot has no images
    if ([_spot images].count == 0) {
        [cell setImage:nil withPlaceholder:_spot.placeholderImage];
    }
    // Sets the images defined by the spot
    else {
        ImageModel *imageModel = _spot.images[indexPath.item];
        [cell setImage:imageModel withPlaceholder:_spot.placeholderImage];
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self goToPhotoAlbum:[_spot images] atIndex:indexPath.item];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return _sliders.count;
    } else if (section == 1) {
        return _advancedSliders.count;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        SliderModel *slider = [_sliders objectAtIndex:indexPath.row];
        
        ReviewSliderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ReviewSliderCell" forIndexPath:indexPath];
        [cell setSliderTemplate:slider.sliderTemplate withSlider:slider showSliderValue:NO];
        [cell setVibeFeel:YES slider:slider];
    
        return cell;
    } else if (indexPath.section == 1) {
        SliderModel *slider = [_advancedSliders objectAtIndex:indexPath.row];
        
        ReviewSliderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ReviewSliderCell" forIndexPath:indexPath];
        [cell setSliderTemplate:slider.sliderTemplate withSlider:slider showSliderValue:NO];
        [cell setVibeFeel:YES slider:slider];
        
        return cell;
    }
    
    return nil;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 77.0f;
    } else if (indexPath.section == 1) {
        return ( [_accordion isSectionOpened:indexPath.section] ? 77.0f : 0.0f);
    }
    return 0.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 2) {
        _sectionHeaderAdvanced = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(tableView.frame), 40.0f)];
        [_sectionHeaderAdvanced setBackgroundColor:[UIColor clearColor]];
        [_sectionHeaderAdvanced setUserInteractionEnabled:YES];
        
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(tableView.frame), 40.0f)];
        [button setBackgroundColor:[UIColor clearColor]];
        [button setTitleColor:kColorOrange forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont fontWithName:@"Lato-Light" size:16.0f]];
        [button.titleLabel setTextAlignment:NSTextAlignmentCenter];
        
        if ([_accordion isSectionOpened:(section-1)]) {
            [button setTitle:@"See less" forState:UIControlStateNormal];
        }
        else {
            [button setTitle:@"See all" forState:UIControlStateNormal];
        }
        
        // Sets up for accordion
        [button setTag:1];
        [button addTarget:_accordion action:@selector(onClickSection:) forControlEvents:UIControlEventTouchUpInside];
        
        [_sectionHeaderAdvanced addSubview:button];
        _btnSeeAll = button;
        
        return _sectionHeaderAdvanced;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 2) {
        if (_advancedSliders.count > 0) {
            return 40.0f;
        }
    }
    return 0.0f;
}

#pragma mark - JHAccordionDelegate

- (void)accordion:(JHAccordion *)accordion openingSection:(NSInteger)section {
}

- (void)accordion:(JHAccordion *)accordion closingSection:(NSInteger)section {
}

- (void)accordion:(JHAccordion *)accordion openedSection:(NSInteger)section {
    if (_btnSeeAll) {
        [_btnSeeAll setTitle:@"See less" forState:UIControlStateNormal];
    }
}

- (void)accordion:(JHAccordion *)accordion closedSection:(NSInteger)section {
    if (_btnSeeAll) {
        [_btnSeeAll setTitle:@"See all" forState:UIControlStateNormal];
    }
}

#pragma mark - Footer

- (BOOL)footerViewController:(FooterViewController *)footerViewController clickedButton:(FooterViewButtonType)footerViewButtonType {
    if (FooterViewButtonHome == footerViewButtonType) {
        return NO;
    } else if (FooterViewButtonMiddle == footerViewButtonType) {
        [self showShareViewControllerWithSpot:_spot shareType:ShareViewControllerShareCheckin];
    } else if (FooterViewButtonRight == footerViewButtonType) {
        [self showAlert:@"Info" message:kInfoSpotProfile];
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

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == _collectionView) {
        [self updateImageArrows];
    }
}

#pragma mark - CheckinConfirmationViewControllerDelegate

- (void)checkinConfirmationViewControllerClickedClose:(CheckinConfirmationViewController *)viewController {
    [self hideCheckinConfirmationViewController:nil];
}

- (void)checkinConfirmationViewControllerClickedDrinkList:(CheckinConfirmationViewController *)viewController {
    [self hideCheckinConfirmationViewController:^{
        [self goToDrinkListMenuAtSpot:_spot];
    }];
}

- (void)checkinConfirmationViewControllerClickedFullMenu:(CheckinConfirmationViewController *)viewController {
    [self hideCheckinConfirmationViewController:^{
        [self goToMenu:_spot];
    }];
}

#pragma mark - Actions

- (IBAction)onClickCall:(id)sender {
    NSString *phoneNumber = [@"telprompt://" stringByAppendingString:_spot.phoneNumber];
    NSURL *url =[NSURL URLWithString:phoneNumber];
    if ([[UIApplication sharedApplication] canOpenURL:url] == YES) {
        [[UIApplication sharedApplication] openURL:url];
    }
}

- (IBAction)onClickImagePrevious:(id)sender {
    NSArray *indexPaths = [_collectionView indexPathsForVisibleItems];
    
    // Makes sure we have an index path
    if (indexPaths.count > 0) {
        
        NSIndexPath *indexPath = [indexPaths objectAtIndex:0];
        // Makes sure we can go back
        if (indexPath.row > 0) {
            [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:(indexPath.row - 1) inSection:indexPath.section] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.4 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [self updateImageArrows];
            });
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
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.4 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [self updateImageArrows];
            });
        }
    }
}

- (IBAction)onClickSpecial:(id)sender {
    _specialsOpen = !_specialsOpen;
    [self updateViewSpecials:YES];
}

- (IBAction)onClickShareSpecial:(id)sender {
    LiveSpecialModel *liveSpecial = [_spot currentLiveSpecial];
    liveSpecial.spot = _spot;
    
    [self showLiveSpecialViewController:liveSpecial needToFetch:NO];
}

- (IBAction)onClickFindSimilar:(id)sender {
    [self doFindSimilar];
}

- (IBAction)onClickReviewIt:(id)sender {
    [self goToNewReviewForSpot:_spot];
}

- (IBAction)onClickDrinkMenu:(id)sender {
    [self goToMenu:_spot];
}

- (IBAction)onClickDirections:(id)sender {
    [self promptForDirectionsForSpot:_spot];
}

#pragma mark - Private - Checkin

- (void)shareViewControllerClickedClose:(ShareViewController *)viewController {
    [self hideShareViewController:^{
        
        if (ShareViewControllerShareCheckin == viewController.shareType) {
            [self showCheckinConfirmationViewController];
        }
        
    }];
}

- (void)shareViewControllerDidFinish:(ShareViewController *)viewController {
    [self hideShareViewController:^{
        
        if (ShareViewControllerShareCheckin == viewController.shareType) {
            [self showCheckinConfirmationViewController];
        }
        
    }];
}

- (void)showCheckinConfirmationViewController {
    if (_checkinConfirmationViewController == nil) {
        
        // Create live special view controller
        _checkinConfirmationViewController = [[self checkinStoryboard] instantiateViewControllerWithIdentifier:( IS_FOUR_INCH ? @"CheckinConfirmationViewController" : @"CheckinConfirmationViewControllerIPhone4" )];
        [_checkinConfirmationViewController setDelegate:self];
        
        // Set alpha to zero so we can animate in
        [_checkinConfirmationViewController.view setAlpha:0.0f];
        [_checkinConfirmationViewController.view setFrame:self.navigationController.view.frame];
        
        // Adding to window
        [[[UIApplication sharedApplication] keyWindow]  addSubview:_checkinConfirmationViewController.view];
        
        // Animating in
        [UIView animateWithDuration:0.35 animations:^{
            [_checkinConfirmationViewController.view setAlpha:1.0f];
        }];
    }
    
    // Updating live special text
    [_checkinConfirmationViewController setSpot:_spot];
}

- (void)hideCheckinConfirmationViewController:(void(^)(void))completion {
    
    // Animating checkkin confirmation out
    [UIView animateWithDuration:0.35 animations:^{
        [_checkinConfirmationViewController.view setAlpha:0.0f];
    } completion:^(BOOL finished) {
        
        // Removing checkin confirmation from view
        [_checkinConfirmationViewController.view removeFromSuperview];
        _checkinConfirmationViewController = nil;
        
        if (completion != nil) {
            completion();
        }
    }];
}

#pragma mark - Private

- (void)fetchSpot {
    [_spot getSpot:nil success:^(SpotModel *spotModel, JSONAPI *jsonApi) {
        _spot = spotModel;
        _averageReview = spotModel.averageReview;
        [self initSliders];
        [self updateView];
    } failure:^(ErrorModel *errorModel) {
        
    }];
}

- (void)initSliders {
    
    // Filling sliders if nil
    if (_sliders == nil) {
        _sliders = [NSMutableArray arrayWithArray:_averageReview.sliders];
        [_sliders sortUsingComparator:^NSComparisonResult(SliderModel *obj1, SliderModel *obj2) {
            return [obj1.sliderTemplate.order compare:obj2.sliderTemplate.order];
        }];
    }
    
    // Filling advanced sliders if nil
    if (_advancedSliders == nil) {
        _advancedSliders = [NSMutableArray array];
        
        // Moving advanced sliders into their own array
        for (SliderModel *slider in _sliders) {
            if (slider.sliderTemplate.required == NO) {
                [_advancedSliders addObject:slider];
            }
        }
        
        // Removing advances sliders from basic array
        for (SliderModel *slider in _advancedSliders) {
            [_sliders removeObject:slider];
        }
    }
    
    // Update view
    [_tblSliders reloadData];
}

- (void)updateView {
    
    // Reload images
    [_collectionView reloadData];
    
    // Set title
    [self setTitle:_spot.name];
    
    // Sets "Opens at <some time>" or "Open until <some time>"
    NSArray *hoursForToday = [_spot.hoursOfOperation datesForToday];
    if (hoursForToday != nil) {
        
        // Creats formatter
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"h:mm a"];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
        
        // Gets open and close dates
        NSDate *dateOpen = hoursForToday.firstObject;
        NSDate *dateClose = hoursForToday.lastObject;
        
        // Sets the stuff
        NSDate *now = [NSDate date];
        if ([now timeIntervalSinceDate:dateOpen] > 0 && [now timeIntervalSinceDate:dateClose] < 0) {
            [_lblHoursOpen setText:[NSString stringWithFormat:@"Open until %@", [dateFormatter stringFromDate:dateClose]]];
        } else {
            [_lblHoursOpen setText:[NSString stringWithFormat:@"Opens at %@", [dateFormatter stringFromDate:dateOpen]]];
        }
        
    } else {
        [_lblHoursOpen setText:@""];
    }
    
    // Spot type
    [_lblSpotType setText:_spot.spotType.name];
    
    [_lblPercentMatch setHidden:(_matchPercent == nil)];
    if (_matchPercent != nil) [_lblPercentMatch setText:[NSString stringWithFormat:@"%@ Match", _matchPercent]];
    
    // Spot addres
    [_lblAddress setText:[_spot fullAddress]];
    
    // Sets phonenumber
    [_btnPhoneNumber setTitle:_spot.phoneNumber forState:UIControlStateNormal];
    [_btnPhoneNumber setHidden:( _spot.phoneNumber.length == 0 )];
    
    // Sets specials
    LiveSpecialModel *liveSpecial = [_spot currentLiveSpecial];
    NSString *todaysSpecial = [[_spot dailySpecials] specialsForToday];
    if (liveSpecial != nil) {
        [_lblSpecialTitle setText:@"Live Special!"];
        [_lblSpecialInfo  setText:liveSpecial.text];
        [_viewSpecials setHidden:NO];
        [_btnShareLiveSpecial setHidden:NO];
    } else if (todaysSpecial != nil) {
        [_lblSpecialTitle setText:@"Current Special!"];
        [_lblSpecialInfo setText:todaysSpecial];
        [_viewSpecials setHidden:NO];
        [_btnShareLiveSpecial setHidden:YES];
    } else {
        [_viewSpecials setHidden:YES];
    }
    [self updateViewSpecials:NO];
    
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
    
    [NetworkHelper preloadImageModels:_spot.images];
}

- (void)updateViewSpecials:(BOOL)animate {
    
    CGRect frame = _viewSpecials.frame;
    frame.size.height = (_specialsOpen ? kSpecialsOpenedHeight : kSpecialsClosedHeight);
    
    float radians = (_specialsOpen ? M_PI : 0);
    
    // Animate
    [UIView animateWithDuration:( animate ? 0.35 : 0.0 ) animations:^{
        _imgExpand.transform = CGAffineTransformMakeRotation(radians);
        [_viewSpecialInfo setAlpha:(_specialsOpen ? 1.0f : 0.0f)];
        [_viewSpecials setFrame:frame];
    }];
    
}

- (void)doFindSimilar {
    [self showHUD:@"Finding similar"];
    
    NSString *name = [NSString stringWithFormat:@"Similar to %@", _spot.name];
    [SpotListModel postSpotList:name spotId:_spot.ID spotTypeId:_spot.spotType.ID latitude:_spot.latitude longitude:_spot.longitude sliders:_averageReview.sliders successBlock:^(SpotListModel *spotListModel, JSONAPI *jsonApi) {
        [self hideHUD];
        
        SpotListViewController *viewController = [self.spotsStoryboard instantiateViewControllerWithIdentifier:@"SpotListViewController"];
        [viewController setSpotList:spotListModel];
        
        [self.navigationController pushViewController:viewController animated:YES];
        
    } failure:^(ErrorModel *errorModel) {
        [self hideHUD];
        [self showAlert:@"Oops" message:errorModel.human];
    }];
}

- (NSIndexPath *)indexPathForCurrentImage {
    NSArray *indexPaths = [_collectionView indexPathsForVisibleItems];
    if (indexPaths.count) {
        return indexPaths[0];
    }
    
    return nil;
}

- (void)updateImageArrows {
    NSIndexPath *indexPath = [self indexPathForCurrentImage];
    
    BOOL hasNext = _spot.images.count ? (indexPath.item < _spot.images.count - 1) : FALSE;
    BOOL hasPrev = _spot.images.count ? (indexPath.item > 0) : FALSE;
    
    [UIView animateWithDuration:0.25 animations:^{
        _btnImageNext.alpha = hasNext ? 1.0 : 0.1;
        _btnImagePrev.alpha = hasPrev ? 1.0 : 0.1;
    } completion:^(BOOL finished) {
    }];
}

@end
