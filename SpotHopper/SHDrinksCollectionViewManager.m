//
//  SHDrinksCollectionViewManager.m
//  SpotHopper
//
//  Created by Brennan Stehling on 6/2/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "SHDrinksCollectionViewManager.h"

#import "DrinkListModel.h"
#import "DrinkModel.h"
#import "DrinkSubTypeModel.h"
#import "ImageModel.h"
#import "SpotModel.h"
#import "BaseAlcoholModel.h"
#import "AverageReviewModel.h"

#import "SHCollectionViewTableManager.h"

#import "SHRatingStarsView.h"
#import "SHStyleKit+Additions.h"
#import "UIImageView+AFNetworking.h"
#import "NetworkHelper.h"

#import "TellMeMyLocation.h"

#import "Tracker.h"
#import "Tracker+Events.h"
#import "Tracker+People.h"

#import <CoreLocation/CoreLocation.h>

#define kMeterToMile 0.000621371f

#define kDrinkCellIdentifier @"DrinkCell"

#define kDrinkCellDrinkImageView 1
#define kDrinkCellDrinkNameLabel 2
#define kDrinkCellBreweryLabel 3
#define kDrinkCellStyleLabel 4
#define kDrinkCellRatingView 5
#define kDrinkCellMatchPercentageImageView 6
#define kDrinkCellMatchPercentageLabel 7
#define kDrinkCellMatchLabel 8
#define kDrinkCellFindSimilarButton 12
#define kDrinkCellReviewItButton 13

#define kDrinkCellTableContainerView 600

#pragma mark - Class Extension
#pragma mark -

@interface SHDrinksCollectionViewManager () <SHCollectionViewTableManagerDelegate, UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, weak) IBOutlet id<SHDrinksCollectionViewManagerDelegate> delegate;

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, strong) DrinkListModel *drinkList;

@end

@implementation SHDrinksCollectionViewManager {
    BOOL _isUpdatingData;
    NSUInteger _currentIndex;
}

#pragma mark - Initialization
#pragma mark -

- (instancetype)init {
    self = [super init];
    if (self) {
        _isUpdatingData = FALSE;
    }
    return self;
}

#pragma mark - Public
#pragma mark -

- (void)updateDrinkList:(DrinkListModel *)drinkList {
    NSAssert(self.delegate, @"Delegate must be defined");
    
    static NSString *lock;
    @synchronized(lock) {
        if (_isUpdatingData) {
            [self performSelector:@selector(updateDrinkList:) withObject:drinkList afterDelay:0.25];
        }
        else {
            _isUpdatingData = TRUE;
            self.drinkList = drinkList;
            [self.collectionView setContentOffset:CGPointMake(0, 0)];
            [self.collectionView reloadData];
            _currentIndex = 0;
            _isUpdatingData = FALSE;
            [Tracker trackListViewDidDisplayDrink:[self drinkAtIndex:_currentIndex] position:_currentIndex+1];
        }
    }
}

- (void)changeIndex:(NSUInteger)index {
    if (index != _currentIndex && index < self.drinkList.drinks.count) {
        _currentIndex = index;
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:_currentIndex inSection:0];
        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:TRUE];
        [self reportedChangedIndex];
    }
}

- (void)changeDrink:(DrinkModel *)drink {
    NSUInteger index = [self.drinkList.drinks indexOfObject:drink];
    if (index != NSNotFound) {
        [self changeIndex:index];
    }
}

- (DrinkModel *)drinkAtIndex:(NSUInteger)index {
    if (index < self.drinkList.drinks.count) {
        DrinkModel *drink = (DrinkModel *)self.drinkList.drinks[index];
        return drink;
    }
    
    return nil;
}

- (NSUInteger)indexForViewInCollectionViewCell:(UIView *)view {
    NSUInteger index = NSNotFound;
    
    while (![view isKindOfClass:[UICollectionViewCell class]] && view.superview) {
        view = view.superview;
    }
    
    if ([view isKindOfClass:[UICollectionViewCell class]]) {
        UICollectionViewCell *cell = (UICollectionViewCell *)view;
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
        if (indexPath) {
            index = indexPath.item;
        }
    }
    
    return index;
}

- (BOOL)hasPrevious {
    NSIndexPath *indexPath = [self indexPathForCurrentItemInCollectionView:self.collectionView];
    return self.drinkList.drinks.count ? (indexPath.item > 0) : FALSE;
}

