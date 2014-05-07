//
//  AdjustSpotListSliderViewController.m
//  SpotHopper
//
//  Created by Josh Holtz on 3/5/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#define kSectionTypes 0
#define kSectionMoods 1
#define kSectionSliders 2
#define kSectionAdvancedSliders 3

#import "AdjustSpotListSliderViewController.h"

#import "SHButtonLatoLight.h"
#import "NSDate+Globalize.h"
#import "TTTAttributedLabel+QuickFonting.h"
#import "UIView+AddBorder.h"

#import "AdjustSliderSectionHeaderView.h"

#import "AdjustSliderOptionCell.h"
#import "ReviewSliderCell.h"

#import "ClientSessionManager.h"
#import "ErrorModel.h"
#import "SpotModel.h"
#import "SpotListModel.h"
#import "SpotListMoodModel.h"
#import "SliderModel.h"
#import "SliderTemplateModel.h"

#import "Tracker.h"

#import "JHAccordion.h"

#import <CoreLocation/CoreLocation.h>

@interface AdjustSpotListSliderViewController () <UITableViewDataSource, UITableViewDelegate, JHAccordionDelegate, ReviewSliderCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tblSliders;
@property (weak, nonatomic) IBOutlet SHButtonLatoLight *btnSubmit;

@property (nonatomic, strong) JHAccordion *accordion;
@property (nonatomic, strong) AdjustSliderSectionHeaderView *sectionHeader0;
@property (nonatomic, strong) AdjustSliderSectionHeaderView *sectionHeader1;
@property (nonatomic, strong) AdjustSliderSectionHeaderView *sectionHeader3;

@property (nonatomic, strong) NSArray *spotTypes;
@property (nonatomic, strong) NSDictionary *selectedSpotType;

@property (nonatomic, strong) NSArray *spotListMoodTypes;
@property (nonatomic, strong) SpotListMoodModel *selectedSpotListMood;

@property (nonatomic, strong) NSArray *allSliderTemplates;
@property (nonatomic, strong) NSArray *sliderTemplates;
@property (nonatomic, strong) NSMutableArray *sliders;
@property (nonatomic, strong) NSMutableArray *advancedSliders;

@property (nonatomic, strong) NSArray *spotTypesUpdate;
@property (nonatomic, strong) NSArray *spotListMoodTypesUpdate;
@property (nonatomic, strong) NSArray *allSliderTemplatesUpdate;

@end

