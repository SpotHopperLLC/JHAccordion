//
//  BaseSlidersSearchTableViewManager.m
//  SpotHopper
//
//  Created by Brennan Stehling on 5/23/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "SHSlidersSearchTableViewManager.h"

#import "JHAccordion.h"

#import "SHSlider.h"

#import "UserModel.h"
#import "DrinkModel.h"
#import "SpotModel.h"
#import "SpotTypeModel.h"
#import "SliderModel.h"
#import "DrinkListModel.h"
#import "DrinkListRequest.h"
#import "SpotListModel.h"
#import "SpotListRequest.h"
#import "SliderTemplateModel.h"
#import "ErrorModel.h"
#import "DrinkTypeModel.h"
#import "DrinkSubTypeModel.h"
#import "BaseAlcoholModel.h"

#import "TellMeMyLocation.h"
#import "Tracker.h"

#import "UIAlertView+Block.h"
#import "SHStyleKit+Additions.h"
#import "UIControl+BlocksKit.h"

#import "Promise.h"

#define kListCellTitleLabel 1
#define kListCellDeleteButton 2
#define kSubTypeCellTitleLabel 1

#define kSliderCellLeftLabel 1
#define kSliderCellRightLabel 2
#define kSliderCellSlider 3
#define kSliderCellDividerView 4

#define kSectionSpotType 0
#define kSectionSpotlists 1
#define kSectionSliders 2

#define kSection_Spots_Spotlists 0
#define kSection_Spots_Sliders 1
#define kSection_Spots_AdvancedSliders 2

#define kSection_Beer_Drinklists 0
#define kSection_Beer_Sliders 1
#define kSection_Beer_AdvancedSliders 2

#define kSection_Cocktail_BaseAlcohol 0
#define kSection_Cocktail_Drinklists 1
#define kSection_Cocktail_Sliders 2
#define kSection_Cocktail_AdvancedSliders 3

#define kSection_Wine_Type 0
#define kSection_Wine_Drinklists 1
#define kSection_Wine_Sliders 2
#define kSection_Wine_AdvancedSliders 3

#define kHeightForDefaultCell 44.0f
#define kHeightForListCell 44.0f
#define kHeightForSubTypeCell 44.0f
#define kHeightForSliderCell 77.0f

#define kOpenedPosition M_PI_2
#define kClosedPosition M_PI_2 * -1

#define kCustomSlidersTitle @"Skip"

#pragma mark - Class Extension
#pragma mark -

@interface SHSlidersSearchTableViewManager () <SHSliderDelegate, JHAccordionDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet JHAccordion *accordion;

@property (weak, nonatomic) IBOutlet id<SHSlidersSearchTableViewManagerDelegate> delegate;

@property (strong, nonatomic) NSString *drinkTypeName;
@property (strong, nonatomic) NSString *drinkSubTypeName;
@property (strong, nonatomic) NSString *baseAlcoholName;

@property (strong, nonatomic) NSArray *drinkTypes;

@property (strong, nonatomic) NSArray *beerSubTypes;
@property (strong, nonatomic) NSArray *cocktailSubTypes;
@property (strong, nonatomic) NSArray *wineSubTypes;

@property (strong, nonatomic) NSArray *baseAlcohols;

@property (strong, nonatomic) NSArray *spotlists;
@property (strong, nonatomic) NSArray *drinklists;
@property (strong, nonatomic) NSArray *sliders;
@property (strong, nonatomic) NSArray *advancedSliders;

@property (strong, nonatomic) NSMutableDictionary *sectionHeaderViews;

@property (strong, nonatomic) UIStoryboard *spotHopperStoryboard;

@property (copy, nonatomic) SpotTypeModel *selectedSpotType;
@property (copy, nonatomic) DrinkTypeModel *selectedDrinkType;

@property (weak, nonatomic) SpotListModel *selectedSpotlist;
@property (weak, nonatomic) DrinkListModel *selectedDrinklist;
@property (weak, nonatomic) DrinkSubTypeModel *selectedDrinkSubType;
@property (weak, nonatomic) BaseAlcoholModel *selectedBaseAlcohol;

@property (assign) SHMode mode;

@end

#pragma mark -

@implementation SHSlidersSearchTableViewManager {
    BOOL _isPreparingForMode;
}

#pragma mark - Public Methods
#pragma mark -

- (void)prepare {
    // prepare accordion
    self.accordion = [[JHAccordion alloc] initWithTableView:self.tableView];
    self.accordion.delegate = self;

    // prefetch data which is cached
    [self fetchMySpotlistsWithCompletionBlock:nil];
    [self fetchMyDrinklistsWithCompletionBlock:nil];
    [self fetchDrinkTypesWithCompletionBlock:nil];
    [self fetchSliderTemplatesWithCompletionBlock:nil];
    [self fetchBaseAlcohols:nil];
}

- (void)prepareForMode:(SHMode)mode {
    _isPreparingForMode = TRUE;
    [self.tableView reloadData];
    
    self.mode = mode;
    
    self.selectedSpotlist = nil;
    self.selectedDrinklist = nil;
    self.selectedDrinkSubType = nil;
    self.selectedBaseAlcohol = nil;
    
    self.baseAlcoholName = nil;

    switch (mode) {
        case SHModeBeer:
            self.drinkTypeName = kDrinkTypeNameBeer;
            break;
        case SHModeCocktail:
            self.drinkTypeName = kDrinkTypeNameCocktail;
            break;
        case SHModeWine:
            self.drinkTypeName = kDrinkTypeNameWine;
            break;
            
        default:
            break;
    }
    
    if (mode == SHModeSpots) {
        [self prepareTableViewForSpotsWithCompletionBlock:^{
            _isPreparingForMode = FALSE;
            [self.tableView reloadData];
        }];
    }
    else {
        [self fetchDrinkTypesWithCompletionBlock:^(NSArray *drinkTypes) {
            self.drinkTypes = drinkTypes;
            
            for (DrinkTypeModel *drinkType in self.drinkTypes) {
                if ([self.drinkTypeName isEqualToString:drinkType.name]) {
                    NSAssert(drinkType.ID, @"ID must be defined");
                    self.selectedDrinkType = drinkType;
                    break;
                }
            }
            
            NSAssert(self.selectedDrinkType, @"Selected drink type must be set");
            
            [self prepareTableViewForDrinkType:self.selectedDrinkType withCompletionBlock:^{
                _isPreparingForMode = FALSE;
                [self.tableView reloadData];
            }];
        }];
    }
}

- (void)prepareTableViewForSpotsWithCompletionBlock:(void (^)())completionBlock {
    BOOL isDataCached = self.spotlists.count;
    
    if (!isDataCached) {
        [self notifyThatManagerIsBusy:@"Loading Moods"];
    }
    
    [self fetchMySpotlistsWithCompletionBlock:^(NSArray *spotlists) {
        self.spotlists = spotlists;
        [self fetchSliderTemplatesWithCompletionBlock:^(NSArray *sliderTemplates) {
            [self filterSlidersTemplatesForSpots:sliderTemplates withCompletionBlock:^(NSArray *sliders, NSArray *advancedSliders) {
                
                self.sliders = sliders;
                self.advancedSliders = advancedSliders;
                
                [self.accordion immediatelyResetOpenedSections:@[[NSNumber numberWithInteger:kSection_Spots_Spotlists]]];
                
                if (!isDataCached) {
                    [self notifyThatManagerIsFree];
                }
                
                if (completionBlock) {
                    completionBlock();
                }
            }];
        }];
    }];
}

- (void)prepareTableViewForDrinkType:(DrinkTypeModel *)drinkType withCompletionBlock:(void (^)())completionBlock {
    [self prepareTableViewForDrinkType:drinkType andDrinkSubType:nil withCompletionBlock:completionBlock];
}

