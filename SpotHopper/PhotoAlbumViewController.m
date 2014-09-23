//
//  PhotoAlbumViewController.m
//  SpotHopper
//
//  Created by Brennan Stehling on 4/30/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "PhotoAlbumViewController.h"

#import "UIViewController+Navigator.h"

#import "ImageModel.h"
#import "NetworkHelper.h"

@interface PhotoAlbumViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;

@end

@implementation PhotoAlbumViewController

#pragma mark - View Lifecycle
#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSCAssert(self.collectionView, @"Outlet is required");
    NSCAssert(self.collectionView.delegate, @"Property is required");
    NSCAssert(self.collectionView.dataSource, @"Property is required");
    
    self.title = @"Photos";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_collectionView reloadData];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - Public
#pragma mark -

- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    _selectedIndex = selectedIndex;
}

#pragma mark - UICollectionViewDataSource
#pragma mark -

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.images.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSCAssert(self.images, @"Images are required");
    if (indexPath.item < self.images.count) {
        ImageModel *imageModel = self.images[indexPath.item];
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ImageCell" forIndexPath:indexPath];
        UIImageView *imageView = (UIImageView *)[cell viewWithTag:1];
        NSCAssert(imageView, @"Image View is required");
        [NetworkHelper loadThumbnailImage:imageModel imageView:imageView placeholderImage:self.placeholderImage];
        
        cell.backgroundColor = self.selectedIndex == indexPath.item ? [UIColor whiteColor] : [UIColor blackColor];
    
        return cell;
    }
    
    return nil;
}

#pragma mark - Navigation
#pragma mark -

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[PhotoViewerViewController class]]) {
        PhotoViewerViewController *photoViewerViewController = segue.destinationViewController;
        photoViewerViewController.images = self.images;
        NSIndexPath *index = [[self.collectionView indexPathsForSelectedItems]lastObject];
        photoViewerViewController.selectedIndex = index.item;
    }
}

#pragma mark - UICollectionViewDelegate
#pragma mark -

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedIndex = indexPath.item;
    [self goToPhotoViewer:_images atIndex:indexPath.item fromPhotoAlbum:self];
}

#pragma mark - PhotoViewerDelegate
#pragma mark -

- (void)photoViewer:(PhotoViewerViewController *)photoViewer didChangeIndex:(NSUInteger)index {
    self.selectedIndex = index;
}

@end
