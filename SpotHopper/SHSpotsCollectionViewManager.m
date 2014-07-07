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
#import "NetworkHelper.h"

#import "TellMeMyLocation.h"
#import "Tracker.h"

#import <CoreLocation/CoreLocation.h>

#define kMeterToMile 0.000621371f

#define kSpotCellIdentifier @"SpotCell"

#define kSpotCellSpotImageView 1
#define kSpotCellSpotNameButton 2
#define kSpotCellSpotTypeLabel 3
#define kSpotCellNeighborhoodLabel 4
#define kSpotCellDistanceLabel 5
#define kSpotCellMatchPercentageImageView 6
#define kSpotCellPositionLabel 7
#define kSpotCellLeftButton 8
#define kSpotCellRightButton 9
#define kSpotCellPercentageLabel 10
#define kSpotCellMatchLabel 11

#pragma mark - Class Extension
#pragma mark -

@interface SHSpotsCollectionViewManager ()

@property (nonatomic, weak) IBOutlet id<SHSpotsCollectionViewManagerDelegate> delegate;
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) SpotListModel *spotList;

@end

@implementation SHSpotsCollectionViewManager {
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

- (void)updateSpotList:(SpotListModel *)spotList {
    NSAssert(self.delegate, @"Delegate must be defined");

    static NSString *lock;
    @synchronized(lock) {
        if (_isUpdatingData) {
            [self performSelector:@selector(updateSpotList:) withObject:spotList afterDelay:0.25];
        }
        else {
            _isUpdatingData = TRUE;
            self.spotList = spotList;
            [self.collectionView reloadData];
            [self.collectionView setContentOffset:CGPointMake(0, 0)];
            _currentIndex = 0;
            _isUpdatingData = FALSE;
        }
    }
}

- (void)changeIndex:(NSUInteger)index {
    if (index != _currentIndex && index < self.spotList.spots.count) {
        NSLog(@"Manager - Changing to index: %lu", (long)index);
        _currentIndex = index;
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:_currentIndex inSection:0];
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
    if ([self hasPrevious] && _currentIndex > 0) {
        [self changeIndex:_currentIndex - 1];
    }
}

- (void)goNext {
    if ([self hasNext]) {
        [self changeIndex:_currentIndex+1];
    }
}

#pragma mark - UICollectionViewDataSource
#pragma mark -

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.spotList.spots.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kSpotCellIdentifier forIndexPath:indexPath];
    if (indexPath.item < self.spotList.spots.count) {
        SpotModel *spot = self.spotList.spots[indexPath.item];
        [self renderCell:cell withSpot:spot atIndex:indexPath.item];
    }
    
    return cell;
}

#pragma mark - UICollectionViewDelegate
#pragma mark -

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Selected item %lu", (long)indexPath.item);
    
    if ([self.delegate respondsToSelector:@selector(spotsCollectionViewManager:didSelectSpotAtIndex:)]) {
        [self.delegate spotsCollectionViewManager:self didSelectSpotAtIndex:indexPath.item];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == self.collectionView) {
        NSIndexPath *indexPath = [self indexPathForCurrentItemInCollectionView:self.collectionView];
        if (indexPath.item != _currentIndex) {
            _currentIndex = indexPath.item;
            [self reportedChangedIndex];
        }
    }
}

#pragma mark - Base Overrides
#pragma mark -

