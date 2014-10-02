//
//  SpecialsCollectionViewManager.m
//  SpotHopper
//
//  Created by Brennan Stehling on 5/20/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "SHSpecialsCollectionViewManager.h"

#import "SHAppUtil.h"

#import "SpecialModel.h"
#import "SpotModel.h"

#import "SHDrawnButton.h"
#import "SHStyleKit+Additions.h"
#import "UIImageView+AFNetworking.h"
#import "ImageUtil.h"

#import "Tracker.h"
#import "Tracker+Events.h"
#import "Tracker+People.h"

#import "NSArray+DailySpecials.h"

#import "SHCollectionViewTableManager.h"

#define kSpecialCellIdentifier @"SpecialCell"

#define kSpecialCellSpotImageView 1
#define kSpecialCellSpotNameLabel 2
#define kSpecialCellSpecialLabel 3
#define kSpecialCellLikeButton 4
#define kSpecialCellLikeLabel 5
#define kSpecialCellShareButton 6
#define kSpecialCellLeftButton 8
#define kSpecialCellRightButton 9
#define kSpecialCellPositionLabel 10
#define kSpecialCellTimeLabel 11

#define kSpecialCellTableContainerView 600

#pragma mark - Class Extension
#pragma mark -

@interface SHSpecialsCollectionViewManager () <SHCollectionViewTableManagerDelegate, UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, weak) IBOutlet id<SHSpecialsCollectionViewManagerDelegate> delegate;

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) NSArray *spots;

@end

@implementation SHSpecialsCollectionViewManager {
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
    return self.spots.count;
}

- (void)updateSpots:(NSArray *)spots {
    NSAssert(self.delegate, @"Delegate must be defined");
    
    static NSString *lock = @"LOCK";
    @synchronized(lock) {
        if (_isUpdatingData) {
            [self performSelector:@selector(updateSpots:) withObject:spots afterDelay:0.25];
        }
        else {
            _isUpdatingData = TRUE;
            self.spots = spots;
            [self.collectionView reloadData];
            self.collectionView.contentOffset = CGPointMake(0, 0);
            self.currentIndex = 0;
            _isUpdatingData = FALSE;
            [Tracker trackListViewDidDisplaySpot:[self spotAtIndex:self.currentIndex] position:self.currentIndex+1 isSpecials:TRUE];
            
            for (SpotModel *spot in spots) {
                [ImageUtil preloadImageModels:spot.images];
            }
        }
    }
}

- (void)changeIndex:(NSUInteger)index {
    // change collection view position if the index is in bounds and set self.currentIndex
    if (index != self.currentIndex && index < self.spots.count) {
        self.currentIndex = index;
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.currentIndex inSection:0];
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

- (UICollectionViewCell *)cellForViewInCollectionViewCell:(UIView *)view {
    while (![view isKindOfClass:[UICollectionViewCell class]] && view.superview) {
        view = view.superview;
    }
    
    if ([view isKindOfClass:[UICollectionViewCell class]]) {
        UICollectionViewCell *cell = (UICollectionViewCell *)view;
        return cell;
    }
    
    return nil;
    
}

- (NSUInteger)indexForViewInCollectionViewCell:(UIView *)view {
    NSUInteger index = NSNotFound;
    UICollectionViewCell *cell = [self cellForViewInCollectionViewCell:view];
    
    if (cell) {
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
        if (indexPath) {
            index = indexPath.item;
        }
    }
    
    return index;
}

- (void)updateCellAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item < self.spots.count) {
        UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
        SpotModel *spot = (SpotModel *)self.spots[indexPath.item];
        SpecialModel *special = [spot specialForToday];
        
        UIButton *likeButton = [self buttonInView:cell withTag:kSpecialCellLikeButton];
        UIImage *highlightedImage = [SHStyleKit drawImage:SHStyleKitDrawingThumbsUpIcon color:SHStyleKitColorMyTintColor size:CGSizeMake(30, 30)];
        [likeButton setImage:highlightedImage forState:UIControlStateHighlighted];
        likeButton.highlighted = special.userLikesSpecial;
        
        UILabel *likeLabel = [self labelInView:cell withTag:kSpecialCellLikeLabel];
        
        NSAssert(special.likeCount < 40000, @"Likes should not exceed 40000 normally");
        
        likeLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)special.likeCount];
    }
}

- (SpotModel *)spotAtIndex:(NSUInteger)index {
    if (index < self.spots.count) {
        return self.spots[index];
    }
    
    return nil;
}

- (BOOL)hasPrevious {
    NSIndexPath *indexPath = [self indexPathForCurrentItemInCollectionView:self.collectionView];
    return self.spots.count ? (indexPath.item > 0) : FALSE;
}

