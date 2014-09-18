//
//  SHCollectionViewTableManager.m
//  SpotHopper
//
//  Created by Brennan Stehling on 9/17/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "SHCollectionViewTableManager.h"

#import "SpotModel.h"
#import "DrinkModel.h"
#import "AverageReviewModel.h"
#import "SliderModel.h"
#import "SliderTemplateModel.h"

#import "SHStyleKit+Additions.h"
#import "Tracker.h"

#define kRowNameSummarySliders @"Summary Sliders"
#define kRowNameDescription @"Description"
#define kRowNameHoursAndPhone @"Hours and Phone"
#define kRowNameHappyHour @"Happy Hour"
#define kRowNameDrinkSummary @"Drink Summary"
#define kRowNameHighestRated @"Highest Rated"

typedef enum {
    Special,
    Spot,
    Drink,
} TableManagerMode;

#pragma mark - Class Extension
#pragma mark -

@interface SHCollectionViewTableManager () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, assign) TableManagerMode mode;
@property (nonatomic, strong) SpotModel *spot;
@property (nonatomic, strong) DrinkModel *drink;

@property (nonatomic, strong) NSArray *summarySliders;
@property (nonatomic, strong) NSMutableArray *rows;

@end

@implementation SHCollectionViewTableManager

- (void)manageTableView:(UITableView *)tableView forTodaysSpecialAtSpot:(SpotModel *)spot {
    NSAssert(tableView, @"Table View is required");
    NSAssert(self.delegate, @"Delegate is required");
    self.mode = Special;
    tableView.dataSource = self;
    tableView.delegate = self;
    self.rows = @[].mutableCopy;
    
    self.tableView = tableView;
    
    [spot fetchSpot:^(SpotModel *spotModel) {
        self.spot = spotModel;
        [tableView reloadData];
    } failure:^(ErrorModel *errorModel) {
        [Tracker logError:errorModel class:[self class] trace:NSStringFromSelector(_cmd)];
    }];
}

- (void)manageTableView:(UITableView *)tableView forSpot:(SpotModel *)spot {
    NSAssert(tableView, @"Table View is required");
    NSAssert(self.delegate, @"Delegate is required");
    self.mode = Spot;
    tableView.dataSource = self;
    tableView.delegate = self;
    self.rows = @[].mutableCopy;
    
    self.tableView = tableView;
    
    [spot fetchSpot:^(SpotModel *spotModel) {
        self.spot = spotModel;
        NSAssert(self.spot.averageReview.sliders.count, @"Sliders are required");
        self.summarySliders = [self extractSummarySliders:self.spot.averageReview.sliders];
        
        if (self.summarySliders.count) {
            [self.rows addObject:kRowNameSummarySliders];
        }
        
        self.spot.descriptionText = @"Testing Description";
        
        if (self.spot.descriptionText.length) {
            [self.rows addObject:kRowNameDescription];
        }
        
        [tableView reloadData];
    } failure:^(ErrorModel *errorModel) {
        [Tracker logError:errorModel class:[self class] trace:NSStringFromSelector(_cmd)];
    }];
}

- (void)manageTableView:(UITableView *)tableView forDrink:(DrinkModel *)drink {
    NSAssert(tableView, @"Table View is required");
    NSAssert(self.delegate, @"Delegate is required");
    self.mode = Drink;
    tableView.dataSource = self;
    tableView.delegate = self;
    self.rows = @[].mutableCopy;
    
    self.tableView = tableView;
    
    [drink fetchDrink:^(DrinkModel *drinkModel) {
        self.drink = drinkModel;
        NSAssert(self.drink.averageReview.sliders.count, @"Sliders are required");
        self.summarySliders = [self extractSummarySliders:self.drink.averageReview.sliders];
        [tableView reloadData];
    } failure:^(ErrorModel *errorModel) {
        [Tracker logError:errorModel class:[self class] trace:NSStringFromSelector(_cmd)];
    }];
}

#pragma mark - Private
#pragma mark -

- (NSArray *)extractSummarySliders:(NSArray *)allSliders {
    NSArray *sorted = [allSliders sortedArrayUsingComparator:^NSComparisonResult(SliderModel *slider1, SliderModel *slider2) {
        return [slider1 compare:slider2];
    }];
    
    // limit to 3
    if (sorted.count > 3) {
        sorted = [sorted subarrayWithRange:NSMakeRange(0, 3)];
    }
    
    return sorted;
}

- (NSString *)nameForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.rows.count) {
        return self.rows[indexPath.row];
    }
    
    return nil;
}

#pragma mark - User Actions
#pragma mark -

- (IBAction)detailButtonTapped:(id)sender {
    DebugLog(@"%@", NSStringFromSelector(_cmd));
    
    if (self.spot) {
        if ([self.delegate respondsToSelector:@selector(collectionViewTableManager:displaySpot:)]) {
            [self.delegate collectionViewTableManager:self displaySpot:self.spot];
        }
    }
    else if (self.drink) {
        if ([self.delegate respondsToSelector:@selector(collectionViewTableManager:displayDrink:)]) {
            [self.delegate collectionViewTableManager:self displayDrink:self.drink];
        }
    }
}

#pragma mark - Rendering Cells
#pragma mark -

