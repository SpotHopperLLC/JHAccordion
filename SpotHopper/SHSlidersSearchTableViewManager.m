//
//  BaseSlidersSearchTableViewManager.m
//  SpotHopper
//
//  Created by Brennan Stehling on 5/23/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "SHSlidersSearchTableViewManager.h"

#import "SHSlider.h"
#import "SHSectionHeaderView.h"

#import "DrinkModel.h"
#import "SpotModel.h"
#import "SliderModel.h"
#import "DrinkListModel.h"
#import "DrinkListRequest.h"
#import "SpotListModel.h"
#import "SpotListRequest.h"
#import "SliderTemplateModel.h"
#import "ErrorModel.h"

#import "TellMeMyLocation.h"
#import "Tracker.h"

#import "SHStyleKit+Additions.h"

NSString * const SliderTemplatesKey = @"SliderTemplatesKey";
NSString * const SpotTypesKey = @"SpotTypesKey";
NSString * const DrinkTypesKey = @"DrinkTypesKey";
NSString * const WineSubTypesKey = @"WineSubTypesKey";

#define kSubTypeCellTitleLabel 1

#define kSliderCellLeftLabel 1
#define kSliderCellRightLabel 2
#define kSliderCellSlider 3
#define kSliderCellDividerView 4

@interface SHSlidersSearchCache : NSCache

- (NSArray *)cachedSliderTemplates;
- (void)cacheSliderTemplates:(NSArray *)sliderTemplates;

- (NSArray *)cachedSpotTypes;
- (void)cacheSpotTypes:(NSArray *)spotTypes;

- (NSArray *)cachedDrinkTypes;
- (void)cacheDrinkTypes:(NSArray *)drinkTypes;

@end

#pragma mark - Class Extension
#pragma mark -

@interface SHSlidersSearchTableViewManager () <SHSliderDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet id<SHSlidersSearchTableViewManagerDelegate> delegate;

@property (strong, nonatomic) NSString *drinkTypeName;
@property (strong, nonatomic) NSString *wineSubTypeName;

@property (strong, nonatomic) NSArray *drinkTypes;
@property (strong, nonatomic) NSArray *wineSubTypes;

@property (strong, nonatomic) NSArray *sliders;
@property (strong, nonatomic) NSArray *advancedSliders;

@property (strong, nonatomic) UIStoryboard *spotHopperStoryboard;

@end

#pragma mark -

@implementation SHSlidersSearchTableViewManager {
    NSUInteger _wineSubTypesCount;
}

#pragma mark - Public Methods
#pragma mark -

- (void)prefetchData {
    [self fetchDrinkTypesWithCompletionBlock:nil];
    [self fetchSliderTemplatesWithCompletionBlock:nil];
}

- (void)prepareForMode:(SHMode)mode {
//    NSAssert(self.tableView, @"Table View is required");
    [self.tableView registerClass:[SHSectionHeaderView class] forHeaderFooterViewReuseIdentifier:@"SectionHeader"];

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
        [self fetchSliderTemplatesWithCompletionBlock:^(NSArray *sliderTemplates) {
            [self filterSlidersTemplatesForSpots:sliderTemplates withCompletionBlock:^(NSArray *sliders, NSArray *advancedSliders) {
                NSLog(@"sliders: %li", (long)sliders.count);
                NSLog(@"advancedSliders: %li", (long)advancedSliders.count);
                
                self.sliders = sliders;
                self.advancedSliders = advancedSliders;
                
                [self.tableView reloadData];
                
                // TODO: open/close sections as appropriate
            }];
        }];
    }];
}

- (void)prepareTableViewForDrinkType:(NSString *)drinkTypeName {
    [self prepareTableViewForDrinkType:drinkTypeName andWineSubType:nil];
}

- (NSDictionary *)selectedDrinkType {
    for (NSDictionary *drinkType in self.drinkTypes) {
        if ([self.drinkTypeName isEqualToString:drinkType[@"name"]]) {
            return drinkType;
        }
    }
    
    return nil;
}