- (void)renderCell:(UICollectionViewCell *)cell withSpot:(SpotModel *)spot atIndex:(NSUInteger)index {
    UIImageView *spotImageView = (UIImageView *)[cell viewWithTag:kSpotCellSpotImageView];
    UIImage *placeholderImage = [SHStyleKit drawImage:SHStyleKitDrawingPlaceholderBasic size:spotImageView.frame.size];
    spotImageView.image = placeholderImage;
    
    if (spot.imageUrl.length) {
        [spotImageView setImageWithURL:[NSURL URLWithString:spot.imageUrl] placeholderImage:nil];
    }
    else if (spot.images.count) {
        ImageModel *imageModel = spot.images[0];
        [NetworkHelper loadImage:imageModel placeholderImage:nil withThumbImageBlock:^(UIImage *thumbImage) {
            spotImageView.image = thumbImage;
        } withFullImageBlock:^(UIImage *fullImage) {
            spotImageView.image = fullImage;
        } withErrorBlock:^(NSError *error) {
            spotImageView.image = nil;
            [Tracker logError:error class:[self class] trace:NSStringFromSelector(_cmd)];
        }];
    }
    
    UIButton *nameButton = [self buttonInView:cell withTag:kSpotCellSpotNameButton];
    UILabel *typeLabel = [self labelInView:cell withTag:kSpotCellSpotTypeLabel];
    UILabel *neighborhoodLabel = [self labelInView:cell withTag:kSpotCellNeighborhoodLabel];
    UILabel *distanceLabel = [self labelInView:cell withTag:kSpotCellDistanceLabel];
    UILabel *positionLabel = [self labelInView:cell withTag:kSpotCellPositionLabel];
    UIImageView *matchImageView = [self imageViewInView:cell withTag:kSpotCellMatchPercentageImageView];
    UILabel *percentageLabel = [self labelInView:cell withTag:kSpotCellPercentageLabel];
    UILabel *matchLabel = [self labelInView:cell withTag:kSpotCellMatchLabel];
    
    NSAssert(nameButton, @"View must be defined");
    NSAssert(typeLabel, @"View must be defined");
    NSAssert(neighborhoodLabel, @"View must be defined");
    NSAssert(distanceLabel, @"View must be defined");
    NSAssert(positionLabel, @"View must be defined");
    NSAssert(matchImageView, @"View must be defined");
    NSAssert(percentageLabel, @"View must be defined");
    NSAssert(matchLabel, @"View must be defined");
    
    [SHStyleKit setLabel:typeLabel textColor:SHStyleKitColorMyTextColor];
    [SHStyleKit setLabel:neighborhoodLabel textColor:SHStyleKitColorMyTextColor];
    [SHStyleKit setLabel:distanceLabel textColor:SHStyleKitColorMyTextColor];
    [SHStyleKit setLabel:positionLabel textColor:SHStyleKitColorMyTextColor];
    [SHStyleKit setLabel:percentageLabel textColor:SHStyleKitColorMyWhiteColor];
    [SHStyleKit setLabel:matchLabel textColor:SHStyleKitColorMyTintColor];
    
    [typeLabel setFont:[UIFont fontWithName:@"Lato-Light" size:14.0f]];
    [neighborhoodLabel setFont:[UIFont fontWithName:@"Lato-Light" size:14.0f]];
    [distanceLabel setFont:[UIFont fontWithName:@"Lato-Light" size:14.0f]];
    [positionLabel setFont:[UIFont fontWithName:@"Lato-Light" size:14.0f]];
    [percentageLabel setFont:[UIFont fontWithName:@"Lato-Light" size:22.0f]];
    [matchLabel setFont:[UIFont fontWithName:@"Lato-Bold" size:14.0f]];
    
    [nameButton setTitle:spot.name forState:UIControlStateNormal];
    nameButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    nameButton.titleLabel.textAlignment = NSTextAlignmentLeft;
    [SHStyleKit setButton:nameButton normalTextColor:SHStyleKitColorMyTintColor highlightedTextColor:SHStyleKitColorMyTextColor];
    typeLabel.text = spot.spotType.name;
    neighborhoodLabel.text = spot.city;
    
    CLLocation *spotLocation = [[CLLocation alloc] initWithLatitude:[spot.latitude floatValue] longitude:[spot.longitude floatValue]];
    CLLocation *currentLocation = [TellMeMyLocation currentDeviceLocation];
    CLLocationDistance meters = [currentLocation distanceFromLocation:spotLocation];
    
    CGFloat miles = meters * kMeterToMile;
    
    distanceLabel.text = [NSString stringWithFormat:@"%0.1f miles away", miles];
    positionLabel.text = [NSString stringWithFormat:@"%lu of %lu", (long)index+1, (long)self.spotList.spots.count];
    percentageLabel.text = [NSString stringWithFormat:@"%@", spot.matchPercent];
    
    UIImage *bubbleImage = [SHStyleKit drawImage:SHStyleKitDrawingMapBubblePinFilledIcon color:SHStyleKitColorNone size:CGSizeMake(60, 60)];
    matchImageView.image = bubbleImage;
    
    UIButton *previousButton = [self buttonInView:cell withTag:kSpotCellLeftButton];
    [SHStyleKit setButton:previousButton withDrawing:SHStyleKitDrawingArrowLeftIcon normalColor:SHStyleKitColorMyTextColor highlightedColor:SHStyleKitColorMyWhiteColor];
    previousButton.hidden = index == 0;
    
    UIButton *nextButton = [self buttonInView:cell withTag:kSpotCellRightButton];
    [SHStyleKit setButton:nextButton withDrawing:SHStyleKitDrawingArrowRightIcon normalColor:SHStyleKitColorMyTextColor highlightedColor:SHStyleKitColorMyWhiteColor];
    nextButton.hidden = index == self.spotList.spots.count - 1;
}

#pragma mark - Private
#pragma mark -

- (void)reportedChangedIndex {
    if ([self.delegate respondsToSelector:@selector(spotsCollectionViewManager:didChangeToSpotAtIndex:)]) {
        [self.delegate spotsCollectionViewManager:self didChangeToSpotAtIndex:_currentIndex];
    }
}

@end
