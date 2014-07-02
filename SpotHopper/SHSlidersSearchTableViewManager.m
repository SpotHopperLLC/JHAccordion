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
#import "SHSectionHeaderView.h"

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
#import "DrinkSubtypeModel.h"

#import "TellMeMyLocation.h"
#import "Tracker.h"

#import "SHStyleKit+Additions.h"
#import "UIControl+BlocksKit.h"

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

#define kSection_Spots_Type 0
#define kSection_Spots_Spotlists 1
#define kSection_Spots_Sliders 2
#define kSection_Spots_AdvancedSliders 3

#define kSection_Beer_Drinklists 0
#define kSection_Beer_Sliders 1
#define kSection_Beer_AdvancedSliders 2

#define kSection_Cocktail_Type 0
#define kSection_Cocktail_Drinklists 1
#define kSection_Cocktail_Sliders 2
#define kSection_Cocktail_AdvancedSliders 3

#define kSection_Wine_Type 0
#define kSection_Wine_Drinklists 1
#define kSection_Wine_Sliders 2
#define kSection_Wine_AdvancedSliders 3

#define kHeightForDefaultCell 44.0f
#define kHeightForListCell 60.0f
#define kHeightForSubtypeCell 44.0f
#define kHeightForSlidercell 77.0f

#define kOpenedPosition M_PI_2
#define kClosedPosition M_PI_2 * -1

#pragma mark - Class Extension
#pragma mark -

@interface SHSlidersSearchTableViewManager () <SHSliderDelegate, JHAccordionDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet JHAccordion *accordion;

@property (weak, nonatomic) IBOutlet id<SHSlidersSearchTableViewManagerDelegate> delegate;

@property (strong, nonatomic) NSString *drinkTypeName;
@property (strong, nonatomic) NSString *wineSubTypeName;

@property (strong, nonatomic) NSArray *spotTypes;
@property (strong, nonatomic) NSArray *drinkTypes;

@property (strong, nonatomic) NSArray *beerSubtypes;
@property (strong, nonatomic) NSArray *cocktailSubtypes;
@property (strong, nonatomic) NSArray *wineSubtypes;

@property (strong, nonatomic) NSArray *spotlists;
@property (strong, nonatomic) NSArray *sliders;
@property (strong, nonatomic) NSArray *advancedSliders;

@property (strong, nonatomic) NSMutableDictionary *sectionHeaderViews;

@property (strong, nonatomic) UIStoryboard *spotHopperStoryboard;

@property (assign) SHMode mode;

@end

#pragma mark -

@implementation SHSlidersSearchTableViewManager {
    NSUInteger _wineSubTypesCount;
}

#pragma mark - Public Methods
#pragma mark -


- (void)prepare {
    // prepare accordion
    self.accordion = [[JHAccordion alloc] initWithTableView:self.tableView];
    self.accordion.delegate = self;

    // prefetch data
    [self fetchMySpotlistsWithCompletionBlock:nil];
    [self fetchSpotTypesWithCompletionBlock:nil];
    [self fetchDrinkTypesWithCompletionBlock:nil];
    [self fetchSliderTemplatesWithCompletionBlock:nil];
}

- (void)prepareForMode:(SHMode)mode {
//    NSAssert(self.tableView, @"Table View is required");
    [self.tableView registerClass:[SHSectionHeaderView class] forHeaderFooterViewReuseIdentifier:@"SectionHeader"];
    
    self.mode = mode;
    [self.tableView reloadData];

    switch (mode) {
        case SHModeSpots:
            [self prepareTableViewForSpots];
            break;
        case SHModeBeer:
            [self prepareTableViewForDrinkType:kDrinkTypeNameBeer];
            break;
        case SHModeCocktail:
            [self prepareTableViewForDrinkType:kDrinkTypeNameCocktail];
            break;
        case SHModeWine:
            [self prepareTableViewForDrinkType:kDrinkTypeNameWine];
            break;
            
        default:
            break;
    }
}

