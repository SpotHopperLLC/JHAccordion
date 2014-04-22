//
//  DrinkProfileViewController.m
//  SpotHopper
//
//  Created by Josh Holtz on 3/14/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "DrinkProfileViewController.h"

#import "UIView+ViewFromNib.h"
#import "UIView+RelativityLaws.h"
#import "UIViewController+Navigator.h"

#import "SpotAnnotation.h"
#import "SHLabelLatoLight.h"

#import "TellMeMyLocation.h"

#import "ReviewSliderCell.h"
#import "SpotImageCollectViewCell.h"

#import "DrinkListViewController.h"

#import "AverageReviewModel.h"
#import "BaseAlcoholModel.h"
#import "ErrorModel.h"
#import "ImageModel.h"
#import "SpotModel.h"
#import "DrinkTypeModel.h"
#import "DrinkSubtypeModel.h"
#import "DrinkListModel.h"

#import <AFNetworking/UIImageView+AFNetworking.h>
#import <JHAccordion/JHAccordion.h>

#import <MapKit/MapKit.h>

@interface DrinkProfileViewController ()<UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate, JHAccordionDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tblSliders;

// Static Header
@property (weak, nonatomic) IBOutlet UILabel *lblSpotName;
@property (weak, nonatomic) IBOutlet SHLabelLatoLight *lblInfo;
@property (weak, nonatomic) IBOutlet UILabel *lblPercentMatch;
@property (weak, nonatomic) IBOutlet SHLabelLatoLight *lblABV;
@property (weak, nonatomic) IBOutlet UIButton *btnRecipe;

// Header
@property (nonatomic, strong) UIView *headerContent;
@property (nonatomic, assign) CGRect initialHeaderContentFrame;
@property (weak, nonatomic) IBOutlet UIView *viewBottomHeader;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *btnImagePrev;
@property (weak, nonatomic) IBOutlet UIButton *btnImageNext;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

// Header - Recipe and Description
@property (nonatomic, assign) BOOL expandedRecipe;
@property (nonatomic, assign) BOOL expandedDescription;
@property (weak, nonatomic) IBOutlet UIView *viewExpand;
@property (weak, nonatomic) IBOutlet UILabel *lblExpandTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblExpandInfo;


@property (nonatomic, strong) TellMeMyLocation *tellMeMyLocation;
@property (nonatomic, strong) CLLocation *location;

@property (nonatomic, strong) NSString *matchPercent;
@property (nonatomic, strong) AverageReviewModel *averageReview;
@property (nonatomic, strong) NSArray *spots;

@property (nonatomic, strong) NSMutableArray *sliders;
@property (nonatomic, strong) NSMutableArray *advancedSliders;

@property (nonatomic, strong) JHAccordion *accordion;
@property (nonatomic, strong) UIView *sectionHeaderAdvanced;

@property (nonatomic, weak) UIButton *btnSeeAll;

@end

@implementation DrinkProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _matchPercent = [_drink matchPercent];
    
    // Shows sidebar button in nav
    [self showSidebarButton:YES animated:YES];
    
    // Configures accordion
    _accordion = [[JHAccordion alloc] initWithTableView:_tblSliders];
    [_accordion setDelegate:self];
    [_accordion openSection:0];
    
    // Configure table header
    // Header content view
    _headerContent = [UIView viewFromNibNamed:@"DrinkProfileHeaderView" withOwner:self];
    _initialHeaderContentFrame = _headerContent.frame;
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
    [_tellMeMyLocation findMe:kCLLocationAccuracyKilometer found:^(CLLocation *newLocation) {
        _location = newLocation;
        [self fetchSpots];
    } failure:^(NSError *error) {
        
    }];
    
    [self updateView];
    [self fetchDrink];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    
    // Adds contextual footer view
    [self addFooterViewController:^(FooterViewController *footerViewController) {
        [footerViewController showHome:YES];
        [footerViewController setRightButton:@"Info" image:[UIImage imageNamed:@"btn_context_info"]];
    }];
    
}

