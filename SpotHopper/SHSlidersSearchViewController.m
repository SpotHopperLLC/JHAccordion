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
#import "ErrorModel.h"
#import "Tracker.h"

@interface SHSlidersSearchViewController () <SHSlidersSearchTableViewManagerDelegate>

@property (assign, nonatomic) SHMode mode;

@property (strong, readwrite, nonatomic) DrinkListModel *drinkListModel;

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
    
    [self.slidersSearchTableViewManager prefetchData];
    
    self.searchButton.titleLabel.font = [UIFont fontWithName:@"Lato-Light" size:26.0f];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSAssert(self.searchButton, @"Outlet is required");
    NSAssert(self.searchButtonBottomConstraint, @"Outlet is required");
    
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
    // TODO: adjust for spotlists
    
    [self showHUD:@"Creating Drinklist"];
    [self.slidersSearchTableViewManager fetchDrinkListResultsWithCompletionBlock:^(DrinkListModel *drinkListModel, ErrorModel *errorModel) {
        [self hideHUD];
        if (errorModel) {
            [Tracker logError:errorModel class:[self class] trace:NSStringFromSelector(_cmd)];
            [self showAlert:@"Oops" message:errorModel.human];
        }
        else {
            self.drinkListModel = drinkListModel;
            [self performSegueWithIdentifier:@"finishCreatingDrinkListForHomeMap" sender:self];
            if ([self.delegate respondsToSelector:@selector(slidersSearchViewController:didPrepareDrinklist:forMode:)]) {
                [self.delegate slidersSearchViewController:self didPrepareDrinklist:drinkListModel forMode:self.mode];
            }
        }
    }];
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

#pragma mark - Public Methods
#pragma mark -

- (void)prepareForMode:(SHMode)mode {
    self.mode = mode;
    [self hideSearchButton:FALSE withCompletionBlock:nil];
    [[self slidersSearchTableViewManager] prepareForMode:mode];
}

#pragma mark - SHSlidersSearchTableViewManagerDelegate
#pragma mark -

- (void)slidersSearchTableViewManagerDidChangeSlider:(SHSlidersSearchTableViewManager *)manager {
    if (self.searchButton.hidden) {
        [self showSearchButton:TRUE withCompletionBlock:nil];
    }
}

@end
