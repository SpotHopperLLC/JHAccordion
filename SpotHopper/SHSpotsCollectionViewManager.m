//
//  SHSpotsCollectionViewManager.m
//  SpotHopper
//
//  Created by Brennan Stehling on 5/16/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "SHSpotsCollectionViewManager.h"

#import "SpotListModel.h"
#import "SpotModel.h"
#import "SpotTypeModel.h"
#import "ImageModel.h"

#import "SHStyleKit+Additions.h"
#import "UIImageView+AFNetworking.h"
#import "ImageUtil.h"

#import "TellMeMyLocation.h"

#import "SHCollectionViewTableManager.h"

#import "Tracker.h"
#import "Tracker+Events.h"
#import "Tracker+People.h"

#import <CoreLocation/CoreLocation.h>

#define kMeterToMile 0.000621371f

#define kSpotCellIdentifier @"SpotCell"

#define kSpotCellSpotImageView 1
#define kSpotCellSpotNameLabel 2
#define kSpotCellSpotTypeLabel 3
#define kSpotCellNeighborhoodLabel 4
#define kSpotCellDistanceLabel 5
#define kSpotCellMatchPercentageImageView 6
#define kSpotCellPositionLabel 7
#define kSpotCellLeftButton 8
#define kSpotCellRightButton 9
#define kSpotCellPercentageLabel 10
#define kSpotCellMatchLabel 11
#define kSpotCellFindSimilarButton 12
#define kSpotCellReviewItButton 13
#define kSpotCellMenuButton 14

#define kSpotCellTableContainerView 600

#pragma mark - Class Extension
#pragma mark -

@interface SHSpotsCollectionViewManager () <SHCollectionViewTableManagerDelegate, UIGestureRecognizerDelegate, UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, weak) IBOutlet id<SHSpotsCollectionViewManagerDelegate> delegate;

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) UITableView *tableView;

@property (nonatomic, strong) SpotListModel *spotList;

@end

@implementation SHSpotsCollectionViewManager {
    BOOL _isUpdatingData;
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

- (NSUInteger)itemCount {
    return self.spotList.spots.count;
}

- (void)updateSpotList:(SpotListModel *)spotList {
    NSAssert(self.delegate, @"Delegate must be defined");

    static NSString *lock = @"LOCK";
    @synchronized(lock) {
        if (_isUpdatingData) {
            [self performSelector:@selector(updateSpotList:) withObject:spotList afterDelay:0.25];
        }
        else {
            _isUpdatingData = TRUE;
            self.spotList = spotList;
            [self.collectionView reloadData];
            self.collectionView.contentOffset = CGPointMake(0, 0);
            self.currentIndex = 0;
            _isUpdatingData = FALSE;
            
            [Tracker trackListViewDidDisplaySpot:[self spotAtIndex:self.currentIndex] position:self.currentIndex+1 isSpecials:FALSE];
            
            for (SpotModel *spot in spotList.spots) {
                [ImageUtil preloadImageModels:spot.images];
            }
        }
    }
}

- (void)changeIndex:(NSUInteger)index {
    if (index != self.currentIndex && index < self.spotList.spots.count) {
        self.currentIndex = index;
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.currentIndex inSection:0];
        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:TRUE];
        [self reportedChangedIndex];
    }
}

- (void)changeSpot:(SpotModel *)spot {
    NSUInteger index = [self.spotList.spots indexOfObject:spot];
    if (index != NSNotFound) {
        [self changeIndex:index];
    }
}

