//
//  PhotoViewerViewController.m
//  SpotHopper
//
//  Created by Brennan Stehling on 5/7/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "PhotoViewerViewController.h"

#import "UIViewController+Navigator.h"

#import "PZPhotoView.h"
#import "ImageModel.h"
#import "ImageUtil.h"

@interface PhotoViewerViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation PhotoViewerViewController {
    BOOL _isFullScreen;
}

#pragma mark - View Lifecycle
#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Photos";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (_images.count) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.selectedIndex inSection:0];
        [_collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:FALSE];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden {
    return _isFullScreen;
}

#pragma mark - Private
#pragma mark -

- (void)toggleFullScreen {
    _isFullScreen = !_isFullScreen;
    
    if (!_isFullScreen) {
        // fade in navigation
        
        [UIView animateWithDuration:0.4 animations:^{
            [self setNeedsStatusBarAppearanceUpdate];
            self.navigationController.navigationBar.alpha = 1.0;
            self.navigationController.toolbar.alpha = 1.0;
        } completion:^(BOOL finished) {
//            [[UIApplication sharedApplication] setStatusBarHidden:FALSE];
        }];
    }
    else {
        // fade out navigation
        
        [UIView animateWithDuration:0.4 animations:^{
            [self setNeedsStatusBarAppearanceUpdate];
            self.navigationController.navigationBar.alpha = 0.0;
            self.navigationController.toolbar.alpha = 0.0;
        } completion:^(BOOL finished) {
//            [[UIApplication sharedApplication] setStatusBarHidden:TRUE];
        }];
    }
}

#pragma mark - UICollectionViewDataSource
#pragma mark -

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _images.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoView" forIndexPath:indexPath];
    
    UIView *view = [cell viewWithTag:1];
    if ([view isKindOfClass:[PZPhotoView class]]) {
        __weak PZPhotoView *photoView = (PZPhotoView *)view;
        ImageModel *imageModel = (ImageModel *)_images[indexPath.item];
        [ImageUtil loadImage:imageModel placeholderImage:nil withThumbImageBlock:^(UIImage *thumbImage) {
            [photoView displayImage:thumbImage];
        } withFullImageBlock:^(UIImage *fullImage) {
            [photoView displayImage:fullImage];
        } withErrorBlock:^(NSError *error) {
            // do nothing
        }];
    }
    
    return cell;
}

#pragma mark - UICollectionViewDelegate
#pragma mark -

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return FALSE;
}

//- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
//    // do nothing
//}

#pragma mark - UIScrollViewDelegate
#pragma mark -

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSArray *visibleItems = [_collectionView indexPathsForVisibleItems];
    if (visibleItems.count) {
        NSIndexPath *indexPath = (NSIndexPath *)visibleItems[0];
        self.selectedIndex = indexPath.item;
        
        if ([_delegate respondsToSelector:@selector(photoViewer:didChangeIndex:)]) {
            [_delegate photoViewer:self didChangeIndex:self.selectedIndex];
        }
    }
}

#pragma mark - PZPhotoViewDelegate
#pragma mark -

- (void)photoViewDidSingleTap:(PZPhotoView *)photoView {
    [self toggleFullScreen];
}

- (void)photoViewDidDoubleTap:(PZPhotoView *)photoView {
    // do nothing
}

- (void)photoViewDidTwoFingerTap:(PZPhotoView *)photoView {
    // do nothing
}

- (void)photoViewDidDoubleTwoFingerTap:(PZPhotoView *)photoView {
    // do nothing
}

@end
