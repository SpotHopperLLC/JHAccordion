//
//  SpecialsCollectionViewManager.m
//  SpotHopper
//
//  Created by Brennan Stehling on 5/20/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "SHSpecialsCollectionViewManager.h"

#import "SpecialModel.h"
#import "SpotModel.h"

#import "SHStyleKit+Additions.h"
#import "UIImageView+AFNetworking.h"
#import "NetworkHelper.h"

#import "Tracker.h"
#import "Tracker+Events.h"
#import "Tracker+People.h"

#import "NSArray+DailySpecials.h"

#define kSpecialCellIdentifier @"SpecialCell"

#define kSpecialCellSpotImageView 1
#define kSpecialCellSpotNameLabel 2
#define kSpecialCellSpecialTextView 3
#define kSpecialCellLikeButton 4
#define kSpecialCellLikeLabel 5
#define kSpecialCellShareButton 6
#define kSpecialCellLeftButton 8
#define kSpecialCellRightButton 9
#define kSpecialCellPositionLabel 10
#define kSpecialCellTimeLabel 11

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
    NSAssert(self.delegate, @"Delegate must be defined");
    
    static NSString *lock;
    @synchronized(lock) {
        if (_isUpdatingData) {
            [self performSelector:@selector(updateSpots:) withObject:spots afterDelay:0.25];
        }
        else {
            _isUpdatingData = TRUE;
            self.spots = spots;
            [self.collectionView setContentOffset:CGPointMake(0, 0)];
            [self.collectionView reloadData];
            _currentIndex = 0;
            _isUpdatingData = FALSE;
            [Tracker trackListViewDidDisplaySpot:[self spotAtIndex:_currentIndex] position:_currentIndex+1 isSpecials:TRUE];
        }
    }
}

- (void)changeIndex:(NSUInteger)index {
    // change collection view position if the index is in bounds and set _currentIndex
    if (index != _currentIndex && index < self.spots.count) {
        DebugLog(@"Manager - Changing to index: %lu", (long)index);
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
        likeButton.highlighted = special.userLikesSpecial;
        
        UILabel *likeLabel = [self labelInView:cell withTag:kSpecialCellLikeLabel];
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
        [self renderCell:cell withSpot:spot atIndex:indexPath.item];

    }
    
    return cell;
}

#pragma mark - UICollectionViewDelegate
#pragma mark -

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    DebugLog(@"Selected item %lu", (long)indexPath.item);
    
    if ([self.delegate respondsToSelector:@selector(specialsCollectionViewManager:didSelectSpotAtIndex:)]) {
        [self.delegate specialsCollectionViewManager:self didSelectSpotAtIndex:indexPath.item];
    }
}

#pragma mark - UIScrollViewDelegate

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

#pragma mark - Base Overrides
#pragma mark -

