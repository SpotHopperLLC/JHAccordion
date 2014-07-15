//
//  SHSearchViewController.m
//  SpotHopper
//
//  Created by Brennan Stehling on 5/22/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "SHSlidersSearchViewController.h"

#import "SHSlidersSearchTableViewManager.h"
#import "SHStyleKit+Additions.h"

#import "DrinkListModel.h"
#import "SpotListModel.h"
#import "DrinkListRequest.h"
#import "SpotListRequest.h"
#import "ErrorModel.h"
#import "Tracker.h"

@interface SHSlidersSearchViewController () <SHSlidersSearchTableViewManagerDelegate>

@property (assign, nonatomic) SHMode mode;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchButtonBottomConstraint;

@property (strong, nonatomic) IBOutlet SHSlidersSearchTableViewManager *slidersSearchTableViewManager;

@end

@implementation SHSlidersSearchViewController

#pragma mark - View Lifecycle
#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad:@[kDidLoadOptionsNoBackground]];
    
    [self.slidersSearchTableViewManager prepare];
    
    self.searchButton.titleLabel.font = [UIFont fontWithName:@"Lato-Light" size:26.0f];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSAssert(self.searchButton, @"Outlet is required");
    NSAssert(self.searchButtonBottomConstraint, @"Outlet is required");
    
    self.tableView.contentOffset = CGPointMake(0, self.tableView.contentInset.top * -1);
    
    [self hideSearchButton:FALSE withCompletionBlock:nil];
}

#pragma mark - User Actions
#pragma mark -

- (IBAction)searchButtonTapped:(id)sender {
    [self prepareSearchResults];
}

#pragma mark - Private
#pragma mark -

- (void)prepareSearchResults {
    if (self.mode == SHModeSpots) {
        [self showHUD:@"Finding Best Matches"];
        [self.slidersSearchTableViewManager fetchSpotListResultsWithCompletionBlock:^(SpotListModel *spotListModel, SpotListRequest *request, ErrorModel *errorModel) {
            [self hideHUD];
            if (errorModel) {
                [Tracker logError:errorModel class:[self class] trace:NSStringFromSelector(_cmd)];
                [self showAlert:@"Oops" message:errorModel.human];
            }
            else {
                if ([self.delegate respondsToSelector:@selector(slidersSearchViewController:didPrepareDrinklist:withRequest:forMode:)]) {
                    [self.delegate slidersSearchViewController:self didPrepareSpotlist:spotListModel withRequest:request forMode:self.mode];
                }
            }
        }];
    }
    else {
        [self showHUD:@"Finding Best Matches"];
        [self.slidersSearchTableViewManager fetchDrinkListResultsWithCompletionBlock:^(DrinkListModel *drinkListModel, DrinkListRequest *request, ErrorModel *errorModel) {
            [self hideHUD];
            if (errorModel) {
                [Tracker logError:errorModel class:[self class] trace:NSStringFromSelector(_cmd)];
                [self showAlert:@"Oops" message:errorModel.human];
            }
            else {
                if ([self.delegate respondsToSelector:@selector(slidersSearchViewController:didPrepareDrinklist:withRequest:forMode:)]) {
                    [self.delegate slidersSearchViewController:self didPrepareDrinklist:drinkListModel withRequest:request forMode:self.mode];
                }
            }
        }];
    }
}

- (void)hideSearchButton:(BOOL)animated withCompletionBlock:(void (^)())completionBlock {
    CGFloat duration = animated ? 0.25f : 0.0f;
    
    CGFloat height = CGRectGetHeight(self.searchButton.frame);
    
    UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState;
    [UIView animateWithDuration:duration delay:0.0 options:options animations:^{
        self.searchButtonBottomConstraint.constant = height * -1;
        
        UIEdgeInsets contentInset = self.tableView.contentInset;
        UIEdgeInsets scrollIndicatorInsets = self.tableView.scrollIndicatorInsets;
        contentInset.bottom = 0.0f;
        scrollIndicatorInsets.bottom = 0.0f;
        self.tableView.contentInset = contentInset;
        self.tableView.scrollIndicatorInsets = scrollIndicatorInsets;
        
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        if (finished) {
            self.searchButton.hidden = TRUE;
            if (completionBlock) {
                completionBlock();
            }
        }
    }];
}

