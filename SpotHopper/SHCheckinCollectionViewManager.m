//
//  SHCheckinCollectionViewManager.m
//  SpotHopper
//
//  Created by Brennan Stehling on 10/2/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "SHCheckinCollectionViewManager.h"

#import "SpotListModel.h"
#import "SpotModel.h"
#import "SpotTypeModel.h"
#import "ImageModel.h"

#import "SHStyleKit+Additions.h"
#import "UIImageView+AFNetworking.h"
#import "ImageUtil.h"

#import "TellMeMyLocation.h"
#import "SHNotifications.h"

#import "SHCollectionViewTableManager.h"

#import "Tracker.h"
#import "Tracker+Events.h"
#import "Tracker+People.h"

#import <CoreLocation/CoreLocation.h>

#define kCheckinCellTableContainerView 600

#pragma mark - Class Extension
#pragma mark -

@interface SHCheckinCollectionViewManager () <SHCollectionViewTableManagerDelegate, UIGestureRecognizerDelegate, UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, weak) IBOutlet id<SHCheckinCollectionViewManagerDelegate> delegate;

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) UITableView *tableView;

@property (strong, nonatomic) CheckInModel *checkin;
@property (strong, nonatomic) SpotModel *spot;

@end

@implementation SHCheckinCollectionViewManager

#pragma mark - Public
#pragma mark -

- (NSUInteger)itemCount {
    return 1;
}

- (void)setCheckin:(CheckInModel *)checkin andSpot:(SpotModel *)spot {
    DebugLog(@"checkin: %@", checkin);
    self.checkin = checkin;
    self.spot = spot;
    
    DebugLog(@"spot: %@", spot.name);
    
    NSAssert(self.collectionView, @"Outlet is required");
    
    [self.collectionView reloadData];
}

#pragma mark - User Actions
#pragma mark -

- (IBAction)shareButtonTapped:(UIButton *)button {
    [Tracker trackUserTappedShare];
    [Tracker trackTappedShare];
    
    [SHNotifications shareCheckin:self.checkin];
}

#pragma mark - SHCollectionViewTableManagerDelegate
#pragma mark -

- (void)collectionViewTableManagerShouldCollapse:(SHCollectionViewTableManager *)mgr {
    if ([self.delegate respondsToSelector:@selector(collectionViewManagerShouldCollapse:)]) {
        [self.delegate collectionViewManagerShouldCollapse:self];
    }
}

#pragma mark - UICollectionViewDataSource
#pragma mark -

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CheckinCellIdentifier = @"CheckinCell";
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CheckinCellIdentifier forIndexPath:indexPath];
    
    UIView *tableContainerView = [cell viewWithTag:kCheckinCellTableContainerView];
    UITableView *tableView = nil;
    if (!tableContainerView.subviews.count) {
        tableView = [self embedTableViewInSuperView:tableContainerView];
    }
    else {
        tableView = (UITableView *)tableContainerView.subviews[0];
    }
    
    SHCollectionViewTableManager *tableManager = [[SHCollectionViewTableManager alloc] init];
    tableManager.delegate = self;
    [tableManager manageTableView:tableView forCheckin:self.checkin atSpot:self.spot];
    [self addTableManager:tableManager forIndexPath:indexPath];
    
    [self renderCell:cell withSpot:self.spot atIndex:indexPath.item];
    
    [self attachedPanGestureToCell:cell];
    
    return cell;
}

#pragma mark - UICollectionViewDelegate
#pragma mark -

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(collectionViewManagerDidTapHeader:)]) {
        [self.delegate collectionViewManagerDidTapHeader:self];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(CGRectGetWidth(collectionView.frame), CGRectGetHeight(collectionView.frame));
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    [self removeTableManagerForIndexPath:indexPath];
}

#pragma mark - Base Overrides
#pragma mark -

- (void)renderCell:(UICollectionViewCell *)cell withSpot:(SpotModel *)spot atIndex:(NSUInteger)index {
    DebugLog(@"%@ (%@)", NSStringFromSelector(_cmd), spot.name);
    UIView *headerView = [cell viewWithTag:500];
    
    UIImageView *spotImageView = (UIImageView *)[headerView viewWithTag:1];
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:2];
    UILabel *typeLabel = (UILabel *)[cell viewWithTag:3];
    UIButton *shareImageButton = (UIButton *)[cell viewWithTag:5];
    UIButton *shareTextButton = (UIButton *)[cell viewWithTag:6];
    
    NSAssert(spotImageView, @"View is required");
    NSAssert(nameLabel, @"View is required");
    NSAssert(typeLabel, @"View is required");
    NSAssert(shareImageButton, @"View is required");
    NSAssert(shareTextButton, @"View is required");
    
    [SHStyleKit setButton:shareTextButton normalTextColor:SHStyleKitColorMyTintColor highlightedTextColor:SHStyleKitColorMyTextColor];
    [SHStyleKit setButton:shareImageButton withDrawing:SHStyleKitDrawingShareIcon normalColor:SHStyleKitColorMyTintColor highlightedColor:SHStyleKitColorMyTextTransparentColor size:CGSizeMake(30, 30)];
    
    [shareImageButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [shareImageButton addTarget:self action:@selector(shareButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [shareTextButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [shareTextButton addTarget:self action:@selector(shareButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    spotImageView.image = nil;
    ImageModel *highlightImage = spot.highlightImage;
    
    if (highlightImage) {
        __weak UIImageView *weakImageView = spotImageView;
        [ImageUtil loadImage:highlightImage placeholderImage:spot.placeholderImage withThumbImageBlock:^(UIImage *thumbImage) {
            weakImageView.image = thumbImage;
        } withFullImageBlock:^(UIImage *fullImage) {
            weakImageView.image = fullImage;
        } withErrorBlock:^(NSError *error) {
            weakImageView.image = spot.placeholderImage;
            [Tracker logError:error class:[self class] trace:NSStringFromSelector(_cmd)];
        }];
    }
    else {
        spotImageView.image = spot.placeholderImage;
    }
    
    nameLabel.text = spot.name;
    typeLabel.text = spot.spotType.name;
}

@end
