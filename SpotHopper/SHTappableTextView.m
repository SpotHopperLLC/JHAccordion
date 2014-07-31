//
//  SHTappableTextView.m
//  SpotHopper
//
//  Created by Brennan Stehling on 7/30/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "SHTappableTextView.h"

@implementation SHTappableTextView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapRecognized:)];
    singleTap.numberOfTapsRequired = 1;
    [self addGestureRecognizer:singleTap];
}

- (void)singleTapRecognized:(id)sender {
    UIView *superview = self.superview;
    
    UICollectionViewCell *cell = nil;
    NSIndexPath *indexPath = nil;
    
    while (superview) {
        if ([superview isKindOfClass:[UICollectionViewCell class]]) {
            cell = (UICollectionViewCell *)superview;
        }
        
        if ([superview isKindOfClass:[UICollectionView class]] && cell) {
            UICollectionView *collectionView = (UICollectionView *)superview;
            indexPath = [collectionView indexPathForCell:cell];
            NSAssert(collectionView.delegate, @"Delegate must be defined");
            NSAssert([collectionView.delegate respondsToSelector:@selector(collectionView:didSelectItemAtIndexPath:)], @"Selection must be supported");
            if (indexPath && [collectionView.delegate respondsToSelector:@selector(collectionView:didSelectItemAtIndexPath:)]) {
                [collectionView.delegate collectionView:collectionView didSelectItemAtIndexPath:indexPath];
            }
            
            return;
        }
        
        superview = superview.superview;
    }
}

@end
