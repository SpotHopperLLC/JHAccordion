//
//  AdjustDrinkListSliderViewController.m
//  SpotHopper
//
//  Created by Josh Holtz on 3/13/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#define kNumberOfSections 6
#define kSectionTypes 0
#define kSectionBaseAlcohols 1
#define kSectionWineSubtypes 2
#define kSectionSliders 4
#define kSectionAdvancedSliders 5

#import "AdjustDrinkListSliderViewController.h"

#import "SHButtonLatoLight.h"
#import "TTTAttributedLabel+QuickFonting.h"
#import "UIView+AddBorder.h"

#import "AdjustSliderSectionHeaderView.h"

#import "AdjustSliderOptionCell.h"
#import "ReviewSliderCell.h"

#import "ClientSessionManager.h"
#import "BaseAlcoholModel.h"
#import "ErrorModel.h"
#import "DrinkModel.h"
#import "DrinkListModel.h"
#import "SliderModel.h"
#import "SliderTemplateModel.h"
#import "SpotModel.h"

#import "Tracker.h"

#import <JHAccordion/JHAccordion.h>

#import <CoreLocation/CoreLocation.h>

@interface AdjustDrinkListSliderViewController ()<UITableViewDataSource, UITableViewDelegate, JHAccordionDelegate, ReviewSliderCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tblSliders;
@property (weak, nonatomic) IBOutlet SHButtonLatoLight *btnSubmit;

@property (nonatomic, strong) JHAccordion *accordion;
@property (nonatomic, strong) AdjustSliderSectionHeaderView *sectionHeaderTypes;
@property (nonatomic, strong) AdjustSliderSectionHeaderView *sectionHeaderBaseAlcohol;
@property (nonatomic, strong) AdjustSliderSectionHeaderView *sectionHeaderWineSubtype;
@property (nonatomic, strong) AdjustSliderSectionHeaderView *sectionHeaderAdvancedSliders;

@property (nonatomic, strong) NSArray *drinkTypes;
@property (nonatomic, strong) NSDictionary *selectedDrinkType;

@property (nonatomic, strong) NSArray *baseAlcohols;
@property (nonatomic, strong) BaseAlcoholModel *selectedBaseAlcohol;

@property (nonatomic, strong) NSArray *wineSubtypes;
@property (nonatomic, strong) NSDictionary *selectedWineSubtype;

@property (nonatomic, strong) NSArray *allSliderTemplates;
@property (nonatomic, strong) NSArray *sliderTemplates;
@property (nonatomic, strong) NSMutableArray *sliders;
@property (nonatomic, strong) NSMutableArray *advancedSliders;

@end

@implementation AdjustDrinkListSliderViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Configures accordion
    _accordion = [[JHAccordion alloc] initWithTableView:_tblSliders];
    [_accordion setDelegate:self];
    
    // Configures table
    [_tblSliders setTableFooterView:[[UIView alloc] init]];
    [_tblSliders registerNib:[UINib nibWithNibName:@"ReviewSliderCellView" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"ReviewSliderCell"];
    
    // Initializes
    _sliders = [NSMutableArray array];
    _advancedSliders = [NSMutableArray array];
    
    [self fetchFormData];
    [self fetchSliderTemplates];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // We don't need to listen for this here
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationPushReceived object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Tracking

- (NSString *)screenName {
    return @"Adjust Drinklist Slider";
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return kNumberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == kSectionTypes) {
        return _drinkTypes.count ;
    } else if (section == kSectionBaseAlcohols) {
        return _baseAlcohols.count + 1;
    } else if (section == kSectionWineSubtypes) {
        return _wineSubtypes.count + 1;
    } else if (section == kSectionSliders) {
        return _sliders.count;
    } else if (section == kSectionAdvancedSliders) {
        return _advancedSliders.count;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    /*
     * Section: Drink types
     */
    if (indexPath.section == kSectionTypes) {
        
        AdjustSliderOptionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AdjustSliderOptionCell" forIndexPath:indexPath];
        NSDictionary *spotType = [_drinkTypes objectAtIndex:indexPath.row];
        [cell.lblTitle setText:[spotType objectForKey:@"name"]];
        
        return cell;
    }
    /*
     * Section: Base Alcohols
     */
    else if (indexPath.section == kSectionBaseAlcohols) {
        
        AdjustSliderOptionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AdjustSliderOptionCell" forIndexPath:indexPath];
        if (indexPath.row == 0) {
            [cell.lblTitle setText:@"Any"];
        } else {
            BaseAlcoholModel *baseAlcohol = [_baseAlcohols objectAtIndex:indexPath.row-1];
            [cell.lblTitle setText:baseAlcohol.name];
        }
        
        return cell;
    }
    /*
     * Section: Wine Subtypes
     */
    else if (indexPath.section == kSectionWineSubtypes) {
        
        AdjustSliderOptionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AdjustSliderOptionCell" forIndexPath:indexPath];
        if (indexPath.row == 0) {
            [cell.lblTitle setText:@"Any"];
        } else {
            NSDictionary *wineSubtype = [_wineSubtypes objectAtIndex:indexPath.row-1];
            [cell.lblTitle setText:[wineSubtype objectForKey:@"name"]];
        }
        
        return cell;
    }
    /*
     * Section: Basic Sliders
     */
    else if (indexPath.section == kSectionSliders) {
        
        SliderModel *slider = [_sliders objectAtIndex:indexPath.row];
        
        ReviewSliderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ReviewSliderCell" forIndexPath:indexPath];
        [cell setDelegate:self];
        [cell setSliderTemplate:slider.sliderTemplate withSlider:slider showSliderValue:NO];
        
        return cell;
    }
    /*
     * Section: Advanced Sliders
     */
    else if (indexPath.section == kSectionAdvancedSliders) {
        
        SliderModel *slider = [_advancedSliders objectAtIndex:indexPath.row];
        
        ReviewSliderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ReviewSliderCell" forIndexPath:indexPath];
        [cell setDelegate:self];
        [cell setSliderTemplate:slider.sliderTemplate withSlider:slider showSliderValue:NO];
        
        return cell;
    }
    
    return nil;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    /*
     * Section: Drink Types
     */
    if (indexPath.section == kSectionTypes) {
        _selectedDrinkType = [_drinkTypes objectAtIndex:indexPath.row];
        
        _selectedBaseAlcohol = nil;
        _selectedWineSubtype = nil;
        
        [self updateSectionHeaderTitles:kSectionBaseAlcohols];
        [self updateSectionHeaderTitles:kSectionWineSubtypes];
        
        [_accordion closeSection:indexPath.section];
        [_accordion closeSection:kSectionBaseAlcohols];
        [_accordion closeSection:kSectionWineSubtypes];
    }
    /*
     * Section: Base Alcohols
     */
    else if (indexPath.section == kSectionBaseAlcohols) {
        if (indexPath.row == 0) {
            _selectedBaseAlcohol = nil;
        } else {
            _selectedBaseAlcohol = [_baseAlcohols objectAtIndex:indexPath.row-1];
        }
        [_accordion closeSection:indexPath.section];
    }
    /*
     * Section: Wine Subtypes
     */
    else if (indexPath.section == kSectionWineSubtypes) {
        if (indexPath.row == 0) {
            _selectedWineSubtype = nil;
        } else {
            _selectedWineSubtype = [_wineSubtypes objectAtIndex:indexPath.row-1];
        }
        [_accordion closeSection:indexPath.section];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kSectionTypes) {
        return ( [_accordion isSectionOpened:indexPath.section] ? 44.0f : 0.0f);
    } else if (indexPath.section == kSectionBaseAlcohols) {
        return ( [_accordion isSectionOpened:indexPath.section] ? 44.0f : 0.0f);
    } else if (indexPath.section == kSectionWineSubtypes) {
        return ( [_accordion isSectionOpened:indexPath.section] ? 44.0f : 0.0f);
    } else if (indexPath.section == kSectionSliders) {
        return 77.0f;
    } else if (indexPath.section == kSectionAdvancedSliders) {
        return ( [_accordion isSectionOpened:indexPath.section] ? 77.0f : 0.0f);
    }
    
    return 0.0f;
} 

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [self sectionHeaderViewForSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == kSectionTypes) {
        return 48.0f;
    } else if (section == kSectionBaseAlcohols && [self isCocktailSelected]) {
        return 48.0f;
    } else if (section == kSectionWineSubtypes && [self isWineSelected]) {
        return 48.0f;
    } else if (section == kSectionAdvancedSliders && _advancedSliders.count > 0) {
        return 48.0f;
    }
    
    return 0.0f;
}

#pragma mark - ReviewSliderCellDelegate

