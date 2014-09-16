//
//  SHMapOverlayCollectionViewController.m
//  SpotHopper
//
//  Created by Brennan Stehling on 5/16/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "SHMapOverlayCollectionViewController.h"

#import <UIKit/UIKit.h>

#import "SHStyleKit+Additions.h"

#import "SpotListModel.h"
#import "SpotModel.h"
#import "DrinkListModel.h"
#import "LikeModel.h"
#import "SpecialModel.h"

#import "Tracker.h"
#import "Tracker+Events.h"
#import "Tracker+People.h"

#import "SHNotifications.h"

#import "UIAlertView+Block.h"

typedef enum {
    SHOverlayCollectionViewModeNone = 0,
    SHOverlayCollectionViewModeSpotlists,
    SHOverlayCollectionViewModeSpecials,
    SHOverlayCollectionViewModeDrinklists,
    SHOverlayCollectionViewModeSpot,
    SHOverlayCollectionViewModeDrink
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
    
//    // HACK: position must be set to appear at the top
//    CGRect frame = self.collectionView.frame;
//    frame.origin.y = 0.0f;
//    self.collectionView.frame = frame;
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

- (void)displaySingleSpot:(SpotModel *)spot {
    self.mode = SHOverlayCollectionViewModeSpot;

    self.collectionView.dataSource = self.spotsCollectionViewManager;
    self.collectionView.delegate = self.spotsCollectionViewManager;
    
    SpotListModel *spotlist = [[SpotListModel alloc] init];
    spotlist.spots = @[spot];
    [self.spotsCollectionViewManager updateSpotList:spotlist];
}

- (void)displayDrink:(DrinkModel *)drink {
    if (self.mode == SHOverlayCollectionViewModeDrinklists) {
        [self.drinksCollectionViewManager changeDrink:drink];
    }
}

- (void)displaySingleDrink:(DrinkModel *)drink {
    self.mode = SHOverlayCollectionViewModeDrink;
    
    self.collectionView.dataSource = self.drinksCollectionViewManager;
    self.collectionView.delegate = self.drinksCollectionViewManager;

    DrinkListModel *drinklist = [[DrinkListModel alloc] init];
    drinklist.drinks = @[drink];
    [self.drinksCollectionViewManager updateDrinkList:drinklist];
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

- (void)expandedViewDidAppear {
    // TODO: do something
    DebugLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)expandedViewDidDisappear {
    // TODO: do something
    DebugLog(@"%@", NSStringFromSelector(_cmd));
}

#pragma mark - Private
#pragma mark -

#pragma mark - User Actions
#pragma mark -

- (IBAction)spotCellLeftButtonTapped:(id)sender {
    [self.spotsCollectionViewManager goPrevious];
}

- (IBAction)spotCellRightButtonTapped:(id)sender {
    [self.spotsCollectionViewManager goNext];
}

- (IBAction)spotCellFindSimilarButtonTapped:(id)sender {
    if (self.mode == SHOverlayCollectionViewModeSpot) {
        NSUInteger index = [self.spotsCollectionViewManager indexForViewInCollectionViewCell:sender];
        if (index != NSNotFound) {
            SpotModel *spot = [self.spotsCollectionViewManager spotAtIndex:index];
            [SHNotifications findSimilarToSpot:spot];
        }
    }
}

- (IBAction)spotCellReviewItButtonTapped:(id)sender {
    if (self.mode == SHOverlayCollectionViewModeSpot) {
        NSUInteger index = [self.spotsCollectionViewManager indexForViewInCollectionViewCell:sender];
        if (index != NSNotFound) {
            SpotModel *spot = [self.spotsCollectionViewManager spotAtIndex:index];
            [SHNotifications reviewSpot:spot];
        }
    }
}

- (IBAction)spotCellMenuButtonTapped:(id)sender {
    if (self.mode == SHOverlayCollectionViewModeSpot) {
        NSUInteger index = [self.spotsCollectionViewManager indexForViewInCollectionViewCell:sender];
        if (index != NSNotFound) {
            SpotModel *spot = [self.spotsCollectionViewManager spotAtIndex:index];
            [SHNotifications openMenuForSpot:spot];
        }
    }
}

- (IBAction)specialCellLeftButtonTapped:(id)sender {
    [self.specialsCollectionViewManager goPrevious];
}

- (IBAction)specialCellRightButtonTapped:(id)sender {
    [self.specialsCollectionViewManager goNext];
}

- (IBAction)specialCellLikeButtonTapped:(id)sender {
    NSUInteger index = [self.specialsCollectionViewManager indexForViewInCollectionViewCell:sender];
    SpotModel *spot = [self.specialsCollectionViewManager spotAtIndex:index];
    SpecialModel *special = [spot specialForToday];
    
    if (!special.spot) {
        special.spot = spot;
    }
    
    if (special.userLikesSpecial) {
        [[LikeModel unlikeSpecial:special] then:^(NSNumber *number) {
            special.userLikesSpecial = FALSE;
            special.likeCount--;
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
            [self.specialsCollectionViewManager updateCellAtIndexPath:indexPath];
        } fail:^(ErrorModel *errorModel) {
            [Tracker logError:errorModel class:[self class] trace:NSStringFromSelector(_cmd)];
        } always:nil];
    }
    else {
        [LikeModel likeSpecial:special success:^(LikeModel *like) {
            special.userLikesSpecial = TRUE;
            special.likeCount++;
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
            [self.specialsCollectionViewManager updateCellAtIndexPath:indexPath];
        } failure:^(ErrorModel *errorModel) {
            [Tracker logError:errorModel class:[self class] trace:NSStringFromSelector(_cmd)];
        }];
    }
}

- (IBAction)specialCellShareButtonTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(mapOverlayCollectionViewController:didRequestShareSpecialForSpotAtIndex:)]) {
        NSUInteger index = [self.specialsCollectionViewManager indexForViewInCollectionViewCell:sender];
        [self.delegate mapOverlayCollectionViewController:self didRequestShareSpecialForSpotAtIndex:index];
    }
}