- (NSDictionary *)selectedWineSubType {
    if (self.wineSubTypeName.length) {
        for (NSDictionary *wineSubType in self.wineSubTypes) {
            if ([self.wineSubTypeName isEqualToString:wineSubType[@"name"]]) {
                return wineSubType;
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
        NSLog(@"drinkTypeName: %@", drinkTypeName);
        self.drinkTypes = drinkTypes;
        if ([kDrinkTypeNameWine isEqualToString:drinkTypeName]) {
            NSArray *wineSubTypes = [self extractWineSubTypesFromDrinkTypes:drinkTypes];
            self.wineSubTypes = wineSubTypes;
        }
        else {
            self.wineSubTypes = nil;
        }
        
        [self fetchSliderTemplatesWithCompletionBlock:^(NSArray *sliderTemplates) {
            NSDictionary *selectedDrinkType = [self selectedDrinkType];
            NSDictionary *selectedWineSubType = [self selectedWineSubType];
            
            NSLog(@"selectedDrinkType: %@", selectedDrinkType);
            NSLog(@"selectedWineSubType: %@", selectedWineSubType);
            
            [self filterSlidersTemplates:sliderTemplates forDrinkType:selectedDrinkType andWineSubType:selectedWineSubType withCompletionBlock:^(NSArray *sliders, NSArray *advancedSliders) {
                
                NSLog(@"sliders: %li", (long)sliders.count);
                NSLog(@"advancedSliders: %li", (long)advancedSliders.count);
                
                self.sliders = sliders;
                self.advancedSliders = advancedSliders;
                
                [self.tableView reloadData];
                
                // TODO: open/close sections as appropriate
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
    
    NSDictionary *selectedDrinkType = [self selectedDrinkType];
    NSDictionary *selectedWineSubType = [self selectedWineSubType];
    
    NSNumber *drinkTypeID = selectedDrinkType[@"id"];
    NSNumber *drinkSubTypeID = selectedWineSubType[@"id"];
    
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

#pragma mark - User Actions
#pragma mark -

- (IBAction)sliderValueChanged:(id)sender {
}

#pragma mark - UITableViewDataSource
#pragma mark -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.wineSubTypes.count) {
        // wine sub types will be displayed as a section with optional selection
        return 3;
    }
    else {
        return 2;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.wineSubTypes.count) {
        // 0 = wine sub types
        // 1 = sliders
        // 2 = advanced sliders
        if (section == 0) {
            return self.wineSubTypes.count;
        }
        else if (section == 1) {
            return self.sliders.count;
        }
        else if (section == 2) {
            return self.advancedSliders.count;
        }
    }
    else {
        // 0 = sliders
        // 1 = advanced sliders
        if (section == 0) {
            return self.sliders.count;
        }
        else if (section == 1) {
            return self.advancedSliders.count;
        }
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.wineSubTypes.count && indexPath.section == 0) {
        static NSString *SubTypeCellIdentifier = @"SubTypeCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SubTypeCellIdentifier forIndexPath:indexPath];
        
        if (indexPath.row < self.wineSubTypes.count) {
            NSDictionary *wineSubType = self.wineSubTypes[indexPath.row];
            UILabel *titleLabel = [self labelInView:cell withTag:kSubTypeCellTitleLabel];
            [SHStyleKit setLabel:titleLabel textColor:SHStyleKitColorMyTextColor];
            titleLabel.text = wineSubType[@"name"];
        }
        
        return cell;
    }
    else {
        static NSString *SliderCellIdentifier = @"SliderCell";

        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SliderCellIdentifier forIndexPath:indexPath];
        
        UILabel *minLabel = [self labelInView:cell withTag:kSliderCellLeftLabel];
        UILabel *maxLabel = [self labelInView:cell withTag:kSliderCellRightLabel];
        
        [SHStyleKit setLabel:minLabel textColor:SHStyleKitColorMyTextColor];
        [SHStyleKit setLabel:maxLabel textColor:SHStyleKitColorMyTextColor];
        
        SliderModel *sliderModel = [self sliderModelAtIndexPath:indexPath];
        SHSlider *slider = [self sliderInView:cell withTag:kSliderCellSlider];
        
        NSAssert(sliderModel, @"Model is required");
//        NSAssert(sliderModel.order, @"Model is required");
        NSAssert(slider, @"View is required");
        
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
}

#pragma mark - UITableViewDelegate
#pragma mark -

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // only the wine type section allows selection
    if (self.wineSubTypes.count && indexPath.section == 0) {
        return indexPath;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"selected: %li, %li", (long)indexPath.section, (long)indexPath.row);
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.25 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [tableView deselectRowAtIndexPath:indexPath animated:TRUE];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        if (self.wineSubTypes.count && indexPath.section == 0 && indexPath.row < self.wineSubTypes.count) {
            // TODO: get the selected wine type and prepare the table again with that selection (beginUpdate/endUpdate?)
            NSDictionary *wineSubType = self.wineSubTypes[indexPath.row];
            NSString *name = wineSubType[@"name"];
            [self prepareTableViewForDrinkType:self.drinkTypeName andWineSubType:name];
        }
    });
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.wineSubTypes.count && indexPath.section == 0) {
        // wine sub types will be displayed as a section with optional selection
        return 44.0f;
    }
    else {
        return 77.0f;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    return [NSString stringWithFormat:@"Section %li", (long)section+1];
    
    NSInteger adjustedIndex = section;
    if (!self.wineSubTypes.count) {
        // 0 wine types
        // 1 sliders
        // 2 advanced sliders
        adjustedIndex++;
    }
    else {
        // 0 sliders
        // 1 advanced sliders
    }
    
    switch (adjustedIndex) {
        case 0:
            return @"Wine Types (Optional)";
            break;
        case 1:
            return @"Sliders";
            break;
        case 2:
            return @"Advanced Sliders";
            break;
            
        default:
            break;
    }
    
    return nil;
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    // TODO: update to set header view details
    
//    UIView *sectionHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 65)];
//    sectionHeaderView.backgroundColor = [UIColor yellowColor];
//    return sectionHeaderView;

//    return [self sectionHeaderViewForSection:section];
    
//    registerClass forHeaderFooterViewReuseIdentifier storyboard
//    viewForHeaderInSection dequeueReusableHeaderFooterViewWithIdentifier UITableViewHeaderFooterView
    
//    UITableViewHeaderFooterView *sectionHeaderView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"SectionHeader"];
//    UIView *sectionHeaderView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"SectionHeader"];
//    return sectionHeaderView;
//}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    DrinkTypeModel *drinkType = [_drinkTypes objectAtIndex:section];
//    
//    // Only shows header if there are drinks in this section
//    if (drinkType != nil && [[_drinkSubtypes objectForKey:drinkType.ID] count] > 0) {
//        return 65.0f;
//    }
//    return 65.0f;
//}

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
    return (self.wineSubTypes.count && section == 1) || section == 0;
}

- (BOOL)isAdvancedSlidersSection:(NSInteger)section {
    return (self.wineSubTypes.count && section == 2) || section == 1;
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

#pragma mark - Caching
#pragma mark -

+ (SHSlidersSearchCache *)sh_sharedCache {
    static SHSlidersSearchCache *_sh_Cache = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sh_Cache = [[SHSlidersSearchCache alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidReceiveMemoryWarningNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * __unused notification) {
            [_sh_Cache removeAllObjects];
        }];
    });
    
    return _sh_Cache;
}

#pragma mark - API Methods
#pragma mark -

- (void)fetchSpotTypesWithCompletionBlock:(void (^)(NSArray * spotTypes))completionBlock {
    NSArray *spotTypes = [[SHSlidersSearchTableViewManager sh_sharedCache] cachedSpotTypes];
    if (spotTypes.count && completionBlock) {
        completionBlock(spotTypes);
        return;
    }
    
    [[SpotModel fetchSpotTypes] then:^(NSArray *spotTypes) {
        // Any is the option when no spot type is defined
        DebugLog(@"spotTypes: %@", spotTypes);
        [[SHSlidersSearchTableViewManager sh_sharedCache] cacheSpotTypes:spotTypes];
        if (completionBlock) {
            completionBlock(spotTypes);
        }
    } fail:^(ErrorModel *errorModel) {
        [Tracker logError:errorModel class:[self class] trace:NSStringFromSelector(_cmd)];
    } always:^{
    }];
}

- (void)fetchDrinkTypesWithCompletionBlock:(void (^)(NSArray * drinkTypes))completionBlock {
    NSArray *drinkTypes = [[SHSlidersSearchTableViewManager sh_sharedCache] cachedDrinkTypes];
    if (drinkTypes.count && completionBlock) {
        completionBlock(drinkTypes);
        return;
    }
    
    [[DrinkModel fetchDrinkTypes] then:^(NSArray *drinkTypes) {
        DebugLog(@"drinkTypes: %@", drinkTypes);
        [[SHSlidersSearchTableViewManager sh_sharedCache] cacheDrinkTypes:drinkTypes];
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
    NSArray *sliderTemplates = [[SHSlidersSearchTableViewManager sh_sharedCache] objectForKey:SliderTemplatesKey];
    if (sliderTemplates.count && completionBlock) {
        completionBlock([sliderTemplates copy]);
        return;
    }
    
    [SliderTemplateModel getSliderTemplates:nil success:^(NSArray *sliderTemplates, JSONAPI *jsonApi) {
        [[SHSlidersSearchTableViewManager sh_sharedCache] cacheSliderTemplates:sliderTemplates];
        if (completionBlock) {
            completionBlock([sliderTemplates copy]);
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

- (void)filterSlidersTemplates:(NSArray *)sliderTemplates forDrinkType:(NSDictionary *)selectedDrinkType andWineSubType:(NSDictionary *)selectedWineSubType withCompletionBlock:(void (^)(NSArray *sliders, NSArray *advancedSliders))completionBlock {
    NSMutableArray *sliders = [@[] mutableCopy];
    NSMutableArray *advancedSliders = [@[] mutableCopy];
    
    NSMutableArray *slidersFiltered = [@[] mutableCopy];
    if (selectedDrinkType == nil) {
        if (completionBlock) {
            completionBlock(nil, nil);
        }
    } else {
        NSNumber *selectedDrinkTypeId = selectedDrinkType[@"id"];
        NSNumber *selectedWineTypeId = selectedWineSubType[@"id"];
        
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

#pragma mark - Section Headers
#pragma mark -

- (SHSectionHeaderView *)instantiateSectionHeaderView {
    // load the VC and get the view (to allow for easily laying out the custom section header)
    if (!self.spotHopperStoryboard) {
        self.spotHopperStoryboard = [UIStoryboard storyboardWithName:@"SpotHopper" bundle:nil];
    }
    UIViewController *vc = [self.spotHopperStoryboard instantiateViewControllerWithIdentifier:@"SectionHeaderScene"];
    SHSectionHeaderView *sectionHeaderView = (SHSectionHeaderView *)[vc.view viewWithTag:100];
    NSAssert(sectionHeaderView, @"View is required");
    [sectionHeaderView removeFromSuperview];
    NSAssert(!sectionHeaderView.superview, @"Superview should not be defined now");
    [sectionHeaderView prepareView];
    
    return sectionHeaderView;
}

- (SHSectionHeaderView*)sectionHeaderViewForSection:(NSInteger)section {
    SHSectionHeaderView *sectionHeaderView = [self instantiateSectionHeaderView];
    [sectionHeaderView setText:[NSString stringWithFormat:@"Section %li", (long)section+1]];
    
//    SHSectionHeaderView *sectionHeaderView = [[SHSectionHeaderView alloc] initWithFrame:CGRectMake(0, 0, 320, 65)];
//    sectionHeaderView.backgroundColor = [UIColor yellowColor];
    
    return sectionHeaderView;
}

#pragma mark - SHSliderDelegate
#pragma mark -

// as the user moves the slider this callback will fire each time the value is changed
- (void)slider:(SHSlider *)slider valueDidChange:(CGFloat)value {
//    NSLog(@"slider did change: %f", value);
}

// one the user completes the gesture this callback is fired
- (void)slider:(SHSlider *)slider valueDidFinishChanging:(CGFloat)value {
    NSLog(@"slider did finish changing: %f", value);
    
    NSIndexPath *indexPath = [self indexPathForView:slider inTableView:self.tableView];
    NSLog(@"indexPath: %@", indexPath);
    
    NSAssert(self.delegate, @"Delegate is required");
    
    if ([self.delegate respondsToSelector:@selector(slidersSearchTableViewManagerDidChangeSlider:)]) {
        [self.delegate slidersSearchTableViewManagerDidChangeSlider:self];
    }
}

@end

@implementation SHSlidersSearchCache

- (NSArray *)cachedSliderTemplates {
    return [self objectForKey:SliderTemplatesKey];
}

- (void)cacheSliderTemplates:(NSArray *)sliderTemplates {
    if (sliderTemplates.count) {
        [self setObject:sliderTemplates forKey:SliderTemplatesKey];
    }
    else {
        [self removeObjectForKey:SliderTemplatesKey];
    }
}

- (NSArray *)cachedSpotTypes {
    return [self objectForKey:SpotTypesKey];
}

- (void)cacheSpotTypes:(NSArray *)spotTypes {
    if (spotTypes.count) {
        [self setObject:spotTypes forKey:SpotTypesKey];
    }
    else {
        [self removeObjectForKey:SpotTypesKey];
    }
}

- (NSArray *)cachedDrinkTypes {
    return [self objectForKey:DrinkTypesKey];
}

- (void)cacheDrinkTypes:(NSArray *)drinkTypes {
    if (drinkTypes.count) {
        [self setObject:drinkTypes forKey:DrinkTypesKey];
    }
    else {
        [self removeObjectForKey:DrinkTypesKey];
    }
}

@end