- (void)showSearchButton:(BOOL)animated withCompletionBlock:(void (^)())completionBlock {
    CGFloat duration = animated ? 0.25f : 0.0f;
    
    self.searchButton.hidden = FALSE;
    CGFloat height = CGRectGetHeight(self.searchButton.frame);
    
    UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState;
    [UIView animateWithDuration:duration delay:0.0 options:options animations:^{
        self.searchButtonBottomConstraint.constant = 0.0f;
        
        UIEdgeInsets contentInset = self.tableView.contentInset;
        UIEdgeInsets scrollIndicatorInsets = self.tableView.scrollIndicatorInsets;
        contentInset.bottom = height;
        scrollIndicatorInsets.bottom = height;
        self.tableView.contentInset = contentInset;
        self.tableView.scrollIndicatorInsets = scrollIndicatorInsets;
        
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        if (finished) {
            if (completionBlock) {
                completionBlock();
            }
        }
    }];
}

- (CLLocationCoordinate2D)searchCenterCoordinate {
    if ([self.delegate respondsToSelector:@selector(searchCoordinateForSlidersSearchViewController:)]) {
        CLLocationCoordinate2D coordinate = [self.delegate searchCoordinateForSlidersSearchViewController:self];
        return coordinate;
    }
    
    return kCLLocationCoordinate2DInvalid;
}

- (CGFloat)searchRadius {
    if ([self.delegate respondsToSelector:@selector(searchRadiusForSlidersSearchViewController:)]) {
        CLLocationDistance meters = [self.delegate searchRadiusForSlidersSearchViewController:self];
        return meters;
    }
    
    return 1000.0f;
}

#pragma mark - Public Methods
#pragma mark -

- (void)prepareForMode:(SHMode)mode {
    self.mode = mode;
    
    [self hideSearchButton:FALSE withCompletionBlock:nil];
    [[self slidersSearchTableViewManager] prepareForMode:mode];
}

#pragma mark - SHSlidersSearchTableViewManagerDelegate
#pragma mark -

- (UIStoryboard *)slidersSearchTableViewManagerStoryboard:(SHSlidersSearchTableViewManager *)manager {
    return self.storyboard;
}

- (void)slidersSearchTableViewManagerDidChangeSlider:(SHSlidersSearchTableViewManager *)manager {
    if (self.searchButton.hidden) {
        [self showSearchButton:TRUE withCompletionBlock:nil];
    }
}

- (void)slidersSearchTableViewManagerWillAnimate:(SHSlidersSearchTableViewManager *)manager {
    if ([self.delegate respondsToSelector:@selector(slidersSearchViewControllerWillAnimate:)]) {
        [self.delegate slidersSearchViewControllerWillAnimate:self];
    }
}

- (void)slidersSearchTableViewManagerDidAnimate:(SHSlidersSearchTableViewManager *)manager {
    if ([self.delegate respondsToSelector:@selector(slidersSearchViewControllerDidAnimate:)]) {
        [self.delegate slidersSearchViewControllerDidAnimate:self];
    }
    
}

- (void)slidersSearchTableViewManagerIsBusy:(SHSlidersSearchTableViewManager *)manager text:(NSString *)text {
    if (text.length) {
        [self showHUD:text];
    }
    else {
        [self showHUD];
    }
}

- (void)slidersSearchTableViewManagerIsFree:(SHSlidersSearchTableViewManager *)manager {
    [self hideHUD];
}

- (CLLocationCoordinate2D)searchCoordinateForSlidersSearchTableViewManager:(SHSlidersSearchTableViewManager *)manager {
    return [self searchCenterCoordinate];
}

- (CLLocationDistance)searchRadiusForSlidersSearchTableViewManager:(SHSlidersSearchTableViewManager *)manager {
    return [self searchRadius];
}

@end