- (BOOL)hasNext {
    NSIndexPath *indexPath = [self indexPathForCurrentItemInCollectionView:self.collectionView];
    return self.spots.count ? (indexPath.item < self.spots.count - 1) : FALSE;
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
    if ([self.delegate respondsToSelector:@selector(specialsCollectionViewManager:displaySpot:)]) {
        [self.delegate specialsCollectionViewManager:self displaySpot:spot];
    }
}

#pragma mark - UICollectionViewDataSource
#pragma mark -

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.spots.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kSpecialCellIdentifier forIndexPath:indexPath];
    
    UIView *selectedBackgroundView = [[UIView alloc] initWithFrame:CGRectZero];
    selectedBackgroundView.backgroundColor = [UIColor clearColor];
    cell.selectedBackgroundView = selectedBackgroundView;
    
    if (indexPath.item < self.spots.count) {
        SpotModel *spot = self.spots[indexPath.item];
        
        UIView *tableContainerView = [cell viewWithTag:kSpecialCellTableContainerView];
        UITableView *tableView = nil;
        if (!tableContainerView.subviews.count) {
             tableView = [self embedTableViewInSuperView:tableContainerView];
        }
        else {
            tableView = (UITableView *)tableContainerView.subviews[0];
        }
        SHCollectionViewTableManager *tableManager = [[SHCollectionViewTableManager alloc] init];
        tableManager.delegate = self;
        [tableManager manageTableView:tableView forTodaysSpecialAtSpot:spot];
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
    
//    if ([self.delegate respondsToSelector:@selector(specialsCollectionViewManager:didSelectSpotAtIndex:)]) {
//        [self.delegate specialsCollectionViewManager:self didSelectSpotAtIndex:indexPath.item];
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
    
    SpecialModel *special = [spot specialForToday];
    UIImageView *spotImageView = (UIImageView *)[headerView viewWithTag:kSpecialCellSpotImageView];
    
    NSAssert([spotImageView isKindOfClass:[UIImageView class]], @"Image View is expected");
    
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
    
    UILabel *nameLabel = [self labelInView:headerView withTag:kSpecialCellSpotNameLabel];
    UILabel *timeLabel = [self labelInView:headerView withTag:kSpecialCellTimeLabel];
    UILabel *specialLabel = [self labelInView:headerView withTag:kSpecialCellSpecialLabel];
    UIButton *likeButton = [self buttonInView:headerView withTag:kSpecialCellLikeButton];
    UILabel *likeLabel = [self labelInView:headerView withTag:kSpecialCellLikeLabel];
    
    NSAssert(nameLabel, @"View must be defined");
    NSAssert(timeLabel, @"View must be defined");
    NSAssert(specialLabel, @"View must be defined");
    NSAssert(likeButton, @"View must be defined");
    NSAssert(likeLabel, @"View must be defined");
    
    [SHStyleKit setLabel:nameLabel textColor:SHStyleKitColorMyTintColor];
    [SHStyleKit setLabel:timeLabel textColor:SHStyleKitColorMyTextColor];
    [SHStyleKit setButton:likeButton withDrawing:SHStyleKitDrawingThumbsUpIcon normalColor:SHStyleKitColorMyWhiteColor highlightedColor:SHStyleKitColorMyTintColor size:CGSizeMake(30, 30)];
    [SHStyleKit setLabel:likeLabel textColor:SHStyleKitColorMyTintColor];
    
    nameLabel.text = spot.name;
    
    if (special) {
        timeLabel.text = special.timeString;
        specialLabel.text = special.text.length ? special.text : @"No Special";
        likeButton.highlighted = special.userLikesSpecial;
        likeLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)special.likeCount];
        likeButton.hidden = FALSE;
        likeLabel.hidden = FALSE;
    }
    else {
        timeLabel.text = nil;
        specialLabel.text = @"No Special";
        likeButton.hidden = TRUE;
        likeLabel.hidden = TRUE;
    }
    
    NSLayoutConstraint *heightConstraint = [[SHAppUtil defaultInstance] getHeightConstraint:specialLabel];
    if (heightConstraint) {
        CGFloat height = [[SHAppUtil defaultInstance] heightForString:specialLabel.text font:specialLabel.font maxWidth:CGRectGetWidth(specialLabel.frame)];
        heightConstraint.constant = MIN(61.0, height);
    }
}

#pragma mark - Private
#pragma mark -

- (void)reportedChangedIndex {
    [Tracker trackListViewDidDisplaySpot:[self spotAtIndex:self.currentIndex] position:self.currentIndex+1 isSpecials:TRUE];
    
    if ([self.delegate respondsToSelector:@selector(specialsCollectionViewManager:didChangeToSpotAtIndex:count:)]) {
        [self.delegate specialsCollectionViewManager:self didChangeToSpotAtIndex:self.currentIndex count:self.spots.count];
    }
}

@end