- (void)renderCell:(UICollectionViewCell *)cell withSpot:(SpotModel *)spot atIndex:(NSUInteger)index {
    SpecialModel *special = [spot specialForToday];

    UIImageView *spotImageView = (UIImageView *)[cell viewWithTag:kSpecialCellSpotImageView];
    
    spotImageView.image = nil;
    
    if (spot.imageUrl.length) {
        [spotImageView setImageWithURL:[NSURL URLWithString:spot.imageUrl] placeholderImage:spot.placeholderImage];
    }
    else if (spot.images.count) {
        ImageModel *imageModel = spot.images[0];
        __weak UIImageView *weakImageView = spotImageView;
        [NetworkHelper loadImage:imageModel placeholderImage:spot.placeholderImage withThumbImageBlock:^(UIImage *thumbImage) {
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
    
    UILabel *nameLabel = [self labelInView:cell withTag:kSpecialCellSpotNameLabel];
    UILabel *timeLabel = [self labelInView:cell withTag:kSpecialCellTimeLabel];
    UITextView *specialTextView = [self textViewInView:cell withTag:kSpecialCellSpecialTextView];
    UIButton *likeButton = [self buttonInView:cell withTag:kSpecialCellLikeButton];
    UILabel *likeLabel = [self labelInView:cell withTag:kSpecialCellLikeLabel];
    UIButton *shareButton = [self buttonInView:cell withTag:kSpecialCellShareButton];
    UILabel *positionLabel = [self labelInView:cell withTag:kSpecialCellPositionLabel];
    
    NSAssert(nameLabel, @"View must be defined");
    NSAssert(timeLabel, @"View must be defined");
    NSAssert(specialTextView, @"View must be defined");
    NSAssert(likeButton, @"View must be defined");
    NSAssert(likeLabel, @"View must be defined");
    NSAssert(shareButton, @"View must be defined");
    NSAssert(positionLabel, @"View must be defined");
    
    [SHStyleKit setLabel:nameLabel textColor:SHStyleKitColorMyTintColor];
    [SHStyleKit setLabel:timeLabel textColor:SHStyleKitColorMyTextColor];
    [SHStyleKit setButton:likeButton withDrawing:SHStyleKitDrawingThumbsUpIcon normalColor:SHStyleKitColorMyTintColor highlightedColor:SHStyleKitColorMyWhiteColor];
    [SHStyleKit setButton:shareButton withDrawing:SHStyleKitDrawingShareIcon normalColor:SHStyleKitColorMyTintColor highlightedColor:SHStyleKitColorMyWhiteColor];
    [SHStyleKit setLabel:likeLabel textColor:SHStyleKitColorMyTintColor];
    [SHStyleKit setLabel:positionLabel textColor:SHStyleKitColorMyTextColor];
    
    [nameLabel setFont:[UIFont fontWithName:@"Lato-Bold" size:14.0f]];
    [timeLabel setFont:[UIFont fontWithName:@"Lato-Light" size:12.0f]];
    specialTextView.contentOffset = CGPointMake(0.0f, 0.0f);
    [specialTextView setFont:[UIFont fontWithName:@"Lato-Light" size:14.0f]];
    [likeLabel setFont:[UIFont fontWithName:@"Lato-Light" size:14.0f]];
    [positionLabel setFont:[UIFont fontWithName:@"Lato-Light" size:14.0f]];
    
    nameLabel.text = spot.name;
    
    if (special) {
        timeLabel.text = special.timeString;
        
        NSDictionary *attributes = @{ NSFontAttributeName : [UIFont fontWithName:@"Lato-Light" size:14.0], NSForegroundColorAttributeName : [SHStyleKit myTextColor] };
        NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:special.text.length ? special.text : @"No Special" attributes:attributes];
        specialTextView.attributedText = attributedString;
        [specialTextView setContentOffset:CGPointMake(0, 0)];
        [specialTextView flashScrollIndicators];
        
        likeButton.highlighted = special.userLikesSpecial;
        likeLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)special.likeCount];
        likeButton.hidden = FALSE;
        likeLabel.hidden = FALSE;
    }
    else {
        timeLabel.text = nil;
        
        NSDictionary *attributes = @{ NSFontAttributeName : [UIFont fontWithName:@"Lato-Light" size:14.0], NSForegroundColorAttributeName : [SHStyleKit myTextColor] };
        NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:@"No Special" attributes:attributes];
        specialTextView.attributedText = attributedString;
        [specialTextView setContentOffset:CGPointMake(0, 0)];
        [specialTextView flashScrollIndicators];

        likeButton.hidden = TRUE;
        likeLabel.hidden = TRUE;
    }
    
    positionLabel.text = [NSString stringWithFormat:@"%lu of %lu", (long)index+1, (long)self.spots.count];
    
    UIButton *previousButton = [self buttonInView:cell withTag:kSpecialCellLeftButton];
    [SHStyleKit setButton:previousButton withDrawing:SHStyleKitDrawingArrowLeftIcon normalColor:SHStyleKitColorMyTextColor highlightedColor:SHStyleKitColorMyWhiteColor];
    previousButton.hidden = index == 0;
    
    UIButton *nextButton = [self buttonInView:cell withTag:kSpecialCellRightButton];
    [SHStyleKit setButton:nextButton withDrawing:SHStyleKitDrawingArrowRightIcon normalColor:SHStyleKitColorMyTextColor highlightedColor:SHStyleKitColorMyWhiteColor];
    nextButton.hidden = index == self.spots.count - 1;
}

#pragma mark - Private
#pragma mark -

- (void)reportedChangedIndex {
    [Tracker trackListViewDidDisplaySpot:[self spotAtIndex:_currentIndex] position:_currentIndex+1 isSpecials:TRUE];
    
    if ([self.delegate respondsToSelector:@selector(specialsCollectionViewManager:didChangeToSpotAtIndex:)]) {
        [self.delegate specialsCollectionViewManager:self didChangeToSpotAtIndex:_currentIndex];
    }
}

@end