- (void)prepareTableViewForDrinkType:(DrinkTypeModel *)drinkType andDrinkSubType:(DrinkSubTypeModel *)drinkSubType withCompletionBlock:(void (^)())completionBlock {
    BOOL isDataCached = self.drinkTypes.count && self.drinklists.count;
    
    self.drinkTypeName = drinkType.name;
    self.drinkSubTypeName = drinkSubType.name;
    
    if (!isDataCached) {
        [self notifyThatManagerIsBusy:@"Loading Flavor Profiles"];
    }
    
    NSAssert(self.drinkTypes, @"Drink types should already be set");
    
    [self fetchBaseAlcohols:^(NSArray *baseAlcohols) {
        self.baseAlcohols = baseAlcohols;
        [self fetchMyDrinklistsWithCompletionBlock:^(NSArray *drinklists) {
            NSArray *filteredDrinklists = [self filteredDrinklists:drinklists drinkType:self.selectedDrinkType drinkSubType:self.selectedDrinkSubType];
            self.drinklists = filteredDrinklists;
            [self fetchSliderTemplatesWithCompletionBlock:^(NSArray *sliderTemplates) {
                DrinkSubTypeModel *selectedDrinkSubType = [self selectedDrinkSubType:self.selectedDrinkType];
                
                [self filterSlidersTemplates:sliderTemplates forDrinkType:self.selectedDrinkType andDrinkSubType:selectedDrinkSubType withCompletionBlock:^(NSArray *sliders, NSArray *advancedSliders) {
                    
                    self.sliders = sliders;
                    self.advancedSliders = advancedSliders;
                    
                    if (self.mode == SHModeBeer) {
                        [self.accordion immediatelyResetOpenedSections:@[[NSNumber numberWithInteger:kSection_Beer_Drinklists]]];
                    }
                    else if (self.mode == SHModeCocktail) {
                        [self.accordion immediatelyResetOpenedSections:@[[NSNumber numberWithInteger:kSection_Cocktail_Drinklists]]];
                    }
                    else if (self.mode == SHModeWine) {
                        if (self.drinkSubTypeName.length) {
                            [self.accordion immediatelyResetOpenedSections:@[[NSNumber numberWithInteger:kSection_Wine_Drinklists]]];
                        }
                        else {
                            [self.accordion immediatelyResetOpenedSections:@[[NSNumber numberWithInteger:kSection_Wine_Type]]];
                        }
                    }
                    
                    if (completionBlock) {
                        completionBlock();
                    }
                    
                    if (!isDataCached) {
                        [self notifyThatManagerIsFree];
                    }
                }];
            }];
        }];
    }];
}

- (DrinkSubTypeModel *)selectedDrinkSubType:(DrinkTypeModel *)drinkType {
    if (drinkType.subtypes.count && self.drinkSubTypeName.length) {
        for (DrinkSubTypeModel *drinkSubType in drinkType.subtypes) {
            if ([self.drinkSubTypeName isEqualToString:drinkSubType.name]) {
                return drinkSubType;
            }
        }
    }
    
    return nil;
}

- (BOOL)isSelectingSpotlist {
    return !self.drinkTypeName.length;
}

#pragma mark - Location
#pragma mark -

- (CLLocationCoordinate2D)searchCenterCoordinate {
    if ([self.delegate respondsToSelector:@selector(searchCoordinateForSlidersSearchTableViewManager:)]) {
        CLLocationCoordinate2D coordinate = [self.delegate searchCoordinateForSlidersSearchTableViewManager:self];
        return coordinate;
    }
    
    return [TellMeMyLocation lastLocation].coordinate;
}

- (CLLocationDistance)searchRadius {
    if ([self.delegate respondsToSelector:@selector(searchRadiusForSlidersSearchTableViewManager:)]) {
        CLLocationDistance meters = [self.delegate searchRadiusForSlidersSearchTableViewManager:self];
        return meters;
    }
    
    return 1000.0f;
}

#pragma mark - Helpers for Section Header Views
#pragma mark -

- (void)setSectionHeaderView:(UIView *)view section:(NSInteger)section {
    if (!self.sectionHeaderViews) {
        self.sectionHeaderViews = @{}.mutableCopy;
    }
    self.sectionHeaderViews[[NSNumber numberWithInteger:section]] = view;
}

- (UIView *)getSectionHeaderView:(NSInteger)section {
    return (UIView *)self.sectionHeaderViews[[NSNumber numberWithInteger:section]];
}

#pragma mark - User Actions
#pragma mark -

- (IBAction)sliderValueChanged:(id)sender {
}

