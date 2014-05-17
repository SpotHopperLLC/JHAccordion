//
//  SHMapOverlayCollectionViewController.m
//  SpotHopper
//
//  Created by Brennan Stehling on 5/16/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "SHMapOverlayCollectionViewController.h"

#import "SHStyleKit+Additions.h"

@interface SHMapOverlayCollectionViewController () <SHSpotsCollectionViewManagerDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet SHSpotsCollectionViewManager *spotsCollectionViewManager;

@end

@implementation SHMapOverlayCollectionViewController

#pragma mark - View Lifecyle
#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad:@[kDidLoadOptionsNoBackground]];
}

#pragma mark - Public
#pragma mark -

- (void)displaySpotList:(SpotListModel *)spotList {
    NSCAssert(self.spotsCollectionViewManager, @"Manager outlet is required");
    [self.spotsCollectionViewManager updateSpotList:spotList];
}

#pragma mark - User Actions
#pragma mark -

- (IBAction)spotCellNameButtonTapped:(id)sender {
    // TODO: use sender to determine view and index for spot
    NSLog(@"%@ (%@)", NSStringFromSelector(_cmd), NSStringFromClass([sender class]));
    
    NSUInteger index = [self.spotsCollectionViewManager indexForViewInCollectionViewCell:sender];
    if (index != NSNotFound) {
        NSLog(@"index: %lu", (long)index);
    }
}

- (IBAction)spotCellLeftButtonTapped:(id)sender {
    // TODO: use sender to determine view and index for spot
    NSLog(@"%@ (%@)", NSStringFromSelector(_cmd), NSStringFromClass([sender class]));
    
    NSUInteger index = [self.spotsCollectionViewManager indexForViewInCollectionViewCell:sender];
    if (index != NSNotFound) {
        NSLog(@"index: %lu", (long)index);
    }
    
    [self.spotsCollectionViewManager goPrevious];
}

- (IBAction)spotCellRightButtonTapped:(id)sender {
    // TODO: use sender to determine view and index for spot
    NSLog(@"%@ (%@)", NSStringFromSelector(_cmd), NSStringFromClass([sender class]));
    
    NSUInteger index = [self.spotsCollectionViewManager indexForViewInCollectionViewCell:sender];
    if (index != NSNotFound) {
        NSLog(@"index: %lu", (long)index);
    }
    
    [self.spotsCollectionViewManager goNext];
}

#pragma mark - SHSpotsCollectionViewManagerDelegate
#pragma mark -

- (void)spotsCollectionViewManager:(SHSpotsCollectionViewManager *)manager didChangeToIndex:(NSUInteger)index {
    NSLog(@"index: %lu", (long)index);
    
    if ([self.delegate respondsToSelector:@selector(mapOverlayCollectionViewController:didChangeToSpotAtIndex:)]) {
        [self.delegate mapOverlayCollectionViewController:self didChangeToSpotAtIndex:index];
    }
}

@end
