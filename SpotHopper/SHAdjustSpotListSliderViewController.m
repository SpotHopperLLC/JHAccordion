//
//  SHAdjustSpotListSliderViewController.m
//  SpotHopper
//
//  Created by Brennan Stehling on 5/14/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#define kSectionTypes 0
#define kSectionMoods 1
#define kSectionSliders 2
#define kSectionAdvancedSliders 3

#import "SHAdjustSpotListSliderViewController.h"

#import "SHStyleKit+Additions.h"

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
#import "TellMeMyLocation.h"

#import <CoreLocation/CoreLocation.h>

#pragma mark -

@interface SHAdjustSpotListSliderViewController () <UITableViewDataSource, UITableViewDelegate, JHAccordionDelegate, ReviewSliderCellDelegate>

#pragma mark -

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIButton *btnRight;

@property (weak, nonatomic) IBOutlet UITableView *tblSliders;
@property (weak, nonatomic) IBOutlet SHButtonLatoLight *btnSubmit;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnSubmitBottomConstraint;

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

#pragma mark -

@implementation SHAdjustSpotListSliderViewController {
    BOOL _isUpdatingTableView;
}

#pragma mark - View Lifecycle
#pragma mark -

- (void)viewDidLoad {
    [self viewDidLoad:@[kDidLoadOptionsNoBackground]];
    
    self.navigationController.navigationBar.barTintColor = [SHStyleKit myLightHeaderColor];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [SHStyleKit myTextColor]};
    
    self.backgroundImageView.image = [SHStyleKit gradientBackgroundWithSize:self.view.frame.size];
    
    [SHStyleKit setButton:self.btnRight withDrawing:SHStyleKitDrawingSpotIcon normalColor:SHStyleKitColorMyTintColor highlightedColor:SHStyleKitColorMyTextColor];
    
    // Configures accordion
    self.accordion = [[JHAccordion alloc] initWithTableView:self.tblSliders];
    [self.accordion setDelegate:self];
    
    // Configures table
    [self.tblSliders setTableFooterView:[[UIView alloc] init]];
    [self.tblSliders registerNib:[UINib nibWithNibName:@"ReviewSliderCellView" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"ReviewSliderCell"];
    
    [self.tblSliders setBackgroundColor:[UIColor clearColor]];
    
    // Initializes
    self.sliders = [NSMutableArray array];
    self.advancedSliders = [NSMutableArray array];
    
    [self fetchFormData];
    [self fetchSliderTemplates];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // We don't need to listen for this here
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationPushReceived object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self hideSubmitButton:FALSE];
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
        return self.spotTypes.count + 1;
    } else if (section == kSectionMoods) {
        return self.spotListMoodTypes.count + 1;
    } else if (section == kSectionSliders) {
        return self.sliders.count;
    } else if (section == kSectionAdvancedSliders) {
        return self.advancedSliders.count;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kSectionTypes) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AdjustSliderOptionCell" forIndexPath:indexPath];
        UILabel *lblTitle = (UILabel *)[cell viewWithTag:1];
        NSAssert(lblTitle, @"Label must be defined");
        
        if (indexPath.row > 0) {
            NSDictionary *spotType = [self.spotTypes objectAtIndex:indexPath.row - 1];
            [lblTitle setText:[spotType objectForKey:@"name"]];
        } else {
            [lblTitle setText:@"Any"];
        }
        
        cell.clipsToBounds = TRUE;
        
        return cell;
    }
    else if (indexPath.section == kSectionMoods) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AdjustSliderOptionCell" forIndexPath:indexPath];
        UILabel *lblTitle = (UILabel *)[cell viewWithTag:1];
        NSAssert(lblTitle, @"Label must be defined");

        if (indexPath.row > 0) {
            SpotListMoodModel *spotListMood = [self.spotListMoodTypes objectAtIndex:indexPath.row - 1];
            [lblTitle setText:spotListMood.name];
        } else {
            [lblTitle setText:@"None"];
        }
        
        cell.clipsToBounds = TRUE;
        
        return cell;
    }
    else if (indexPath.section == kSectionSliders) {
        SliderModel *slider = [self.sliders objectAtIndex:indexPath.row];
        ReviewSliderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ReviewSliderCell" forIndexPath:indexPath];
        [cell setDelegate:self];
        [cell setSliderTemplate:slider.sliderTemplate withSlider:slider showSliderValue:NO];
        
        cell.clipsToBounds = TRUE;
        
        return cell;
    }
    else if (indexPath.section == kSectionAdvancedSliders) {
        SliderModel *slider = [self.advancedSliders objectAtIndex:indexPath.row];
        ReviewSliderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ReviewSliderCell" forIndexPath:indexPath];
        [cell setDelegate:self];
        [cell setSliderTemplate:slider.sliderTemplate withSlider:slider showSliderValue:NO];
        
        cell.clipsToBounds = TRUE;
        
        return cell;
    }
    
    return nil;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [cell setBackgroundColor:[UIColor clearColor]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == kSectionTypes) {
        if (indexPath.row > 0) {
            self.selectedSpotType = [self.spotTypes objectAtIndex:indexPath.row - 1];
        } else {
            self.selectedSpotType = nil;
        }
        [self.accordion closeSection:indexPath.section];
        
    } else if (indexPath.section == kSectionMoods) {
        if (indexPath.row > 0) {
            self.selectedSpotListMood = [self.spotListMoodTypes objectAtIndex:indexPath.row - 1];
            if (self.selectedSpotListMood.name.length) {
                [Tracker track:@"Selected Spotlist Mood" properties:@{@"Name" : self.selectedSpotListMood.name}];
            }
            [self showSubmitButton:YES];
        } else {
            self.selectedSpotListMood = nil;
            [self hideSubmitButton:YES];
        }
        [self.accordion closeSection:indexPath.section];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kSectionTypes) {
        return ( [self.accordion isSectionOpened:indexPath.section] ? 44.0f : 0.0f);
    } else if (indexPath.section == kSectionMoods) {
        return ( [self.accordion isSectionOpened:indexPath.section] ? 44.0f : 0.0f);
    } else if (indexPath.section == kSectionSliders) {
        return 77.0f;
    } else if (indexPath.section == kSectionAdvancedSliders) {
        return ( [self.accordion isSectionOpened:indexPath.section] ? 77.0f : 0.0f);
    }
    
    return 0.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [self sectionHeaderViewForSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == kSectionTypes || section == kSectionMoods) {
        return 48.0f;
    } else if (section == 3 && self.advancedSliders.count > 0) {
        return 48.0f;
    }
    
    return 0.0f;
}

