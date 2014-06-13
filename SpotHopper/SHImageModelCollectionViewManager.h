//
//  SHImageModelCollectionViewManager.h
//  SpotHopper
//
//  Created by Tracee Pettigrew on 5/30/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SHBaseCollectionViewManager.h"
#import "ImageModel.h"

@protocol SHImageModelCollectionDelegate;

@interface SHImageModelCollectionViewManager : SHBaseCollectionViewManager <UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) NSArray *imageModels;

- (void)changeIndex:(NSUInteger)index;
- (void)changeImage:(ImageModel *)spot;

- (NSUInteger)indexForViewInCollectionViewCell:(UIView *)view;

- (BOOL)hasPrevious;
- (BOOL)hasNext;

- (void)goPrevious;
- (void)goNext;

@end

@protocol SHImageModelCollectionDelegate<NSObject>

@optional
- (void)imageCollectionViewManager:(SHImageModelCollectionViewManager *)manager didChangeToImageAtIndex:(NSUInteger)index;
- (void)imageCollectionViewManager:(SHImageModelCollectionViewManager *)manager didSelectImageAtIndex:(NSUInteger)index;

@end
