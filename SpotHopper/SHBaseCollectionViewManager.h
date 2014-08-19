//
//  SHBaseCollectionViewManager.h
//  SpotHopper
//
//  Created by Brennan Stehling on 5/21/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SpotModel;

@interface SHBaseCollectionViewManager : NSObject

- (void)renderCell:(UICollectionViewCell *)cell withSpot:(SpotModel *)spot atIndex:(NSUInteger)index;

- (UILabel *)labelInView:(UIView *)view withTag:(NSUInteger)tag;
- (UIButton *)buttonInView:(UIView *)view withTag:(NSUInteger)tag;
- (UITextView *)textViewInView:(UIView *)view withTag:(NSUInteger)tag;
- (UIImageView *)imageViewInView:(UIView *)view withTag:(NSUInteger)tag;

- (NSIndexPath *)indexPathForCurrentItemInCollectionView:(UICollectionView *)collectionView;

@end