#pragma mark - ReviewSliderCellDelegate

- (void)reviewSliderCell:(ReviewSliderCell *)cell changedValue:(CGFloat)value {
    // Sets slider to darker/selected color for good
    [cell.slider setUserMoved:YES];
    
    NSIndexPath *indexPath = [self.tblSliders indexPathForCell:cell];
    
    if (indexPath.section == kSectionSliders) {
        SliderModel *slider = [self.sliders objectAtIndex:indexPath.row];
        [slider setValue:[NSNumber numberWithFloat:(value * 10)]];
    } else if (indexPath.section == kSectionAdvancedSliders) {
        SliderModel *slider = [self.advancedSliders objectAtIndex:indexPath.row];
        [slider setValue:[NSNumber numberWithFloat:(value * 10)]];
    }
}

- (void)reviewSliderCell:(ReviewSliderCell*)cell finishedChangingValue:(CGFloat)value {
    // move table view of sliders up a little to make the next slider visible
    [self slideCell:cell aboveTableViewMidwayPoint:self.tblSliders];
    
    if (self.btnSubmitBottomConstraint.constant != 0) {
        [self.btnSubmit setTitle:@"Search" forState:UIControlStateNormal];
        [self showSubmitButton:TRUE];
    }
}

#pragma mark - JHAccordionDelegate