- (BOOL)hasNext {
    NSIndexPath *indexPath = [self indexPathForCurrentItemInCollectionView:self.collectionView];
    return self.drinkList.drinks.count ? (indexPath.item < self.drinkList.drinks.count - 1) : FALSE;
}

- (void)goPrevious {
    if ([self hasPrevious] && _currentIndex > 0) {
        [self changeIndex:_currentIndex - 1];
    }
}

- (void)goNext {
    if ([self hasNext]) {
        [self changeIndex:_currentIndex+1];
    }
}

#pragma mark - SHCollectionViewTableManagerDelegate
#pragma mark -

- (void)collectionViewTableManagerShouldCollapse:(SHCollectionViewTableManager *)mgr {
    if ([self.delegate respondsToSelector:@selector(collectionViewManagerShouldCollapse:)]) {
        [self.delegate collectionViewManagerShouldCollapse:self];
    }
}

- (void)collectionViewTableManager:(SHCollectionViewTableManager *)mgr displayDrink:(DrinkModel *)drink {
    if ([self.delegate respondsToSelector:@selector(drinksCollectionViewManager:displayDrink:)]) {
        [self.delegate drinksCollectionViewManager:self displayDrink:drink];
    }
}

#pragma mark - UICollectionViewDataSource
#pragma mark -

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.drinkList.drinks.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kDrinkCellIdentifier forIndexPath:indexPath];
    
    UIView *selectedBackgroundView = [[UIView alloc] initWithFrame:CGRectZero];
    selectedBackgroundView.backgroundColor = [UIColor clearColor];
    cell.selectedBackgroundView = selectedBackgroundView;
    
    if (indexPath.item < self.drinkList.drinks.count) {
        DrinkModel *drink = self.drinkList.drinks[indexPath.item];
        
        UIView *tableContainerView = [cell viewWithTag:kDrinkCellTableContainerView];
        UITableView *tableView = nil;
        if (!tableContainerView.subviews.count) {
            tableView = [self embedTableViewInSuperView:tableContainerView];
        }
        else {
            tableView = (UITableView *)tableContainerView.subviews[0];
        }
        
        SHCollectionViewTableManager *tableManager = [[SHCollectionViewTableManager alloc] init];
        tableManager.delegate = self;
        [tableManager manageTableView:tableView forDrink:drink];
        [self addTableManager:tableManager forIndexPath:indexPath];
        
        [self renderCell:cell withDrink:drink atIndex:indexPath.item];
    }
    
    [self attachedPanGestureToCell:cell];
    
    return cell;
}

#pragma mark - UICollectionViewDelegate
#pragma mark -

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(collectionViewManagerDidTapHeader:)]) {
        [self.delegate collectionViewManagerDidTapHeader:self];
    }
    
//    if ([self.delegate respondsToSelector:@selector(drinksCollectionViewManager:didSelectDrinkAtIndex:)]) {
//        [self.delegate drinksCollectionViewManager:self didSelectDrinkAtIndex:indexPath.item];
//    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    [self removeTableManagerForIndexPath:indexPath];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    LOG_FRAME(@"collection view", collectionView.frame);
    return CGSizeMake(CGRectGetWidth(collectionView.frame), CGRectGetHeight(collectionView.frame));
}

#pragma mark - UIScrollViewDelegate
#pragma mark -

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == self.collectionView) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            NSIndexPath *indexPath = [self indexPathForCurrentItemInCollectionView:self.collectionView];
            if (indexPath.item != _currentIndex) {
                _currentIndex = indexPath.item;
                [self reportedChangedIndex];
            }
        });
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    // if the velocity is "slow" it should just go the next cell, otherwise let it go to the next paged position
    // positive x is moving right, negative x is moving left
    // slow is < 0.75
    
    CGFloat width = CGRectGetWidth(self.collectionView.frame);
    NSUInteger currentIndex = MAX(MIN(round(self.collectionView.contentOffset.x / CGRectGetWidth(self.collectionView.frame)), self.drinkList.drinks.count - 1), 0);
    
    if (fabsf(velocity.x) > 2.0) {
        CGFloat x = targetContentOffset->x;
        x = roundf(x / width) * width;
        targetContentOffset->x = x;
    }
    else {
        NSUInteger targetIndex = velocity.x > 0.0 ? MIN(currentIndex + 1, self.drinkList.drinks.count - 1) : MAX(currentIndex - 1, 0);
        targetContentOffset->x = targetIndex * width;
    }
}

#pragma mark - Base Overrides
#pragma mark -

