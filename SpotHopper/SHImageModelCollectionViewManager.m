//
//  SHImageModelCollectionViewManager.m
//  SpotHopper
//
//  Created by Tracee Pettigrew on 5/30/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "SHImageModelCollectionViewManager.h"

#import "PhotoAlbumViewController.h"
#import "PhotoViewerViewController.h"

#import "ImageModel.h"
#import "NetworkHelper.h"
#import "Tracker.h"

#define kImageView 1
#define kPreviousButton 2
#define kNextButton 3

#pragma mark - Class Extension
#pragma mark -

@interface SHImageModelCollectionViewManager ()

@property (nonatomic, weak) IBOutlet id<SHImageModelCollectionDelegate> delegate;

@end

@implementation SHImageModelCollectionViewManager


#pragma mark - UICollectionViewDataSource
#pragma mark -

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return MAX(1, self.imageModels.count);
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    // dequeue named cell template
    
    static NSString *ImageCellIdentifier = @"ImageCell";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ImageCellIdentifier forIndexPath:indexPath];
    
    if (self.imageModels.count) {
        // get image view by tag and use NetworkHelper to load image
        
        UIImageView *imageView = (UIImageView *)[cell viewWithTag:kImageView];
        
        ImageModel *imageModel = self.imageModels[indexPath.item];
        
        [NetworkHelper loadImage:imageModel placeholderImage:nil withThumbImageBlock:^(UIImage *thumbImage) {
            imageView.image = thumbImage;
        } withFullImageBlock:^(UIImage *fullImage) {
            imageView.image = fullImage;
        } withErrorBlock:^(NSError *error) {
            
        }];
    }
    else {
        // TODO: use placeholder image
    }
    
    return cell;
    
}

#pragma mark - UICollectionViewDelegate
#pragma mark -

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Selected item!");
    
    //trigger segue 
    if ([self.delegate respondsToSelector:@selector(imageCollectionViewManager:didSelectImageAtIndex:)]) {
        [self.delegate imageCollectionViewManager:self didSelectImageAtIndex:self.currentIndex];
    }
    
}

#pragma mark - UIScrollViewDelegate
#pragma mark -

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == self.collectionView) {
        NSIndexPath *indexPath = [self indexPathForCurrentItemInCollectionView:self.collectionView];
        if (indexPath.item != self.currentIndex) {
            self.currentIndex = indexPath.item;
            [self reportedChangedIndex];
        }
    }
}

#pragma mark - Public
#pragma mark -

/**
 changes the index of the collection view to either the previous or next image's index
 */
- (void)changeIndex:(NSUInteger)index {
    // TODO: change collection view position if the index is in bounds and set _currentIndex
    
    if (index != self.currentIndex && index < self.imageModels.count) {
        NSLog(@"Manager - Changing to index: %lu", (long)index);
        self.currentIndex = index;
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.currentIndex inSection:0];
        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:TRUE];
    }
}

- (void)changeImage:(ImageModel *)image {
    NSUInteger index = [self.imageModels indexOfObject:image];
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
    return self.imageModels.count ? (indexPath.item > 0) : FALSE;
}

- (BOOL)hasNext {
    NSIndexPath *indexPath = [self indexPathForCurrentItemInCollectionView:self.collectionView];
    return self.imageModels.count ? (indexPath.item < self.imageModels.count - 1) : FALSE;
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

#pragma mark - Private
#pragma mark -

- (void)reportedChangedIndex {
    if ([self.delegate respondsToSelector:@selector(imageCollectionViewManager:didChangeToImageAtIndex:)]) {
        [self.delegate imageCollectionViewManager:self didChangeToImageAtIndex:self.currentIndex];
    }
}



@end
