//
//  AdjustSpotListSliderViewController.m
//  SpotHopper
//
//  Created by Josh Holtz on 3/5/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "AdjustSpotListSliderViewController.h"

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
#import "SliderModel.h"
#import "SliderTemplateModel.h"

#import <JHAccordion/JHAccordion.h>

@interface AdjustSpotListSliderViewController ()<UITableViewDataSource, UITableViewDelegate, JHAccordionDelegate, ReviewSliderCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tblSliders;

@property (nonatomic, strong) JHAccordion *accordion;
@property (nonatomic, strong) AdjustSliderSectionHeaderView *sectionHeader0;
@property (nonatomic, strong) AdjustSliderSectionHeaderView *sectionHeader1;
@property (nonatomic, strong) AdjustSliderSectionHeaderView *sectionHeader3;

@property (nonatomic, strong) NSArray *spotTypes;
@property (nonatomic, strong) NSDictionary *selectedSpotType;

@property (nonatomic, strong) NSArray *sliderTemplates;
@property (nonatomic, strong) NSMutableArray *sliders;
@property (nonatomic, strong) NSMutableArray *advancedSliders;

@end

@implementation AdjustSpotListSliderViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return _spotTypes.count;
    } else if (section == 1) {
        
    } else if (section == 2) {
        return _sliders.count;
    } else if (section == 3) {
        return _advancedSliders.count;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        NSDictionary *spotType = [_spotTypes objectAtIndex:indexPath.row];
        
        AdjustSliderOptionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AdjustSliderOptionCell" forIndexPath:indexPath];
        [cell.lblTitle setText:[spotType objectForKey:@"name"]];
        
        return cell;
    } else if (indexPath.section == 1) {
        
    }  else if (indexPath.section == 2) {
        
        SliderModel *slider = [_sliders objectAtIndex:indexPath.row];
        
        ReviewSliderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ReviewSliderCell" forIndexPath:indexPath];
        [cell setDelegate:self];
        [cell setSliderTemplate:slider.sliderTemplate withSlider:slider showSliderValue:NO];
        
        return cell;
    } else if (indexPath.section == 3) {
        
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
    
    if (indexPath.section == 0) {
        _selectedSpotType = [_spotTypes objectAtIndex:indexPath.row];
        [_accordion closeSection:indexPath.section];
        
    } else if (indexPath.section == 1) {
        
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return ( [_accordion isSectionOpened:indexPath.section] ? 44.0f : 0.0f);
    } else if (indexPath.section == 1) {
        return ( [_accordion isSectionOpened:indexPath.section] ? 44.0f : 0.0f);
    } else if (indexPath.section == 2) {
        return 77.0f;
    } else if (indexPath.section == 3) {
        return ( [_accordion isSectionOpened:indexPath.section] ? 77.0f : 0.0f);
    }
    
    return 0.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [self sectionHeaderViewForSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0 || section == 1) {
        return 48.0f;
    } else if (section == 3 && _advancedSliders.count > 0) {
        return 48.0f;
    }
    
    return 0.0f;
}

#pragma mark - ReviewSliderCellDelegate

- (void)reviewSliderCell:(ReviewSliderCell *)cell changedValue:(float)value {
    NSIndexPath *indexPath = [_tblSliders indexPathForCell:cell];
    
    if (indexPath.section == 2) {
        SliderModel *slider = [_sliders objectAtIndex:indexPath.row];
        [slider setValue:[NSNumber numberWithFloat:(value * 10)]];
    } else if (indexPath.section == 3) {
        SliderModel *slider = [_advancedSliders objectAtIndex:indexPath.row];
        [slider setValue:[NSNumber numberWithFloat:(value * 10)]];
    }
}

#pragma mark - JHAccordionDelegate

- (void)accordion:(JHAccordion *)accordion openingSection:(NSInteger)section {
    if (section == 0) [_sectionHeader0 setSelected:YES];
    else if (section == 1) [_sectionHeader1 setSelected:YES];
    else if (section == 3) [_sectionHeader3 setSelected:YES];
}

- (void)accordion:(JHAccordion *)accordion closingSection:(NSInteger)section {
    if (section == 0) {
        [_sectionHeader0 setSelected:NO];
        [self fetchSliderTemplates];
    } else if (section == 1) [_sectionHeader1 setSelected:NO];
    else if (section == 3) [_sectionHeader3 setSelected:NO];
    
    [self updateSectionHeaderTitles:section];
}