#pragma mark - UITableViewDataSource
#pragma mark -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (_isPreparingForMode) {
        return 0;
    }
    
    if (self.mode == SHModeSpots) {
        return 3;
    }
    else if (self.mode == SHModeBeer) {
        return 3;
    }
    else if (self.mode == SHModeCocktail) {
        return 4;
    }
    else if (self.mode == SHModeWine) {
        return 4;
    }
    
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_isPreparingForMode) {
        return 0;
    }
    
    if (self.mode == SHModeSpots) {
        switch (section) {
            case kSection_Spots_Spotlists:
                // Moods, Drinklists
                return self.spotlists.count;
            case kSection_Spots_Sliders:
                // Basic Sliders
                return self.sliders.count;
            case kSection_Spots_AdvancedSliders:
                // Advanced Sliders
                return self.advancedSliders.count;
                
            default:
                break;
        }
    }
    else if (self.mode == SHModeBeer) {
        switch (section) {
            case kSection_Beer_Drinklists:
                // Moods, Drinklists
                return self.drinklists.count;
            case kSection_Beer_Sliders:
                // Basic Sliders
                return self.sliders.count;
            case kSection_Beer_AdvancedSliders:
                // Advanced Sliders
                return self.advancedSliders.count;
                
            default:
                break;
        }
    }
    else if (self.mode == SHModeCocktail) {
        switch (section) {
            case kSection_Cocktail_BaseAlcohol:
                return self.baseAlcohols.count;
            case kSection_Cocktail_Drinklists:
                // Moods, Drinklists
                return self.drinklists.count;
            case kSection_Cocktail_Sliders:
                // Basic Sliders
                return self.sliders.count;
            case kSection_Cocktail_AdvancedSliders:
                // Advanced Sliders
                return self.advancedSliders.count;
                
            default:
                break;
        }
    }
    else if (self.mode == SHModeWine) {
        switch (section) {
            case kSection_Wine_Type:
                return self.wineSubTypes.count;
            case kSection_Wine_Drinklists:
                // Moods, Drinklists
                return self.drinklists.count;
            case kSection_Wine_Sliders:
                // Basic Sliders
                return self.sliders.count;
            case kSection_Wine_AdvancedSliders:
                // Advanced Sliders
                return self.advancedSliders.count;
                
            default:
                break;
        }
    }
    
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(slidersSearchTableViewManagerStoryboard:)]) {
        
        UIStoryboard *storyboard = [self.delegate slidersSearchTableViewManagerStoryboard:self];
        
        BOOL useSimpleSectionHeader = FALSE;
        NSString *sectionTitle = nil;

        if (self.mode == SHModeSpots) {
            switch (section) {
                case kSection_Spots_Spotlists:
                    if (self.selectedSpotlist.name.length) {
                        sectionTitle = [NSString stringWithFormat:@"Step 1 - %@", self.selectedSpotlist.name];
                    }
                    else {
                        sectionTitle = @"Step 1 - Select Mood";
                    }
                    break;
                    
                case kSection_Spots_Sliders:
                    sectionTitle = @"Step 2 - Tweak Sliders";
                    break;
                    
                case kSection_Spots_AdvancedSliders:
                    sectionTitle = @"Advanced Sliders";
                    useSimpleSectionHeader = TRUE;
                    break;
                    
                default:
                    break;
            }
        }
        else if (self.mode == SHModeBeer) {
            switch (section) {
                case kSection_Beer_Drinklists:
                    if (self.selectedDrinklist.name.length) {
                        sectionTitle = [NSString stringWithFormat:@"Step 1 - %@", self.selectedDrinklist.name];
                    }
                    else {
                        sectionTitle = @"Step 1 - Select Style";
                    }
                    break;
                    
                case kSection_Beer_Sliders:
                    sectionTitle = @"Step 2 - Tweak Sliders";
                    break;
                    
                case kSection_Beer_AdvancedSliders:
                    sectionTitle = @"Advanced Sliders";
                    useSimpleSectionHeader = TRUE;
                    break;
                    
                default:
                    break;
            }
        }
        else if (self.mode == SHModeCocktail) {
            switch (section) {
                case kSection_Cocktail_BaseAlcohol:
                    if (self.baseAlcoholName.length) {
                        sectionTitle = [NSString stringWithFormat:@"Step 1 - %@", self.baseAlcoholName];
                    }
                    else {
                        sectionTitle = @"Step 1 - Base Alcohol (optional)";
                    }
                    break;
                    
                case kSection_Cocktail_Drinklists:
                    if (self.selectedDrinklist.name.length) {
                        sectionTitle = [NSString stringWithFormat:@"Step 2 - %@", self.selectedDrinklist.name];
                    }
                    else {
                        sectionTitle = @"Step 2 - Select Style";
                    }
                    break;
                    
                case kSection_Cocktail_Sliders:
                    sectionTitle = @"Step 3 - Tweak Sliders";
                    break;
                    
                case kSection_Cocktail_AdvancedSliders:
                    sectionTitle = @"Advanced Sliders";
                    useSimpleSectionHeader = TRUE;
                    break;
                    
                default:
                    break;
            }
        }
        else if (self.mode == SHModeWine) {
            switch (section) {
                case kSection_Wine_Type:
                    if (self.drinkSubTypeName.length) {
                        sectionTitle = [NSString stringWithFormat:@"Step 1 - %@", self.drinkSubTypeName];
                    }
                    else {
                        sectionTitle = @"Step 1 - Select Type";
                    }
                    break;
                    
                case kSection_Wine_Drinklists:
                    if (self.selectedDrinklist.name.length) {
                        sectionTitle = [NSString stringWithFormat:@"Step 2 - %@", self.selectedDrinklist.name];
                    }
                    else {
                        sectionTitle = @"Step 2 - Select Style";
                    }
                    break;
                    
                case kSection_Wine_Sliders:
                    sectionTitle = @"Step 3 - Tweak Sliders";
                    break;
                    
                case kSection_Wine_AdvancedSliders:
                    sectionTitle = @"Advanced Sliders";
                    useSimpleSectionHeader = TRUE;
                    break;
                    
                default:
                    break;
            }
        }
        
        UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:useSimpleSectionHeader ? @"SimpleSectionHeaderScene" : @"FullSectionHeaderScene"];
        UIView *view = vc.view;
        
        UILabel *titleLabel = (UILabel *)[view viewWithTag:1];
        UIImageView *arrowImageView = (UIImageView *)[view viewWithTag:2];
        UIButton *button = (UIButton *)[view viewWithTag:3];

        BOOL isOpened = [self.accordion isSectionOpened:section];
        SHStyleKitColor tintColor = isOpened ? SHStyleKitColorMyTintColor : SHStyleKitColorMyTextColor;
        
        titleLabel.text = sectionTitle;
        titleLabel.textColor = [SHStyleKit color:SHStyleKitColorMyTextColor];
        titleLabel.highlightedTextColor = [SHStyleKit color:SHStyleKitColorMyTintColor];
        titleLabel.highlighted = isOpened;
        
        [SHStyleKit setImageView:arrowImageView withDrawing:SHStyleKitDrawingNavigationArrowRightIcon color:tintColor];
        
        if ([button bk_hasEventHandlersForControlEvents:UIControlEventTouchUpInside]) {
            [button bk_removeEventHandlersForControlEvents:UIControlEventTouchUpInside];
        }
        
        [button bk_addEventHandler:^(id sender) {
            BOOL isOpened = [self.accordion isSectionOpened:section];
            
            if (isOpened) {
                [self.accordion closeSection:section];
            }
            else {
                [self.accordion openSection:section];
            }
        } forControlEvents:UIControlEventTouchUpInside];
        
        arrowImageView.transform = CGAffineTransformMakeRotation(isOpened ? kOpenedPosition : kClosedPosition);
        
        [self setSectionHeaderView:view section:section];
        
        return view;
    }
    
    NSAssert(false, @"Condition should never be met");
    
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.mode == SHModeSpots) {
        if (indexPath.section == kSection_Spots_Spotlists && indexPath.row < self.spotlists.count) {
            SpotListModel *spotlist = [self spotlistAtIndexPath:indexPath];
            return [self configureListCellForIndexPath:indexPath forTableView:tableView withTitle:spotlist.name deleteEnabled:[spotlist.ID isEqual:[NSNull null]]];
        }
        else if (indexPath.section == kSection_Spots_Sliders && indexPath.row < self.sliders.count) {
            return [self configureSliderCellForIndexPath:indexPath forTableView:tableView];
        }
        else if (indexPath.section == kSection_Spots_AdvancedSliders) {
            return [self configureSliderCellForIndexPath:indexPath forTableView:tableView];
        }
        else {
            DebugLog(@"indexPath: %li, %li", (long)indexPath.section, (long)indexPath.row);
        }
    }
    else if (self.mode == SHModeBeer) {
        if (indexPath.section == kSection_Beer_Drinklists && indexPath.row < self.drinklists.count) {
            DrinkListModel *drinklist = [self drinklistAtIndexPath:indexPath];
            return [self configureListCellForIndexPath:indexPath forTableView:tableView withTitle:drinklist.name deleteEnabled:[drinklist.ID isEqual:[NSNull null]]];
        }
        else if (indexPath.section == kSection_Beer_Sliders && indexPath.row < self.sliders.count) {
            return [self configureSliderCellForIndexPath:indexPath forTableView:tableView];
        }
        else if (indexPath.section == kSection_Beer_AdvancedSliders) {
            return [self configureSliderCellForIndexPath:indexPath forTableView:tableView];
        }
        else {
            DebugLog(@"indexPath: %li, %li", (long)indexPath.section, (long)indexPath.row);
        }
    }
    else if (self.mode == SHModeCocktail) {
        if (indexPath.section == kSection_Cocktail_BaseAlcohol && indexPath.row < self.baseAlcohols.count) {
            BaseAlcoholModel *baseAlcohol = [self baseAlcoholAtIndexPath:indexPath];
            return [self configureSubTypeCellForIndexPath:indexPath forTableView:tableView withTitle:baseAlcohol.name];
        }
        else if (indexPath.section == kSection_Cocktail_Drinklists && indexPath.row < self.drinklists.count) {
            DrinkListModel *drinklist = [self drinklistAtIndexPath:indexPath];
            return [self configureListCellForIndexPath:indexPath forTableView:tableView withTitle:drinklist.name deleteEnabled:[drinklist.ID isEqual:[NSNull null]]];
        }
        else if (indexPath.section == kSection_Cocktail_Sliders && indexPath.row < self.sliders.count) {
            return [self configureSliderCellForIndexPath:indexPath forTableView:tableView];
        }
        else if (indexPath.section == kSection_Cocktail_AdvancedSliders) {
            return [self configureSliderCellForIndexPath:indexPath forTableView:tableView];
        }
        else {
            DebugLog(@"indexPath: %li, %li", (long)indexPath.section, (long)indexPath.row);
        }
    }
    else if (self.mode == SHModeWine) {
        if (indexPath.section == kSection_Wine_Type && indexPath.row < self.wineSubTypes.count) {
            DrinkSubTypeModel *drinkSubType = [self drinkSubTypeAtIndexPath:indexPath];
            return [self configureSubTypeCellForIndexPath:indexPath forTableView:tableView withTitle:drinkSubType.name];
        }
        else if (indexPath.section == kSection_Wine_Drinklists && indexPath.row < self.drinklists.count) {
            DrinkListModel *drinklist = [self drinklistAtIndexPath:indexPath];
            return [self configureListCellForIndexPath:indexPath forTableView:tableView withTitle:drinklist.name deleteEnabled:[drinklist.ID isEqual:[NSNull null]]];
        }
        else if (indexPath.section == kSection_Wine_Sliders && indexPath.row < self.sliders.count) {
            return [self configureSliderCellForIndexPath:indexPath forTableView:tableView];
        }
        else if (indexPath.section == kSection_Wine_AdvancedSliders) {
            return [self configureSliderCellForIndexPath:indexPath forTableView:tableView];
        }
        else {
            DebugLog(@"indexPath: %li, %li", (long)indexPath.section, (long)indexPath.row);
        }
    }
    else {
        DebugLog(@"Mode is %@", self.mode == SHModeNone ? @"None" : @"Unknown");
    }
    
    NSAssert(FALSE, @"Condition should never be met");
    
    return nil;
}

