//
//  SHMapOverlayCollectionViewController.m
//  SpotHopper
//
//  Created by Brennan Stehling on 5/16/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "SHMapOverlayCollectionViewController.h"

#import "SHStyleKit+Additions.h"

#import "SpotListModel.h"
#import "SpotModel.h"
#import "DrinkListModel.h"

#import "UIAlertView+Block.h"

typedef enum {
    SHOverlayCollectionViewModeNone = 0,
    SHOverlayCollectionViewModeSpotlists,
    SHOverlayCollectionViewModeSpecials,
    SHOverlayCollectionViewModeDrinklists
} SHOverlayCollectionViewMode;

@interface SHMapOverlayCollectionViewController () <SHSpotsCollectionViewManagerDelegate, SHSpecialsCollectionViewManagerDelegate, SHDrinksCollectionViewManagerDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet SHSpotsCollectionViewManager *spotsCollectionViewManager;
@property (weak, nonatomic) IBOutlet SHSpecialsCollectionViewManager *specialsCollectionViewManager;
@property (weak, nonatomic) IBOutlet SHDrinksCollectionViewManager *drinksCollectionViewManager;

@property (assign, nonatomic) SHOverlayCollectionViewMode mode;

@end

@implementation SHMapOverlayCollectionViewController

#pragma mark - View Lifecyle
#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad:@[kDidLoadOptionsNoBackground]];
    
    NSAssert(self.collectionView, @"Outlet is required");
    NSAssert(self.spotsCollectionViewManager, @"Outlet is required");
    NSAssert(self.drinksCollectionViewManager, @"Outlet is required");
    NSAssert(self.specialsCollectionViewManager, @"Outlet is required");
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.collectionView flashScrollIndicators];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

#pragma mark - Public
#pragma mark -

- (void)displaySpotList:(SpotListModel *)spotList {
    self.collectionView.frame = self.view.frame;
    self.mode = SHOverlayCollectionViewModeSpotlists;
    self.collectionView.dataSource = self.spotsCollectionViewManager;
    self.collectionView.delegate = self.spotsCollectionViewManager;
    [self.spotsCollectionViewManager updateSpotList:spotList];
}

- (void)displaySpot:(SpotModel *)spot {
    if (self.mode == SHOverlayCollectionViewModeSpotlists) {
        [self.spotsCollectionViewManager changeSpot:spot];
    }
    else if (self.mode == SHOverlayCollectionViewModeSpecials) {
        [self.specialsCollectionViewManager changeSpot:spot];
    }
}

- (void)displayDrink:(DrinkModel *)drink {
    if (self.mode == SHOverlayCollectionViewModeDrinklists) {
        [self.drinksCollectionViewManager changeDrink:drink];
    }
}

- (void)displaySpecialsForSpots:(NSArray *)spots {
    self.mode = SHOverlayCollectionViewModeSpecials;
    self.collectionView.dataSource = self.specialsCollectionViewManager;
    self.collectionView.delegate = self.specialsCollectionViewManager;
    [self.specialsCollectionViewManager updateSpots:spots];
}

- (void)displayDrinklist:(DrinkListModel *)drinklist {
    self.mode = SHOverlayCollectionViewModeDrinklists;
    self.collectionView.dataSource = self.drinksCollectionViewManager;
    self.collectionView.delegate = self.drinksCollectionViewManager;
    [self.drinksCollectionViewManager updateDrinkList:drinklist];
}

#pragma mark - Private
#pragma mark -

#pragma mark - User Actions
#pragma mark -

