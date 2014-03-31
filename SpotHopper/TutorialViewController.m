//
//  TutorialViewController.m
//  SpotHopper
//
//  Created by Brennan Stehling on 3/28/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "TutorialViewController.h"

@interface TutorialViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@end

@implementation TutorialViewController

#pragma mark - UICollectionViewDelegate

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 0;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return  nil;
}

#pragma mark - Images

- (UIImage *)dotFilledImage {
    static UIImage *image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(30, 30), NO, 0.0f);
        
        UIBezierPath* dotPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(1.5, 1.5, 27, 27)];
        [[UIColor whiteColor] setFill];
        [dotPath fill];
        
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
    });
    return image;
}

- (UIImage *)dotOutlinedImage {
    static UIImage *image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(30, 30), NO, 0.0f);
        
        UIBezierPath* dotPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(1.5, 1.5, 27, 27)];
        [[UIColor whiteColor] setStroke];
        dotPath.lineWidth = 2;
        [dotPath stroke];
        
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
    });
    return image;
}

@end
