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
#import "ImageModel.h"
#import "SpotModel.h"
#import "AverageReviewModel.h"

#import "SHStyleKit+Additions.h"
#import "UIImageView+AFNetworking.h"
#import "NetworkHelper.h"

#import "TellMeMyLocation.h"
#import "Tracker.h"

#import <CoreLocation/CoreLocation.h>

#define kMeterToMile 0.000621371f

#define kDrinkCellIdentifier @"DrinkCell"

#define kDrinkCellDrinkImageView 1
#define kDrinkCellDrinkNameButton 2
#define kDrinkCellBreweryLabel 3
#define kDrinkCellStyleLabel 4
#define kDrinkCellRankingLabel 5
#define kDrinkCellMatchPercentageImageView 6
#define kDrinkCellMatchPercentageLabel 7
#define kDrinkCellMatchLabel 8
#define kDrinkCellPreviousButton 9
#define kDrinkCellPositionLabel 10
#define kDrinkCellNextButton 11

#pragma mark - Class Extension
#pragma mark -

@interface SHDrinksCollectionViewManager ()

@property (nonatomic, weak) IBOutlet id<SHDrinksCollectionViewManagerDelegate> delegate;
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;

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
        }
    }
}

- (void)changeIndex:(NSUInteger)index {
    if (index != _currentIndex && index < self.drinkList.drinks.count) {
        NSLog(@"Manager - Changing to index: %lu", (long)index);
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

#pragma mark - UICollectionViewDataSource
#pragma mark -

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.drinkList.drinks.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kDrinkCellIdentifier forIndexPath:indexPath];
    if (indexPath.item < self.drinkList.drinks.count) {
        DrinkModel *drink = self.drinkList.drinks[indexPath.item];
        [self renderCell:cell withDrink:drink atIndex:indexPath.item];
    }
    
    return cell;
}