- (IBAction)spotCellNameButtonTapped:(id)sender {
    NSLog(@"%@ (%@)", NSStringFromSelector(_cmd), NSStringFromClass([sender class]));
    
    NSUInteger index = [self.spotsCollectionViewManager indexForViewInCollectionViewCell:sender];
    if (index != NSNotFound) {
        NSLog(@"index: %lu", (long)index);
        //call the delegate to trigger transition
        [self spotsCollectionViewManager:self.spotsCollectionViewManager didSelectSpotAtIndex:index];
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

- (IBAction)specialCellNameButtonTapped:(id)sender {
    NSLog(@"%@ (%@)", NSStringFromSelector(_cmd), NSStringFromClass([sender class]));
    
    NSUInteger index = [self.specialsCollectionViewManager indexForViewInCollectionViewCell:sender];
    if (index != NSNotFound) {
        NSLog(@"index: %lu", (long)index);
        [self spotsCollectionViewManager:self.spotsCollectionViewManager didSelectSpotAtIndex:index];
    }
}

- (IBAction)specialCellLeftButtonTapped:(id)sender {
    NSLog(@"%@ (%@)", NSStringFromSelector(_cmd), NSStringFromClass([sender class]));
    
    NSUInteger index = [self.specialsCollectionViewManager indexForViewInCollectionViewCell:sender];
    if (index != NSNotFound) {
        NSLog(@"index: %lu", (long)index);
    }
    
    [self.specialsCollectionViewManager goPrevious];
}

- (IBAction)specialCellRightButtonTapped:(id)sender {
    NSLog(@"%@ (%@)", NSStringFromSelector(_cmd), NSStringFromClass([sender class]));
    
    NSUInteger index = [self.specialsCollectionViewManager indexForViewInCollectionViewCell:sender];
    if (index != NSNotFound) {
        NSLog(@"Overlay - index: %lu", (long)index);
    }
    
    [self.specialsCollectionViewManager goNext];
}

- (IBAction)specialCellLikeButtonTapped:(id)sender {
    NSLog(@"%@ (%@)", NSStringFromSelector(_cmd), NSStringFromClass([sender class]));
    
    // TODO: implement
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops" message:@"This feature is not fully implemented. Please continue development." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
    }];
    
    NSUInteger index = [self.specialsCollectionViewManager indexForViewInCollectionViewCell:sender];
    if (index != NSNotFound) {
        NSLog(@"index: %lu", (long)index);
    }
}

- (IBAction)specialCellShareButtonTapped:(id)sender {
    NSLog(@"%@ (%@)", NSStringFromSelector(_cmd), NSStringFromClass([sender class]));
    
    // TODO: implement
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops" message:@"This feature is not fully implemented. Please continue development." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
    }];
    
    NSUInteger index = [self.specialsCollectionViewManager indexForViewInCollectionViewCell:sender];
    if (index != NSNotFound) {
        NSLog(@"index: %lu", (long)index);
    }
}

- (IBAction)drinkCellNameButtonTapped:(id)sender {
    NSLog(@"%@ (%@)", NSStringFromSelector(_cmd), NSStringFromClass([sender class]));
    
    NSUInteger index = [self.drinksCollectionViewManager indexForViewInCollectionViewCell:sender];
    if (index != NSNotFound) {
        NSLog(@"index: %lu", (long)index);
        [self drinksCollectionViewManager:self.drinksCollectionViewManager didSelectDrinkAtIndex:index];
    }
}

- (IBAction)drinkCellLeftButtonTapped:(id)sender {
    NSLog(@"%@ (%@)", NSStringFromSelector(_cmd), NSStringFromClass([sender class]));
    
    NSUInteger index = [self.drinksCollectionViewManager indexForViewInCollectionViewCell:sender];
    if (index != NSNotFound) {
        NSLog(@"index: %lu", (long)index);
    }
    
    [self.drinksCollectionViewManager goPrevious];
}

- (IBAction)drinkCellRightButtonTapped:(id)sender {
    NSLog(@"%@ (%@)", NSStringFromSelector(_cmd), NSStringFromClass([sender class]));
    
    NSUInteger index = [self.drinksCollectionViewManager indexForViewInCollectionViewCell:sender];
    if (index != NSNotFound) {
        NSLog(@"Overlay - index: %lu", (long)index);
    }
    
    [self.drinksCollectionViewManager goNext];
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

#pragma mark - SHDrinksCollectionViewManagerDelegate
#pragma mark -


- (void)drinksCollectionViewManager:(SHDrinksCollectionViewManager *)manager didChangeToDrinkAtIndex:(NSUInteger)index {
    if ([self.delegate respondsToSelector:@selector(mapOverlayCollectionViewController:didChangeToDrinkAtIndex:)]) {
        [self.delegate mapOverlayCollectionViewController:self didChangeToDrinkAtIndex:index];
    }
}

- (void)drinksCollectionViewManager:(SHDrinksCollectionViewManager *)manager didSelectDrinkAtIndex:(NSUInteger)index {
    if ([self.delegate respondsToSelector:@selector(mapOverlayCollectionViewController:didSelectDrinkAtIndex:)]) {
        [self.delegate mapOverlayCollectionViewController:self didSelectDrinkAtIndex:index];
    }
}

@end
