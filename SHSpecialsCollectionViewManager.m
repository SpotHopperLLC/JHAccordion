//
//  SpecialsCollectionViewManager.m
//  SpotHopper
//
//  Created by Brennan Stehling on 5/20/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "SHSpecialsCollectionViewManager.h"

#import "SpotModel.h"

#import "SHStyleKit+Additions.h"
#import "UIImageView+AFNetworking.h"
#import "NetworkHelper.h"
#import "Tracker.h"

#import "NSArray+DailySpecials.h"

#define kSpecialCellIdentifier @"SpecialCell"

#define kSpecialCellSpotImageView 1
#define kSpecialCellSpotNameButton 2
#define kSpecialCellSpecialLabel 3
#define kSpecialCellLikeButton 4
#define kSpecialCellLikeLabel 5
#define kSpecialCellShareButton 6
#define kSpecialCellShareLabel 7
#define kSpecialCellLeftButton 8
#define kSpecialCellRightButton 9
#define kSpecialCellPositionLabel 10
#define kSpecialCellMatchLabel 11

#pragma mark - Class Extension
#pragma mark -

@interface SHSpecialsCollectionViewManager ()

@property (nonatomic, weak) IBOutlet id<SHSpecialsCollectionViewManagerDelegate> delegate;
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) NSArray *spots;

@end

@implementation SHSpecialsCollectionViewManager {
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

- (void)updateSpots:(NSArray *)spots {
    static NSString *lock;
    @synchronized(lock) {
        if (_isUpdatingData) {
            [self performSelector:@selector(updateSpots:) withObject:spots afterDelay:0.25];
        }
        else {
            _isUpdatingData = TRUE;
            self.spots = spots;
            [self.collectionView reloadData];
            _isUpdatingData = FALSE;
        }
    }
}

- (void)changeIndex:(NSUInteger)index {
    // TODO: change collection view position if the index is in bounds and set _currentIndex
    
    if (index != _currentIndex && index < self.spots.count) {
        NSLog(@"Manager - Changing to index: %lu", (long)index);
        _currentIndex = index;
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:_currentIndex inSection:0];
        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:TRUE];
        [self reportedChangedIndex];
    }
}

- (void)changeSpot:(SpotModel *)spot {
    NSUInteger index = [self.spots indexOfObject:spot];
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
    return self.spots.count ? (indexPath.item > 0) : FALSE;
}

- (BOOL)hasNext {
    NSIndexPath *indexPath = [self indexPathForCurrentItem];
    return self.spots.count ? (indexPath.item < self.spots.count - 1) : FALSE;
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
    return self.spots.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    // dequeue named cell template
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kSpecialCellIdentifier forIndexPath:indexPath];
    
    if (indexPath.item < self.spots.count) {
        SpotModel *spot = self.spots[indexPath.item];
        
        UIImageView *spotImageView = (UIImageView *)[cell viewWithTag:kSpecialCellSpotImageView];
        
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
        
        UIButton *nameButton = [self buttonInView:cell withTag:kSpecialCellSpotNameButton];
        UILabel *specialLabel = [self labelInView:cell withTag:kSpecialCellSpecialLabel];
        UIButton *likeButton = [self buttonInView:cell withTag:kSpecialCellLikeButton];
        UILabel *likeLabel = [self labelInView:cell withTag:kSpecialCellLikeLabel];
        UIButton *shareButton = [self buttonInView:cell withTag:kSpecialCellShareButton];
        UILabel *shareLabel = [self labelInView:cell withTag:kSpecialCellShareLabel];
        UILabel *positionLabel = [self labelInView:cell withTag:kSpecialCellPositionLabel];
        
        [SHStyleKit setButton:likeButton withDrawing:SHStyleKitDrawingThumbsUpIcon normalColor:SHStyleKitColorMyTintColor highlightedColor:SHStyleKitColorMyWhiteColor];
        [SHStyleKit setButton:shareButton withDrawing:SHStyleKitDrawingShareIcon normalColor:SHStyleKitColorMyTintColor highlightedColor:SHStyleKitColorMyWhiteColor];
        
        [SHStyleKit setLabel:specialLabel textColor:SHStyleKitColorMyTextColor];
        [SHStyleKit setLabel:likeLabel textColor:SHStyleKitColorMyTintColor];
        [SHStyleKit setLabel:shareLabel textColor:SHStyleKitColorMyTintColor];
        [SHStyleKit setLabel:positionLabel textColor:SHStyleKitColorMyTextColor];
        
        [specialLabel setFont:[UIFont fontWithName:@"Lato-Light" size:14.0f]];
        [likeLabel setFont:[UIFont fontWithName:@"Lato-Light" size:14.0f]];
        [shareLabel setFont:[UIFont fontWithName:@"Lato-Light" size:12.0f]];
        [positionLabel setFont:[UIFont fontWithName:@"Lato-Light" size:14.0f]];
        
        [nameButton setTitle:spot.name forState:UIControlStateNormal];
        [nameButton setTitleColor:[SHStyleKit myTextColor] forState:UIControlStateNormal];
        
        specialLabel.text = [spot.dailySpecials specialsForToday];
        
        likeLabel.text = @"0";

        positionLabel.text = [NSString stringWithFormat:@"%lu of %lu", (long)indexPath.item+1, (long)self.spots.count];
        
        UIButton *previousButton = [self buttonInView:cell withTag:kSpecialCellLeftButton];
        [SHStyleKit setButton:previousButton withDrawing:SHStyleKitDrawingPreviousArrowIcon normalColor:SHStyleKitColorMyTextColor highlightedColor:SHStyleKitColorMyWhiteColor];
        previousButton.hidden = indexPath.item == 0;
        
        UIButton *nextButton = [self buttonInView:cell withTag:kSpecialCellRightButton];
        [SHStyleKit setButton:nextButton withDrawing:SHStyleKitDrawingNextArrowIcon normalColor:SHStyleKitColorMyTextColor highlightedColor:SHStyleKitColorMyWhiteColor];
        nextButton.hidden = indexPath.item == self.spots.count - 1;
    }
    
    return cell;
}

#pragma mark - UICollectionViewDelegate
#pragma mark -

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Selected item %lu", (long)indexPath.item);
    
    if ([self.delegate respondsToSelector:@selector(specialsCollectionViewManager:didSelectSpotAtIndex:)]) {
        [self.delegate specialsCollectionViewManager:self didSelectSpotAtIndex:indexPath.item];
    }
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
    if ([self.delegate respondsToSelector:@selector(specialsCollectionViewManager:didChangeToSpotAtIndex:)]) {
        [self.delegate specialsCollectionViewManager:self didChangeToSpotAtIndex:_currentIndex];
    }
}

@end
