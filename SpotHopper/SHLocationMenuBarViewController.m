//
//  SHLocationMenuBarViewController.m
//  SpotHopper
//
//  Created by Brennan Stehling on 5/13/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "SHLocationMenuBarViewController.h"

#import "SHStyleKit.h"
#import "SHStyleKit+Additions.h"

#import "SpotModel.h"

#define kAnimationDuration 0.35f

@interface SHLocationMenuBarViewController ()

@property (weak, nonatomic) IBOutlet UIView *locationView;
@property (weak, nonatomic) IBOutlet UILabel *nearLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UIImageView *locationArrowImageView;
@property (weak, nonatomic) IBOutlet UIButton *pickLocationButton;

@property (weak, nonatomic) IBOutlet UIView *filterView;
@property (weak, nonatomic) IBOutlet UILabel *filterLabel;
@property (weak, nonatomic) IBOutlet UIImageView *filterArrowImageView;
@property (weak, nonatomic) IBOutlet UIButton *filterButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leadingConstraint;

@property (weak, nonatomic) SpotModel *scopedSpot;
@property (weak, nonatomic) SpotModel *selectedSpot;

@end

@implementation SHLocationMenuBarViewController {
    BOOL _isDisplayingSpotDrinklist;
}

#pragma mark - View Lifecycle
#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad:@[kDidLoadOptionsNoBackground]];
    
    UIColor *textColor = [SHStyleKit myTextColor];
    self.nearLabel.textColor = textColor;
    self.locationLabel.textColor = textColor;
    self.filterLabel.textColor = textColor;
    
    UIImage *arrowImage = [SHStyleKit drawImage:SHStyleKitDrawingNavigationArrowRightIcon color:SHStyleKitColorMyTextColor size:CGSizeMake(20, 20)];
    self.locationArrowImageView.image = arrowImage;
    self.filterArrowImageView.image = arrowImage;
    
    [self updateLocationTitle:@"Locating..."];
}

#pragma mark - Public
#pragma mark -

- (void)updateLocationTitle:(NSString *)locationTitle {
    self.locationLabel.text = locationTitle;
}

- (void)selectSpot:(SpotModel *)spot withCompletionBlock:(void (^)())completionBlock {
    if (!self.scopedSpot && self.selectedSpot) {
        self.selectedSpot = spot;
        [self showFilterView:TRUE withCompletionBlock:completionBlock];
    }
    else if (!self.scopedSpot && !self.selectedSpot) {
        self.selectedSpot = spot;
        [self showFilterView:TRUE withCompletionBlock:completionBlock];
    }
    else {
        self.selectedSpot = spot;
        if (completionBlock) {
            completionBlock();
        }
    }
}

- (void)deselectSpot:(SpotModel *)spot withCompletionBlock:(void (^)())completionBlock {
    // deselection/selection can happen in an unexpected order
    if (!self.scopedSpot && [spot isEqual:self.selectedSpot]) {
        self.selectedSpot = nil;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            if (!self.selectedSpot) {
                [self hideFilterView:TRUE withCompletionBlock:completionBlock];
            }
        });
    }
    else {
        self.selectedSpot = nil;
        if (completionBlock) {
            completionBlock();
        }
    }
}

- (void)scopeToSpot:(SpotModel *)spot withCompletionBlock:(void (^)())completionBlock {
    if (![spot isEqual:self.scopedSpot]) {
        self.scopedSpot = spot;
        [self showFilterView:TRUE withCompletionBlock:completionBlock];
    }
    else if (completionBlock) {
        completionBlock();
    }
}

- (void)descopeFromSpot:(SpotModel *)spot withCompletionBlock:(void (^)())completionBlock {
    if ([spot isEqual:self.scopedSpot]) {
        self.scopedSpot = nil;
        self.selectedSpot = nil;
        [self hideFilterView:TRUE withCompletionBlock:completionBlock];
    }
    else if (completionBlock) {
        completionBlock();
    }
}

#pragma mark - User Actions
#pragma mark -

- (IBAction)locationButtonTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(locationMenuBarViewControllerDidRequestLocationChange:)]) {
        [self.delegate locationMenuBarViewControllerDidRequestLocationChange:self];
    }
}

- (IBAction)filterButtonTapped:(id)sender {
    if (self.scopedSpot) {
        // descope the scoped spot
        
        [self descopeFromSpot:self.scopedSpot withCompletionBlock:^{
            if ([self.delegate respondsToSelector:@selector(locationMenuBarViewControllerDidDescope:)]) {
                [self.delegate locationMenuBarViewControllerDidDescope:self];
            }
        }];
    }
    else if (self.selectedSpot) {
        // scope to selected spot
        self.scopedSpot = self.selectedSpot;
        
        [self showFilterView:TRUE withCompletionBlock:^{
            if ([self.delegate respondsToSelector:@selector(locationMenuBarViewController:didScopeToSpot:)]) {
                [self.delegate locationMenuBarViewController:self didScopeToSpot:self.scopedSpot];
            }
        }];
    }
}

#pragma mark - Private
#pragma mark -

- (BOOL)isLocationViewHidden {
    return self.leadingConstraint.constant != 0.0;
}

- (void)updateFilterLabel {
    if (self.scopedSpot) {
        self.filterLabel.text = [NSString stringWithFormat:@"Where? %@", self.scopedSpot.name];
        UIImage *closeImage = [SHStyleKit drawImage:SHStyleKitDrawingCloseIcon color:SHStyleKitColorMyTextColor size:CGSizeMake(20, 20)];
        self.filterArrowImageView.image = closeImage;
    }
    else if (self.selectedSpot) {
        self.filterLabel.text = [NSString stringWithFormat:@"Filter results to %@?", self.selectedSpot.name];
        UIImage *arrowImage = [SHStyleKit drawImage:SHStyleKitDrawingNavigationArrowRightIcon color:SHStyleKitColorMyTextColor size:CGSizeMake(20, 20)];
        self.filterArrowImageView.image = arrowImage;
    }
    else {
        self.filterLabel.text = nil;
    }
}

- (void)showFilterView:(BOOL)animated withCompletionBlock:(void (^)())completionBlock {
    // set filterLabel with spot name and animate views to the left
    
    [self updateFilterLabel];
    
    CGFloat newConstant = CGRectGetWidth(self.view.frame) * -1;
    
    CGFloat duration = animated ? kAnimationDuration : 0.0f;
    UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState;
    [UIView animateWithDuration:duration delay:0.0f usingSpringWithDamping:0.9f initialSpringVelocity:9.0f options:options animations:^{
        self.leadingConstraint.constant = newConstant;
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        if (completionBlock) {
            completionBlock();
        }
    }];
}

- (void)hideFilterView:(BOOL)animated withCompletionBlock:(void (^)())completionBlock {
    CGFloat duration = animated ? kAnimationDuration : 0.0f;
    UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState;
    [UIView animateWithDuration:duration delay:0.0f usingSpringWithDamping:0.9f initialSpringVelocity:9.0f options:options animations:^{
        self.leadingConstraint.constant = 0.0f;
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        if (completionBlock) {
            completionBlock();
        }
    }];
}

@end
