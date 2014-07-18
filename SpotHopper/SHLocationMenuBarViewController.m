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

@property (weak, nonatomic) SpotModel *spot;

@property (strong, nonatomic) NSMutableArray *selectedQueue;
@property (strong, nonatomic) NSMutableArray *deselectedQueue;

@end

@implementation SHLocationMenuBarViewController {
    BOOL _isHiding;
    BOOL _isShowing;
    BOOL _isDisplayingSpotDrinklist;
}

#pragma mark - View Lifecycle
#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad:@[kDidLoadOptionsNoBackground]];
    
    self.selectedQueue = @[].mutableCopy;
    self.deselectedQueue = @[].mutableCopy;
    
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

- (void)selectSpot:(SpotModel *)spot {
    if (!spot) {
        return;
    }
    [self.selectedQueue addObject:spot];
    [self processQueue];
}

- (void)deselectSpot:(SpotModel *)spot {
    if (!spot) {
        return;
    }
    if (_isDisplayingSpotDrinklist) { return; }
    [self.deselectedQueue addObject:spot];
    [self processQueue];
}

- (void)selectSpotDrinkListForSpot:(SpotModel *)spot {
    _isDisplayingSpotDrinklist = TRUE;
    [self selectSpot:spot];
}

- (void)deselectSpotDrinkList {
    _isDisplayingSpotDrinklist = FALSE;
    [self deselectSpot:self.spot];
}

#pragma mark - User Actions
#pragma mark -

- (IBAction)locationButtonTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(locationMenuBarViewControllerDidRequestLocationChange:)]) {
        [self.delegate locationMenuBarViewControllerDidRequestLocationChange:self];
    }
}

- (IBAction)filterButtonTapped:(id)sender {
    if (_isDisplayingSpotDrinklist) {
        
        if (self.spot) {
            _isDisplayingSpotDrinklist = FALSE;
            [self updateFilterLabelWithSpot:self.spot];
            self.spot = nil;
            if ([self.delegate respondsToSelector:@selector(locationMenuBarViewController:didDeselectSpot:)]) {
                [self.delegate locationMenuBarViewController:self didDeselectSpot:self.spot];
            }
        }
    }
    else {
        if (self.spot && [self.delegate respondsToSelector:@selector(locationMenuBarViewController:didSelectSpot:)]) {
            [self.delegate locationMenuBarViewController:self didSelectSpot:self.spot];
        }
    }
}

#pragma mark - Private
#pragma mark -

- (BOOL)isLocationViewHidden {
    return self.leadingConstraint.constant != 0.0;
}

- (void)processQueue {
    if (!_isShowing && self.deselectedQueue.count) {
        [self.deselectedQueue removeAllObjects];
        [self hideFilterView:TRUE withCompletionBlock:^{
            [self processQueue];
        }];
    }
    else if (!_isHiding && self.selectedQueue.count) {
        SpotModel *spot = [self.selectedQueue lastObject];
        [self.selectedQueue removeAllObjects];
        [self showFilterViewForSpot:spot animated:TRUE withCompletionBlock:^{
            [self processQueue];
        }];
    }
}

- (void)updateFilterLabelWithSpot:(SpotModel *)spot {
    if (_isDisplayingSpotDrinklist) {
        self.filterLabel.text = [NSString stringWithFormat:@"Where? %@", spot.name];
        UIImage *closeImage = [SHStyleKit drawImage:SHStyleKitDrawingCloseIcon color:SHStyleKitColorMyTextColor size:CGSizeMake(20, 20)];
        self.filterArrowImageView.image = closeImage;
    }
    else {
        self.filterLabel.text = [NSString stringWithFormat:@"Filter results to %@?", spot.name];
        UIImage *arrowImage = [SHStyleKit drawImage:SHStyleKitDrawingNavigationArrowRightIcon color:SHStyleKitColorMyTextColor size:CGSizeMake(20, 20)];
        self.filterArrowImageView.image = arrowImage;
    }
}

- (void)showFilterViewForSpot:(SpotModel *)spot animated:(BOOL)animated withCompletionBlock:(void (^)())completionBlock {
    // set filterLabel with spot name and animate views to the left
    
    _isShowing = TRUE;
    
    self.spot = spot;
    
    [self updateFilterLabelWithSpot:spot];
    
    CGFloat newConstant = CGRectGetWidth(self.view.frame) * -1;
    
    CGFloat duration = animated ? 0.35 : 0.0;
    UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState;
    [UIView animateWithDuration:duration delay:0.0 usingSpringWithDamping:0.9 initialSpringVelocity:9.0 options:options animations:^{
        self.leadingConstraint.constant = newConstant;
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        _isShowing = FALSE;
        if (completionBlock) {
            completionBlock();
        }
    }];
}

- (void)hideFilterView:(BOOL)animated withCompletionBlock:(void (^)())completionBlock {
    _isHiding = TRUE;
    CGFloat duration = animated ? 0.35 : 0.0;
    UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState;
    [UIView animateWithDuration:duration delay:0.0 usingSpringWithDamping:0.9 initialSpringVelocity:9.0 options:options animations:^{
        self.leadingConstraint.constant = 0.0;
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        _isHiding = FALSE;
        if (completionBlock) {
            completionBlock();
        }
    }];
}

@end