- (void)reviewSliderCell:(ReviewSliderCell *)cell changedValue:(CGFloat)value {
    // Sets slider to darker/selected color for good
    [cell.slider setUserMoved:YES];
    
    NSIndexPath *indexPath = [_tblSliders indexPathForCell:cell];
    
    if (indexPath.section == kSectionSliders) {
        SliderModel *slider = [_sliders objectAtIndex:indexPath.row];
        [slider setValue:[NSNumber numberWithFloat:(value * 10)]];
    } else if (indexPath.section == kSectionAdvancedSliders) {
        SliderModel *slider = [_advancedSliders objectAtIndex:indexPath.row];
        [slider setValue:[NSNumber numberWithFloat:(value * 10)]];
    }
}

- (void)reviewSliderCell:(ReviewSliderCell*)cell finishedChangingValue:(CGFloat)value {
    // move table view of sliders up a little to make the next slider visible
    [self slideCell:cell aboveTableViewMidwayPoint:_tblSliders];
    
    if (_btnSubmit.hidden) {
        [_btnSubmit setTitle:@"Search" forState:UIControlStateNormal];
        [self showSubmitButton:TRUE];
    }
}

#pragma mark - JHAccordionDelegate

- (void)accordion:(JHAccordion *)accordion openingSection:(NSInteger)section {
    if (section == kSectionTypes) [_sectionHeaderTypes setSelected:YES];
    else if (section == kSectionBaseAlcohols) [_sectionHeaderBaseAlcohol setSelected:YES];
    else if (section == kSectionWineSubtypes) [_sectionHeaderWineSubtype setSelected:YES];
    else if (section == kSectionAdvancedSliders) [_sectionHeaderAdvancedSliders setSelected:YES];
}

- (void)accordion:(JHAccordion *)accordion closingSection:(NSInteger)section {
    if (section == kSectionTypes) {
        [_sectionHeaderTypes setSelected:NO];
        [self filterSliderTemplates];
    }
    else if (section == kSectionBaseAlcohols) [_sectionHeaderBaseAlcohol setSelected:NO];
    else if (section == kSectionWineSubtypes) {
        [_sectionHeaderWineSubtype setSelected:NO];
        [self filterSliderTemplates];
    }
    else if (section == kSectionAdvancedSliders) [_sectionHeaderAdvancedSliders setSelected:NO];
    
    [self updateSectionHeaderTitles:section];
}

- (void)accordion:(JHAccordion *)accordion openedSection:(NSInteger)section {
    CGRect sectionRect = [_tblSliders rectForSection:section];
    
    CGFloat tableHeight = CGRectGetHeight(_tblSliders.frame);
    if (sectionRect.origin.y > tableHeight) {
        CGFloat newOffset = sectionRect.origin.y - (tableHeight / 3);
        CGPoint offset = CGPointMake(0.0, newOffset);
        [_tblSliders setContentOffset:offset animated:TRUE];
    }
}

- (void)accordion:(JHAccordion *)accordion closedSection:(NSInteger)section {
    if (section == kSectionTypes) {
        [_tblSliders reloadData];
        [self hideSubmitButton:TRUE];
    }
}

#pragma mark - Actions

- (IBAction)onClickClose:(id)sender {
    if ([_delegate respondsToSelector:@selector(adjustDrinkSliderListSliderViewControllerDelegateClickClose:)]) {
        [_delegate adjustDrinkSliderListSliderViewControllerDelegateClickClose:self];
    }
}

- (IBAction)onClickSubmit:(id)sender {
    [self doCreateDrinklist];
}

#pragma mark - Public

- (void)resetForm {
    [_tblSliders scrollRectToVisible:CGRectMake(0, 0, CGRectGetWidth(_tblSliders.frame), 1) animated:NO];
    [self hideSubmitButton:FALSE];

    // Reset
    _selectedDrinkType = nil;
    _selectedBaseAlcohol = nil;
    _selectedWineSubtype = nil;
    
    // Close section
    [_accordion closeSection:kSectionTypes];
    [_accordion closeSection:kSectionBaseAlcohols];
    [_accordion closeSection:kSectionWineSubtypes];
    [_accordion closeSection:kSectionAdvancedSliders];
    
    // Resets headers
    [self updateSectionHeaderTitles:kSectionTypes];
    [self updateSectionHeaderTitles:kSectionBaseAlcohols];
    [self updateSectionHeaderTitles:kSectionWineSubtypes];
    [self updateSectionHeaderTitles:kSectionAdvancedSliders];
    
    [_sliders removeAllObjects];
    [_advancedSliders removeAllObjects];
    
    [self filterSliderTemplates];
    
    // Reload
    [_tblSliders reloadData];
}

