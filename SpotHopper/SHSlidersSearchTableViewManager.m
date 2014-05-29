//
//  BaseSlidersSearchTableViewManager.m
//  SpotHopper
//
//  Created by Brennan Stehling on 5/23/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "SHSlidersSearchTableViewManager.h"

#import "SHSlider.h"

#import "DrinkModel.h"
#import "SpotModel.h"
#import "SliderModel.h"
#import "SliderTemplateModel.h"
#import "ErrorModel.h"

#import "Tracker.h"

#import "SHStyleKit+Additions.h"

NSString * const SliderTemplatesKey = @"SliderTemplatesKey";
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

- (NSArray *)cachedDrinkTypes;
- (void)cacheDrinkTypes:(NSArray *)drinkTypes;

@end

#pragma mark - Class Extension
#pragma mark -

@interface SHSlidersSearchTableViewManager () <SHSliderDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet id<SHSlidersSearchTableViewDelegate> delegate;

@property (strong, nonatomic) NSString *drinkTypeName;
@property (strong, nonatomic) NSString *wineSubTypeName;

@property (strong, nonatomic) NSArray *wineSubTypes;

@property (strong, nonatomic) NSArray *sliders;
@property (strong, nonatomic) NSArray *advancedSliders;

@end

#pragma mark -

@implementation SHSlidersSearchTableViewManager {
    NSUInteger _wineSubTypesCount;
}

#pragma mark - Public Methods
#pragma mark -

- (void)prepareForMode:(SHMode)mode {
    switch (mode) {
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

- (void)prepareTableViewForDrinkType:(NSString *)drinkTypeName {
    [self prepareTableViewForDrinkType:drinkTypeName andWineSubType:nil];
}

- (void)prepareTableViewForDrinkType:(NSString *)drinkTypeName andWineSubType:(NSString *)wineSubTypeName {
    [self.tableView setContentOffset:CGPointMake(0, 0) animated:FALSE];
    
    self.drinkTypeName = drinkTypeName;
    self.wineSubTypeName = wineSubTypeName;
    
    [self fetchDrinkTypesWithCompletionBlock:^(NSArray *drinkTypes) {
        NSLog(@"drinkTypeName: %@", drinkTypeName);
        if ([kDrinkTypeNameWine isEqualToString:drinkTypeName]) {
            NSArray *wineSubTypes = [self extractWineSubTypesFromDrinkTypes:drinkTypes];
            self.wineSubTypes = wineSubTypes;
        }
        else {
            self.wineSubTypes = nil;
        }
        [self fetchSliderTemplatesWithCompletionBlock:^(NSArray *sliderTemplates) {
            
            NSDictionary *selectedDrinkType = nil;
            NSDictionary *selectedWineSubType = nil;
            
            for (NSDictionary *dictionary in drinkTypes) {
                if ([drinkTypeName isEqualToString:dictionary[@"name"]]) {
                    selectedDrinkType = dictionary;
                    break;
                }
            }
            
            if (wineSubTypeName.length) {
                for (NSDictionary *dictionary in self.wineSubTypes) {
                    if ([wineSubTypeName isEqualToString:dictionary[@"name"]]) {
                        selectedWineSubType = dictionary;
                        break;
                    }
                }
            }
            
            [self filterSlidersTemplates:sliderTemplates forDrinkType:selectedDrinkType andWineSubType:selectedWineSubType withCompletionBlock:^(NSArray *sliders, NSArray *advancedSliders) {
                
                self.sliders = sliders;
                self.advancedSliders = advancedSliders;
                
                [self.tableView reloadData];
                
                // open/close sections as appropriate
            }];
        }];
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
        UISlider *slider = [self sliderInView:cell withTag:kSliderCellSlider];
        
        NSAssert(sliderModel, @"Model is required");
        //NSAssert(slider, @"View is required");
        
        if (sliderModel && slider) {
            minLabel.text = sliderModel.sliderTemplate.minLabel;
            maxLabel.text = sliderModel.sliderTemplate.maxLabel;
            
//            if (!sliderModel.value) {
//                [slider setSelectedValue:(sliderModel.sliderTemplate.defaultValue.floatValue / 10.0f)];
//                [slider setUserMoved:NO];
//            }
//            else {
//                [slider setSelectedValue:(sliderModel.value.floatValue / 10.0f)];
//                [slider setUserMoved:YES];
//            }
        }
        
//        slider.delegate = self;
        
        return cell;
    }
}

#pragma mark - UITableViewDelegate
#pragma mark -

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"selected: %li, %li", (long)indexPath.section, (long)indexPath.row);
    
     if (self.wineSubTypes.count && indexPath.section == 0) {
         // TODO: get the selected wine type and prepare the table again with that selection (beginUpdate/endUpdate?)
         
         [self prepareTableViewForDrinkType:self.drinkTypeName andWineSubType:nil];
     }
    
    [tableView deselectRowAtIndexPath:indexPath animated:TRUE];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 77.0f;
}

#pragma mark - Helper Methods
#pragma mark -

- (UISlider *)sliderInView:(UIView *)view withTag:(NSUInteger)tag {
    UIView *taggedView = [view viewWithTag:tag];
    if ([taggedView isKindOfClass:[UISlider class]]) {
        return (UISlider *)taggedView;
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

- (void)fetchDrinkTypesWithCompletionBlock:(void (^)(NSArray * drinkTypes))completionBlock {
    NSArray *drinkTypes = [[SHSlidersSearchTableViewManager sh_sharedCache] objectForKey:DrinkTypesKey];
    if (drinkTypes.count && completionBlock) {
        completionBlock(drinkTypes);
    }
    
    // Gets drink form data (Beer, Wine and Cocktail)
    [DrinkModel getDrinks:@{kDrinkModelParamsPageSize:@0} success:^(NSArray *spotModels, JSONAPI *jsonApi) {
        NSDictionary *forms = [jsonApi objectForKey:@"form"];
        if (forms != nil) {
            NSArray *drinkTypes = [forms objectForKey:@"drink_types"];
            [[SHSlidersSearchTableViewManager sh_sharedCache] cacheDrinkTypes:drinkTypes];
            if (completionBlock) {
                completionBlock(drinkTypes);
            }
        }
    } failure:^(ErrorModel *errorModel) {
        [Tracker logError:errorModel class:[self class] trace:NSStringFromSelector(_cmd)];
        if (completionBlock) {
            completionBlock(nil);
        }
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
        completionBlock(sliderTemplates);
    }
    
    [SliderTemplateModel getSliderTemplates:nil success:^(NSArray *sliderTemplates, JSONAPI *jsonApi) {
        [[SHSlidersSearchTableViewManager sh_sharedCache] cacheSliderTemplates:sliderTemplates];
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
        
        // Filters by spot id
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
        if (!slider.sliderTemplate.required) {
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
}

// one the user completes the gesture this callback is fired
- (void)slider:(SHSlider *)slider valueDidFinishChanging:(CGFloat)value {
    NSLog(@"slider changed: %f", value);
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
