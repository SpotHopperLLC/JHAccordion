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
#import "NetworkHelper.h"

@interface PhotoViewerViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

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
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
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
        }];
    }
    else {
        // fade out navigation
        
        [UIView animateWithDuration:0.4 animations:^{
            [self setNeedsStatusBarAppearanceUpdate];
            self.navigationController.navigationBar.alpha = 0.0;
            self.navigationController.toolbar.alpha = 0.0;
        } completion:^(BOOL finished) {
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
        PZPhotoView *photoView = (PZPhotoView *)view;
        ImageModel *imageModel = (ImageModel *)_images[indexPath.item];
        [NetworkHelper loadImage:imageModel placeholderImage:nil withThumbImageBlock:^(UIImage *thumbImage) {
            [photoView displayImage:thumbImage];
        } withFullImageBlock:^(UIImage *fullImage) {
            [photoView displayImage:fullImage];
        } withErrorBlock:^(NSError *error) {
            NSLog(@"Error: %@", error);
        }];
    }
    
    return cell;
}

#pragma mark - UICollectionViewDelegate
#pragma mark -

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Selected item!");
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