#pragma mark - UITableViewDelegate
#pragma mark -

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.mode == SHModeSpots) {
        if (indexPath.section == kSection_Spots_Spotlists) {
            return indexPath;
        }
    }
    else if (self.mode == SHModeBeer) {
        if (indexPath.section == kSection_Beer_Drinklists) {
            return indexPath;
        }
    }
    else if (self.mode == SHModeCocktail) {
        if (indexPath.section == kSection_Cocktail_BaseAlcohol || indexPath.section == kSection_Cocktail_Drinklists) {
            return indexPath;
        }
    }
    else if (self.mode == SHModeWine) {
        if (indexPath.section == kSection_Wine_Type || indexPath.section == kSection_Wine_Drinklists) {
            return indexPath;
        }
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.25 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [tableView deselectRowAtIndexPath:indexPath animated:TRUE];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.25 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        if (self.mode == SHModeSpots) {
            if (indexPath.section == kSection_Spots_Spotlists) {
                [self userDidSelectSpotlistAtIndexPath:indexPath];
            }
        }
        else if (self.mode == SHModeBeer) {
            if (indexPath.section == kSection_Beer_Drinklists) {
                [self userDidSelectDrinklistAtIndexPath:indexPath];
            }
        }
        else if (self.mode == SHModeCocktail) {
            if (indexPath.section == kSection_Cocktail_BaseAlcohol) {
                [self userDidSelectBaseAlcoholAtIndexPath:indexPath];
            }
            else if (indexPath.section == kSection_Cocktail_Drinklists) {
                [self userDidSelectDrinklistAtIndexPath:indexPath];
            }
        }
        else if (self.mode == SHModeWine) {
            if (indexPath.section == kSection_Wine_Type) {
                [self userDidSelectDrinkSubTypeAtIndexPath:indexPath];
            }
            else if (indexPath.section == kSection_Wine_Drinklists) {
                [self userDidSelectDrinklistAtIndexPath:indexPath];
            }
        }
    });
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (![self.accordion isSectionOpened:indexPath.section]) {
        return 0.0f;
    }
    else if (self.mode == SHModeSpots) {
        switch (indexPath.section) {
//            case kSection_Spots_Type:
//                return kHeightForSubTypeCell;
            case kSection_Spots_Spotlists:
                return kHeightForListCell;
            case kSection_Spots_Sliders:
                return kHeightForSliderCell;
            case kSection_Spots_AdvancedSliders:
                return kHeightForSliderCell;
        }
    }
    else if (self.mode == SHModeBeer) {
        switch (indexPath.section) {
            case kSection_Beer_Drinklists:
                return kHeightForListCell;
            case kSection_Beer_Sliders:
                return kHeightForSliderCell;
            case kSection_Beer_AdvancedSliders:
                return kHeightForSliderCell;
        }
    }
    else if (self.mode == SHModeCocktail) {
        switch (indexPath.section) {
                return kHeightForSubTypeCell;
            case kSection_Cocktail_Drinklists:
                return kHeightForListCell;
            case kSection_Cocktail_Sliders:
                return kHeightForSliderCell;
            case kSection_Cocktail_AdvancedSliders:
                return kHeightForSliderCell;
        }
    }
    else if (self.mode == SHModeWine) {
        switch (indexPath.section) {
            case kSection_Wine_Type:
                return kHeightForSubTypeCell;
            case kSection_Wine_Drinklists:
                return kHeightForListCell;
            case kSection_Wine_Sliders:
                return kHeightForSliderCell;
            case kSection_Wine_AdvancedSliders:
                return kHeightForSliderCell;
        }
    }
    
    return kHeightForDefaultCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (self.mode == SHModeWine && section == kSection_Wine_Drinklists && !self.selectedDrinkSubType) {
        return 0.0f;
    }
    else if (!self.selectedSpotlist && !self.selectedDrinklist) {
        if ((self.mode == SHModeSpots && section == kSection_Spots_Sliders) ||
            (self.mode == SHModeBeer && section == kSection_Beer_Sliders) ||
            (self.mode == SHModeCocktail && section == kSection_Cocktail_Sliders) ||
            (self.mode == SHModeWine && section == kSection_Wine_Sliders)) {
            return 0.0f;
        }
        else if ((self.mode == SHModeSpots && section == kSection_Spots_AdvancedSliders) ||
            (self.mode == SHModeBeer && section == kSection_Beer_AdvancedSliders) ||
            (self.mode == SHModeCocktail && section == kSection_Cocktail_AdvancedSliders) ||
            (self.mode == SHModeWine && section == kSection_Wine_AdvancedSliders)) {
            return 0.0f;
        }
    }
    
    return 65.0f;
}

- (void)updateSectionTitle:(NSString *)title section:(NSInteger)section {
    UIView *headerView = [self getSectionHeaderView:section];
    UILabel *label = (UILabel *)[headerView viewWithTag:1];
    label.text = title;
}

#pragma mark - Cell Configuration
#pragma mark -

- (UITableViewCell *)configureListCellForIndexPath:(NSIndexPath *)indexPath forTableView:(UITableView *)tableView withTitle:(NSString *)title deleteEnabled:(BOOL)deleteEnabled {
    static NSString *ListCellIdentifier = @"ListCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ListCellIdentifier forIndexPath:indexPath];
    
    UILabel *titleLabel = [self labelInView:cell withTag:kListCellTitleLabel];
    UIButton *deleteButton = [self buttonInView:cell withTag:kListCellDeleteButton];
    
    deleteButton.hidden = deleteEnabled;
    
    [SHStyleKit setLabel:titleLabel textColor:SHStyleKitColorMyTextColor];
    titleLabel.text = title;
    
    UIView *backgroundView = [[UIView alloc] init];
    backgroundView.backgroundColor = [SHStyleKit color:SHStyleKitColorMyTintColorTransparent];
    cell.selectedBackgroundView = backgroundView;
    
    [SHStyleKit setButton:deleteButton withDrawing:SHStyleKitDrawingDeleteIcon normalColor:SHStyleKitColorMyTextColor highlightedColor:SHStyleKitColorMyTextColor];
    
    if ([deleteButton bk_hasEventHandlersForControlEvents:UIControlEventTouchUpInside]) {
        [deleteButton bk_removeEventHandlersForControlEvents:UIControlEventTouchUpInside];
    }
    
    [deleteButton bk_addEventHandler:^(id sender) {
        NSString *message = nil;
        
        if (self.mode == SHModeSpots) {
            message = @"Are you sure you want to delete this mood?";
        }
        else {
            message = @"Are you sure you want to delete this style?";
        }
        
        [self notifyThatManagerWillAnimate];
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Confirm Delete" message:message delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        [alertView showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                if (self.mode == SHModeSpots && indexPath.section == kSection_Spots_Spotlists) {
                    SpotListModel *spotlist = [self spotlistAtIndexPath:indexPath];
                    [[spotlist purgeSpotList] then:^(NSNumber *success) {
                        DebugLog(@"Deleted: %@", [success boolValue] ? @"YES" : @"NO");
                    } fail:^(ErrorModel *errorModel) {
                        [Tracker logError:errorModel class:[self class] trace:NSStringFromSelector(_cmd)];
                    } always:^{
                        [self prepareTableViewForSpotsWithCompletionBlock:nil];
                    }];
                }
                else if ((self.mode == SHModeBeer && indexPath.section == kSection_Beer_Drinklists) ||
                         (self.mode == SHModeCocktail && indexPath.section == kSection_Cocktail_Drinklists) ||
                         (self.mode == SHModeWine && indexPath.section == kSection_Wine_Drinklists))
                {
                    DrinkListModel *drinklist = [self drinklistAtIndexPath:indexPath];
                    [[drinklist purgeDrinkList] then:^(NSNumber *success) {
                        DebugLog(@"Deleted: %@", [success boolValue] ? @"YES" : @"NO");
                    } fail:^(ErrorModel *errorModel) {
                        [Tracker logError:errorModel class:[self class] trace:NSStringFromSelector(_cmd)];
                    } always:^{
                        [self prepareTableViewForDrinkType:self.selectedDrinkType andDrinkSubType:self.selectedDrinkSubType withCompletionBlock:nil];
                    }];
                }
                else {
                    DebugLog(@"No action taken");
                }
            }
            
            [self notifyThatManagerDidAnimate];
        }];
        
        
    } forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (UITableViewCell *)configureSubTypeCellForIndexPath:(NSIndexPath *)indexPath forTableView:(UITableView *)tableView withTitle:(NSString *)title {
    static NSString *SubTypeCellIdentifier = @"SubTypeCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SubTypeCellIdentifier forIndexPath:indexPath];
    
    UILabel *titleLabel = [self labelInView:cell withTag:kSubTypeCellTitleLabel];
    [SHStyleKit setLabel:titleLabel textColor:SHStyleKitColorMyTextColor];
    titleLabel.text = title;
    
    UIView *backgroundView = [[UIView alloc] init];
    backgroundView.backgroundColor = [SHStyleKit color:SHStyleKitColorMyTintColorTransparent];
    cell.selectedBackgroundView = backgroundView;
    
    return cell;
}

- (UITableViewCell *)configureSliderCellForIndexPath:(NSIndexPath *)indexPath forTableView:(UITableView *)tableView {
    static NSString *SliderCellIdentifier = @"SliderCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SliderCellIdentifier forIndexPath:indexPath];
    
    UILabel *minLabel = [self labelInView:cell withTag:kSliderCellLeftLabel];
    UILabel *maxLabel = [self labelInView:cell withTag:kSliderCellRightLabel];
    
    [SHStyleKit setLabel:minLabel textColor:SHStyleKitColorMyTextColor];
    [SHStyleKit setLabel:maxLabel textColor:SHStyleKitColorMyTextColor];
    
    SliderModel *sliderModel = [self sliderModelAtIndexPath:indexPath];
    SHSlider *slider = [self sliderInView:cell withTag:kSliderCellSlider];
    
    NSAssert(sliderModel, @"slider Model is required");
    NSAssert(slider, @"Slider View is required");
    
    if (sliderModel && slider) {
        minLabel.text = sliderModel.sliderTemplate.minLabel;
        maxLabel.text = sliderModel.sliderTemplate.maxLabel;
        
        slider.vibeFeel = NO;
        slider.sliderModel = sliderModel;
        
        if (!sliderModel.value) {
            slider.selectedValue = (sliderModel.sliderTemplate.defaultValue.floatValue / 10.0f);
            slider.userMoved = NO;
        }
        else {
            slider.selectedValue = (sliderModel.value.floatValue / 10.0f);
            slider.userMoved = YES;
        }
    }
    
    return cell;
}

#pragma mark - Selection
#pragma mark -