#pragma mark - Private

- (BOOL)isCocktailSelected {
    return [[_selectedDrinkType objectForKey:@"name"] isEqualToString:kDrinkTypeNameCocktail];
}

- (BOOL)isWineSelected {
    return [[_selectedDrinkType objectForKey:@"name"] isEqualToString:kDrinkTypeNameWine];
}

- (void)fetchFormData {
    
    // Gets drink form data
    Promise *promiseFormData = [DrinkModel getDrinks:@{kDrinkModelParamsPageSize:@0} success:^(NSArray *spotModels, JSONAPI *jsonApi) {
        
        NSDictionary *forms = [jsonApi objectForKey:@"form"];
        if (forms != nil) {
            _drinkTypes = [forms objectForKey:@"drink_types"];
            
            // Saves off wine subtypes into list
            for (NSDictionary *drinkType in _drinkTypes) {
                if ([[drinkType objectForKey:@"name"] isEqualToString:kDrinkTypeNameWine] == YES) {
                    _wineSubtypes = [drinkType objectForKey:@"drink_subtypes"];
                    break;
                }
            }
            
        }
        
        
    } failure:^(ErrorModel *errorModel) {
        
    }];
 
    // Gets drink form data
    Promise *promiseBaseAlcohols = [BaseAlcoholModel getBaseAlcohols:nil success:^(NSArray *baseAlcoholModels, JSONAPI *jsonAPI) {
        _baseAlcohols = [baseAlcoholModels sortedArrayUsingComparator:^NSComparisonResult(BaseAlcoholModel *obj1, BaseAlcoholModel *obj2) {
            return [obj1.name caseInsensitiveCompare:obj2.name];
        }];
    } failure:^(ErrorModel *errorModel) {
        
    }];
    
    // Waits for both spots and drinks to finish
    [When when:@[promiseFormData, promiseBaseAlcohols] then:^{
        
    } fail:^(id error) {
        [self hideHUD];
        [self showAlert:@"Oops" message:@"Looks like there was an error loading forms. Please try again later" block:^{
            [self.navigationController popViewControllerAnimated:YES];
        }];
    } always:^{
        [self hideHUD];
        [_tblSliders reloadData];
    }];
    
}

- (void)filterSliderTemplates {
    
    NSMutableArray *slidersFiltered = [NSMutableArray array];
    if (_selectedDrinkType == nil) {
        _sliderTemplates = nil;
    } else {
        NSNumber *selectedDrinkTypeId = [_selectedDrinkType objectForKey:@"id"];
        NSNumber *selectedWineTypeId = [_selectedWineSubtype objectForKey:@"id"];
        
        // Filters by spot idea
        for (SliderTemplateModel *sliderTemplate in _allSliderTemplates) {
            
            NSArray *drinkTypeIds = [sliderTemplate.drinkTypes valueForKey:@"ID"];
            NSArray *drinkSubtypeIds = [sliderTemplate.drinkSubtypes valueForKey:@"ID"];
            
            // Only filter by drink type if wine subtype is nil
            if (_selectedWineSubtype == nil && [drinkTypeIds containsObject:selectedDrinkTypeId]) {
                [slidersFiltered addObject:sliderTemplate];
            }
            // Else filter by drink type and drink subtype
            else if (_selectedWineSubtype != nil && [drinkTypeIds containsObject:selectedDrinkTypeId] && [drinkSubtypeIds containsObject:selectedWineTypeId]) {
                [slidersFiltered addObject:sliderTemplate];
            }
            
        }
        
    }
    _sliderTemplates = slidersFiltered;
    
    
    // Creating sliders
    [_sliders removeAllObjects];
    for (SliderTemplateModel *sliderTemplate in _sliderTemplates) {
        SliderModel *slider = [[SliderModel alloc] init];
        [slider setSliderTemplate:sliderTemplate];
        [_sliders addObject:slider];
    }
    
    // Filling advanced sliders if nil
    [_advancedSliders removeAllObjects];
    
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
    
    // Reloading table
    [_tblSliders reloadData];
    
}

- (void)fetchSliderTemplates {
    
    [SliderTemplateModel getSliderTemplates:nil success:^(NSArray *sliderTemplates, JSONAPI *jsonApi) {
        [self hideHUD];
        _allSliderTemplates = sliderTemplates;
        
        [self filterSliderTemplates];
        
    } failure:^(ErrorModel *errorModel) {
        [self hideHUD];
    }];
}