- (void)accordion:(JHAccordion *)accordion openedSection:(NSInteger)section {
    
}

- (void)accordion:(JHAccordion *)accordion closedSection:(NSInteger)section {
    [_tblSliders reloadData];
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

#pragma mark - Private

- (void)fetchFormData {
    
    // Gets spot form data
    [SpotModel getSpots:@{kSpotModelParamsPageSize:@0} success:^(NSArray *spotModels, JSONAPI *jsonApi) {
        
        NSDictionary *forms = [jsonApi objectForKey:@"form"];
        if (forms != nil) {
            _spotTypes = [forms objectForKey:@"spot_types"];
            [_tblSliders reloadData];
        }
        
    } failure:^(ErrorModel *errorModel) {

    }];
}

- (void)fetchSliderTemplates {
    
    // Gets sliders
    NSDictionary *params;
    NSNumber *spotTypeId = [_selectedSpotType objectForKey:@"id"];
    
    if (spotTypeId != nil) {
        params = @{
                   kSliderTemplateModelParamSpotTypeId: spotTypeId,
                   kSliderTemplateModelParamsPageSize: @100,
                   kSliderTemplateModelParamPage: @1
                   };
    }
    
    if (params != nil) {
        [self showHUD:@"Loading sliders"];
        [SliderTemplateModel getSliderTemplates:params success:^(NSArray *sliderTemplates, JSONAPI *jsonApi) {
            [self hideHUD];
            _sliderTemplates = sliderTemplates;
            
            // Creating sliders
            [_sliders removeAllObjects];
            for (SliderTemplateModel *sliderTemplate in _sliderTemplates) {
                SliderModel *slider = [[SliderModel alloc] init];
                [slider setValue:sliderTemplate.defaultValue];
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
            
        } failure:^(ErrorModel *errorModel) {
            [self hideHUD];
        }];
    }
}

- (void)doCreateSpotlist {
    NSMutableArray *allTheSliders = [NSMutableArray array];
    [allTheSliders addObjectsFromArray:_sliders];
    [allTheSliders addObjectsFromArray:_advancedSliders];
    
    [SpotListModel postSpotList:[NSDate date].stringAsShortDateShortTime sliders:allTheSliders successBlock:^(SpotListModel *spotListModel, JSONAPI *jsonApi) {
        [self hideHUD];
        [self showHUDCompleted:@"Spotlist created!" block:^{
            
            if ([_delegate respondsToSelector:@selector(adjustSliderListSliderViewControllerDelegate:createdSpotList:)]) {
                [_delegate adjustSliderListSliderViewControllerDelegate:self createdSpotList:spotListModel];
            }
            
        }];
        
    } failure:^(ErrorModel *errorModel) {
        [self hideHUD];
        [self showAlert:@"Oops" message:errorModel.human];
    }];
}

- (void)updateSectionHeaderTitles:(NSInteger)section {
    
    if (section == 0) {
        
        if (_selectedSpotType == nil) {
            [_sectionHeader0.lblText setText:@"Select Spot Type"];
        } else {
            [_sectionHeader0.lblText setText:[_selectedSpotType objectForKey:@"name"]];
        }
        
    } else if (section == 1) {
        
        CGFloat fontSize = _sectionHeader1.lblText.font.pointSize;
        [_sectionHeader1.lblText setText:@"Select Mood (optional)" withFont:[UIFont fontWithName:@"Lato-LightItalic" size:fontSize] onString:@"(optional)"];
        
    }
    
}

- (AdjustSliderSectionHeaderView*)sectionHeaderViewForSection:(NSInteger)section {
    
    if (section == 0) {
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
    } else if (section == 1) {
        if (_sectionHeader1 == nil) {
            _sectionHeader1 = [[AdjustSliderSectionHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(_tblSliders.frame), 48.0f)];
            
            [_sectionHeader1.btnBackground setTag:section];
            [_sectionHeader1.btnBackground addTarget:_accordion action:@selector(onClickSection:) forControlEvents:UIControlEventTouchUpInside];
            
            // Add borders
            [_sectionHeader1 addBottomBorder:[UIColor colorWithWhite:1.0f alpha:0.8f]];
            
            [self updateSectionHeaderTitles:section];
        }
        
        return _sectionHeader1;
    } else if (section == 3) {
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