- (SpotModel *)spotAtIndex:(NSUInteger)index {
    if (index < self.spotList.spots.count) {
        SpotModel *spot = (SpotModel *)self.spotList.spots[index];
        return spot;
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
    return self.spotList.spots.count ? (indexPath.item > 0) : FALSE;
}

- (BOOL)hasNext {
    NSIndexPath *indexPath = [self indexPathForCurrentItemInCollectionView:self.collectionView];
    return self.spotList.spots.count ? (indexPath.item < self.spotList.spots.count - 1) : FALSE;
}

- (void)goPrevious {
    if ([self hasPrevious] && self.currentIndex > 0) {
        [self changeIndex:self.currentIndex - 1];
    }
}

- (void)goNext {
    if ([self hasNext]) {
        [self changeIndex:self.currentIndex+1];
    }
}

#pragma mark - SHCollectionViewTableManagerDelegate
#pragma mark -

- (void)collectionViewTableManagerShouldCollapse:(SHCollectionViewTableManager *)mgr {
    if ([self.delegate respondsToSelector:@selector(collectionViewManagerShouldCollapse:)]) {
        [self.delegate collectionViewManagerShouldCollapse:self];
    }
}

- (void)collectionViewTableManager:(SHCollectionViewTableManager *)mgr displaySpot:(SpotModel *)spot {
    if ([self.delegate respondsToSelector:@selector(spotsCollectionViewManager:displaySpot:)]) {
        [self.delegate spotsCollectionViewManager:self displaySpot:spot];
    }
}

#pragma mark - UICollectionViewDataSource
#pragma mark -

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.spotList.spots.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kSpotCellIdentifier forIndexPath:indexPath];
    
    UIView *selectedBackgroundView = [[UIView alloc] initWithFrame:CGRectZero];
    selectedBackgroundView.backgroundColor = [UIColor clearColor];
    cell.selectedBackgroundView = selectedBackgroundView;
    
    if (indexPath.item < self.spotList.spots.count) {
        SpotModel *spot = self.spotList.spots[indexPath.item];
        
        UIView *tableContainerView = [cell viewWithTag:kSpotCellTableContainerView];
        UITableView *tableView = nil;
        if (!tableContainerView.subviews.count) {
            tableView = [self embedTableViewInSuperView:tableContainerView];
        }
        else {
            tableView = (UITableView *)tableContainerView.subviews[0];
        }
        
        SHCollectionViewTableManager *tableManager = [[SHCollectionViewTableManager alloc] init];
        tableManager.delegate = self;
        [tableManager manageTableView:tableView forSpot:spot];
        [self addTableManager:tableManager forIndexPath:indexPath];
        
        [self renderCell:cell withSpot:spot atIndex:indexPath.item];
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
    
//    if ([self.delegate respondsToSelector:@selector(spotsCollectionViewManager:didSelectSpotAtIndex:)]) {
//        [self.delegate spotsCollectionViewManager:self didSelectSpotAtIndex:indexPath.item];
//    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(CGRectGetWidth(collectionView.frame), CGRectGetHeight(collectionView.frame));
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    [self removeTableManagerForIndexPath:indexPath];
}

#pragma mark - Base Overrides
#pragma mark -