- (void)doCreateDrinklist {
    if (_selectedDrinkType == nil) {
        [self showAlert:@"Oops" message:@"Please select a drink type"];
        return;
    }
    
    NSMutableArray *allTheSliders = [NSMutableArray array];
    [allTheSliders addObjectsFromArray:_sliders];
    [allTheSliders addObjectsFromArray:_advancedSliders];
    
    NSNumber *latitude = nil, *longitude = nil;
    if (_location != nil) {
        latitude = [NSNumber numberWithFloat:_location.coordinate.latitude];
        longitude = [NSNumber numberWithFloat:_location.coordinate.longitude];
    }
    
    [Tracker track:@"Creating Drinklist"];
    
    [self showHUD:@"Creating drinklist"];
    [DrinkListModel postDrinkList:kDrinkListModelDefaultName
                         latitude:latitude
                        longitude:longitude sliders:allTheSliders
                          drinkId:nil
                      drinkTypeId:[_selectedDrinkType objectForKey:@"id"]
                   drinkSubtypeId:[_selectedWineSubtype objectForKey:@"id"]
                    baseAlcoholId:_selectedBaseAlcohol.ID
                           spotId:_spot.ID
                     successBlock:^(DrinkListModel *drinkListModel, JSONAPI *jsonApi) {
        [Tracker track:@"Created Drinklist" properties:@{@"Success" : @TRUE}];
        [self hideHUD];
        [self showHUDCompleted:@"Drinklist created!" block:^{
            
            if ([_delegate respondsToSelector:@selector(adjustDrinkSliderListSliderViewControllerDelegate:createdDrinkList:)]) {
                [_delegate adjustDrinkSliderListSliderViewControllerDelegate:self createdDrinkList:drinkListModel];
            }
            
        }];
    } failure:^(ErrorModel *errorModel) {
        [Tracker track:@"Created Drinklist" properties:@{@"Success" : @FALSE}];
        [self hideHUD];
        [self showAlert:@"Oops" message:errorModel.human];
    }];
}

- (void)updateSectionHeaderTitles:(NSInteger)section {
    
    if (section == kSectionTypes) {
        
        // Sets label for drink type
        if (_selectedDrinkType == nil) {
            [_sectionHeaderTypes.lblText setText:@"Select Drink Type"];
        } else {
            [_sectionHeaderTypes.lblText setText:[_selectedDrinkType objectForKey:@"name"]];
        }
        
    } else if (section == kSectionBaseAlcohols) {
        
        // Sets label for base alcohol
        if (_selectedBaseAlcohol == nil) {
            CGFloat fontSize = _sectionHeaderBaseAlcohol.lblText.font.pointSize;
            [_sectionHeaderBaseAlcohol.lblText setText:@"Select Base Alcohol (optional)" withFont:[UIFont fontWithName:@"Lato-LightItalic" size:fontSize] onString:@"(optional)"];
        } else {
            [_sectionHeaderBaseAlcohol.lblText setText:_selectedBaseAlcohol.name];
        }
        
    } else if (section == kSectionWineSubtypes) {
        
        // Sets label for wine subtype
        if (_selectedWineSubtype == nil) {
            CGFloat fontSize = _sectionHeaderWineSubtype.lblText.font.pointSize;
            [_sectionHeaderWineSubtype.lblText setText:@"Select Wine Type (optional)" withFont:[UIFont fontWithName:@"Lato-LightItalic" size:fontSize] onString:@"(optional)"];
        } else {
            [_sectionHeaderWineSubtype.lblText setText:[_selectedWineSubtype objectForKey:@"name"]];
        }
        
    }
    
}

