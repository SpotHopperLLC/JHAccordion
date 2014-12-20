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
#import "ImageUtil.h"
#import "Tracker.h"

#define kImageView 1

#pragma mark - Class Extension
#pragma mark -

@interface SHImageModelCollectionViewManager ()

@property (weak, nonatomic) IBOutlet id<SHImageModelCollectionDelegate> delegate;

@property (strong, nonatomic) NSMutableDictionary *operations;

@end

@implementation SHImageModelCollectionViewManager

#pragma mark - UICollectionViewDataSource
#pragma mark -

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return MAX(1, self.imageModels.count);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ImageCellIdentifier = @"ImageCell";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ImageCellIdentifier forIndexPath:indexPath];
    
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:kImageView];
    imageView.image = self.placeholderImage;

    if (self.imageModels.count) {
        ImageModel *imageModel = self.imageModels[indexPath.item];
        
        __weak UIImageView *weakImageView = imageView;
        __weak SHImageModelCollectionViewManager *weakSelf = self;
        
        if (imageModel.fullUrl.length) {
            NSURL *url = [NSURL URLWithString:imageModel.fullUrl];
            NSOperation *operation = [ImageUtil fetchImageWithURL:url cachable:TRUE withCompletionBlock:^(UIImage *image, NSError *error) {
                if (!error && image) {
                    weakImageView.image = image;
                }
                
                [weakSelf.operations removeObjectForKey:indexPath];
            }];
            
            if (!self.operations) {
                self.operations = @{}.mutableCopy;
            }
            self.operations[indexPath] = operation;
        }
    }
    
    return cell;
}

#pragma mark - UICollectionViewDelegate
#pragma mark -

- (void)collectionView:(UICollectionView *)collectionView willEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    NSOperation *operation = self.operations[indexPath];
    if (operation) {
        if (operation.isExecuting) {
            [operation cancel];
        }
        [self.operations removeObjectForKey:indexPath];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
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
    // change collection view position if the index is in bounds and set self.currentIndex
    if (index != self.currentIndex && index < self.imageModels.count) {
        self.currentIndex = index;
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.currentIndex inSection:0];
        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:TRUE];
        [self reportedChangedIndex];
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
        [self changeIndex:(self.currentIndex - 1)];
    }
}

- (void)goNext {
    if ([self hasNext]) {
        [self changeIndex:(self.currentIndex+1)];
    }
}

#pragma mark - Private
#pragma mark -
 
- (NSIndexPath *)indexPathForCurrentImage {
    NSArray *indexPaths = [_collectionView indexPathsForVisibleItems];
    if (indexPaths.count) {
        return indexPaths[0];
    }
    
    return nil;
}

- (void)didReachEnd:(BOOL)hasMore button:(UIButton*)button {
    if (hasMore) {
        button.alpha = 0.1;
        button.enabled = TRUE;
    }
    else{
        button.alpha = 1.0;
        button.enabled = FALSE;
    }
}

- (void)reportedChangedIndex {
    if ([self.delegate respondsToSelector:@selector(imageCollectionViewManager:didChangeToImageAtIndex:)]) {
        [self.delegate imageCollectionViewManager:self didChangeToImageAtIndex:self.currentIndex];
    }
}

@end