- (UITableViewCell *)renderCellForSummarySliders:(NSArray *)summarySliders atIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"SummarySlidersCell" forIndexPath:indexPath];

    UILabel *leftLabel1 = (UILabel *)[cell viewWithTag:101];
    UILabel *leftLabel2 = (UILabel *)[cell viewWithTag:201];
    UILabel *leftLabel3 = (UILabel *)[cell viewWithTag:301];

    UILabel *rightLabel1 = (UILabel *)[cell viewWithTag:102];
    UILabel *rightLabel2 = (UILabel *)[cell viewWithTag:202];
    UILabel *rightLabel3 = (UILabel *)[cell viewWithTag:302];
    
    UIImageView *imageView1 = (UIImageView *)[cell viewWithTag:103];
    UIImageView *imageView2 = (UIImageView *)[cell viewWithTag:203];
    UIImageView *imageView3 = (UIImageView *)[cell viewWithTag:303];

    UIButton *detailButton = (UIButton *)[cell viewWithTag:4];
    [SHStyleKit setButton:detailButton normalTextColor:SHStyleKitColorMyTintColor highlightedTextColor:SHStyleKitColorMyTintTransparentColor];
    [detailButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [detailButton addTarget:self action:@selector(detailButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    CGSize size = CGSizeMake(60, 60);
    
    if (summarySliders.count > 0) {
        SliderModel *slider = summarySliders[0];
        CGFloat position = slider.value.floatValue/10;
        leftLabel1.text = slider.sliderTemplate.minLabelShortDisplayed;
        rightLabel1.text = slider.sliderTemplate.maxLabelShortDisplayed;
        imageView1.image = [SHStyleKit drawImage:SHStyleKitDrawingSwooshDial color:SHStyleKitColorMyTintColor size:size position:position];
    }
    else {
        leftLabel1.text = nil;
        rightLabel1.text = nil;
        imageView1.image = nil;
    }
    
    if (summarySliders.count > 1) {
        SliderModel *slider = summarySliders[1];
        CGFloat position = slider.value.floatValue/10;
        leftLabel2.text = slider.sliderTemplate.minLabelShortDisplayed;
        rightLabel2.text = slider.sliderTemplate.maxLabelShortDisplayed;
        imageView2.image = [SHStyleKit drawImage:SHStyleKitDrawingSwooshDial color:SHStyleKitColorMyTintColor size:size position:position];
    }
    else {
        leftLabel2.text = nil;
        rightLabel2.text = nil;
        imageView2.image = nil;
    }

    if (summarySliders.count > 2) {
        SliderModel *slider = summarySliders[2];
        CGFloat position = slider.value.floatValue/10;
        leftLabel3.text = slider.sliderTemplate.minLabelShortDisplayed;
        rightLabel3.text = slider.sliderTemplate.maxLabelShortDisplayed;
        imageView3.image = [SHStyleKit drawImage:SHStyleKitDrawingSwooshDial color:SHStyleKitColorMyTintColor size:size position:position];
    }
    else {
        leftLabel3.text = nil;
        rightLabel3.text = nil;
        imageView3.image = nil;
    }

    return cell;
}

- (UITableViewCell *)renderCellForDescription:(NSString *)description atIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"DescriptionCell" forIndexPath:indexPath];

    UILabel *descriptionLabel = (UILabel *)[cell viewWithTag:1];
    [descriptionLabel setFont:[UIFont fontWithName:@"Lato-Light" size:descriptionLabel.font.pointSize]];
    descriptionLabel.text = description;
    
    return cell;
}

#pragma mark - UITableViewDataSource
#pragma mark -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.rows.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = nil;
    
    NSString *rowName = [self nameForRowAtIndexPath:indexPath];
    
    if (self.mode == Special) {
        NSAssert(FALSE, @"Not Supported");
    }
    else if (self.mode == Spot) {
        if ([rowName isEqualToString:kRowNameSummarySliders]) {
            cell = [self renderCellForSummarySliders:self.summarySliders atIndexPath:indexPath];
        }
        else if ([rowName isEqualToString:kRowNameDescription]) {
            cell = [self renderCellForDescription:self.spot.descriptionText atIndexPath:indexPath];
        }
    }
    else if (self.mode == Drink) {
        if ([rowName isEqualToString:kRowNameSummarySliders]) {
            cell = [self renderCellForSummarySliders:self.summarySliders atIndexPath:indexPath];
        }
        else if ([rowName isEqualToString:kRowNameDescription]) {
            cell = [self renderCellForDescription:self.drink.descriptionText atIndexPath:indexPath];
        }
    }

    if (!cell) {
        DebugLog(@"Index Path: %lu, %lu", (unsigned long)indexPath.section, (unsigned long)indexPath.row);
        NSAssert(FALSE, @"Cell must be defined");
    }
    
    UIView *selectedBackgroundView = [[UIView alloc] initWithFrame:CGRectZero];
    selectedBackgroundView.backgroundColor = [UIColor clearColor];
    cell.selectedBackgroundView = selectedBackgroundView;
    
    return cell;
}

#pragma mark - UITableViewDelegate
#pragma mark -

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return 70.0f;
    }
    else {
        return 44.0f;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.25f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [tableView deselectRowAtIndexPath:indexPath animated:TRUE];
    });
}

#pragma mark - UIScrollViewDelegate
#pragma mark -

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.tableView) {
        // if value is < -50 then trigger view to collapse view
        if (scrollView.contentOffset.y < -50.0f) {
            if ([self.delegate respondsToSelector:@selector(collectionViewTableManagerShouldCollapse:)]) {
                [self.delegate collectionViewTableManagerShouldCollapse:self];
            }
        }
    }
}

@end
