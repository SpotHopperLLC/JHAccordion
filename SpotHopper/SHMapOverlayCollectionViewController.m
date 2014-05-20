//
//  SHMapOverlayCollectionViewController.m
//  SpotHopper
//
//  Created by Brennan Stehling on 5/16/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "SHMapOverlayCollectionViewController.h"

#import "SHStyleKit+Additions.h"

@interface SHMapOverlayCollectionViewController () <SHSpotsCollectionViewManagerDelegate, SHSpecialsCollectionViewManagerDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet SHSpotsCollectionViewManager *spotsCollectionViewManager;
@property (weak, nonatomic) IBOutlet SHSpecialsCollectionViewManager *specialsCollectionViewManager;

@end

@implementation SHMapOverlayCollectionViewController

#pragma mark - View Lifecyle
#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad:@[kDidLoadOptionsNoBackground]];
    
    NSAssert(self.collectionView, @"Outlet is required");
    NSAssert(self.spotsCollectionViewManager, @"Outlet is required");
    NSAssert(self.specialsCollectionViewManager, @"Outlet is required");
}

#pragma mark - Public
#pragma mark -

- (void)displaySpotList:(SpotListModel *)spotList {
    self.collectionView.dataSource = self.spotsCollectionViewManager;
    self.collectionView.delegate = self.spotsCollectionViewManager;
    [self.spotsCollectionViewManager updateSpotList:spotList];
}

- (void)displaySpot:(SpotModel *)spot {
    [self.spotsCollectionViewManager changeSpot:spot];
}

- (void)displaySpecialsForSpots:(NSArray *)spots {
    self.collectionView.dataSource = self.specialsCollectionViewManager;
    self.collectionView.delegate = self.specialsCollectionViewManager;
    [self.specialsCollectionViewManager updateSpots:spots];
}

#pragma mark - User Actions
#pragma mark -

- (IBAction)spotCellNameButtonTapped:(id)sender {
    NSLog(@"%@ (%@)", NSStringFromSelector(_cmd), NSStringFromClass([sender class]));
    
    NSUInteger index = [self.spotsCollectionViewManager indexForViewInCollectionViewCell:sender];
    if (index != NSNotFound) {
        NSLog(@"index: %lu", (long)index);
    }
}

- (IBAction)spotCellLeftButtonTapped:(id)sender {
    NSLog(@"%@ (%@)", NSStringFromSelector(_cmd), NSStringFromClass([sender class]));
    
    NSUInteger index = [self.spotsCollectionViewManager indexForViewInCollectionViewCell:sender];
    if (index != NSNotFound) {
        NSLog(@"index: %lu", (long)index);
    }
    
    [self.spotsCollectionViewManager goPrevious];
}

- (IBAction)spotCellRightButtonTapped:(id)sender {
    NSLog(@"%@ (%@)", NSStringFromSelector(_cmd), NSStringFromClass([sender class]));
    
    NSUInteger index = [self.spotsCollectionViewManager indexForViewInCollectionViewCell:sender];
    if (index != NSNotFound) {
        NSLog(@"Overlay - index: %lu", (long)index);
    }
    
    [self.spotsCollectionViewManager goNext];
}

#pragma mark - SHSpotsCollectionViewManagerDelegate
#pragma mark -

- (void)spotsCollectionViewManager:(SHSpotsCollectionViewManager *)manager didChangeToSpotAtIndex:(NSUInteger)index {
    NSLog(@"Overlay - didChangeToSpotAtIndex: %lu", (long)index);
    
    if ([self.delegate respondsToSelector:@selector(mapOverlayCollectionViewController:didChangeToSpotAtIndex:)]) {
        [self.delegate mapOverlayCollectionViewController:self didChangeToSpotAtIndex:index];
    }
}

- (void)spotsCollectionViewManager:(SHSpotsCollectionViewManager *)manager didSelectSpotAtIndex:(NSUInteger)index {
    NSLog(@"Overlay - didSelectSpotAtIndex: %lu", (long)index);

    if ([self.delegate respondsToSelector:@selector(mapOverlayCollectionViewController:didSelectSpotAtIndex:)]) {
        [self.delegate mapOverlayCollectionViewController:self didSelectSpotAtIndex:index];
    }
}

#pragma mark - SHSpecialsCollectionViewManagerDelegate
#pragma mark -

- (void)specialsCollectionViewManager:(SHSpecialsCollectionViewManager *)manager didChangeToSpotAtIndex:(NSUInteger)index {
    NSLog(@"Overlay - didChangeToSpotAtIndex: %lu", (long)index);
    
    if ([self.delegate respondsToSelector:@selector(mapOverlayCollectionViewController:didChangeToSpotAtIndex:)]) {
        [self.delegate mapOverlayCollectionViewController:self didChangeToSpotAtIndex:index];
    }
}

- (void)specialsCollectionViewManager:(SHSpecialsCollectionViewManager *)manager didSelectSpotAtIndex:(NSUInteger)index {
    NSLog(@"Overlay - didSelectSpotAtIndex: %lu", (long)index);
    
    if ([self.delegate respondsToSelector:@selector(mapOverlayCollectionViewController:didSelectSpotAtIndex:)]) {
        [self.delegate mapOverlayCollectionViewController:self didSelectSpotAtIndex:index];
    }
}

@end