- (void)userDidSelectSpotlistAtIndexPath:(NSIndexPath *)indexPath {
    SpotListModel *spotlist = [self spotlistAtIndexPath:indexPath];
    self.selectedSpotlist = spotlist;
    
    [self updateSectionTitle:[NSString stringWithFormat:@"Step 1 - %@", spotlist.name] section:indexPath.section];
    
    void (^completeBlock)(BOOL) = ^void (BOOL didSetAdvancedSlider) {
        [self.accordion closeSection:indexPath.section];
        
        if (self.mode == SHModeSpots) {
            if (didSetAdvancedSlider) {
                [self.accordion openSections:@[[NSNumber numberWithInteger:kSection_Spots_Sliders],
                                                                 [NSNumber numberWithInteger:kSection_Spots_AdvancedSliders]]];
            }
            else {
                [self.accordion openSections:@[[NSNumber numberWithInteger:kSection_Spots_Sliders]]];
            }
        }
        else if (self.mode == SHModeBeer) {
            if (didSetAdvancedSlider) {
                [self.accordion openSections:@[[NSNumber numberWithInteger:kSection_Beer_Sliders],
                                                                 [NSNumber numberWithInteger:kSection_Beer_AdvancedSliders]]];
            }
            else {
                [self.accordion openSections:@[[NSNumber numberWithInteger:kSection_Beer_Sliders]]];
            }
        }
        else if (self.mode == SHModeCocktail) {
            if (didSetAdvancedSlider) {
                [self.accordion openSections:@[[NSNumber numberWithInteger:kSection_Cocktail_Sliders],
                                                                 [NSNumber numberWithInteger:kSection_Cocktail_AdvancedSliders]]];
            }
            else {
                [self.accordion openSections:@[[NSNumber numberWithInteger:kSection_Cocktail_Sliders]]];
            }
        }
        else if (self.mode == SHModeWine) {
            if (didSetAdvancedSlider) {
                [self.accordion openSections:@[[NSNumber numberWithInteger:kSection_Wine_Sliders],
                                                                 [NSNumber numberWithInteger:kSection_Wine_AdvancedSliders]]];
            }
            else {
                [self.accordion openSections:@[[NSNumber numberWithInteger:kSection_Wine_Sliders]]];
            }
        }
        
        [self notifyThatManagerIsFree];
    };
    
    [self notifyThatManagerIsBusy:@"Pre-setting mood sliders"];
    if ([[NSNull null] isEqual:spotlist.ID]) {
        [self updateSliders:nil withCompletionBlock:completeBlock];
    }
    else {
        [[spotlist fetchSpotList] then:^(SpotListModel *spotlist) {
            [self updateSliders:spotlist.sliders withCompletionBlock:completeBlock];
        } fail:^(ErrorModel *errorModel) {
            [Tracker logError:errorModel class:[self class] trace:NSStringFromSelector(_cmd)];
        } always:nil];
    }
}

- (void)userDidSelectBaseAlcoholAtIndexPath:(NSIndexPath *)indexPath {
    BaseAlcoholModel *baseAlcohol = [self baseAlcoholAtIndexPath:indexPath];
    
    [self updateSectionTitle:[NSString stringWithFormat:@"Step 1 - %@", baseAlcohol.name] section:indexPath.section];
    [self.accordion closeSection:indexPath.section];
    
    if ([[NSNull null] isEqual:baseAlcohol.ID]) {
        self.baseAlcoholName = nil;
        self.selectedBaseAlcohol = nil;
    }
    else {
        self.baseAlcoholName = baseAlcohol.name;
        self.selectedBaseAlcohol = baseAlcohol;
    }
}

- (void)userDidSelectDrinkSubTypeAtIndexPath:(NSIndexPath *)indexPath {
    DrinkSubTypeModel *drinkSubType = [self drinkSubTypeAtIndexPath:indexPath];
    
    [self updateSectionTitle:[NSString stringWithFormat:@"Step 1 - %@", drinkSubType.name] section:indexPath.section];
    [self.accordion closeSection:indexPath.section];
    
    if ([[NSNull null] isEqual:drinkSubType.ID]) {
        self.drinkSubTypeName = nil;
        self.selectedDrinkSubType = nil;
    }
    else {
        self.drinkSubTypeName = drinkSubType.name;
        self.selectedDrinkSubType = drinkSubType;
    }
    
    [self notifyThatManagerIsBusy];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        NSAssert(self.selectedDrinkType.ID, @"ID must be defined");
        NSAssert(!self.selectedDrinkSubType || self.selectedDrinkSubType.ID, @"ID must be defined is the model instance is defined");
        
        [self prepareTableViewForDrinkType:self.selectedDrinkType andDrinkSubType:self.selectedDrinkSubType withCompletionBlock:nil];
        [self notifyThatManagerIsFree];
    });
}

- (void)userDidSelectDrinklistAtIndexPath:(NSIndexPath *)indexPath {
    DrinkListModel *drinklist = [self drinklistAtIndexPath:indexPath];
    self.selectedDrinklist = drinklist;
    if (self.mode == SHModeBeer) {
        [self updateSectionTitle:[NSString stringWithFormat:@"Step 1 - %@", drinklist.name] section:indexPath.section];
    }
    else {
        [self updateSectionTitle:[NSString stringWithFormat:@"Step 2 - %@", drinklist.name] section:indexPath.section];
    }
    
    void (^completeBlock)(BOOL) = ^void (BOOL didSetAdvancedSlider) {
        [self.accordion closeSection:indexPath.section];
        
        if (self.mode == SHModeSpots) {
            if (didSetAdvancedSlider) {
                [self.accordion immediatelyResetOpenedSections:@[[NSNumber numberWithInteger:kSection_Spots_Sliders],
                                                                 [NSNumber numberWithInteger:kSection_Spots_AdvancedSliders]]];
            }
            else {
                [self.accordion immediatelyResetOpenedSections:@[[NSNumber numberWithInteger:kSection_Spots_Sliders]]];
            }
        }
        else if (self.mode == SHModeBeer) {
            if (didSetAdvancedSlider) {
                [self.accordion immediatelyResetOpenedSections:@[[NSNumber numberWithInteger:kSection_Beer_Sliders],
                                                                 [NSNumber numberWithInteger:kSection_Beer_AdvancedSliders]]];
            }
            else {
                [self.accordion immediatelyResetOpenedSections:@[[NSNumber numberWithInteger:kSection_Beer_Sliders]]];
            }
        }
        else if (self.mode == SHModeCocktail) {
            if (didSetAdvancedSlider) {
                [self.accordion immediatelyResetOpenedSections:@[[NSNumber numberWithInteger:kSection_Cocktail_Sliders],
                                                                 [NSNumber numberWithInteger:kSection_Cocktail_AdvancedSliders]]];
            }
            else {
                [self.accordion immediatelyResetOpenedSections:@[[NSNumber numberWithInteger:kSection_Cocktail_Sliders]]];
            }
        }
        else if (self.mode == SHModeWine) {
            if (didSetAdvancedSlider) {
                [self.accordion immediatelyResetOpenedSections:@[[NSNumber numberWithInteger:kSection_Wine_Sliders],
                                                                 [NSNumber numberWithInteger:kSection_Wine_AdvancedSliders]]];
            }
            else {
                [self.accordion immediatelyResetOpenedSections:@[[NSNumber numberWithInteger:kSection_Wine_Sliders]]];
            }
        }
        
        [self notifyThatManagerIsFree];
    };
    
    [self notifyThatManagerIsBusy:@"Pre-setting flavor sliders"];
    if ([[NSNull null] isEqual:drinklist.ID]) {
        [self updateSliders:nil withCompletionBlock:completeBlock];
    }
    else {
        [[drinklist fetchDrinkList] then:^(DrinkListModel *drinklist) {
            [self updateSliders:drinklist.sliders withCompletionBlock:completeBlock];
        } fail:^(ErrorModel *errorModel) {
            [Tracker logError:errorModel class:[self class] trace:NSStringFromSelector(_cmd)];
        } always:nil];
    }
}

#pragma mark - Helper Methods
#pragma mark -

- (SHSlider *)sliderInView:(UIView *)view withTag:(NSUInteger)tag {
    UIView *taggedView = [view viewWithTag:tag];
    if ([taggedView isKindOfClass:[SHSlider class]]) {
        return (SHSlider *)taggedView;
    }
    return nil;
}

- (UILabel *)labelInView:(UIView *)view withTag:(NSUInteger)tag {
    UIView *taggedView = [view viewWithTag:tag];
    if ([taggedView isKindOfClass:[UILabel class]]) {
        return (UILabel *)taggedView;
    }
    return nil;
}

- (UIButton *)buttonInView:(UIView *)view withTag:(NSUInteger)tag {
    UIView *taggedView = [view viewWithTag:tag];
    if ([taggedView isKindOfClass:[UIButton class]]) {
        return (UIButton *)taggedView;
    }
    return nil;
}

- (BOOL)isSlidersSection:(NSInteger)section {
    if (self.mode == SHModeSpots) {
        return section == kSection_Spots_Sliders;
    }
    else if (self.mode == SHModeBeer) {
        return section == kSection_Beer_Sliders;
    }
    else if (self.mode == SHModeCocktail) {
        return section == kSection_Cocktail_Sliders;
    }
    else if (self.mode == SHModeWine) {
        return section == kSection_Wine_Sliders;
    }
    
    return FALSE;
}