- (void)renderCell:(UICollectionViewCell *)cell withDrink:(DrinkModel *)drink atIndex:(NSUInteger)index {
    UIView *headerView = [cell viewWithTag:500];
    
    UIImageView *drinkImageView = [self imageViewInView:headerView withTag:kDrinkCellDrinkImageView];
    UILabel *nameLabel = [self labelInView:headerView withTag:kDrinkCellDrinkNameLabel];
    UILabel *breweryLabel = [self labelInView:headerView withTag:kDrinkCellBreweryLabel];
    UILabel *styleLabel = [self labelInView:headerView withTag:kDrinkCellStyleLabel];
    UIImageView *matchImageView = [self imageViewInView:headerView withTag:kDrinkCellMatchPercentageImageView];
    UILabel *percentageLabel = [self labelInView:headerView withTag:kDrinkCellMatchPercentageLabel];
    UILabel *matchLabel = [self labelInView:headerView withTag:kDrinkCellMatchLabel];
    
    SHRatingStarsView *ratingView = (SHRatingStarsView *)[headerView viewWithTag:kDrinkCellRatingView];
    
    NSAssert(drinkImageView, @"View must be defined");
    NSAssert(nameLabel, @"View must be defined");
    NSAssert(breweryLabel, @"View must be defined");
    NSAssert(styleLabel, @"View must be defined");
    NSAssert(percentageLabel, @"View must be defined");
    NSAssert(matchLabel, @"View must be defined");
    NSAssert(ratingView, @"View must be defined");
    
    [SHStyleKit setLabel:nameLabel textColor:SHStyleKitColorMyTintColor];
    [SHStyleKit setLabel:breweryLabel textColor:SHStyleKitColorMyTextColor];
    [SHStyleKit setLabel:styleLabel textColor:SHStyleKitColorMyTextColor];
    [SHStyleKit setLabel:matchLabel textColor:SHStyleKitColorMyTintColor];
    
    [nameLabel setFont:[UIFont fontWithName:@"Lato-Bold" size:14.0f]];
    [breweryLabel setFont:[UIFont fontWithName:@"Lato-Light" size:14.0f]];
    [styleLabel setFont:[UIFont fontWithName:@"Lato-Light" size:14.0f]];
    [matchLabel setFont:[UIFont fontWithName:@"Lato-Light" size:14.0f]];
    
    drinkImageView.image = nil;
    ImageModel *highlightImage = drink.highlightImage;
    
    if (highlightImage) {
        __weak UIImageView *weakImageView = drinkImageView;
        [NetworkHelper loadImage:highlightImage placeholderImage:drink.placeholderImage withThumbImageBlock:^(UIImage *thumbImage) {
            weakImageView.image = thumbImage;
        } withFullImageBlock:^(UIImage *fullImage) {
            weakImageView.image = fullImage;
        } withErrorBlock:^(NSError *error) {
            weakImageView.image = drink.placeholderImage;
            [Tracker logError:error class:[self class] trace:NSStringFromSelector(_cmd)];
        }];
    }
    else {
        drinkImageView.image = drink.placeholderImage;
    }
   
    nameLabel.text = drink.name;
    breweryLabel.text = drink.spot.name;
    styleLabel.text = drink.drinkStyle;

    ratingView.rating = drink.averageReview.rating.floatValue;
    
    if (drink.matchPercent.length) {
        percentageLabel.hidden = FALSE;
        matchLabel.hidden = FALSE;
        percentageLabel.text = [NSString stringWithFormat:@"%@", drink.matchPercent];
        UIImage *bubbleImage = [SHStyleKit drawImage:SHStyleKitDrawingMapBubblePinFilledIcon color:SHStyleKitColorNone size:CGSizeMake(60, 60)];
        matchImageView.image = bubbleImage;
    }
    else {
        percentageLabel.hidden = TRUE;
        matchLabel.hidden = TRUE;
        matchImageView.image = nil;
    }
}

#pragma mark - Private
#pragma mark -

- (void)reportedChangedIndex {
    [Tracker trackListViewDidDisplayDrink:[self drinkAtIndex:_currentIndex] position:_currentIndex+1];
    
    if ([self.delegate respondsToSelector:@selector(drinksCollectionViewManager:didChangeToDrinkAtIndex:count:)]) {
        [self.delegate drinksCollectionViewManager:self didChangeToDrinkAtIndex:_currentIndex count:self.drinkList.drinks.count];
    }
}

@end