- (IBAction)drinkCellLeftButtonTapped:(id)sender {
    [self.drinksCollectionViewManager goPrevious];
}

- (IBAction)drinkCellRightButtonTapped:(id)sender {
    [self.drinksCollectionViewManager goNext];
}

- (IBAction)drinkCellFindSimilarButtonTapped:(id)sender {
    if (self.mode == SHOverlayCollectionViewModeDrink) {
        NSUInteger index = [self.drinksCollectionViewManager indexForViewInCollectionViewCell:sender];
        if (index != NSNotFound) {
            DrinkModel *drink = [self.drinksCollectionViewManager drinkAtIndex:index];
            [SHNotifications findSimilarToDrink:drink];
        }
    }
}

- (IBAction)drinkCellReviewItButtonTapped:(id)sender {
    if (self.mode == SHOverlayCollectionViewModeDrink) {
        NSUInteger index = [self.drinksCollectionViewManager indexForViewInCollectionViewCell:sender];
        if (index != NSNotFound) {
            DrinkModel *drink = [self.drinksCollectionViewManager drinkAtIndex:index];
            [SHNotifications reviewDrink:drink];
        }
    }
}

#pragma mark - SHBaseCollectionViewManagerDelegate
#pragma mark -

- (UIView *)collectionViewManagerPrimaryView:(SHBaseCollectionViewManager *)mgr{
    if ([self.delegate respondsToSelector:@selector(mapOverlayCollectionViewControllerPrimaryView:)]) {
        return [self.delegate mapOverlayCollectionViewControllerPrimaryView:self];
    }
    
    return nil;
}

- (void)collectionViewManagerDidTapHeader:(SHBaseCollectionViewManager *)mgr {
    if ([self.delegate respondsToSelector:@selector(mapOverlayCollectionViewControllerDidTapHeader:)]) {
        [self.delegate mapOverlayCollectionViewControllerDidTapHeader:self];
    }
}

- (void)collectionViewManagerShouldCollapse:(SHBaseCollectionViewManager *)mgr {
    if ([self.delegate respondsToSelector:@selector(mapOverlayCollectionViewControllerShouldCollapse:)]) {
        [self.delegate mapOverlayCollectionViewControllerShouldCollapse:self];
    }
}

- (void)collectionViewManager:(SHBaseCollectionViewManager *)mgr didMoveToPoint:(CGPoint)point {
    if ([self.delegate respondsToSelector:@selector(mapOverlayCollectionViewController:didMoveToPoint:)]) {
        [self.delegate mapOverlayCollectionViewController:self didMoveToPoint:point];
    }
}

- (void)collectionViewManager:(SHBaseCollectionViewManager *)mgr didStopMovingAtPoint:(CGPoint)point withVelocity:(CGPoint)velocity {
    if ([self.delegate respondsToSelector:@selector(mapOverlayCollectionViewController:didStopMovingAtPoint:withVelocity:)]) {
        [self.delegate mapOverlayCollectionViewController:self didStopMovingAtPoint:point withVelocity:velocity];
    }
}

#pragma mark - SHSpotsCollectionViewManagerDelegate
#pragma mark -

- (void)spotsCollectionViewManager:(SHSpotsCollectionViewManager *)manager didChangeToSpotAtIndex:(NSUInteger)index {
    if ([self.delegate respondsToSelector:@selector(mapOverlayCollectionViewController:didChangeToSpotAtIndex:)]) {
        [self.delegate mapOverlayCollectionViewController:self didChangeToSpotAtIndex:index];
    }
}

- (void)spotsCollectionViewManager:(SHSpotsCollectionViewManager *)manager didSelectSpotAtIndex:(NSUInteger)index {
    if ([self.delegate respondsToSelector:@selector(mapOverlayCollectionViewController:didSelectSpotAtIndex:)]) {
        [self.delegate mapOverlayCollectionViewController:self didSelectSpotAtIndex:index];
    }
}

#pragma mark - SHSpecialsCollectionViewManagerDelegate
#pragma mark -

- (void)specialsCollectionViewManager:(SHSpecialsCollectionViewManager *)manager didChangeToSpotAtIndex:(NSUInteger)index {
    if ([self.delegate respondsToSelector:@selector(mapOverlayCollectionViewController:didChangeToSpotAtIndex:)]) {
        [self.delegate mapOverlayCollectionViewController:self didChangeToSpotAtIndex:index];
    }
}

- (void)specialsCollectionViewManager:(SHSpecialsCollectionViewManager *)manager didSelectSpotAtIndex:(NSUInteger)index {
    if ([self.delegate respondsToSelector:@selector(mapOverlayCollectionViewController:didSelectSpotAtIndex:)]) {
        [self.delegate mapOverlayCollectionViewController:self didSelectSpotAtIndex:index];
    }
}

- (void)specialsCollectionViewManager:(SHSpecialsCollectionViewManager *)manager didRequestShareSpecialForSpotAtIndex:(NSUInteger)index {
    if ([self.delegate respondsToSelector:@selector(mapOverlayCollectionViewController:didRequestShareSpecialForSpotAtIndex:)]) {
        [self.delegate mapOverlayCollectionViewController:self didRequestShareSpecialForSpotAtIndex:index];
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