- (void)renderCell:(UICollectionViewCell *)cell withSpot:(SpotModel *)spot atIndex:(NSUInteger)index {
    UIView *headerView = [cell viewWithTag:500];
    
    UIImageView *spotImageView = (UIImageView *)[headerView viewWithTag:kSpotCellSpotImageView];
    
    spotImageView.image = nil;
    ImageModel *highlightImage = spot.highlightImage;
    
    if (highlightImage) {
        __weak UIImageView *weakImageView = spotImageView;
        [ImageUtil loadImage:highlightImage placeholderImage:spot.placeholderImage withThumbImageBlock:^(UIImage *thumbImage) {
            weakImageView.image = thumbImage;
        } withFullImageBlock:^(UIImage *fullImage) {
            weakImageView.image = fullImage;
        } withErrorBlock:^(NSError *error) {
            weakImageView.image = spot.placeholderImage;
            [Tracker logError:error class:[self class] trace:NSStringFromSelector(_cmd)];
        }];
    }
    else {
        spotImageView.image = spot.placeholderImage;
    }
    
    UILabel *nameLabel = [self labelInView:headerView withTag:kSpotCellSpotNameLabel];
    UILabel *typeLabel = [self labelInView:headerView withTag:kSpotCellSpotTypeLabel];
    UILabel *neighborhoodLabel = [self labelInView:headerView withTag:kSpotCellNeighborhoodLabel];
    UILabel *distanceLabel = [self labelInView:headerView withTag:kSpotCellDistanceLabel];
    UIImageView *matchImageView = [self imageViewInView:headerView withTag:kSpotCellMatchPercentageImageView];
    UILabel *percentageLabel = [self labelInView:headerView withTag:kSpotCellPercentageLabel];
    UILabel *matchLabel = [self labelInView:headerView withTag:kSpotCellMatchLabel];
    
    NSAssert(nameLabel, @"View must be defined");
    NSAssert(typeLabel, @"View must be defined");
    NSAssert(neighborhoodLabel, @"View must be defined");
    NSAssert(distanceLabel, @"View must be defined");
    NSAssert(matchImageView, @"View must be defined");
    NSAssert(percentageLabel, @"View must be defined");
    NSAssert(matchLabel, @"View must be defined");
    
    [SHStyleKit setLabel:typeLabel textColor:SHStyleKitColorMyTextColor];
    [SHStyleKit setLabel:neighborhoodLabel textColor:SHStyleKitColorMyTextColor];
    [SHStyleKit setLabel:distanceLabel textColor:SHStyleKitColorMyTextColor];
    [SHStyleKit setLabel:percentageLabel textColor:SHStyleKitColorMyWhiteColor];
    [SHStyleKit setLabel:matchLabel textColor:SHStyleKitColorMyTintColor];
    
    [nameLabel setFont:[UIFont fontWithName:@"Lato-Bold" size:14.0f]];
    [typeLabel setFont:[UIFont fontWithName:@"Lato-Light" size:14.0f]];
    [neighborhoodLabel setFont:[UIFont fontWithName:@"Lato-Light" size:14.0f]];
    [distanceLabel setFont:[UIFont fontWithName:@"Lato-Light" size:14.0f]];
    [percentageLabel setFont:[UIFont fontWithName:@"Lato-Light" size:22.0f]];
    [matchLabel setFont:[UIFont fontWithName:@"Lato-Bold" size:14.0f]];
    
    nameLabel.text = spot.name;
    nameLabel.textColor = [SHStyleKit color:SHStyleKitColorMyTintColor];
    
    typeLabel.text = spot.spotType.name;
    neighborhoodLabel.text = spot.city;
    
    CLLocation *spotLocation = [[CLLocation alloc] initWithLatitude:[spot.latitude floatValue] longitude:[spot.longitude floatValue]];
    CLLocation *currentLocation = [TellMeMyLocation currentLocation];
    CLLocationDistance meters = [currentLocation distanceFromLocation:spotLocation];
    
    CGFloat miles = meters * kMeterToMile;
    
    distanceLabel.text = [NSString stringWithFormat:@"%0.1f miles away", miles];
    percentageLabel.text = [NSString stringWithFormat:@"%@", spot.matchPercent];
    
    if (self.spotList.spots.count == 1) {
        matchImageView.image = nil;
        
        percentageLabel.hidden = TRUE;
        matchLabel.hidden = TRUE;
    }
    else {
        UIImage *bubbleImage = [SHStyleKit drawImage:SHStyleKitDrawingMapBubblePinFilledIcon color:SHStyleKitColorNone size:CGSizeMake(60, 60)];
        matchImageView.image = bubbleImage;

        percentageLabel.hidden = FALSE;
        matchLabel.hidden = FALSE;
    }
}

#pragma mark - Private
#pragma mark -

- (void)reportedChangedIndex {
    [Tracker trackListViewDidDisplaySpot:[self spotAtIndex:self.currentIndex] position:self.currentIndex+1 isSpecials:FALSE];

    if ([self.delegate respondsToSelector:@selector(spotsCollectionViewManager:didChangeToSpotAtIndex:count:)]) {
        [self.delegate spotsCollectionViewManager:self didChangeToSpotAtIndex:self.currentIndex count:self.spotList.spots.count];
    }
}

@end
