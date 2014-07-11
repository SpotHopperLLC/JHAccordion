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
#define kDescriptionLabel 4

#pragma mark - Class Extension
#pragma mark -

@interface SHImageModelCollectionViewManager ()
@property (nonatomic, weak) IBOutlet id<SHImageModelCollectionDelegate> delegate;
@end

@implementation SHImageModelCollectionViewManager {
//    @property (assign, nonatomic) NSUInteger currentIndex;
    NSUInteger _currentIndex;
}


#pragma mark - UICollectionViewDataSource
#pragma mark -

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return MAX(1, self.imageModels.count);
}

- (void)previousButtonTapped:(id)sender {
    
    [self goPrevious];
    
}

- (void)nextButtonTapped:(id)sender {
    [self goNext];
}


// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    // dequeue named cell template
    
    NSLog(@"made it into manager!");
    static NSString *ImageCellIdentifier = @"ImageCell";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ImageCellIdentifier forIndexPath:indexPath];
    
    if (self.imageModels.count) {
        // get image view by tag and use NetworkHelper to load image
        //attach previous and next buttons to goPrevious and goNext to trigger image transitions
        
        UIButton *previousButton = (UIButton *)[cell viewWithTag:kPreviousButton];
        UIButton *nextButton = (UIButton *)[cell viewWithTag:kNextButton];
        
        if (self.imageModels.count > 1) {
            [previousButton addTarget:self action:@selector(previousButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            [nextButton addTarget:self action:@selector(nextButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            
        }else{
            previousButton.hidden = TRUE;
            nextButton.hidden = TRUE;
        }
        
        UIImageView *imageView = (UIImageView *)[cell viewWithTag:kImageView];
        
        ImageModel *imageModel = self.imageModels[indexPath.item];
        
        __weak UIImageView *weakImageView = imageView;
        [NetworkHelper loadImage:imageModel placeholderImage:nil withThumbImageBlock:^(UIImage *thumbImage) {
            weakImageView.image = thumbImage;
        } withFullImageBlock:^(UIImage *fullImage) {
            weakImageView.image = fullImage;
        } withErrorBlock:^(NSError *error) {
            weakImageView.image = nil;
            [Tracker logError:error class:[self class] trace:NSStringFromSelector(_cmd)];
        }];
        
        UILabel *descriptionLabel = (UILabel *)[cell viewWithTag:kDescriptionLabel];
        descriptionLabel.hidden = TRUE;
        
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
        [self.delegate imageCollectionViewManager:self didSelectImageAtIndex:_currentIndex];
    }
    
}

#pragma mark - UIScrollViewDelegate
#pragma mark -

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == self.collectionView) {
        NSIndexPath *indexPath = [self indexPathForCurrentItemInCollectionView:self.collectionView];
        if (indexPath.item != _currentIndex) {
            _currentIndex = indexPath.item;
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
    
    if (index != _currentIndex && index < self.imageModels.count) {
        NSLog(@"Manager - Changing to index: %lu", (long)index);
        _currentIndex = index;
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:_currentIndex inSection:0];
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
    if ([self hasPrevious] && _currentIndex > 0) {
        [self changeIndex:(_currentIndex - 1)];
    }
}

- (void)goNext {
    if ([self hasNext]) {
        [self changeIndex:(_currentIndex+1)];
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
    }else{
        button.alpha = 1.0;
        button.enabled = FALSE;
    }
}

- (void)reportedChangedIndex {
    if ([self.delegate respondsToSelector:@selector(imageCollectionViewManager:didChangeToImageAtIndex:)]) {
        [self.delegate imageCollectionViewManager:self didChangeToImageAtIndex:_currentIndex];
    }
}



@end