- (BOOL)isAdvancedSlidersSection:(NSInteger)section {
    if (self.mode == SHModeSpots) {
        return section == kSection_Spots_AdvancedSliders;
    }
    else if (self.mode == SHModeBeer) {
        return section == kSection_Beer_AdvancedSliders;
    }
    else if (self.mode == SHModeCocktail) {
        return section == kSection_Cocktail_AdvancedSliders;
    }
    else if (self.mode == SHModeWine) {
        return section == kSection_Wine_AdvancedSliders;
    }
    
    return FALSE;
}

- (NSIndexPath *)indexPathForView:(UIView *)view inTableView:(UITableView *)tableView {
    UIView *superview = view;
    while (superview && ![superview isKindOfClass:[UITableViewCell class]]) {
        superview = superview.superview;
    }
    
    if (superview && [superview isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [tableView indexPathForCell:(UITableViewCell *)superview];
        return indexPath;
    }
    
    return nil;
}

- (NSArray *)filteredDrinklists:(NSArray *)drinklists drinkType:(DrinkTypeModel *)drinkType drinkSubType:(DrinkSubTypeModel *)drinkSubType {
    if (!drinkType) {
        return drinklists;
    }
    
    NSMutableArray *filteredLists = @[].mutableCopy;
    
    for (DrinkListModel *drinklist in drinklists) {
        
        NSAssert(drinklist.drinkType, @"Drinklist must have a drink type");
        
        if ([[NSNull null] isEqual:drinklist.ID]) {
            // Custom list option
            [filteredLists addObject:drinklist];
        }
        else if ([drinklist.drinkType.name isEqualToString:drinkType.name]) {
            if (drinkSubType) {
                if ([drinklist.drinkSubType.name isEqualToString:drinkSubType.name]) {
                    NSAssert([drinklist.drinkSubType isEqual:drinkSubType], @"Model instances must be equal");
                    NSAssert([drinklist.drinkSubType.ID isEqual:drinkSubType.ID], @"ID values must be equal");
                    [filteredLists addObject:drinklist];
                }
            }
            else {
                [filteredLists addObject:drinklist];
            }
        }
    }
    
    return filteredLists;
}

- (void)updateSliders:(NSArray *)sliders withCompletionBlock:(void (^)(BOOL didSetAdvancedSlider))completionBlock {
    NSMutableArray *allSliders = @[].mutableCopy;
    [allSliders addObjectsFromArray:self.sliders];
    [allSliders addObjectsFromArray:self.advancedSliders];
    
    if (!sliders.count) {
        // Custom Spotlist with no predefined slider values
        for (SliderModel *searchSlider in allSliders) {
            searchSlider.value = nil;
        }
        if (completionBlock) {
            completionBlock(FALSE);
        }
        return;
    }
    
#ifndef NDEBUG
    for (SliderModel *slider __unused in sliders) {
        NSAssert(slider.ID, @"Slider ID must be defined");
        NSAssert(slider.sliderTemplate, @"Slider Template must be defined");
    }
#endif
    
    BOOL didSetAdvancedSlider = FALSE;
    
    for (SliderModel *searchSlider in allSliders) {
        NSAssert(searchSlider.sliderTemplate, @"Slider Template must be defined");
        
        searchSlider.value = nil;
        for (SliderModel *spotlistSlider in sliders) {
            NSAssert(spotlistSlider.sliderTemplate, @"Slider Templates must be defined");
            if ([searchSlider.sliderTemplate isEqual:spotlistSlider.sliderTemplate]) {
                searchSlider.value = spotlistSlider.value;
                if (searchSlider.sliderTemplate.isAdvanced) {
                    didSetAdvancedSlider = TRUE;
                }
            }
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(slidersSearchTableViewManagerDidChangeSlider:)]) {
        [self.delegate slidersSearchTableViewManagerDidChangeSlider:self];
    }
    
    if (completionBlock) {
        completionBlock(didSetAdvancedSlider);
    }
}

- (BOOL)hasFourInchDisplay {
    return ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone && [UIScreen mainScreen].bounds.size.height == 568.0);
}

#pragma mark - Data Lookups
#pragma mark -

- (SpotListModel *)spotlistAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.spotlists.count) {
        SpotListModel *spotlist = self.spotlists[indexPath.row];
        return spotlist;
    }
    
    return nil;
}

- (DrinkSubTypeModel *)drinkSubTypeAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *subtypes = nil;
    
    if (self.mode == SHModeWine && indexPath.section == kSection_Wine_Type) {
        subtypes = self.wineSubTypes;
    }
    
    if (indexPath.row < subtypes.count) {
        DrinkSubTypeModel *subType = subtypes[indexPath.row];
        return subType;
    }
    
    return nil;
}

- (BaseAlcoholModel *)baseAlcoholAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.baseAlcohols.count) {
        BaseAlcoholModel *baseAlcohol = self.baseAlcohols[indexPath.row];
        return baseAlcohol;
    }
    
    return nil;
}

- (DrinkListModel *)drinklistAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.drinklists.count) {
        DrinkListModel *drinklist = self.drinklists[indexPath.row];
        return drinklist;
    }
    
    return nil;
}

- (SliderModel *)sliderModelAtIndexPath:(NSIndexPath *)indexPath {
    if ([self isSlidersSection:indexPath.section] && indexPath.row < self.sliders.count) {
        return self.sliders[indexPath.row];
    }
    else if ([self isAdvancedSlidersSection:indexPath.section] && indexPath.row < self.advancedSliders.count) {
        return self.advancedSliders[indexPath.row];
    }
    
    return nil;
}

#pragma mark - Busy Status
#pragma mark -

- (void)notifyThatManagerWillAnimate {
    if ([self.delegate respondsToSelector:@selector(slidersSearchTableViewManagerWillAnimate:)]) {
        [self.delegate slidersSearchTableViewManagerWillAnimate:self];
    }
}

- (void)notifyThatManagerDidAnimate {
    if ([self.delegate respondsToSelector:@selector(slidersSearchTableViewManagerDidAnimate:)]) {
        [self.delegate slidersSearchTableViewManagerDidAnimate:self];
    }
}

- (void)notifyThatManagerIsBusy {
    [self notifyThatManagerIsBusy:nil];
}

- (void)notifyThatManagerIsBusy:(NSString *)text {
    if ([self.delegate respondsToSelector:@selector(slidersSearchTableViewManagerIsBusy:text:)]) {
        [self.delegate slidersSearchTableViewManagerIsBusy:self text:text];
    }
}

- (void)notifyThatManagerIsFree {
    if ([self.delegate respondsToSelector:@selector(slidersSearchTableViewManagerIsFree:)]) {
        [self.delegate slidersSearchTableViewManagerIsFree:self];
    }
}

#pragma mark - API Methods
#pragma mark -

- (void)fetchMySpotlistsWithCompletionBlock:(void (^)(NSArray * spotlists))completionBlock {
    if ([UserModel isLoggedIn]) {
        [[SpotListModel fetchMySpotLists] then:^(NSArray *spotlists) {
            // add Custom Mood at the top
            SpotListModel *skipSpotlist = [[SpotListModel alloc] init];
            skipSpotlist.ID = [NSNull null];
            skipSpotlist.name = kCustomSlidersTitle;
            
            NSMutableArray *allSpotlists = @[].mutableCopy;
            [allSpotlists addObjectsFromArray:spotlists];
            [allSpotlists addObject:skipSpotlist];
            
            if (completionBlock) {
                completionBlock(allSpotlists);
            }
        } fail:^(ErrorModel *errorModel) {
            [Tracker logError:errorModel class:[self class] trace:NSStringFromSelector(_cmd)];
            if (completionBlock) {
                completionBlock(nil);
            }
        } always:nil];
    }
}

- (void)fetchMyDrinklistsWithCompletionBlock:(void (^)(NSArray * drinklists))completionBlock {
    if ([UserModel isLoggedIn]) {
        [[DrinkListModel fetchMyDrinkLists] then:^(NSArray *drinklists) {
            
            // add Custom Mood at the top
            DrinkListModel *skipDrinklist = [[DrinkListModel alloc] init];
            skipDrinklist.ID = [NSNull null];
            skipDrinklist.name = kCustomSlidersTitle;
            if (drinklists.count) {
                skipDrinklist.drinkType = ((DrinkListModel *)drinklists[0]).drinkType;
            }
            
            NSMutableArray *allDrinklists = @[].mutableCopy;
            [allDrinklists addObjectsFromArray:drinklists];
            [allDrinklists addObject:skipDrinklist];
            
#ifndef NDEBUG
            for (DrinkListModel *drinklist __unused in allDrinklists) {
                NSAssert(drinklist.drinkType.name.length, @"Drink Type must be defined");
            }
#endif
            
            if (completionBlock) {
                completionBlock(allDrinklists);
            }
        } fail:^(ErrorModel *errorModel) {
            [Tracker logError:errorModel class:[self class] trace:NSStringFromSelector(_cmd)];
            if (completionBlock) {
                completionBlock(nil);
            }
        } always:nil];
    }
    else if (completionBlock) {
        completionBlock(nil);
    }
}