#pragma mark - UICollectionViewDelegate
#pragma mark -

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Selected item %lu", (long)indexPath.item);
    
    if ([self.delegate respondsToSelector:@selector(drinksCollectionViewManager:didSelectDrinkAtIndex:)]) {
        [self.delegate drinksCollectionViewManager:self didSelectDrinkAtIndex:indexPath.item];
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

- (void)renderCell:(UICollectionViewCell *)cell withDrink:(DrinkModel *)drink atIndex:(NSUInteger)index {
    UIImageView *drinkImageView = [self imageViewInView:cell withTag:kDrinkCellDrinkImageView];
    UIButton *nameButton = [self buttonInView:cell withTag:kDrinkCellDrinkNameButton];
    UILabel *breweryLabel = [self labelInView:cell withTag:kDrinkCellBreweryLabel];
    UILabel *styleLabel = [self labelInView:cell withTag:kDrinkCellStyleLabel];
    UILabel *rankingLabel = [self labelInView:cell withTag:kDrinkCellRankingLabel];
    UIImageView *matchImageView = [self imageViewInView:cell withTag:kDrinkCellMatchPercentageImageView];
    UILabel *percentageLabel = [self labelInView:cell withTag:kDrinkCellMatchPercentageLabel];
    UILabel *matchLabel = [self labelInView:cell withTag:kDrinkCellMatchLabel];
    UIButton *previousButton = [self buttonInView:cell withTag:kDrinkCellPreviousButton];
    UIButton *nextButton = [self buttonInView:cell withTag:kDrinkCellNextButton];
    UILabel *positionLabel = [self labelInView:cell withTag:kDrinkCellPositionLabel];
    
    NSAssert(drinkImageView, @"View must be defined");
    NSAssert(nameButton, @"View must be defined");
    NSAssert(breweryLabel, @"View must be defined");
    NSAssert(styleLabel, @"View must be defined");
    NSAssert(rankingLabel, @"View must be defined");
    NSAssert(percentageLabel, @"View must be defined");
    NSAssert(matchLabel, @"View must be defined");
    NSAssert(previousButton, @"View must be defined");
    NSAssert(nextButton, @"View must be defined");
    NSAssert(positionLabel, @"View must be defined");
    
    [SHStyleKit setLabel:breweryLabel textColor:SHStyleKitColorMyTextColor];
    [SHStyleKit setLabel:styleLabel textColor:SHStyleKitColorMyTextColor];
    [SHStyleKit setLabel:rankingLabel textColor:SHStyleKitColorMyTextColor];
    [SHStyleKit setLabel:matchLabel textColor:SHStyleKitColorMyTintColor];
    [SHStyleKit setLabel:positionLabel textColor:SHStyleKitColorMyTextColor];
    
    [breweryLabel setFont:[UIFont fontWithName:@"Lato-Light" size:14.0f]];
    [styleLabel setFont:[UIFont fontWithName:@"Lato-Light" size:14.0f]];
    [rankingLabel setFont:[UIFont fontWithName:@"Lato-Light" size:14.0f]];
    [positionLabel setFont:[UIFont fontWithName:@"Lato-Bold" size:14.0f]];
    [matchLabel setFont:[UIFont fontWithName:@"Lato-Light" size:14.0f]];
    
    drinkImageView.image = nil;
    
    if (drink.imageUrl.length) {
        [drinkImageView setImageWithURL:[NSURL URLWithString:drink.imageUrl] placeholderImage:drink.placeholderImage];
    }
    else if (drink.images.count) {
        ImageModel *imageModel = drink.images[0];
        __weak UIImageView *weakImageView = drinkImageView;
        [NetworkHelper loadImage:imageModel placeholderImage:drink.placeholderImage withThumbImageBlock:^(UIImage *thumbImage) {
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
   
    [nameButton setTitle:drink.name forState:UIControlStateNormal];
    nameButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    nameButton.titleLabel.textAlignment = NSTextAlignmentLeft;
    [SHStyleKit setButton:nameButton normalTextColor:SHStyleKitColorMyTintColor highlightedTextColor:SHStyleKitColorMyTextColor];

    breweryLabel.text = drink.spot.name;
    styleLabel.text = drink.style;
    rankingLabel.text = [NSString stringWithFormat:@"%.1f/10", [drink.averageReview.rating floatValue]];
    
    positionLabel.text = [NSString stringWithFormat:@"%lu of %lu", (long)index+1, (long)self.drinkList.drinks.count];
    
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
        
        UIImage *image = nil;
        if (drink.isBeer) {
            image = [SHStyleKit drawImage:SHStyleKitDrawingBeerIcon color:SHStyleKitColorMyTintColor size:CGSizeMake(60, 60)];
        }
        else if (drink.isCocktail) {
            image = [SHStyleKit drawImage:SHStyleKitDrawingCocktailIcon color:SHStyleKitColorMyTintColor size:CGSizeMake(60, 60)];
        }
        else if (drink.isWine) {
            image = [SHStyleKit drawImage:SHStyleKitDrawingWineIcon color:SHStyleKitColorMyTintColor size:CGSizeMake(60, 60)];
        }
        
        matchImageView.image = image;
    }
    
    if (self.drinkList.drinks.count == 1) {
        previousButton.hidden = TRUE;
        nextButton.hidden = TRUE;
        positionLabel.hidden = TRUE;
    }
    else {
        positionLabel.hidden = FALSE;
        
        [SHStyleKit setButton:previousButton withDrawing:SHStyleKitDrawingArrowLeftIcon normalColor:SHStyleKitColorMyTextColor highlightedColor:SHStyleKitColorMyWhiteColor];
        previousButton.hidden = index == 0;
        
        [SHStyleKit setButton:nextButton withDrawing:SHStyleKitDrawingArrowRightIcon normalColor:SHStyleKitColorMyTextColor highlightedColor:SHStyleKitColorMyWhiteColor];
        nextButton.hidden = index == self.drinkList.drinks.count - 1;
    }
}

#pragma mark - Private
#pragma mark -

- (void)reportedChangedIndex {
    if ([self.delegate respondsToSelector:@selector(drinksCollectionViewManager:didChangeToDrinkAtIndex:)]) {
        [self.delegate drinksCollectionViewManager:self didChangeToDrinkAtIndex:_currentIndex];
    }
}

@end