- (void)accordion:(JHAccordion *)accordion openingSection:(NSInteger)section {
    if (section == kSectionTypes) [self.sectionHeader0 setSelected:YES];
    else if (section == kSectionMoods) [self.sectionHeader1 setSelected:YES];
    else if (section == kSectionAdvancedSliders) [self.sectionHeader3 setSelected:YES];
}

- (void)accordion:(JHAccordion *)accordion closingSection:(NSInteger)section {
    if (section == kSectionTypes) {
        [self.sectionHeader0 setSelected:NO];
        [self filterSliderTemplates];
    } else if (section == kSectionMoods) [self.sectionHeader1 setSelected:NO];
    else if (section == kSectionAdvancedSliders) [self.sectionHeader3 setSelected:NO];
    
    [self updateSectionHeaderTitles:section];
}

- (void)accordion:(JHAccordion *)accordion openedSection:(NSInteger)section {
}

- (void)accordion:(JHAccordion *)accordion closedSection:(NSInteger)section {
    if (section == kSectionTypes) {
        [self.tblSliders reloadData];
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

- (IBAction)searchButtonTapped:(id)sender {
    [self doCreateSpotlist];
}

#pragma mark - Public

- (void)resetForm {
    [self.tblSliders scrollRectToVisible:CGRectMake(0, 0, CGRectGetWidth(self.tblSliders.frame), 1) animated:NO];
    [self.btnSubmit setHidden:TRUE];
    
    // Reset
    self.selectedSpotType = nil;
    self.selectedSpotListMood = nil;
    
    // Close section
    [self.accordion closeSection:kSectionTypes];
    [self.accordion closeSection:kSectionMoods];
    [self.accordion closeSection:kSectionAdvancedSliders];
    
    // Resets headers
    [self updateSectionHeaderTitles:kSectionTypes];
    [self updateSectionHeaderTitles:kSectionMoods];
    [self updateSectionHeaderTitles:kSectionAdvancedSliders];
    
    [self.sliders removeAllObjects];
    [self.advancedSliders removeAllObjects];
    
    [self filterSliderTemplates];
    
    // Reload
    [self.tblSliders reloadData];
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
            self.spotTypesUpdate = userSpotTypes;
            
        }
        
        [self updateSpotTypes];
    } failure:^(ErrorModel *errorModel) {
        [Tracker logError:errorModel.error class:[self class] trace:NSStringFromSelector(_cmd)];
    }];
    
    [SpotListMoodModel getSpotListMoods:nil success:^(NSArray *spotListMoodModels, JSONAPI *jsonApi) {
        self.spotListMoodTypesUpdate = spotListMoodModels;
        [self updateSpotListMoodTypes];
    } failure:^(ErrorModel *errorModel) {
        [Tracker logError:errorModel.error class:[self class] trace:NSStringFromSelector(_cmd)];
    }];
}