- (void)fetchDrinkTypesWithCompletionBlock:(void (^)(NSArray * drinkTypes))completionBlock {
    [[DrinkModel fetchDrinkTypes] then:^(NSArray *drinkTypes) {
        
        for (DrinkTypeModel *drinkType in drinkTypes) {
            NSAssert(drinkType.ID, @"ID must be defined");
            
            if ([kDrinkTypeNameBeer isEqualToString:drinkType.name]) {
                self.beerSubTypes = drinkType.subtypes;
            }
            else if ([kDrinkTypeNameCocktail isEqualToString:drinkType.name]) {
                NSMutableArray *allDrinkSubTypes = @[].mutableCopy;
                
                // add Any at the top
                DrinkSubTypeModel *anySubType = [[DrinkSubTypeModel alloc] init];
                anySubType.ID = [NSNull null];
                anySubType.name = @"Any";
                
                [allDrinkSubTypes addObject:anySubType];
                [allDrinkSubTypes addObjectsFromArray:drinkType.subtypes];
                
                self.cocktailSubTypes = allDrinkSubTypes;
            }
            else if ([kDrinkTypeNameWine isEqualToString:drinkType.name]) {
                self.wineSubTypes = drinkType.subtypes;
            }
        }
        
        if (completionBlock) {
            completionBlock(drinkTypes);
        }
    } fail:^(ErrorModel *errorModel) {
        [Tracker logError:errorModel class:[self class] trace:NSStringFromSelector(_cmd)];
        if (completionBlock) {
            completionBlock(nil);
        }
    } always:nil];
}

- (void)fetchBaseAlcohols:(void (^)(NSArray * baseAlcohols))completionBlock {
    [[BaseAlcoholModel fetchBaseAlcohols] then:^(NSArray *baseAlcohols) {
        if (completionBlock) {
            completionBlock(baseAlcohols);
        }
    } fail:^(ErrorModel *errorModel) {
        [Tracker logError:errorModel class:[self class] trace:NSStringFromSelector(_cmd)];
        if (completionBlock) {
            completionBlock(nil);
        }
    } always:nil];
}

- (NSArray *)extractWineSubTypesFromDrinkTypes:(NSArray *)drinkTypes {
    for (NSDictionary *drinkType in drinkTypes) {
        if ([drinkType[@"name"] isEqualToString:kDrinkTypeNameWine]) {
            NSArray *wineSubTypes = [drinkType objectForKey:@"drink_subtypes"];
            return wineSubTypes;
        }
    }
    
    return nil;
}

- (void)fetchSliderTemplatesWithCompletionBlock:(void (^)(NSArray * sliderTemplates))completionBlock {
    [SliderTemplateModel fetchSliderTemplates:^(NSArray *sliderTemplates) {
        if (completionBlock) {
            completionBlock(sliderTemplates);
        }
    } failure:^(ErrorModel *errorModel) {
        [Tracker logError:errorModel class:[self class] trace:NSStringFromSelector(_cmd)];
        if (completionBlock) {
            completionBlock(nil);
        }
    }];
}

- (void)filterSlidersTemplatesForSpots:(NSArray *)sliderTemplates withCompletionBlock:(void (^)(NSArray *sliders, NSArray *advancedSliders))completionBlock {
    NSMutableArray *sliders = [@[] mutableCopy];
    NSMutableArray *advancedSliders = [@[] mutableCopy];
    NSMutableArray *slidersFiltered = [@[] mutableCopy];

    for (SliderTemplateModel *sliderTemplate in sliderTemplates) {
        if (sliderTemplate.spotTypes.count) {
            [slidersFiltered addObject:sliderTemplate];
        }
    }
    
    // Creating sliders
    for (SliderTemplateModel *sliderTemplate in slidersFiltered) {
        SliderModel *slider = [[SliderModel alloc] init];
        slider.sliderTemplate = sliderTemplate;
        
        NSAssert([sliderTemplate isEqual:slider.sliderTemplate], @"Slider template which was just set better match");
        
        if (!slider.sliderTemplate.isAdvanced) {
            [sliders addObject:slider];
        }
        else {
            [advancedSliders addObject:slider];
        }
    }
    
    if (completionBlock) {
        completionBlock(sliders, advancedSliders);
    }
}

- (void)filterSlidersTemplates:(NSArray *)sliderTemplates
                  forDrinkType:(DrinkTypeModel *)selectedDrinkType
               andDrinkSubType:(DrinkSubTypeModel *)selectedDrinkSubType
           withCompletionBlock:(void (^)(NSArray *sliders, NSArray *advancedSliders))completionBlock {
    NSMutableArray *sliders = [@[] mutableCopy];
    NSMutableArray *advancedSliders = [@[] mutableCopy];
    
    NSMutableArray *slidersFiltered = [@[] mutableCopy];
    if (selectedDrinkType == nil) {
        if (completionBlock) {
            completionBlock(nil, nil);
        }
    }
    else {
        NSNumber *selectedDrinkTypeId = selectedDrinkType.ID;
        NSNumber *selectedSubTypeId = selectedDrinkSubType.ID;
        
        // Filters by drink id
        for (SliderTemplateModel *sliderTemplate in sliderTemplates) {
            NSArray *drinkTypeIds = [sliderTemplate.drinkTypes valueForKey:@"ID"];
            NSArray *drinkSubTypeIds = [sliderTemplate.drinkSubtypes valueForKey:@"ID"];

            // only wine sub type will filter otherwise just filter by drink type
//            if (([kDrinkTypeNameWine isEqualToString:selectedDrinkSubType.name] && [drinkSubTypeIds containsObject:selectedSubTypeId]) ||
//                [drinkTypeIds containsObject:selectedDrinkTypeId]) {
//                [slidersFiltered addObject:sliderTemplate];
//            }
            
            if ([drinkTypeIds containsObject:selectedDrinkTypeId]) {
                if (selectedDrinkSubType) {
                    if ([drinkSubTypeIds containsObject:selectedSubTypeId]) {
                        [slidersFiltered addObject:sliderTemplate];
                    }
                }
                else {
                    [slidersFiltered addObject:sliderTemplate];
                }
            }
            
//            // Only filter by drink type if drink subtype is nil
//            if (!selectedDrinkSubType && [drinkTypeIds containsObject:selectedDrinkTypeId]) {
//                [slidersFiltered addObject:sliderTemplate];
//            }
//            // Else filter by drink type and drink subtype
//            else if (selectedDrinkSubType && [drinkTypeIds containsObject:selectedDrinkTypeId] && [drinkSubTypeIds containsObject:selectedSubTypeId]) {
//                [slidersFiltered addObject:sliderTemplate];
//            }
        }
    }
    
    // Creating sliders
    for (SliderTemplateModel *sliderTemplate in slidersFiltered) {
        SliderModel *slider = [[SliderModel alloc] init];
        [slider setSliderTemplate:sliderTemplate];
        if (slider.sliderTemplate.required) {
            [sliders addObject:slider];
        }
        else {
            [advancedSliders addObject:slider];
        }
    }
    
    if (completionBlock) {
        completionBlock(sliders, advancedSliders);
    }
}

- (void)fetchSpotListResultsWithCompletionBlock:(void (^)(SpotListModel *spotListModel, SpotListRequest *request, ErrorModel *errorModel))completionBlock {
    NSMutableArray *allTheSliders = @[].mutableCopy;
    [allTheSliders addObjectsFromArray:self.sliders];
    [allTheSliders addObjectsFromArray:self.advancedSliders];
    
    NSString *sliderType = [self isSelectingSpotlist] ? @"Spotlist" : @"Drinklist";
    
    for (SliderModel *sliderModel in self.sliders) {
        if (sliderModel.value) {
            [Tracker track:@"Slider Value Set" properties:@{@"Type" : sliderType, @"Name" : sliderModel.sliderTemplate.name, @"Value" : sliderModel.value, @"Advanced" : @NO}];
        }
    }
    for (SliderModel *sliderModel in self.advancedSliders) {
        if (sliderModel.value) {
            [Tracker track:@"Slider Value Set" properties:@{@"Type" : sliderType, @"Name" : sliderModel.sliderTemplate.name, @"Value" : sliderModel.value, @"Advanced" : @YES}];
        }
    }
    
    CLLocationCoordinate2D coordinate = [self searchCenterCoordinate];
    CGFloat radius = [self searchRadius];
    
    NSNumber *latitude = nil, *longitude = nil;
    if (CLLocationCoordinate2DIsValid(coordinate)) {
        latitude = [NSNumber numberWithFloat:coordinate.latitude];
        longitude = [NSNumber numberWithFloat:coordinate.longitude];
    }
    
    [Tracker track:@"Creating Spotlist"];
    
    SpotListRequest *request = [[SpotListRequest alloc] init];
    if (self.selectedSpotlist && ![[NSNull null] isEqual:self.selectedSpotlist.ID]) {
        request.spotListId = self.selectedSpotlist.ID;
    }
    if (self.selectedSpotType && ![[NSNull null] isEqual:self.selectedSpotType.ID]) {
        request.spotTypeId = self.selectedSpotType.ID;
    }
    
    if ([kCustomSlidersTitle isEqualToString:self.selectedSpotlist.name]) {
        request.name = kSpotListModelDefaultName;
    }
    else {
        request.name = self.selectedSpotlist.name.length ? self.selectedSpotlist.name : kSpotListModelDefaultName;
    }
    
    request.coordinate = coordinate;
    request.radius = radius;
    request.sliders = allTheSliders;
    
    [[SpotListModel fetchSpotListWithRequest:request] then:^(SpotListModel *spotListModel) {
        // TODO: add tracking for spotId and spotTypeId when those values are added to this search filter
        [Tracker track:@"Created Spotlist" properties:@{@"Success" : @TRUE, @"Created With Sliders" : @TRUE}];
        
        if (completionBlock) {
            completionBlock(spotListModel, request, nil);
        }
    } fail:^(ErrorModel *errorModel) {
        if (completionBlock) {
            completionBlock(nil, nil, errorModel);
        }
    } always:^{
    }];
    
    if (![[NSNull null] isEqual:self.selectedSpotlist.ID]) {
        // save the changes to the spotlist if it is an existing spotlist
    }
    
}