- (void)prepareTableViewForSpots {
    [self fetchSpotTypesWithCompletionBlock:^(NSArray *spotTypes) {
        self.spotTypes = spotTypes;
        [self fetchMySpotlistsWithCompletionBlock:^(NSArray *spotlists) {
            self.spotlists = spotlists;
            [self fetchSliderTemplatesWithCompletionBlock:^(NSArray *sliderTemplates) {
                [self filterSlidersTemplatesForSpots:sliderTemplates withCompletionBlock:^(NSArray *sliders, NSArray *advancedSliders) {
                    
                    self.sliders = sliders;
                    self.advancedSliders = advancedSliders;
                    
                    [self.accordion immediatelyResetOpenedSections:@[[NSNumber numberWithInteger:kSection_Spots_Spotlists]]];
                }];
            }];
        }];
    }];
}

- (void)prepareTableViewForDrinkType:(NSString *)drinkTypeName {
    [self prepareTableViewForDrinkType:drinkTypeName andWineSubType:nil];
}

- (DrinkTypeModel *)selectedDrinkType {
    for (DrinkTypeModel *drinkType in self.drinkTypes) {
        if ([self.drinkTypeName isEqualToString:drinkType.name]) {
            return drinkType;
        }
    }
    
    return nil;
}

- (DrinkSubtypeModel *)selectedWineSubType {
    if (self.wineSubTypeName.length) {
        for (DrinkSubtypeModel *wineSubtype in self.wineSubtypes) {
            if ([self.wineSubTypeName isEqualToString:wineSubtype.name]) {
                return wineSubtype;
            }
        }
    }
    
    return nil;
}

- (void)prepareTableViewForDrinkType:(NSString *)drinkTypeName andWineSubType:(NSString *)wineSubTypeName {
    //[self.tableView setContentOffset:CGPointMake(0, 0) animated:FALSE];
    
    self.drinkTypeName = drinkTypeName;
    self.wineSubTypeName = wineSubTypeName;
    
    [self fetchDrinkTypesWithCompletionBlock:^(NSArray *drinkTypes) {
        DebugLog(@"drinkTypeName: %@", drinkTypeName);
        self.drinkTypes = drinkTypes;
        
        [self fetchSliderTemplatesWithCompletionBlock:^(NSArray *sliderTemplates) {
            DrinkTypeModel *selectedDrinkType = [self selectedDrinkType];
            DrinkSubtypeModel *selectedWineSubType = [self selectedWineSubType];
            
            DebugLog(@"selectedDrinkType: %@", selectedDrinkType);
            DebugLog(@"selectedWineSubType: %@", selectedWineSubType);
            
            [self filterSlidersTemplates:sliderTemplates forDrinkType:selectedDrinkType andWineSubType:selectedWineSubType withCompletionBlock:^(NSArray *sliders, NSArray *advancedSliders) {
                
                DebugLog(@"sliders: %li", (long)sliders.count);
                DebugLog(@"advancedSliders: %li", (long)advancedSliders.count);
                
                self.sliders = sliders;
                self.advancedSliders = advancedSliders;
                
                [self.tableView reloadData];
                
                // TODO: open/close sections as appropriate
                DebugLog(@"TODO");

            }];
        }];
    }];
}

- (BOOL)isSelectingSpotlist {
    return !self.drinkTypeName.length;
}

- (void)fetchSpotListResultsWithCompletionBlock:(void (^)(SpotListModel *spotListModel, SpotListRequest *request, ErrorModel *errorModel))completionBlock {
    NSMutableArray *allTheSliders = [NSMutableArray array];
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
    
    // TODO: review how the last location is set
    CLLocation *location = [TellMeMyLocation lastLocation];
    
    NSNumber *latitude = nil, *longitude = nil;
    if (location != nil) {
        latitude = [NSNumber numberWithFloat:location.coordinate.latitude];
        longitude = [NSNumber numberWithFloat:location.coordinate.longitude];
    }
    
    [Tracker track:@"Creating Spotlist"];
    
    SpotListRequest *request = [[SpotListRequest alloc] init];
    request.name = kSpotListModelDefaultName;
    request.coordinate = location.coordinate;
    request.sliders = allTheSliders;
    
    // TODO: add spotId and/or spotTypeId if it is defined
    
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
}