- (void)filterSliderTemplates {
    
    NSMutableArray *slidersFiltered = [NSMutableArray array];
    if (self.selectedSpotType == nil) {
        
        // Filters if is used for any spot type
        for (SliderTemplateModel *sliderTemplate in self.allSliderTemplates) {
            if (sliderTemplate.spotTypes.count > 0) {
                [slidersFiltered addObject:sliderTemplate];
            }
        }
        
    } else {
        NSNumber *selectedSpotTypeId = [self.selectedSpotType objectForKey:@"id"];
        
        // Filters by spot idea
        for (SliderTemplateModel *sliderTemplate in self.allSliderTemplates) {
            NSArray *spotTypeIds = [sliderTemplate.spotTypes valueForKey:@"ID"];
            
            if ([spotTypeIds containsObject:selectedSpotTypeId]) {
                [slidersFiltered addObject:sliderTemplate];
            }
        }
        
    }
    
    self.sliderTemplates = slidersFiltered;
    
    // Creating sliders
    [self.sliders removeAllObjects];
    for (SliderTemplateModel *sliderTemplate in self.sliderTemplates) {
        SliderModel *slider = [[SliderModel alloc] init];
        [slider setSliderTemplate:sliderTemplate];
        [self.sliders addObject:slider];
    }
    
    // Filling advanced sliders if nil
    [self.advancedSliders removeAllObjects];
    
    // Moving advanced sliders into their own array
    for (SliderModel *slider in self.sliders) {
        if (slider.sliderTemplate.required == NO) {
            [self.advancedSliders addObject:slider];
        }
    }
    
    // Removing advances sliders from basic array
    for (SliderModel *slider in self.advancedSliders) {
        [self.sliders removeObject:slider];
    }
    
    // Reloading table
    [self.tblSliders reloadData];
}

- (void)fetchSliderTemplates {
    [SliderTemplateModel fetchSliderTemplates:^(NSArray *sliderTemplates) {
        [self hideHUD];
        self.allSliderTemplatesUpdate = sliderTemplates;
        
        [self filterSliderTemplates];
        [self updateAllSliderTemplates];
    } failure:^(ErrorModel *errorModel) {
        [self hideHUD];
        [Tracker logError:errorModel.error class:[self class] trace:NSStringFromSelector(_cmd)];
    }];
}

- (void)doCreateSpotlist {
    NSMutableArray *allTheSliders = [NSMutableArray array];
    [allTheSliders addObjectsFromArray:self.sliders];
    [allTheSliders addObjectsFromArray:self.advancedSliders];
    
    for (SliderModel *sliderModel in self.sliders) {
        if (sliderModel.value) {
            [Tracker track:@"Slider Value Set" properties:@{@"Type" : @"Spotlist", @"Name" : sliderModel.sliderTemplate.name, @"Value" : sliderModel.value, @"Advanced" : @NO}];
        }
    }
    for (SliderModel *sliderModel in self.advancedSliders) {
        if (sliderModel.value) {
            [Tracker track:@"Slider Value Set" properties:@{@"Type" : @"Spotlist", @"Name" : sliderModel.sliderTemplate.name, @"Value" : sliderModel.value, @"Advanced" : @YES}];
        }
    }
    
    NSNumber *latitude = nil, *longitude = nil;
    if (_location != nil) {
        latitude = [NSNumber numberWithFloat:_location.coordinate.latitude];
        longitude = [NSNumber numberWithFloat:_location.coordinate.longitude];
    }
    
    NSNumber *spotTypeId = [self.selectedSpotType objectForKey:@"id"];
    
    [Tracker track:@"Creating Spotlist"];
    
    [self showHUD:@"Creating spotlist"];
    [SpotListModel postSpotList:kSpotListModelDefaultName spotId:nil spotTypeId:spotTypeId latitude:latitude longitude:longitude sliders:allTheSliders successBlock:^(SpotListModel *spotListModel, JSONAPI *jsonApi) {
        [Tracker track:@"Created Spotlist" properties:@{@"Success" : @TRUE, @"Spot Type ID" : spotTypeId ?: @0, @"Created With Sliders" : @TRUE}];
        [self hideHUD];
        [self showHUDCompleted:@"Spotlist created!" block:^{
            if ([self.delegate respondsToSelector:@selector(adjustSpotListSliderViewController:didCreateSpotList:)]) {
                [self.delegate adjustSpotListSliderViewController:self didCreateSpotList:spotListModel];
            }
            self.spotListModel = spotListModel;
            [self performSegueWithIdentifier:@"finishCreatingSpotListForHomeMap" sender:self];
        }];
        
    } failure:^(ErrorModel *errorModel) {
        [Tracker track:@"Created Spotlist" properties:@{@"Success" : @FALSE}];
        [self hideHUD];
        [self showAlert:@"Oops" message:errorModel.human];
        [Tracker logError:errorModel.error class:[self class] trace:NSStringFromSelector(_cmd)];
    }];
}

