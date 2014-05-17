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

@interface SHSpotsCollectionViewManager () <UICollectionViewDataSource, UICollectionViewDelegate>

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
    // TODO: implement by carefully updating when the collection view if not already updating

    static NSString *lock;
    @synchronized(lock) {
        if (_isUpdatingData) {
            [self performSelector:@selector(updateSpotList:) withObject:spotList afterDelay:0.25];
        }
        else {
            _isUpdatingData = TRUE;
            self.spotList = spotList;
            [self.collectionView reloadData];
            _isUpdatingData = FALSE;
        }
    }
}

- (void)changeIndex:(NSUInteger)index {
    // TODO: change collection view position if the index is in bounds and set _currentIndex
    
    if (index != _currentIndex) {
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
    NSIndexPath *indexPath = [self indexPathForCurrentItem];
    return self.spotList.spots.count ? (indexPath.item > 0) : FALSE;
}

- (BOOL)hasNext {
    NSIndexPath *indexPath = [self indexPathForCurrentItem];
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

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    // dequeue named cell template
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kSpotCellIdentifier forIndexPath:indexPath];
    
    if (indexPath.item < self.spotList.spots.count) {
        SpotModel *spot = self.spotList.spots[indexPath.item];
        
        UIImageView *spotImageView = (UIImageView *)[cell viewWithTag:kSpotCellSpotImageView];
        
        NSLog(@"spot.imageUrl: %@", spot.imageUrl);
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
                [Tracker logError:error.description class:[self class] trace:NSStringFromSelector(_cmd)];
            }];
        }
        else {
            spotImageView.image = nil;
        }
        
        UIButton *nameButton = [self buttonInView:cell withTag:kSpotCellSpotNameButton];
        UILabel *typeLabel = [self labelInView:cell withTag:kSpotCellSpotTypeLabel];
        UILabel *neighborhoodLabel = [self labelInView:cell withTag:kSpotCellNeighborhoodLabel];
        UILabel *distanceLabel = [self labelInView:cell withTag:kSpotCellDistanceLabel];
        UILabel *positionLabel = [self labelInView:cell withTag:kSpotCellPositionLabel];
        UIImageView *matchImageView = [self imageViewInView:cell withTag:kSpotCellMatchPercentageImageView];
        UILabel *percentageLabel = [self labelInView:cell withTag:kSpotCellPercentageLabel];
        UILabel *matchLabel = [self labelInView:cell withTag:kSpotCellMatchLabel];
        
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
        [nameButton setTitleColor:[SHStyleKit myTextColor] forState:UIControlStateNormal];
        typeLabel.text = spot.spotType.name;
        neighborhoodLabel.text = spot.city;
        
        CLLocation *spotLocation = [[CLLocation alloc] initWithLatitude:[spot.latitude floatValue] longitude:[spot.longitude floatValue]];
        CLLocation *currentLocation = [TellMeMyLocation currentDeviceLocation];
        CLLocationDistance meters = [currentLocation distanceFromLocation:spotLocation];
        CGFloat miles = meters/1609.344;
        
        distanceLabel.text = [NSString stringWithFormat:@"%0.1f miles away", miles];
        positionLabel.text = [NSString stringWithFormat:@"%lu of %lu", indexPath.item+1, self.spotList.spots.count];
        percentageLabel.text = [NSString stringWithFormat:@"%@", spot.matchPercent];
        
        UIImage *bubbleImage = [SHStyleKit drawImage:SHStyleKitDrawingMapBubblePinFilledIcon color:SHStyleKitColorMyWhiteColor size:CGSizeMake(60, 60)];
        matchImageView.image = bubbleImage;
        
        UIButton *previousButton = [self buttonInView:cell withTag:kSpotCellLeftButton];
        [SHStyleKit setButton:previousButton withDrawing:SHStyleKitDrawingPreviousArrowIcon normalColor:SHStyleKitColorMyTintColor highlightedColor:SHStyleKitColorMyTextColor];
        previousButton.hidden = indexPath.item == 0;
    
        UIButton *nextButton = [self buttonInView:cell withTag:kSpotCellRightButton];
        [SHStyleKit setButton:nextButton withDrawing:SHStyleKitDrawingNextArrowIcon normalColor:SHStyleKitColorMyTintColor highlightedColor:SHStyleKitColorMyTextColor];
        nextButton.hidden = indexPath.item == self.spotList.spots.count - 1;
    }
    
    return cell;
}

#pragma mark - UICollectionViewDelegate
#pragma mark -

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Selected item!");
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == self.collectionView) {
        NSIndexPath *indexPath = [self indexPathForCurrentItem];
        if (indexPath.item != _currentIndex) {
            _currentIndex = indexPath.item;
            [self reportedChangedIndex];
        }
    }
}

#pragma mark - Private
#pragma mark -

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

- (UIImageView *)imageViewInView:(UIView *)view withTag:(NSUInteger)tag {
    UIView *taggedView = [view viewWithTag:tag];
    if ([taggedView isKindOfClass:[UIImageView class]]) {
        return (UIImageView *)taggedView;
    }
    return nil;
}

- (NSIndexPath *)indexPathForCurrentItem {
    NSArray *indexPaths = [self.collectionView indexPathsForVisibleItems];
    if (indexPaths.count) {
        return indexPaths[0];
    }
    
    return nil;
}

- (void)reportedChangedIndex {
    if ([self.delegate respondsToSelector:@selector(spotsCollectionViewManager:didChangeToIndex:)]) {
        [self.delegate spotsCollectionViewManager:self didChangeToIndex:_currentIndex];
    }
}

@end
