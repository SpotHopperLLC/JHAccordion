//
//  AdjustDrinkListSliderViewController.m
//  SpotHopper
//
//  Created by Josh Holtz on 3/13/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#define kSectionTypes 0
#define kSectionSliders 1
#define kSectionAdvancedSliders 2

#import "AdjustDrinkListSliderViewController.h"

#import "TTTAttributedLabel+QuickFonting.h"
#import "UIView+AddBorder.h"

#import "AdjustSliderSectionHeaderView.h"

#import "AdjustSliderOptionCell.h"
#import "ReviewSliderCell.h"

#import "ClientSessionManager.h"
#import "ErrorModel.h"
#import "DrinkModel.h"
#import "DrinkListModel.h"
#import "SliderModel.h"
#import "SliderTemplateModel.h"
#import "SpotModel.h"

#import <JHAccordion/JHAccordion.h>

#import <CoreLocation/CoreLocation.h>

@interface AdjustDrinkListSliderViewController ()<UITableViewDataSource, UITableViewDelegate, JHAccordionDelegate, ReviewSliderCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tblSliders;

@property (nonatomic, strong) JHAccordion *accordion;
@property (nonatomic, strong) AdjustSliderSectionHeaderView *sectionHeader0;
@property (nonatomic, strong) AdjustSliderSectionHeaderView *sectionHeader1;
@property (nonatomic, strong) AdjustSliderSectionHeaderView *sectionHeader3;

@property (nonatomic, strong) NSArray *drinkTypes;
@property (nonatomic, strong) NSDictionary *selectedDrinkType;

@property (nonatomic, strong) NSArray *allSliderTemplates;
@property (nonatomic, strong) NSArray *sliderTemplates;
@property (nonatomic, strong) NSMutableArray *sliders;
@property (nonatomic, strong) NSMutableArray *advancedSliders;

@end

@implementation AdjustDrinkListSliderViewController

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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == kSectionTypes) {
        return _drinkTypes.count + 1;
    } else if (section == kSectionSliders) {
        return _sliders.count;
    } else if (section == kSectionAdvancedSliders) {
        return _advancedSliders.count;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == kSectionTypes) {
        
        AdjustSliderOptionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AdjustSliderOptionCell" forIndexPath:indexPath];
        if (indexPath.row > 0) {
            NSDictionary *spotType = [_drinkTypes objectAtIndex:indexPath.row - 1];
            [cell.lblTitle setText:[spotType objectForKey:@"name"]];
        } else {
            [cell.lblTitle setText:@"Any"];
        }
        
        return cell;
    }  else if (indexPath.section == kSectionSliders) {
        
        SliderModel *slider = [_sliders objectAtIndex:indexPath.row];
        
        ReviewSliderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ReviewSliderCell" forIndexPath:indexPath];
        [cell setDelegate:self];
        [cell setSliderTemplate:slider.sliderTemplate withSlider:slider showSliderValue:NO];
        
        return cell;
    } else if (indexPath.section == kSectionAdvancedSliders) {
        
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
    
    if (indexPath.section == kSectionTypes) {
        if (indexPath.row > 0) {
            _selectedDrinkType = [_drinkTypes objectAtIndex:indexPath.row - 1];
        } else {
            _selectedDrinkType = nil;
        }
        [_accordion closeSection:indexPath.section];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kSectionTypes) {
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
    } else if (section == 3 && _advancedSliders.count > 0) {
        return 48.0f;
    }
    
    return 0.0f;
}

#pragma mark - ReviewSliderCellDelegate

