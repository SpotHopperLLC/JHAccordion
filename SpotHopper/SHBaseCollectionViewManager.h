//
//  SHBaseCollectionViewManager.h
//  SpotHopper
//
//  Created by Brennan Stehling on 5/21/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SpotModel, SHCollectionViewTableManager;

@protocol SHBaseCollectionViewManagerDelegate;

@interface SHBaseCollectionViewManager : NSObject

@property (weak, nonatomic) id<SHBaseCollectionViewManagerDelegate> delegate;

@property (assign, nonatomic) NSUInteger currentIndex;
@property (readonly, nonatomic) NSUInteger itemCount;

- (void)addTableManager:(SHCollectionViewTableManager *)tableManager forIndexPath:(NSIndexPath *)indexPath;

- (void)removeTableManagerForIndexPath:(NSIndexPath *)indexPath;

- (void)expandedViewDidAppear;

- (void)expandedViewDidDisappear;

- (void)attachedPanGestureToCell:(UICollectionViewCell *)cell;

- (UILabel *)labelInView:(UIView *)view withTag:(NSUInteger)tag;
- (UIButton *)buttonInView:(UIView *)view withTag:(NSUInteger)tag;
- (UITextView *)textViewInView:(UIView *)view withTag:(NSUInteger)tag;
- (UIImageView *)imageViewInView:(UIView *)view withTag:(NSUInteger)tag;

- (NSIndexPath *)indexPathForCurrentItemInCollectionView:(UICollectionView *)collectionView;
- (UITableView *)embedTableViewInSuperView:(UIView *)superview;

@end

@protocol SHBaseCollectionViewManagerDelegate <NSObject>

@required

- (UIView *)collectionViewManagerPrimaryView:(SHBaseCollectionViewManager *)mgr;

- (UITableView *)collectionViewManager:(SHBaseCollectionViewManager *)mgr embedTableViewInSuperview:(UIView *)superview;

@optional

- (void)collectionViewManagerDidTapHeader:(SHBaseCollectionViewManager *)mgr;

- (void)collectionViewManagerShouldCollapse:(SHBaseCollectionViewManager *)mgr;

- (void)collectionViewManager:(SHBaseCollectionViewManager *)mgr didMoveToPoint:(CGPoint)point;

- (void)collectionViewManager:(SHBaseCollectionViewManager *)mgr didStopMovingAtPoint:(CGPoint)point withVelocity:(CGPoint)velocity;

@end