- (void)changeMood {
    if (self.selectedSpotListMood == nil) {
        for (SliderModel *slider in self.sliders) {
            [slider setValue:nil];
        }
    } else {
        
        // Puts sliders into dictionary so that they can be easily found by the slider tempate ID
        NSMutableDictionary *sliderTemplateToSliderMap = [NSMutableDictionary dictionary];
        for (SliderModel *slider in self.sliders) {
            [sliderTemplateToSliderMap setObject:slider forKey:slider.sliderTemplate.ID];
            [slider setValue:nil];
        }
        for (SliderModel *slider in self.advancedSliders) {
            [sliderTemplateToSliderMap setObject:slider forKey:slider.sliderTemplate.ID];
            [slider setValue:nil];
        }
        
        // Sets the mooooooood if the slider templates match
        for (SliderModel *moodSlider in self.selectedSpotListMood.sliders) {
            SliderModel *slider = [sliderTemplateToSliderMap objectForKey:moodSlider.sliderTemplate.ID];
            if (slider != nil) {
                [slider setValue:moodSlider.value];
            }
        }
    }
    
    [self.tblSliders reloadData];
}

- (void)updateSectionHeaderTitles:(NSInteger)section {
    
    if (section == kSectionTypes) {
        
        if (self.selectedSpotType == nil) {
            CGFloat fontSize = self.sectionHeader0.lblText.font.pointSize;
            [self.sectionHeader0.lblText setText:@"Select Spot Type (optional)" withFont:[UIFont fontWithName:@"Lato-LightItalic" size:fontSize] onString:@"(optional)"];
        } else {
            [self.sectionHeader0.lblText setText:[self.selectedSpotType objectForKey:@"name"]];
        }
        
    } else if (section == kSectionMoods) {
        
        if (self.selectedSpotListMood == nil) {
            CGFloat fontSize = self.sectionHeader1.lblText.font.pointSize;
            [self.sectionHeader1.lblText setText:@"Select Mood (optional)" withFont:[UIFont fontWithName:@"Lato-LightItalic" size:fontSize] onString:@"(optional)"];
        } else {
            [self.sectionHeader1.lblText setText:self.selectedSpotListMood.name];
        }
        
    }
    
}

- (AdjustSliderSectionHeaderView*)sectionHeaderViewForSection:(NSInteger)section {
    
    if (section == kSectionTypes) {
        if (self.sectionHeader0 == nil) {
            self.sectionHeader0 = [[AdjustSliderSectionHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tblSliders.frame), 48.0f)];
            
            [self.sectionHeader0.btnBackground setTag:section];
            [self.sectionHeader0.btnBackground addTarget:self.accordion action:@selector(onClickSection:) forControlEvents:UIControlEventTouchUpInside];
            
            // Add borders
            [self.sectionHeader0 addTopBorder:[UIColor colorWithWhite:1.0f alpha:0.8f]];
            [self.sectionHeader0 addBottomBorder:[UIColor colorWithWhite:1.0f alpha:0.8f]];
            
            [self updateSectionHeaderTitles:section];
        }
        
        return self.sectionHeader0;
    } else if (section == kSectionMoods) {
        if (self.sectionHeader1 == nil) {
            self.sectionHeader1 = [[AdjustSliderSectionHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tblSliders.frame), 48.0f)];
            
            [self.sectionHeader1.btnBackground setTag:section];
            [self.sectionHeader1.btnBackground addTarget:self.accordion action:@selector(onClickSection:) forControlEvents:UIControlEventTouchUpInside];
            
            // Add borders
            [self.sectionHeader1 addBottomBorder:[UIColor colorWithWhite:1.0f alpha:0.8f]];
            
            [self updateSectionHeaderTitles:section];
        }
        
        return self.sectionHeader1;
    } else if (section == kSectionAdvancedSliders) {
        if (self.sectionHeader3 == nil) {
            self.sectionHeader3 = [[AdjustSliderSectionHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tblSliders.frame), 48.0f)];
            
            [self.sectionHeader3 setText:@"Advanced Sliders"];
            
            [self.sectionHeader3.btnBackground setTag:section];
            [self.sectionHeader3.btnBackground addTarget:self.accordion action:@selector(onClickSection:) forControlEvents:UIControlEventTouchUpInside];
            
            // Add borders
            [self.sectionHeader3 addBottomBorder:[UIColor colorWithWhite:1.0f alpha:0.8f]];
            
            [self updateSectionHeaderTitles:section];
        }
        
        return self.sectionHeader3;
    }
    return nil;
}