- (void)fetchDrinkListResultsWithCompletionBlock:(void (^)(DrinkListModel *drinkListModel, DrinkListRequest *request, ErrorModel *errorModel))completionBlock {
    NSMutableArray *allTheSliders = @[].mutableCopy;
    [allTheSliders addObjectsFromArray:self.sliders];
    [allTheSliders addObjectsFromArray:self.advancedSliders];
    
    NSString *sliderType = [self isSelectingSpotlist] ? @"Spotlist" : @"Drinklist";
    
    for (SliderModel *sliderModel in self.sliders) {
        if (sliderModel.value) {
            [Tracker track:@"Slider Value Set" properties:@{@"Type" : sliderType, @"Name" : sliderModel.sliderTemplate.name, @"Value" : sliderModel.value, @"Advanced" : @NO}];
        }
    }
    for (SliderModel *sliderModel in self.advancedSliders) {
        if (sliderModel.value) {
            [Tracker track:@"Slider Value Set" properties:@{@"Type" : sliderType, @"Name" : sliderModel.sliderTemplate.name, @"Value" : sliderModel.value, @"Advanced" : @YES}];
        }
    }
    
    CLLocationCoordinate2D coordinate = [self searchCenterCoordinate];
    CGFloat radiusInMiles = [self searchRadius];
    
    NSNumber *latitude = nil, *longitude = nil;
    if (CLLocationCoordinate2DIsValid(coordinate)) {
        latitude = [NSNumber numberWithFloat:coordinate.latitude];
        longitude = [NSNumber numberWithFloat:coordinate.longitude];
    }
    
    [Tracker track:@"Creating Drinklist"];
    
    NSNumber *drinkTypeID = self.selectedDrinkType.ID;
    NSNumber *drinkSubTypeID = self.selectedDrinkSubType.ID;
    NSNumber *baseAlcoholID = self.selectedBaseAlcohol.ID;
    
    DrinkListRequest *request = [[DrinkListRequest alloc] init];
    if (self.selectedDrinklist && ![[NSNull null] isEqual:self.selectedDrinklist.ID]) {
        request.drinkListId = self.selectedDrinklist.ID;
    }
    
    if ([kCustomSlidersTitle isEqualToString:self.selectedDrinklist.name]) {
        request.name = kDrinkListModelDefaultName;
    }
    else {
        request.name = self.selectedDrinklist.name.length ? self.selectedDrinklist.name : kDrinkListModelDefaultName;
    }
    
    request.coordinate = coordinate;
    request.radius = radiusInMiles;
    request.sliders = allTheSliders;
    request.drinkTypeId = drinkTypeID;
    request.drinkSubTypeId = drinkSubTypeID;
    request.baseAlcoholId = baseAlcoholID;
    
    if ([self.delegate respondsToSelector:@selector(slidersSearchTableViewManagerScopedSpot:)]) {
        SpotModel *spot = [self.delegate slidersSearchTableViewManagerScopedSpot:self];
        request.spotId = spot.ID;
    }

    [DrinkListModel fetchDrinkListWithRequest:request success:^(DrinkListModel *drinkListModel) {
        [Tracker track:@"Created Drinklist" properties:@{@"Success" : @TRUE, @"Drink Type ID" : drinkTypeID ?: @0, @"Drink Sub Type ID" : drinkSubTypeID ?: @0, @"Created With Sliders" : @TRUE}];
        
        // now fetch the spots for the first drink so it is ready then request the rest cache all of the results for fast access
        
        if (drinkListModel.drinks.count) {
            NSMutableArray *promises = @[].mutableCopy;
            for (DrinkModel *drink in drinkListModel.drinks) {
                Promise *promise = [drink fetchSpotsForDrinkListRequest:request];
                [promises addObject:promise];
            }
            
            [When when:promises then:^{
                if (completionBlock) {
                    completionBlock(drinkListModel, request, nil);
                }
            } fail:nil always:nil];
        }
        else {
            if (completionBlock) {
                completionBlock(drinkListModel, request, nil);
            }
        }
    } failure:^(ErrorModel *errorModel) {
        [Tracker track:@"Created Drinklist" properties:@{@"Success" : @FALSE}];
        [Tracker logError:errorModel class:[self class] trace:NSStringFromSelector(_cmd)];
        if (completionBlock) {
            completionBlock(nil, nil, errorModel);
        }
    }];
}

#pragma mark - SHSliderDelegate
#pragma mark -

// as the user moves the slider this callback will fire each time the value is changed
- (void)slider:(SHSlider *)slider valueDidChange:(CGFloat)value {
}

// one the user completes the gesture this callback is fired
- (void)slider:(SHSlider *)slider valueDidFinishChanging:(CGFloat)value {
    NSAssert(self.delegate, @"Delegate is required");
    
    if ([self.delegate respondsToSelector:@selector(slidersSearchTableViewManagerDidChangeSlider:)]) {
        [self.delegate slidersSearchTableViewManagerDidChangeSlider:self];
    }
}

#pragma mark - JHAccordionDelegate
#pragma mark -

- (BOOL)accordionShouldAllowOnlyOneOpenSection:(JHAccordion*)accordion {
    return NO;
}

- (void)accordion:(JHAccordion*)accordion contentSizeChanged:(CGSize)contentSize {
    [accordion slideUpLastOpenedSection];
}

- (void)accordion:(JHAccordion*)accordion openingSection:(NSInteger)section {
    UIView *view = [self getSectionHeaderView:section];
    UILabel *titleLabel = (UILabel *)[view viewWithTag:1];
    UIImageView *arrowImageView = (UIImageView *)[view viewWithTag:2];
    
    titleLabel.highlighted =  TRUE;
    [SHStyleKit setImageView:arrowImageView withDrawing:SHStyleKitDrawingNavigationArrowRightIcon color:SHStyleKitColorMyTintColor];
    
    [UIView animateWithDuration:0.35 animations:^{
        arrowImageView.transform = CGAffineTransformMakeRotation(kOpenedPosition);
    }];
}

- (void)accordion:(JHAccordion*)accordion closingSection:(NSInteger)section {
    UIView *view = [self getSectionHeaderView:section];
    UILabel *titleLabel = (UILabel *)[view viewWithTag:1];
    UIImageView *arrowImageView = (UIImageView *)[view viewWithTag:2];
    
    titleLabel.highlighted = FALSE;
    [SHStyleKit setImageView:arrowImageView withDrawing:SHStyleKitDrawingNavigationArrowRightIcon color:SHStyleKitColorMyTextColor];

    // scroll to the top when a list is selected
    if ((self.mode == SHModeSpots && section == kSection_Spots_Spotlists) ||
        (self.mode == SHModeBeer && section == kSection_Beer_Drinklists) ||
        (self.mode == SHModeCocktail && section == kSection_Cocktail_Drinklists) ||
        (self.mode == SHModeWine && section == kSection_Wine_Drinklists)) {
        CGPoint offset = CGPointMake(0.0f, [self hasFourInchDisplay] ? -64.0f : 0.0f);
        [self.tableView setContentOffset:offset animated:TRUE];
    }
    
    [UIView animateWithDuration:0.35 animations:^{
        arrowImageView.transform = CGAffineTransformMakeRotation(kClosedPosition);
    }];
}

- (void)accordion:(JHAccordion*)accordion willUpdateTableView:(UITableView *)tableView {
    [self notifyThatManagerWillAnimate];
}

- (void)accordion:(JHAccordion*)accordion didUpdateTableView:(UITableView *)tableView {
    [self notifyThatManagerDidAnimate];
}

@end