- (AdjustSliderSectionHeaderView*)sectionHeaderViewForSection:(NSInteger)section {
    
    if (section == kSectionTypes) {
        if (_sectionHeaderTypes == nil) {
            _sectionHeaderTypes = [[AdjustSliderSectionHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(_tblSliders.frame), 48.0f)];
            
            [_sectionHeaderTypes.btnBackground setTag:section];
            [_sectionHeaderTypes.btnBackground addTarget:_accordion action:@selector(onClickSection:) forControlEvents:UIControlEventTouchUpInside];
            
            // Add borders
            [_sectionHeaderTypes addTopBorder:[UIColor colorWithWhite:1.0f alpha:0.8f]];
            [_sectionHeaderTypes addBottomBorder:[UIColor colorWithWhite:1.0f alpha:0.8f]];
            
            [self updateSectionHeaderTitles:section];
        }
        
        return _sectionHeaderTypes;
    } else if (section == kSectionBaseAlcohols) {
        if (_sectionHeaderBaseAlcohol == nil) {
            _sectionHeaderBaseAlcohol = [[AdjustSliderSectionHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(_tblSliders.frame), 48.0f)];
            
            [_sectionHeaderBaseAlcohol.btnBackground setTag:section];
            [_sectionHeaderBaseAlcohol.btnBackground addTarget:_accordion action:@selector(onClickSection:) forControlEvents:UIControlEventTouchUpInside];
            
            // Add borders
            [_sectionHeaderBaseAlcohol addBottomBorder:[UIColor colorWithWhite:1.0f alpha:0.8f]];
            
            [self updateSectionHeaderTitles:section];
        }
        
        return _sectionHeaderBaseAlcohol;
    } else if (section == kSectionWineSubtypes) {
        if (_sectionHeaderWineSubtype == nil) {
            _sectionHeaderWineSubtype = [[AdjustSliderSectionHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(_tblSliders.frame), 48.0f)];
            
            [_sectionHeaderWineSubtype.btnBackground setTag:section];
            [_sectionHeaderWineSubtype.btnBackground addTarget:_accordion action:@selector(onClickSection:) forControlEvents:UIControlEventTouchUpInside];
            
            // Add borders
            [_sectionHeaderWineSubtype addBottomBorder:[UIColor colorWithWhite:1.0f alpha:0.8f]];
            
            [self updateSectionHeaderTitles:section];
        }
        
        return _sectionHeaderWineSubtype;
    } else if (section == kSectionAdvancedSliders) {
        if (_sectionHeaderAdvancedSliders == nil) {
            _sectionHeaderAdvancedSliders = [[AdjustSliderSectionHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(_tblSliders.frame), 48.0f)];
            
            [_sectionHeaderAdvancedSliders setText:@"Advanced Sliders"];
            
            [_sectionHeaderAdvancedSliders.btnBackground setTag:section];
            [_sectionHeaderAdvancedSliders.btnBackground addTarget:_accordion action:@selector(onClickSection:) forControlEvents:UIControlEventTouchUpInside];
            
            // Add borders
            [_sectionHeaderAdvancedSliders addBottomBorder:[UIColor colorWithWhite:1.0f alpha:0.8f]];
            
            [self updateSectionHeaderTitles:section];
        }
        
        return _sectionHeaderAdvancedSliders;
    }
    return nil;
}

- (void)hideSubmitButton:(BOOL)animated {
    // 1) slide the button down and out of view
    // 2) set hidden to TRUE
    
    CGFloat viewHeight = CGRectGetHeight(self.view.frame);
    
    CGRect hiddenFrame = _btnSubmit.frame;
    hiddenFrame.origin.y = viewHeight;
    _btnSubmit.frame = hiddenFrame;
    
    [UIView animateWithDuration:0.5 animations:^{
        _btnSubmit.frame = hiddenFrame;
        _tblSliders.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
        _tblSliders.scrollIndicatorInsets = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
    } completion:^(BOOL finished) {
        [_btnSubmit setHidden:TRUE];
    }];
}

- (void)showSubmitButton:(BOOL)animated {
    // 1) position it below the superview (out of view)
    // 2) set to hidden = false
    // 3) animate it up into position
    // 4) update the table with insets so it will not cover table cells
    
    CGFloat buttonHeight = CGRectGetHeight(_btnSubmit.frame);
    CGFloat viewHeight = CGRectGetHeight(self.view.frame);
    
    CGRect hiddenFrame = _btnSubmit.frame;
    hiddenFrame.origin.y = viewHeight;
    _btnSubmit.frame = hiddenFrame;
    _btnSubmit.hidden = FALSE;
    [self.view bringSubviewToFront:_btnSubmit];
    
    [UIView animateWithDuration:0.5 animations:^{
        CGRect visibleFrame = _btnSubmit.frame;
        visibleFrame.origin.y = viewHeight - buttonHeight;
        _btnSubmit.frame = visibleFrame;
        _tblSliders.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, buttonHeight, 0.0f);
        _tblSliders.scrollIndicatorInsets = UIEdgeInsetsMake(0.0f, 0.0f, buttonHeight, 0.0f);
    } completion:^(BOOL finished) {
    }];
}

@end