- (void)hideSubmitButton:(BOOL)animated {
    // 1) slide the button down and out of view
    // 2) set hidden to TRUE
    
    [UIView animateWithDuration:animated ? 0.5 : 0.0 animations:^{
        self.btnSubmitBottomConstraint.constant = -1 * CGRectGetHeight(self.btnSubmit.frame);
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
        self.tblSliders.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
        self.tblSliders.scrollIndicatorInsets = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
    } completion:^(BOOL finished) {
        self.btnSubmit.hidden = TRUE;
    }];
}

- (void)showSubmitButton:(BOOL)animated {
    // 1) position it below the superview (out of view)
    // 2) set to hidden = false
    // 3) animate it up into position
    // 4) update the table with insets so it will not cover table cells
    
    self.btnSubmit.hidden = FALSE;
    CGFloat buttonHeight = CGRectGetHeight(self.btnSubmit.frame);
    
    [self.view bringSubviewToFront:self.btnSubmit];
    
    [UIView animateWithDuration:animated ? 0.5 : 0.0 animations:^{
        self.btnSubmitBottomConstraint.constant = 0;
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
        self.tblSliders.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, buttonHeight, 0.0f);
        self.tblSliders.scrollIndicatorInsets = UIEdgeInsetsMake(0.0f, 0.0f, buttonHeight, 0.0f);
    } completion:^(BOOL finished) {
    }];
}

- (void)updateSpotTypes {
    if (!_isUpdatingTableView && self.spotTypesUpdate) {
        self.spotTypes = self.spotTypesUpdate;
        self.spotTypesUpdate = nil;
        [self.tblSliders reloadData];
    }
    else if (_isUpdatingTableView && self.spotTypesUpdate) {
        // update later when the table may be done updating
        [self performSelector:@selector(updateSpotTypes) withObject:nil afterDelay:0.25];
    }
}

- (void)updateSpotListMoodTypes {
    if (!_isUpdatingTableView && self.spotListMoodTypesUpdate) {
        self.spotListMoodTypes = self.spotListMoodTypesUpdate;
        self.spotListMoodTypesUpdate = nil;
        [self.tblSliders reloadData];
    }
    else if (_isUpdatingTableView && self.spotListMoodTypesUpdate) {
        // update later when the table may be done updating
        [self performSelector:@selector(updateSpotListMoodTypes) withObject:nil afterDelay:0.25];
    }
}

- (void)updateAllSliderTemplates {
    if (!_isUpdatingTableView && self.allSliderTemplatesUpdate) {
        self.allSliderTemplates = self.allSliderTemplatesUpdate;
        self.allSliderTemplatesUpdate = nil;
        [self.tblSliders reloadData];
    }
    else if (_isUpdatingTableView && self.allSliderTemplatesUpdate) {
        // update later when the table may be done updating
        [self performSelector:@selector(updateAllSliderTemplates) withObject:nil afterDelay:0.25];
    }
}

@end