- (BOOL)footerViewController:(FooterViewController *)footerViewController clickedButton:(FooterViewButtonType)footerViewButtonType {
    if (FooterViewButtonRight == footerViewButtonType) {
        [self showAlert:@"Info" message:kInfoDrinkProfile];
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
    return @"Drink Profile";
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    // Alwas should show one image (the once being the placeholder if drink has no images)
    return MAX( 1 , [_drink images].count );
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    SpotImageCollectViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SpotImageCollectViewCell" forIndexPath:indexPath];
    
    // Uses placeholder if drink has no images
    if ([_drink images].count == 0) {
        [cell setImage:nil withPlaceholder:_drink.placeholderImage];
    }
    // Sets the images defined by the drink
    else {
        ImageModel *image = [[_drink images] objectAtIndex:indexPath.row];
        [cell setImage:image withPlaceholder:_drink.placeholderImage];
    }
    
    return cell;
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

- (IBAction)onClickRecipe:(id)sender {
    // Closes description first if already opten
    if (_expandedDescription == YES) {
        
        [self toggleDescriptionExpand:^(BOOL closed) {
            // Then opens recipe
            [self toggleRecipeExpand:nil];
        }];
        
    }
    // Else opens recipe
    else {
        [self toggleRecipeExpand:nil];
    }
}

- (IBAction)onClickDescription:(id)sender {
    // Closes recipe first if already opten
    if (_expandedRecipe == YES) {
        
        [self toggleRecipeExpand:^(BOOL closed) {
            // Then opens description
            [self toggleDescriptionExpand:nil];
        }];
        
    }
    // Else opens description
    else {
        [self toggleDescriptionExpand:nil];
    }
}

- (IBAction)onClickFindIt:(id)sender {
    [self goToFindDrinksAt:_drink];
}

#pragma mark - Private Expand

- (void)toggleRecipeExpand:(void (^)(BOOL closed))completion {
    if ([self isExpandClosed] == YES) {
        // Sets info
        [_lblExpandTitle setText:@"Recipe"];
        [_lblExpandInfo setText: ( _drink.recipeOfDrink.length > 0 ? _drink.recipeOfDrink : @"No recipe" ) ];
        
        // Expands view to be height of recipe
        [_lblExpandInfo fitLabelHeight];
        [self addExtraHeight:_lblExpandInfo];
        [_viewExpand alignToChildBottom:_lblExpandInfo withSpacing:5.0f];
    }
    
    [self animateExpand:^(BOOL closed) {
        
        // State stuff
        _expandedRecipe = !closed;
        _expandedDescription = NO;
        
        if (closed == YES) {
            
            // Clears
            [_lblExpandTitle setText:@""];
            [_lblExpandInfo setText:@""];
            
            // Expands view to be height of recipe
            [_lblExpandInfo fitLabelHeight];
            [self addExtraHeight:_lblExpandInfo];
            [_viewExpand alignToChildBottom:_lblExpandInfo withSpacing:5.0f];
            
            [_tblSliders scrollRectToVisible:CGRectMake(0.0f, 0.0f, CGRectGetWidth(_tblSliders.frame), 1.0f) animated:YES];
        }
        
        if (completion) {
            completion(closed);
        }
        
    }];
}

- (void)toggleDescriptionExpand:(void (^)(BOOL closed))completion {
    if ([self isExpandClosed] == YES) {
        // Sets info
        [_lblExpandTitle setText:@"Description"];
        [_lblExpandInfo setText: ( _drink.descriptionOfDrink.length > 0 ? _drink.descriptionOfDrink : @"No description" ) ];
        
        // Expands view to be height of recipe
        [_lblExpandInfo fitLabelHeight];
        [self addExtraHeight:_lblExpandInfo];
        [_viewExpand alignToChildBottom:_lblExpandInfo withSpacing:5.0f];
    }
    
    [self animateExpand:^(BOOL closed) {
        
        // State stuff
        _expandedRecipe = NO;
        _expandedDescription = !closed;
        
        if (closed == YES) {
            
            // Clears
            [_lblExpandTitle setText:@""];
            [_lblExpandInfo setText:@""];
            
            // Expands view to be height of recipe
            [_lblExpandInfo fitLabelHeight];
            [self addExtraHeight:_lblExpandInfo];
            [_viewExpand alignToChildBottom:_lblExpandInfo withSpacing:5.0f];
            
            [_tblSliders scrollRectToVisible:CGRectMake(0.0f, 0.0f, CGRectGetWidth(_tblSliders.frame), 1.0f) animated:YES];
        }
        
        if (completion) {
            completion(closed);
        }
        
    }];
}

- (void)addExtraHeight:(UILabel*)label {
    CGRect frame = label.frame;
    frame.size.height += 50.0f;
    [label setFrame:frame];
}

- (BOOL)isExpandClosed {
    CGRect frame = _headerContent.frame;
    return CGRectEqualToRect(frame, _initialHeaderContentFrame);
}

- (void)animateExpand:(void (^)(BOOL closed))completion {
    
    // Calculates frames to expand or dexpand (yes, its a word) the header
    CGRect frame = _headerContent.frame;
    CGRect frameBottomStuff = _viewBottomHeader.frame;
    
    if ([self isExpandClosed] == YES) {
        
        // Will open bottom part of header to below the expanded recipe or description
        frameBottomStuff.origin.y =  CGRectGetMaxY(_viewExpand.frame);
        
        // Will expand the height the header to the bottom of bottom part of header
        frame.size.height = CGRectGetMaxY(frameBottomStuff);
        
    } else {
        
        // Will set header back to initial size
        frame = _initialHeaderContentFrame;
        
        // Will size bottom part of header back to initial size
        frameBottomStuff.origin.y =  CGRectGetMinY(_viewExpand.frame);
    }
    
    // Animates the header
    [UIView animateWithDuration:0.35 animations:^{
        [_headerContent setFrame:frame];
        [_viewBottomHeader setFrame:frameBottomStuff];
    } completion:^(BOOL finished) {
        
        // Resets the header size to place the cells in the correct spot
        [_tblSliders setTableHeaderView:_headerContent];
        
        // Calls callback block
        BOOL closed =[self isExpandClosed];
        completion(closed);
        
    }];
}

#pragma mark - Private

- (void)fetchDrink {
    [_drink getDrink:nil success:^(DrinkModel *drinkModel, JSONAPI *jsonApi) {
        _drink = drinkModel;
        _averageReview = drinkModel.averageReview;
        [self updateView];
        [self initSliders];
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
    
    // Reload images
    [_collectionView reloadData];
    
    // Set title
    [self setTitle:_drink.name];
    
    // Spot type
    [_lblSpotName setText:_drink.spot.name];
    
    [_lblPercentMatch setHidden:(_drink.match == nil)];
    if (_drink.match != nil) [_lblPercentMatch setText:[NSString stringWithFormat:@"%@ Match", [_drink matchPercent]]];
    
    // Sets Rating and stuff
    NSString *style = nil;
    NSString *emptyText = @"No rating";
    if ([_drink isBeer] == YES) {
        style = _drink.style;
        emptyText = @"No style or rating";
    } else if ([_drink isCocktail] == YES) {
        BaseAlcoholModel *baseAlcohol = [[_drink baseAlochols] firstObject];
        style = baseAlcohol.name;
        emptyText = @"No rating";
    }
    
    if (style.length > 0 && _drink.averageReview != nil) {
        [_lblInfo setText:[NSString stringWithFormat:@"%@ - %.1f/10", style, _drink.averageReview.rating.floatValue]];
    } else if (style.length > 0) {
        [_lblInfo setText:style];
    } else if (_drink.averageReview != nil) {
        [_lblInfo setText:[NSString stringWithFormat:@"%.1f/10", _drink.averageReview.rating.floatValue]];
    } else {
        [_lblInfo italic:YES];
        [_lblInfo setText:emptyText];
    }
    
    // Beer - ABV
    if ([_drink isBeer] == YES) {
        
        // Hides recipe button
        [_btnRecipe setHidden:YES];
        
        // This is the bottom right extra info label
        [_lblABV setHidden:NO];
        
        // Setting ABV
        [_lblABV setText:_drink.abvPercentString];
    }
    // Cocktail - Recipe
    else if ([_drink isCocktail] == YES) {
    
        // Shows recipe button
        [_btnRecipe setHidden:NO];
        
        // This is the bottom right extra info label
        [_lblABV setHidden:YES];
        
    }
    // Wine - Varietal
    else if ([_drink isWine] == YES) {
        
        // Hides recipe button
        [_btnRecipe setHidden:YES];
        
        // This is the bottom right extra info label
        [_lblABV setHidden:NO];
        
        // Setting ABV
        [_lblABV setText:_drink.varietal];
        
    }
    
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
            NSLog(@"Order - %@", slider.sliderTemplate.order);
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
    [DrinkListModel postDrinkList:name
                         latitude:[NSNumber numberWithFloat:_location.coordinate.latitude]
                        longitude:[NSNumber numberWithFloat:_location.coordinate.longitude]
                          sliders:_averageReview.sliders
                          drinkId:_drink.ID
                      drinkTypeId:_drink.drinkType.ID
                   drinkSubtypeId:_drink.drinkSubtype.ID
                    baseAlcoholId:nil
                           spotId:nil
                     successBlock:^(DrinkListModel *drinkListModel, JSONAPI *jsonApi) {
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