- (void)reviewSliderCell:(ReviewSliderCell *)cell changedValue:(float)value {
    
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

#pragma mark - JHAccordionDelegate

- (void)accordion:(JHAccordion *)accordion openingSection:(NSInteger)section {
    if (section == kSectionTypes) [_sectionHeader0 setSelected:YES];
    else if (section == kSectionAdvancedSliders) [_sectionHeader3 setSelected:YES];
}

- (void)accordion:(JHAccordion *)accordion closingSection:(NSInteger)section {
    if (section == kSectionTypes) {
        [_sectionHeader0 setSelected:NO];
        [self filterSliderTemplates];
    }
    else if (section == kSectionAdvancedSliders) [_sectionHeader3 setSelected:NO];
    
    [self updateSectionHeaderTitles:section];
}

- (void)accordion:(JHAccordion *)accordion openedSection:(NSInteger)section {
    
}

- (void)accordion:(JHAccordion *)accordion closedSection:(NSInteger)section {
    if (section == kSectionTypes) {
        [_tblSliders reloadData];
    }
}

#pragma mark - Actions

- (IBAction)onClickClose:(id)sender {
    if ([_delegate respondsToSelector:@selector(adjustDrinkSliderListSliderViewControllerDelegateClickClose:)]) {
        [_delegate adjustDrinkSliderListSliderViewControllerDelegateClickClose:self];
    }
}

- (IBAction)onClickSubmit:(id)sender {
    [self doCreateSpotlist];
}

#pragma mark - Public

- (void)resetForm {
    // Reset
    _selectedDrinkType = nil;
    
    // Resets headers
    [self updateSectionHeaderTitles:kSectionTypes];
    
    [_sliders removeAllObjects];
    [_advancedSliders removeAllObjects];
    
    [self filterSliderTemplates];
    
    // Reload
    [_tblSliders reloadData];
}

#pragma mark - Private

- (void)fetchFormData {
    
    // Gets drink form data
    [DrinkModel getDrinks:@{kDrinkModelParamsPageSize:@0} success:^(NSArray *spotModels, JSONAPI *jsonApi) {
        
        NSDictionary *forms = [jsonApi objectForKey:@"form"];
        if (forms != nil) {
            _drinkTypes = [forms objectForKey:@"drink_types"];
        }
        [_tblSliders reloadData];
        
    } failure:^(ErrorModel *errorModel) {
        
    }];
    
}

- (void)filterSliderTemplates {
    
    NSMutableArray *slidersFiltered = [NSMutableArray array];
    if (_selectedDrinkType == nil) {
        _sliderTemplates = nil;
//        // Filters if is used for any drink type
//        for (SliderTemplateModel *sliderTemplate in _allSliderTemplates) {
//            if (sliderTemplate.drinkTypes.count > 0) {
//                [slidersFiltered addObject:sliderTemplate];
//            }
//        }
        
    } else {
        NSNumber *selectedSpotTypeId = [_selectedDrinkType objectForKey:@"id"];
        
        // Filters by spot idea
        for (SliderTemplateModel *sliderTemplate in _allSliderTemplates) {
            NSArray *spotTypeIds = [sliderTemplate.drinkTypes valueForKey:@"ID"];
            
            if ([spotTypeIds containsObject:selectedSpotTypeId]) {
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
    
    [self showHUD:@"Loading sliders"];
    [SliderTemplateModel getSliderTemplates:nil success:^(NSArray *sliderTemplates, JSONAPI *jsonApi) {
        [self hideHUD];
        _allSliderTemplates = sliderTemplates;
        
        [self filterSliderTemplates];
        
    } failure:^(ErrorModel *errorModel) {
        [self hideHUD];
    }];
}

- (void)doCreateSpotlist {
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
    
    [self showHUD:@"Creating drinklist"];
    [DrinkListModel postDrinkList:kDrinkListModelDefaultName latitude:latitude longitude:longitude sliders:allTheSliders drinkId:nil drinkTypeId:[_selectedDrinkType objectForKey:@"id"] spotId:_spot.ID successBlock:^(DrinkListModel *drinkListModel, JSONAPI *jsonApi) {
        [self hideHUD];
        [self showHUDCompleted:@"Drinklist created!" block:^{
            
            if ([_delegate respondsToSelector:@selector(adjustDrinkSliderListSliderViewControllerDelegate:createdDrinkList:)]) {
                [_delegate adjustDrinkSliderListSliderViewControllerDelegate:self createdDrinkList:drinkListModel];
            }
            
        }];
        
    } failure:^(ErrorModel *errorModel) {
        [self hideHUD];
        [self showAlert:@"Oops" message:errorModel.human];
    }];
}

- (void)updateSectionHeaderTitles:(NSInteger)section {
    
    if (section == kSectionTypes) {
        
        if (_selectedDrinkType == nil) {
            [_sectionHeader0.lblText setText:@"Select Drink Type"];
        } else {
            [_sectionHeader0.lblText setText:[_selectedDrinkType objectForKey:@"name"]];
        }
        
    }
    
}

- (AdjustSliderSectionHeaderView*)sectionHeaderViewForSection:(NSInteger)section {
    
    if (section == kSectionTypes) {
        if (_sectionHeader0 == nil) {
            _sectionHeader0 = [[AdjustSliderSectionHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(_tblSliders.frame), 48.0f)];
            
            [_sectionHeader0.btnBackground setTag:section];
            [_sectionHeader0.btnBackground addTarget:_accordion action:@selector(onClickSection:) forControlEvents:UIControlEventTouchUpInside];
            
            // Add borders
            [_sectionHeader0 addTopBorder:[UIColor colorWithWhite:1.0f alpha:0.8f]];
            [_sectionHeader0 addBottomBorder:[UIColor colorWithWhite:1.0f alpha:0.8f]];
            
            [self updateSectionHeaderTitles:section];
        }
        
        return _sectionHeader0;
    } else if (section == kSectionAdvancedSliders) {
        if (_sectionHeader3 == nil) {
            _sectionHeader3 = [[AdjustSliderSectionHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(_tblSliders.frame), 48.0f)];
            
            [_sectionHeader3 setText:@"Advanced Sliders"];
            
            [_sectionHeader3.btnBackground setTag:section];
            [_sectionHeader3.btnBackground addTarget:_accordion action:@selector(onClickSection:) forControlEvents:UIControlEventTouchUpInside];
            
            // Add borders
            [_sectionHeader3 addBottomBorder:[UIColor colorWithWhite:1.0f alpha:0.8f]];
            
            [self updateSectionHeaderTitles:section];
        }
        
        return _sectionHeader3;
    }
    return nil;
}

@end