- (void)fetchDrinkListResultsWithCompletionBlock:(void (^)(DrinkListModel *drinkListModel, DrinkListRequest *request, ErrorModel *errorModel))completionBlock {
    NSMutableArray *allTheSliders = [NSMutableArray array];
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
    
    // TODO: review how the last location is set
    CLLocation *location = [TellMeMyLocation lastLocation];
    
    NSNumber *latitude = nil, *longitude = nil;
    if (location != nil) {
        latitude = [NSNumber numberWithFloat:location.coordinate.latitude];
        longitude = [NSNumber numberWithFloat:location.coordinate.longitude];
    }
    
    [Tracker track:@"Creating Drinklist"];
    
    DrinkTypeModel *selectedDrinkType = [self selectedDrinkType];
    DrinkSubtypeModel *selectedWineSubType = [self selectedWineSubType];
    
    NSNumber *drinkTypeID = selectedDrinkType.ID;
    NSNumber *drinkSubTypeID = selectedWineSubType.ID;
    
    DrinkListRequest *request = [[DrinkListRequest alloc] init];
    request.name = kDrinkListModelDefaultName;
    request.coordinate = location.coordinate;
    request.sliders = allTheSliders;
    request.drinkTypeId = drinkTypeID;
    request.drinkSubTypeId = drinkSubTypeID;
    
    [DrinkListModel fetchDrinkListWithRequest:request success:^(DrinkListModel *drinkListModel, JSONAPI *jsonApi) {
        [Tracker track:@"Created Drinklist" properties:@{@"Success" : @TRUE, @"Drink Type ID" : drinkTypeID ?: @0, @"Drink Sub Type ID" : drinkSubTypeID ?: @0, @"Created With Sliders" : @TRUE}];
        
        // now fetch the spots for the first drink so it is ready then request the rest cache all of the results for fast access
        
        if (drinkListModel.drinks.count) {
            DrinkModel *firstDrink = drinkListModel.drinks[0];
            [[firstDrink fetchSpotsForLocation:location] then:^(NSArray *spots) {
                // pre-cache the menu for each spot
                for (SpotModel *spotModel in spots) {
                    [spotModel fetchMenu];
                }
                
                if (completionBlock) {
                    completionBlock(drinkListModel, request, nil);
                }

                // now that the spots for the first drink are fetched now prefetch the rest
                if (drinkListModel.drinks.count > 1) {
                    NSMutableArray *promises = @[].mutableCopy;
                    for (NSUInteger i=1; i<drinkListModel.drinks.count; i++) {
                        DrinkModel *drink = drinkListModel.drinks[i];
                        Promise *promise = [drink fetchSpotsForLocation:location];
                        [promises addObject:promise];
                        [promise then:^(NSArray *spots) {
                            // pre-cache the menu for each spot
                            for (SpotModel *spotModel in spots) {
                                [spotModel fetchMenu];
                            }
                        } fail:nil always:nil];
                    }
                    
                    [When when:promises then:^{
                        DebugLog(@"Finished all drink/spot fetches");
                    } fail:nil always:nil];
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
    if (self.mode == SHModeSpots) {
        return 4;
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
    if (self.mode == SHModeSpots) {
        switch (section) {
            case kSection_Spots_Type:
                // Any, Bar, Club, Lounge, etc
                return self.spotTypes.count;
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
                break;
            case kSection_Beer_Sliders:
                // Basic Sliders
                break;
            case kSection_Beer_AdvancedSliders:
                // Advanced Sliders
                break;
                
            default:
                break;
        }
    }
    else if (self.mode == SHModeCocktail) {
        switch (section) {
            case kSection_Cocktail_Type:
                break;
            case kSection_Cocktail_Drinklists:
                // Moods, Drinklists
                break;
            case kSection_Cocktail_Sliders:
                // Basic Sliders
                break;
            case kSection_Cocktail_AdvancedSliders:
                // Advanced Sliders
                break;
                
            default:
                break;
        }
    }
    else if (self.mode == SHModeWine) {
        switch (section) {
            case kSection_Wine_Type:
                break;
            case kSection_Wine_Drinklists:
                // Moods, Drinklists
                break;
            case kSection_Wine_Sliders:
                // Basic Sliders
                break;
            case kSection_Wine_AdvancedSliders:
                // Advanced Sliders
                break;
                
            default:
                break;
        }
    }
    
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(slidersSearchTableViewManagerStoryboard:)]) {
        UIStoryboard *storyboard = [self.delegate slidersSearchTableViewManagerStoryboard:self];
        UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"SlidersSearchSectionHeaderScene"];
        UIView *view = vc.view;
        
        UILabel *titleLabel = (UILabel *)[view viewWithTag:1];
        UIImageView *arrowImageView = (UIImageView *)[view viewWithTag:2];
        UIButton *button = (UIButton *)[view viewWithTag:3];
        
        NSString *sectionTitle = nil;
        
        if (self.mode == SHModeSpots) {
            switch (section) {
                case kSection_Spots_Type:
                    sectionTitle = @"Spot Type (optional)";
                    break;
                    
                case kSection_Spots_Spotlists:
                    sectionTitle = @"Moods";
                    break;
                    
                case kSection_Spots_Sliders:
                    sectionTitle = @"Sliders";
                    break;
                    
                case kSection_Spots_AdvancedSliders:
                    sectionTitle = @"Advanced Sliders";
                    break;
                    
                default:
                    break;
            }
        }
        else if (self.mode == SHModeBeer) {
            switch (section) {
                case kSection_Beer_Drinklists:
                    sectionTitle = @"Style";
                    break;
                    
                case kSection_Beer_Sliders:
                    sectionTitle = @"Sliders";
                    break;
                    
                case kSection_Beer_AdvancedSliders:
                    sectionTitle = @"Advanced Sliders";
                    break;
                    
                default:
                    break;
            }
        }
        else if (self.mode == SHModeCocktail) {
            switch (section) {
                case kSection_Cocktail_Type:
                    sectionTitle = @"Base Alcohol (optional)";
                    break;
                    
                case kSection_Cocktail_Drinklists:
                    sectionTitle = @"Style";
                    break;
                    
                case kSection_Cocktail_Sliders:
                    sectionTitle = @"Sliders";
                    break;
                    
                case kSection_Cocktail_AdvancedSliders:
                    sectionTitle = @"Advanced Sliders";
                    break;
                    
                default:
                    break;
            }
        }
        else if (self.mode == SHModeWine) {
            switch (section) {
                case kSection_Wine_Type:
                    sectionTitle = @"Select Type";
                    break;
                    
                case kSection_Wine_Drinklists:
                    sectionTitle = @"Style";
                    break;
                    
                case kSection_Wine_Sliders:
                    sectionTitle = @"Sliders";
                    break;
                    
                case kSection_Wine_AdvancedSliders:
                    sectionTitle = @"Advanced Sliders";
                    break;
                    
                default:
                    break;
            }
        }
        
        titleLabel.text = sectionTitle;
        [SHStyleKit setLabel:titleLabel textColor:SHStyleKitColorMyTintColor];
        
        [SHStyleKit setImageView:arrowImageView withDrawing:SHStyleKitDrawingNavigationArrowRightIcon color:SHStyleKitColorMyTintColor];
        
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
        
        BOOL isOpened = [self.accordion isSectionOpened:section];
        arrowImageView.transform = CGAffineTransformMakeRotation(isOpened ? kOpenedPosition : kClosedPosition);
        
        [self setSectionHeaderView:view section:section];
        
        return view;
    }
    
    NSAssert(false, @"Condition should never be met");
    
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.mode == SHModeSpots) {
//        DebugLog(@"Spots");
        if (indexPath.section == kSection_Spots_Type && indexPath.row < self.spotTypes.count) {
            SpotTypeModel *spotType = self.spotTypes[indexPath.row];
            return [self configureSubTypeCellForIndexPath:indexPath forTableView:tableView withTitle:spotType.name];
        }
        else if (indexPath.section == kSection_Spots_Spotlists && indexPath.row < self.spotlists.count) {
            SpotListModel *spotlist = [self spotlistAtIndexPath:indexPath];
            return [self configureListCellForIndexPath:indexPath forTableView:tableView withTitle:spotlist.name];
        }
        else if (indexPath.section == kSection_Spots_Sliders && indexPath.row < self.sliders.count) {
            return [self configureSliderCellForIndexPath:indexPath forTableView:tableView];
        }
        else if (indexPath.section == kSection_Spots_AdvancedSliders) {
            return [self configureSliderCellForIndexPath:indexPath forTableView:tableView];
        }
    }
    else if (self.mode == SHModeBeer) {
//        DebugLog(@"Beer");
        if (indexPath.section == kSection_Wine_Type && indexPath.row < self.wineSubtypes.count) {
//            NSDictionary *wineSubType = self.wineSubTypes[indexPath.row];
//            titleLabel.text = wineSubType[@"name"];
            return [self configureSubTypeCellForIndexPath:indexPath forTableView:tableView withTitle:@"FINISH"];
        }
    }
    else if (self.mode == SHModeCocktail) {
//        DebugLog(@"Cocktail");
    }
    else if (self.mode == SHModeWine) {
//        DebugLog(@"Wine");
    }
    else {
        DebugLog(@"Mode is %@", self.mode == SHModeNone ? @"None" : @"Unknown");
    }
    
    NSAssert(false, @"Condition should never be met");
    
    return nil;
}

#pragma mark - UITableViewDelegate
#pragma mark -

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.mode == SHModeSpots) {
        if (indexPath.section == kSection_Spots_Type || indexPath.section == kSection_Spots_Spotlists) {
            return indexPath;
        }
    }
    else if (self.mode == SHModeBeer) {
        if (indexPath.section == kSection_Beer_Drinklists) {
            return indexPath;
        }
    }
    else if (self.mode == SHModeCocktail) {
        if (indexPath.section == kSection_Cocktail_Type || indexPath.section == kSection_Cocktail_Drinklists) {
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
    DebugLog(@"selected: %li, %li", (long)indexPath.section, (long)indexPath.row);
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.25 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [tableView deselectRowAtIndexPath:indexPath animated:TRUE];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        if (self.mode == SHModeSpots) {
            if (indexPath.section == kSection_Spots_Type) {
                // TODO: handle spot type selection
                DebugLog(@"TODO");
            }
            else if (indexPath.section == kSection_Spots_Spotlists) {
                // TODO: handle spotlist selection (update slider values)
                DebugLog(@"TODO");
                
                UIView *headerView = [self getSectionHeaderView:indexPath.section];
                UILabel *label = (UILabel *)[headerView viewWithTag:1];
                
                SpotListModel *spotlist = [self spotlistAtIndexPath:indexPath];
                label.text = spotlist.name;
                [self.accordion closeSection:kSection_Spots_Spotlists];
                [self.accordion openSection:kSection_Spots_Sliders];
            }
        }
        else if (self.mode == SHModeBeer) {
            if (indexPath.section == kSection_Beer_Drinklists) {
                // TODO: handle drinklist selection
                DebugLog(@"TODO");
            }
        }
        else if (self.mode == SHModeCocktail) {
            if (indexPath.section == kSection_Cocktail_Type) {
                // TODO: handle drinklist selection
                DebugLog(@"TODO");
            }
            else if (indexPath.section == kSection_Cocktail_Drinklists) {
                // TODO: handle drinklist selection
                DebugLog(@"TODO");
            }
        }
        else if (self.mode == SHModeWine) {
            if (indexPath.section == kSection_Wine_Type && indexPath.row < self.wineSubtypes.count) {
                // TODO: get the selected wine type and prepare the table again with that selection (beginUpdate/endUpdate?)
                DrinkSubtypeModel *wineSubtype = self.wineSubtypes[indexPath.row];
                NSString *name = wineSubtype.name;
                [self prepareTableViewForDrinkType:self.drinkTypeName andWineSubType:name];
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
            case kSection_Spots_Type:
                return kHeightForSubtypeCell;
            case kSection_Spots_Spotlists:
                return kHeightForListCell;
            case kSection_Spots_Sliders:
                return kHeightForSlidercell;
            case kSection_Spots_AdvancedSliders:
                return kHeightForSlidercell;
        }
    }
    else if (self.mode == SHModeBeer) {
        switch (indexPath.section) {
            case kSection_Beer_Drinklists:
                return kHeightForListCell;
            case kSection_Beer_Sliders:
                return kHeightForSlidercell;
            case kSection_Beer_AdvancedSliders:
                return kHeightForSlidercell;
        }
    }
    else if (self.mode == SHModeCocktail) {
        switch (indexPath.section) {
                return kHeightForSubtypeCell;
            case kSection_Cocktail_Drinklists:
                return kHeightForListCell;
            case kSection_Cocktail_Sliders:
                return kHeightForSlidercell;
            case kSection_Cocktail_AdvancedSliders:
                return kHeightForSlidercell;
        }
    }
    else if (self.mode == SHModeWine) {
        switch (indexPath.section) {
            case kSection_Wine_Type:
                return kHeightForSubtypeCell;
            case kSection_Wine_Drinklists:
                return kHeightForListCell;
            case kSection_Wine_Sliders:
                return kHeightForSlidercell;
            case kSection_Wine_AdvancedSliders:
                return kHeightForSlidercell;
        }
    }
    
    return kHeightForDefaultCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 65.0f;
}

#pragma mark - Cell Configuration
#pragma mark -

- (UITableViewCell *)configureListCellForIndexPath:(NSIndexPath *)indexPath forTableView:(UITableView *)tableView withTitle:(NSString *)title {
    static NSString *ListCellIdentifier = @"ListCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ListCellIdentifier forIndexPath:indexPath];
    
    UILabel *titleLabel = [self labelInView:cell withTag:kListCellTitleLabel];
    UIButton *deleteButton = [self buttonInView:cell withTag:kListCellDeleteButton];
    
    [SHStyleKit setLabel:titleLabel textColor:SHStyleKitColorMyTextColor];
    titleLabel.text = title;
    
    [SHStyleKit setButton:deleteButton withDrawing:SHStyleKitDrawingDeleteIcon normalColor:SHStyleKitColorMyTextColor highlightedColor:SHStyleKitColorMyTextColor];
    
    if ([deleteButton bk_hasEventHandlersForControlEvents:UIControlEventTouchUpInside]) {
        [deleteButton bk_removeEventHandlersForControlEvents:UIControlEventTouchUpInside];
    }
    
    [deleteButton bk_addEventHandler:^(id sender) {
        // TODO: implement prompt to delete list
        DebugLog(@"delete list?");
    } forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (UITableViewCell *)configureSubTypeCellForIndexPath:(NSIndexPath *)indexPath forTableView:(UITableView *)tableView withTitle:(NSString *)title {
    static NSString *SubTypeCellIdentifier = @"SubTypeCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SubTypeCellIdentifier forIndexPath:indexPath];
    
    UILabel *titleLabel = [self labelInView:cell withTag:kSubTypeCellTitleLabel];
    [SHStyleKit setLabel:titleLabel textColor:SHStyleKitColorMyTextColor];
    titleLabel.text = title;
    
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

- (SpotListModel *)spotlistAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.spotlists.count) {
        SpotListModel *spotlist = self.spotlists[indexPath.row];
        return spotlist;
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

#pragma mark - API Methods
#pragma mark -

- (void)fetchMySpotlistsWithCompletionBlock:(void (^)(NSArray * spotlists))completionBlock {
    if ([UserModel isLoggedIn]) {
        UserModel *user = [UserModel currentUser];
        
        [[user fetchMySpotLists] then:^(NSArray *spotlists) {
            // add Custom Mood at the top
            SpotListModel *customSpotlist = [[SpotListModel alloc] init];
            customSpotlist.ID = [NSNull null];
            customSpotlist.name = @"Custom Mood";
            
            NSMutableArray *allSpotlists = @[].mutableCopy;
            [allSpotlists addObject:customSpotlist];
            [allSpotlists addObjectsFromArray:spotlists];
            
            if (completionBlock) {
                completionBlock(allSpotlists);
            }
        } fail:^(ErrorModel *error) {
        } always:nil];
    }
}

- (void)fetchSpotTypesWithCompletionBlock:(void (^)(NSArray * spotTypes))completionBlock {
    [[SpotModel fetchSpotTypes] then:^(NSArray *spotTypes) {
        // Any is the option when no spot type is defined
        if (completionBlock) {
            completionBlock(spotTypes);
        }
    } fail:^(ErrorModel *errorModel) {
        [Tracker logError:errorModel class:[self class] trace:NSStringFromSelector(_cmd)];
    } always:^{
    }];
}

- (void)fetchDrinkTypesWithCompletionBlock:(void (^)(NSArray * drinkTypes))completionBlock {
    [[DrinkModel fetchDrinkTypes] then:^(NSArray *drinkTypes) {
        DebugLog(@"drinkTypes: %@", drinkTypes);
        
        for (DrinkTypeModel *drinkType in drinkTypes) {
            if ([kDrinkTypeNameBeer isEqualToString:drinkType.name]) {
                self.beerSubtypes = drinkType.subtypes;
            }
            else if ([kDrinkTypeNameCocktail isEqualToString:drinkType.name]) {
                self.cocktailSubtypes = drinkType.subtypes;
            }
            else if ([kDrinkTypeNameWine isEqualToString:drinkType.name]) {
                self.wineSubtypes = drinkType.subtypes;
            }
        }
        
        if (completionBlock) {
            completionBlock(drinkTypes);
        }
    } fail:^(ErrorModel *errorModel) {
        [Tracker logError:errorModel class:[self class] trace:NSStringFromSelector(_cmd)];
    } always:^{
    }];
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

- (void)filterSlidersTemplates:(NSArray *)sliderTemplates forDrinkType:(DrinkTypeModel *)selectedDrinkType andWineSubType:(DrinkSubtypeModel *)selectedWineSubType withCompletionBlock:(void (^)(NSArray *sliders, NSArray *advancedSliders))completionBlock {
    NSMutableArray *sliders = [@[] mutableCopy];
    NSMutableArray *advancedSliders = [@[] mutableCopy];
    
    NSMutableArray *slidersFiltered = [@[] mutableCopy];
    if (selectedDrinkType == nil) {
        if (completionBlock) {
            completionBlock(nil, nil);
        }
    } else {
        NSNumber *selectedDrinkTypeId = selectedDrinkType.ID;
        NSNumber *selectedWineTypeId = selectedWineSubType.ID;
        
        // Filters by drink id
        for (SliderTemplateModel *sliderTemplate in sliderTemplates) {
            NSArray *drinkTypeIds = [sliderTemplate.drinkTypes valueForKey:@"ID"];
            NSArray *drinkSubtypeIds = [sliderTemplate.drinkSubtypes valueForKey:@"ID"];
            
            // Only filter by drink type if wine subtype is nil
            if (!selectedWineSubType && [drinkTypeIds containsObject:selectedDrinkTypeId]) {
                [slidersFiltered addObject:sliderTemplate];
            }
            // Else filter by drink type and drink subtype
            else if (selectedWineSubType && [drinkTypeIds containsObject:selectedDrinkTypeId] && [drinkSubtypeIds containsObject:selectedWineTypeId]) {
                [slidersFiltered addObject:sliderTemplate];
            }
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

#pragma mark - SHSliderDelegate
#pragma mark -

// as the user moves the slider this callback will fire each time the value is changed
- (void)slider:(SHSlider *)slider valueDidChange:(CGFloat)value {
//    DebugLog(@"slider did change: %f", value);
}

// one the user completes the gesture this callback is fired
- (void)slider:(SHSlider *)slider valueDidFinishChanging:(CGFloat)value {
    DebugLog(@"slider did finish changing: %f", value);
    
    NSIndexPath *indexPath = [self indexPathForView:slider inTableView:self.tableView];
    DebugLog(@"indexPath: %@", indexPath);
    
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
//    DebugLog(@"%@", NSStringFromSelector(_cmd));
    [accordion slideUpLastOpenedSection];
}

- (void)accordion:(JHAccordion*)accordion openingSection:(NSInteger)section {
//    DebugLog(@"%@", NSStringFromSelector(_cmd));
    UIView *headerView = [self getSectionHeaderView:section];
    UIImageView *arrowImageView = (UIImageView *)[headerView viewWithTag:2];
    [UIView animateWithDuration:0.35 animations:^{
        arrowImageView.transform = CGAffineTransformMakeRotation(kOpenedPosition);
    }];
}

- (void)accordion:(JHAccordion*)accordion closingSection:(NSInteger)section {
//    DebugLog(@"%@", NSStringFromSelector(_cmd));
    UIView *headerView = [self getSectionHeaderView:section];
    UIImageView *arrowImageView = (UIImageView *)[headerView viewWithTag:2];
    [UIView animateWithDuration:0.35 animations:^{
        arrowImageView.transform = CGAffineTransformMakeRotation(kClosedPosition);
    }];
}

- (void)accordion:(JHAccordion*)accordion willUpdateTableView:(UITableView *)tableView {
    if ([self.delegate respondsToSelector:@selector(slidersSearchTableViewManagerWillAnimate:)]) {
        [self.delegate slidersSearchTableViewManagerWillAnimate:self];
    }
    
}

- (void)accordion:(JHAccordion*)accordion didUpdateTableView:(UITableView *)tableView {
    if ([self.delegate respondsToSelector:@selector(slidersSearchTableViewManagerDidAnimate:)]) {
        [self.delegate slidersSearchTableViewManagerDidAnimate:self];
    }
}

@end
