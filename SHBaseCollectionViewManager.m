//
//  SHBaseCollectionViewManager.m
//  SpotHopper
//
//  Created by Brennan Stehling on 5/21/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "SHBaseCollectionViewManager.h"

@implementation SHBaseCollectionViewManager

#pragma mark - Methods to override
#pragma mark -

- (void)renderCell:(UICollectionViewCell *)cell withSpot:(SpotModel *)spot atIndex:(NSUInteger)index {
    // override
}

#pragma mark - Helper Methods
#pragma mark -

- (UILabel *)labelInView:(UIView *)view withTag:(NSUInteger)tag {
    UIView *taggedView = [view viewWithTag:tag];
    if ([taggedView isKindOfClass:[UILabel class]]) {
        return (UILabel *)taggedView;
    }
    return nil;
}

- (UIButton *)buttonInView:(UIView *)view withTag:(NSUInteger)tag {
    UIView *taggedView = [view viewWithTag:tag];
    if ([taggedView isKindOfClass:[UIButton class]]) {
        return (UIButton *)taggedView;
    }
    return nil;
}

- (UITextView *)textViewInView:(UIView *)view withTag:(NSUInteger)tag {
    UIView *taggedView = [view viewWithTag:tag];
    if ([taggedView isKindOfClass:[UITextView class]]) {
        return (UITextView *)taggedView;
    }
    return nil;
}

- (UIImageView *)imageViewInView:(UIView *)view withTag:(NSUInteger)tag {
    UIView *taggedView = [view viewWithTag:tag];
    if ([taggedView isKindOfClass:[UIImageView class]]) {
        return (UIImageView *)taggedView;
    }
    return nil;
}

- (NSIndexPath *)indexPathForCurrentItemInCollectionView:(UICollectionView *)collectionView {
    NSArray *indexPaths = [collectionView indexPathsForVisibleItems];
    if (indexPaths.count) {
        return indexPaths[0];
    }
    
    return nil;
}

@end
