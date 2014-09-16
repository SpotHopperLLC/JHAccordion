//
//  SHBaseCollectionViewManager.m
//  SpotHopper
//
//  Created by Brennan Stehling on 5/21/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "SHBaseCollectionViewManager.h"

#define kTagHeaderView 500
#define kTagTableView 600

#pragma mark - Class Extension
#pragma mark -

@interface SHBaseCollectionViewManager () <UIGestureRecognizerDelegate>

@property (strong, nonatomic) UIPanGestureRecognizer *panGestureRecognizer;

@end

@implementation SHBaseCollectionViewManager {
    CGPoint _panGestureStartingPoint;
}

#pragma mark - Methods to override
#pragma mark -

- (void)expandedViewDidAppear {
    // do nothing
}

- (void)expandedViewDidDisappear {
    // do nothing
}

- (void)attachedPanGestureToCell:(UICollectionViewCell *)cell {
    if (self.panGestureRecognizer == nil) {
        UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)];
        panGestureRecognizer.delegate = self;
        self.panGestureRecognizer = panGestureRecognizer;
    }
    
    UIView *headerView = [cell viewWithTag:kTagHeaderView];
    headerView.gestureRecognizers = @[self.panGestureRecognizer];
}

#pragma mark - Private
#pragma mark -

- (UIView *)primaryView {
    if ([self.delegate respondsToSelector:@selector(collectionViewManagerPrimaryView:)]) {
        return [self.delegate collectionViewManagerPrimaryView:self];
    }
    
    return nil;
}

- (void)panningDidMoveToPoint:(CGPoint)point {
    DebugLog(@"%@", NSStringFromSelector(_cmd));
    
    if ([self.delegate respondsToSelector:@selector(collectionViewManager:didMoveToPoint:)]) {
        [self.delegate collectionViewManager:self didMoveToPoint:point];
    }
}

- (void)panningDidStopMovingAtPoint:(CGPoint)point withVelocity:(CGPoint)velocity {
    DebugLog(@"%@", NSStringFromSelector(_cmd));
    
    if ([self.delegate respondsToSelector:@selector(collectionViewManager:didStopMovingAtPoint:withVelocity:)]) {
        [self.delegate collectionViewManager:self didStopMovingAtPoint:point withVelocity:velocity];
    }
}

#pragma mark - Gestures
#pragma mark -

- (IBAction)panGestureRecognized:(UIPanGestureRecognizer *)gestureRecognizer {
    LOG_FRAME(@"primary", self.primaryView.frame);
    
    CGPoint point = [gestureRecognizer locationInView:self.primaryView];
    CGFloat adjustedY = point.y - _panGestureStartingPoint.y;
    
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
        case UIGestureRecognizerStateChanged: {
            [self panningDidMoveToPoint:CGPointMake(0.0f, adjustedY)];
        }
            break;
            
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed: {
            CGPoint velocity = [gestureRecognizer velocityInView:gestureRecognizer.view];
            [self panningDidStopMovingAtPoint:CGPointMake(0.0f, adjustedY) withVelocity:velocity];
        }
            
            break;
            
        default:
            NSAssert(FALSE, @"Condition should never occur.");
            break;
    }
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

#pragma mark - UIGestureRecognizerDelegate
#pragma mark -

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer {
    // ensure the pan gesture does not handle horizontal movement so sliders do not
    // interfere with paging the collection view
    
    BOOL should = YES;
    
    if ([gestureRecognizer isEqual:self.panGestureRecognizer]) {
        CGPoint translation = [gestureRecognizer translationInView:gestureRecognizer.view];
        // Check for vertical gesture
        
        should = fabsf(translation.y) > fabsf(translation.x);
        
        if (should) {
            CGPoint point = [gestureRecognizer locationInView:gestureRecognizer.view];
            _panGestureStartingPoint = point;
        }
    }
    
    return should;
}

@end
