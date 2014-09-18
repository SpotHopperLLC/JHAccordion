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
#import "Tracker+Events.h"

#import "UIAlertView+Block.h"

@interface SHSlidersSearchViewController () <SHSlidersSearchTableViewManagerDelegate>

@property (assign, nonatomic) SHMode mode;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;

@property (weak, nonatomic) IBOutlet UIView *toastView;
@property (weak, nonatomic) IBOutlet UILabel *toastLabel;

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
    self.toastLabel.font = [UIFont fontWithName:@"Lato-Light" size:18.0f];
    
    self.toastView.layer.cornerRadius = 15.0f;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSAssert(self.searchButton, @"Outlet is required");
    NSAssert(self.searchButtonBottomConstraint, @"Outlet is required");
    
    self.tableView.contentOffset = CGPointMake(0, self.tableView.contentInset.top * -1);
    
    [self hideSearchButton:FALSE withCompletionBlock:nil];
    [self hideToastView:FALSE withCompletionBlock:nil];
}

#pragma mark - User Actions
#pragma mark -

- (IBAction)searchButtonTapped:(id)sender {
    [Tracker trackSliderSearchButtonTapped:self.mode];
    
    [self prepareSearchResults];
}

#pragma mark - Private
#pragma mark -

- (void)prepareSearchResults {
    void (^continueBlock)(NSString *) = ^void(NSString *listName) {
        if (self.mode == SHModeSpots) {
            [self showHUD:@"Finding Best Matches"];
            [self.slidersSearchTableViewManager fetchSpotListResultsWithListName:listName withCompletionBlock:^(SpotListModel *spotListModel, SpotListRequest *request, ErrorModel *errorModel) {
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
            [self.slidersSearchTableViewManager fetchDrinkListResultsWithListName:listName basedOnSliders:TRUE withCompletionBlock:^(DrinkListModel *drinkListModel, DrinkListRequest *request, ErrorModel *errorModel) {
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
    };
    
    if (self.slidersSearchTableViewManager.isCustomRequest) {
        NSString *title = nil;
        NSString *message = nil;
        NSString *defaultListName = self.slidersSearchTableViewManager.customListName;
        if (SHModeSpots == self.mode) {
            title = @"Name this mood?";
            message = @"Do you want to save your slider criteria as a new custom mood?";
        }
        else {
            title = @"Name this style?";
            message = @"Do you want to save your slider criteria as a new custom style?";
        }
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"Skip" otherButtonTitles:@"Save", nil];
        [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
        [[alertView textFieldAtIndex:0] setPlaceholder:defaultListName];
        [[alertView textFieldAtIndex:0] setAutocapitalizationType:UITextAutocapitalizationTypeWords];
        [alertView showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
            NSString *listName = nil;
            if (buttonIndex == 1) {
                listName = [alertView textFieldAtIndex:0].text;
            }
            
            continueBlock(listName);
        }];
    }
    else {
        continueBlock(nil);
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

- (void)hideToastView {
    [self hideToastView:TRUE withCompletionBlock:nil];
}

- (void)hideToastView:(BOOL)animated withCompletionBlock:(void (^)())completionBlock {
    CGFloat duration = animated ? 0.45f : 0.0f;
    
    UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState;
    [UIView animateWithDuration:duration delay:0.0f options:options animations:^{
        self.toastView.alpha = 0.0f;
    } completion:^(BOOL finished) {
    }];
    
    if (completionBlock) {
        completionBlock();
    }
}

- (void)showToastViewWithText:(NSString *)text animated:(BOOL)animated withCompletionBlock:(void (^)())completionBlock {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideToastView) object:nil];

    self.toastLabel.text = text;

    CGFloat duration = animated ? 0.25f : 0.0f;
    
    UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState;
    [UIView animateWithDuration:duration delay:0.0f options:options animations:^{
        self.toastView.alpha = 1.0f;
    } completion:^(BOOL finished) {
    }];
    
    if (completionBlock) {
        completionBlock();
    }
    
    [self performSelector:@selector(hideToastView) withObject:nil afterDelay:3.0f];
}

- (CLLocationCoordinate2D)searchCenterCoordinate {
    if ([self.delegate respondsToSelector:@selector(searchCoordinateForSlidersSearchViewController:)]) {
        CLLocationCoordinate2D coordinate = [self.delegate searchCoordinateForSlidersSearchViewController:self];
        return coordinate;
    }
    
    return kCLLocationCoordinate2DInvalid;
}

- (CLLocationDistance)searchRadius {
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

- (void)slidersSearchTableViewManagerDidSelectHighestRated:(SHSlidersSearchTableViewManager *)manager {
    DebugLog(@"%@", NSStringFromSelector(_cmd));
    
    // TODO: prepare Highest Rated drinklist
    [self showHUD:@"Finding Best Matches"];
    [self.slidersSearchTableViewManager fetchDrinkListResultsWithListName:@"Highest Rated" basedOnSliders:FALSE withCompletionBlock:^(DrinkListModel *drinkListModel, DrinkListRequest *request, ErrorModel *errorModel) {
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

- (void)slidersSearchTableViewManagerHasStatus:(SHSlidersSearchTableViewManager *)manager text:(NSString *)text {
    [self showToastViewWithText:text animated:TRUE withCompletionBlock:nil];
}

- (CLLocationCoordinate2D)searchCoordinateForSlidersSearchTableViewManager:(SHSlidersSearchTableViewManager *)manager {
    return [self searchCenterCoordinate];
}

- (CLLocationDistance)searchRadiusForSlidersSearchTableViewManager:(SHSlidersSearchTableViewManager *)manager {
    return [self searchRadius];
}

- (SpotModel *)slidersSearchTableViewManagerScopedSpot:(SHSlidersSearchTableViewManager *)manager {
    if ([self.delegate respondsToSelector:@selector(slidersSearchViewControllerScopedSpot:)]) {
        SpotModel *spot = [self.delegate slidersSearchViewControllerScopedSpot:self];
        return spot;
    }
    
    return nil;
}

@end