@implementation AdjustSpotListSliderViewController {
    BOOL _isUpdatingTableView;
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
    return @"Adjust Spotlist Slider";
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == kSectionTypes) {
        return _spotTypes.count + 1;
    } else if (section == kSectionMoods) {
        return _spotListMoodTypes.count + 1;
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
            NSDictionary *spotType = [_spotTypes objectAtIndex:indexPath.row - 1];
            [cell.lblTitle setText:[spotType objectForKey:@"name"]];
        } else {
            [cell.lblTitle setText:@"Any"];
        }
        
        return cell;
    }
    else if (indexPath.section == kSectionMoods) {
        AdjustSliderOptionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AdjustSliderOptionCell" forIndexPath:indexPath];
        if (indexPath.row > 0) {
            SpotListMoodModel *spotListMood = [_spotListMoodTypes objectAtIndex:indexPath.row - 1];
            [cell.lblTitle setText:spotListMood.name];
        } else {
            [cell.lblTitle setText:@"None"];
        }
        
        return cell;
    }
    else if (indexPath.section == kSectionSliders) {
        SliderModel *slider = [_sliders objectAtIndex:indexPath.row];
        ReviewSliderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ReviewSliderCell" forIndexPath:indexPath];
        [cell setDelegate:self];
        [cell setSliderTemplate:slider.sliderTemplate withSlider:slider showSliderValue:NO];
        
        return cell;
    }
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
    
    if (indexPath.section == kSectionTypes) {
        if (indexPath.row > 0) {
            _selectedSpotType = [_spotTypes objectAtIndex:indexPath.row - 1];
        } else {
            _selectedSpotType = nil;
        }
        [_accordion closeSection:indexPath.section];
        
    } else if (indexPath.section == kSectionMoods) {
        if (indexPath.row > 0) {
            _selectedSpotListMood = [_spotListMoodTypes objectAtIndex:indexPath.row - 1];
            [self showSubmitButton:YES];
        } else {
            _selectedSpotListMood = nil;
            [self hideSubmitButton:YES];
        }
        [_accordion closeSection:indexPath.section];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kSectionTypes) {
        return ( [_accordion isSectionOpened:indexPath.section] ? 44.0f : 0.0f);
    } else if (indexPath.section == kSectionMoods) {
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
    if (section == kSectionTypes || section == kSectionMoods) {
        return 48.0f;
    } else if (section == 3 && _advancedSliders.count > 0) {
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
    if (section == kSectionTypes) [_sectionHeader0 setSelected:YES];
    else if (section == kSectionMoods) [_sectionHeader1 setSelected:YES];
    else if (section == kSectionAdvancedSliders) [_sectionHeader3 setSelected:YES];
}

- (void)accordion:(JHAccordion *)accordion closingSection:(NSInteger)section {
    if (section == kSectionTypes) {
        [_sectionHeader0 setSelected:NO];
        [self filterSliderTemplates];
    } else if (section == kSectionMoods) [_sectionHeader1 setSelected:NO];
    else if (section == kSectionAdvancedSliders) [_sectionHeader3 setSelected:NO];
    
    [self updateSectionHeaderTitles:section];
}

- (void)accordion:(JHAccordion *)accordion openedSection:(NSInteger)section {
}

- (void)accordion:(JHAccordion *)accordion closedSection:(NSInteger)section {
    if (section == kSectionTypes) {
        [_tblSliders reloadData];
        [self hideSubmitButton:TRUE];
    } else if (section == kSectionMoods) {
        [self changeMood];
    }
}

- (void)accordion:(JHAccordion*)accordion contentSizeChanged:(CGSize)contentSize {
    [accordion slideUpLastOpenedSection];
}

- (void)accordion:(JHAccordion*)accordion willUpdateTableView:(UITableView *)tableView {
    _isUpdatingTableView = TRUE;
}

- (void)accordion:(JHAccordion*)accordion didUpdateTableView:(UITableView *)tableView {
    _isUpdatingTableView = FALSE;
    
    [self updateSpotTypes];
    [self updateSpotListMoodTypes];
    [self updateAllSliderTemplates];
}

#pragma mark - Actions

- (IBAction)onClickClose:(id)sender {
    if ([_delegate respondsToSelector:@selector(adjustSliderListSliderViewControllerDelegateClickClose:)]) {
        [_delegate adjustSliderListSliderViewControllerDelegateClickClose:self];
    }
}

- (IBAction)onClickSubmit:(id)sender {
    [self doCreateSpotlist];
}

#pragma mark - Public

- (void)resetForm {
    [_tblSliders scrollRectToVisible:CGRectMake(0, 0, CGRectGetWidth(_tblSliders.frame), 1) animated:NO];
    [_btnSubmit setHidden:TRUE];
    
    // Reset
    _selectedSpotType = nil;
    _selectedSpotListMood = nil;
    
    // Close section
    [_accordion closeSection:kSectionTypes];
    [_accordion closeSection:kSectionMoods];
    [_accordion closeSection:kSectionAdvancedSliders];
    
    // Resets headers
    [self updateSectionHeaderTitles:kSectionTypes];
    [self updateSectionHeaderTitles:kSectionMoods];
    [self updateSectionHeaderTitles:kSectionAdvancedSliders];
    
    [_sliders removeAllObjects];
    [_advancedSliders removeAllObjects];
    
    [self filterSliderTemplates];
    
    // Reload
    [_tblSliders reloadData];
}

#pragma mark - Private

- (void)fetchFormData {
    // Gets spot form data
    [SpotModel getSpots:@{kSpotModelParamsPageSize:@0} success:^(NSArray *spotModels, JSONAPI *jsonApi) {
        NSDictionary *forms = [jsonApi objectForKey:@"form"];
        if (forms != nil) {
            
            // Get spot types only user can see
            NSMutableArray *userSpotTypes = [NSMutableArray array];
            NSArray *allSpotTypes = [forms objectForKey:@"spot_types"];
            for (NSDictionary *spotType in allSpotTypes) {
                if ([[spotType objectForKey:@"visible_to_users"] boolValue] == YES) {
                    [userSpotTypes addObject:spotType];
                }
            }
            _spotTypesUpdate = userSpotTypes;
            
        }
        
        [self updateSpotTypes];
    } failure:^(ErrorModel *errorModel) {

    }];
    
    [SpotListMoodModel getSpotListMoods:nil success:^(NSArray *spotListMoodModels, JSONAPI *jsonApi) {
        _spotListMoodTypesUpdate = spotListMoodModels;
        [self updateSpotListMoodTypes];
    } failure:^(ErrorModel *errorModel) {
        
    }];
}

- (void)filterSliderTemplates {
    
    NSMutableArray *slidersFiltered = [NSMutableArray array];
    if (_selectedSpotType == nil) {
        
        // Filters if is used for any spot type
        for (SliderTemplateModel *sliderTemplate in _allSliderTemplates) {
            if (sliderTemplate.spotTypes.count > 0) {
                [slidersFiltered addObject:sliderTemplate];
            }
        }
        
    } else {
        NSNumber *selectedSpotTypeId = [_selectedSpotType objectForKey:@"id"];
        
        // Filters by spot idea
        for (SliderTemplateModel *sliderTemplate in _allSliderTemplates) {
            NSArray *spotTypeIds = [sliderTemplate.spotTypes valueForKey:@"ID"];
            
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
    
//    [self showHUD:@"Loading sliders"];
    [SliderTemplateModel getSliderTemplates:nil success:^(NSArray *sliderTemplates, JSONAPI *jsonApi) {
        [self hideHUD];
        _allSliderTemplatesUpdate = sliderTemplates;
        
        [self filterSliderTemplates];
        [self updateAllSliderTemplates];
    } failure:^(ErrorModel *errorModel) {
        [self hideHUD];
    }];
}

- (void)doCreateSpotlist {
    NSMutableArray *allTheSliders = [NSMutableArray array];
    [allTheSliders addObjectsFromArray:_sliders];
    [allTheSliders addObjectsFromArray:_advancedSliders];
    
    for (SliderModel *sliderModel in _sliders) {
        if (sliderModel.value) {
            [Tracker track:@"Slider Value Set" properties:@{@"Type" : @"Spotlist", @"Name" : sliderModel.sliderTemplate.name, @"Value" : sliderModel.value, @"Advanced" : @NO}];
        }
    }
    for (SliderModel *sliderModel in _advancedSliders) {
        if (sliderModel.value) {
            [Tracker track:@"Slider Value Set" properties:@{@"Type" : @"Spotlist", @"Name" : sliderModel.sliderTemplate.name, @"Value" : sliderModel.value, @"Advanced" : @YES}];
        }
    }
    
    NSNumber *latitude = nil, *longitude = nil;
    if (_location != nil) {
        latitude = [NSNumber numberWithFloat:_location.coordinate.latitude];
        longitude = [NSNumber numberWithFloat:_location.coordinate.longitude];
    }
    
    NSNumber *spotTypeId = [_selectedSpotType objectForKey:@"id"];
    
    [Tracker track:@"Creating Spotlist"];
    
    [self showHUD:@"Creating spotlist"];
    [SpotListModel postSpotList:kSpotListModelDefaultName spotId:nil spotTypeId:spotTypeId latitude:latitude longitude:longitude sliders:allTheSliders successBlock:^(SpotListModel *spotListModel, JSONAPI *jsonApi) {
        [Tracker track:@"Created Spotlist" properties:@{@"Success" : @TRUE}];
        [self hideHUD];
        [self showHUDCompleted:@"Spotlist created!" block:^{
            
            if ([_delegate respondsToSelector:@selector(adjustSliderListSliderViewControllerDelegate:createdSpotList:)]) {
                [_delegate adjustSliderListSliderViewControllerDelegate:self createdSpotList:spotListModel];
            }
            
        }];
        
    } failure:^(ErrorModel *errorModel) {
        [Tracker track:@"Created Spotlist" properties:@{@"Success" : @FALSE}];
        [self hideHUD];
        [self showAlert:@"Oops" message:errorModel.human];
    }];
}

- (void)changeMood {
    if (_selectedSpotListMood == nil) {
        for (SliderModel *slider in _sliders) {
            [slider setValue:nil];
        }
    } else {
        
        // Puts sliders into dictionary so that they can be easily found by the slider tempate ID
        NSMutableDictionary *sliderTemplateToSliderMap = [NSMutableDictionary dictionary];
        for (SliderModel *slider in _sliders) {
            [sliderTemplateToSliderMap setObject:slider forKey:slider.sliderTemplate.ID];
            [slider setValue:nil];
        }
        for (SliderModel *slider in _advancedSliders) {
            [sliderTemplateToSliderMap setObject:slider forKey:slider.sliderTemplate.ID];
            [slider setValue:nil];
        }
        
        // Sets the mooooooood if the slider templates match
        for (SliderModel *moodSlider in _selectedSpotListMood.sliders) {
            SliderModel *slider = [sliderTemplateToSliderMap objectForKey:moodSlider.sliderTemplate.ID];
            if (slider != nil) {
                [slider setValue:moodSlider.value];
            }
        }
    }
    
    [_tblSliders reloadData];
}

- (void)updateSectionHeaderTitles:(NSInteger)section {
    
    if (section == kSectionTypes) {
        
        if (_selectedSpotType == nil) {
            CGFloat fontSize = _sectionHeader0.lblText.font.pointSize;
            [_sectionHeader0.lblText setText:@"Select Spot Type (optional)" withFont:[UIFont fontWithName:@"Lato-LightItalic" size:fontSize] onString:@"(optional)"];
        } else {
            [_sectionHeader0.lblText setText:[_selectedSpotType objectForKey:@"name"]];
        }
        
    } else if (section == kSectionMoods) {
        
        if (_selectedSpotListMood == nil) {
            CGFloat fontSize = _sectionHeader1.lblText.font.pointSize;
            [_sectionHeader1.lblText setText:@"Select Mood (optional)" withFont:[UIFont fontWithName:@"Lato-LightItalic" size:fontSize] onString:@"(optional)"];
        } else {
            [_sectionHeader1.lblText setText:_selectedSpotListMood.name];
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
    } else if (section == kSectionMoods) {
        if (_sectionHeader1 == nil) {
            _sectionHeader1 = [[AdjustSliderSectionHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(_tblSliders.frame), 48.0f)];
            
            [_sectionHeader1.btnBackground setTag:section];
            [_sectionHeader1.btnBackground addTarget:_accordion action:@selector(onClickSection:) forControlEvents:UIControlEventTouchUpInside];
            
            // Add borders
            [_sectionHeader1 addBottomBorder:[UIColor colorWithWhite:1.0f alpha:0.8f]];
            
            [self updateSectionHeaderTitles:section];
        }
        
        return _sectionHeader1;
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
    if (_btnSubmit.hidden == FALSE) return;
    
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

- (void)updateSpotTypes {
    if (!_isUpdatingTableView && _spotTypesUpdate) {
        _spotTypes = _spotTypesUpdate;
        _spotTypesUpdate = nil;
        [_tblSliders reloadData];
    }
    else if (_isUpdatingTableView && _spotTypesUpdate) {
        // update later when the table may be done updating
        [self performSelector:@selector(updateSpotTypes) withObject:nil afterDelay:0.25];
    }
}

- (void)updateSpotListMoodTypes {
    if (!_isUpdatingTableView && _spotListMoodTypesUpdate) {
        _spotListMoodTypes = _spotListMoodTypesUpdate;
        _spotListMoodTypesUpdate = nil;
        [_tblSliders reloadData];
    }
    else if (_isUpdatingTableView && _spotListMoodTypesUpdate) {
        // update later when the table may be done updating
        [self performSelector:@selector(updateSpotListMoodTypes) withObject:nil afterDelay:0.25];
    }
}

- (void)updateAllSliderTemplates {
    if (!_isUpdatingTableView && _allSliderTemplatesUpdate) {
        _allSliderTemplates = _allSliderTemplatesUpdate;
        _allSliderTemplatesUpdate = nil;
        [_tblSliders reloadData];
    }
    else if (_isUpdatingTableView && _allSliderTemplatesUpdate) {
        // update later when the table may be done updating
        [self performSelector:@selector(updateAllSliderTemplates) withObject:nil afterDelay:0.25];
    }
}

@end
