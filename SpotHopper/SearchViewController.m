//
//  SearchViewController.m
//  SpotHopper
//
//  Created by Josh Holtz on 4/1/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#define kPageSize @15

#import "SearchViewController.h"

#import "NSNumber+Helpers.h"

#import "SHNavigationController.h"
#import "FindSimilarViewController.h"

#import "DrinkModel.h"
#import "SpotModel.h"
#import "ErrorModel.h"
#import "Tracker.h"

#import "SearchCell.h"

@interface SearchViewController ()<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *txtSearch;
@property (weak, nonatomic) IBOutlet UITableView *tblResults;

@property (nonatomic, strong) NSTimer *searchTimer;

@property (nonatomic, assign) CGRect tblResultsInitialFrame;

@property (nonatomic, strong) NSNumber *page;
@property (nonatomic, strong) NSMutableArray *results;

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Configures table
    [_tblResults setTableFooterView:[[UIView alloc] init]];
    [_tblResults registerNib:[UINib nibWithNibName:@"SearchCellView" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"SearchCell"];
    
    // Register pull to refresh
    [self registerRefreshTableView:_tblResults withReloadType:kPullRefreshTypeBoth];
    
    // Initializes stuff
    _tblResultsInitialFrame = CGRectZero;
    _results = @[].mutableCopy;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    
    [_txtSearch becomeFirstResponder];
    
    // Configures text search
    [_txtSearch addTarget:self action:@selector(onEditingChangeSearch:) forControlEvents:UIControlEventEditingChanged];
    
    // No navigation bar
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    
    // Gets table frame
    if (CGRectEqualToRect(_tblResultsInitialFrame, CGRectZero)) {
        _tblResultsInitialFrame = _tblResults.frame;
    }
    
    // Keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    // Configures text search
    [_txtSearch removeTarget:self action:@selector(onEditingChangeSearch:) forControlEvents:UIControlEventEditingChanged];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - Tracking

- (NSString *)screenName {
    return @"Search";
}

#pragma mark - Keyboard

- (NSArray *)textfieldToHideKeyboard {
    return @[_txtSearch];
}

- (void)keyboardWillShow:(NSNotification*)notification {
    [self keyboardWillHideOrShow:notification show:YES];
}

- (void)keyboardWillHide:(NSNotification*)notification {
    [self keyboardWillHideOrShow:notification show:NO];
}

- (void)keyboardWillHideOrShow:(NSNotification*)notification show:(BOOL)show {
    NSDictionary *userInfo = notification.userInfo;
    NSTimeInterval duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    
    CGRect keyboardFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGRect frame = _tblResults.frame;
    if (show) {
        frame.size.height = CGRectGetHeight(self.view.frame) - CGRectGetMinY(frame) - CGRectGetHeight(keyboardFrame);
        if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
            frame.size.height -= 20.0f;
        }
    } else {
        frame = _tblResultsInitialFrame;
    }
    
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionBeginFromCurrentState | curve animations:^{
        [_tblResults setFrame:frame];
    } completion:^(BOOL finished) {
        [self dataDidFinishRefreshing];
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _results.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SearchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchCell" forIndexPath:indexPath];
    
    if (indexPath.row < _results.count) {
        JSONAPIResource *result = [_results objectAtIndex:indexPath.row];
        
        if ([result isKindOfClass:[DrinkModel class]]) {
            DrinkModel *drink = (DrinkModel*)result;
            [cell setDrink:drink];
        } else if ([result isKindOfClass:[SpotModel class]]) {
            SpotModel *spot = (SpotModel*)result;
            [cell setSpot:spot];
        }
    }
    
    return cell;
    
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < _results.count) {
        JSONAPIResource *result = [_results objectAtIndex:indexPath.row];
        if ([result isKindOfClass:[DrinkModel class]]) {
            DrinkModel *drink = (DrinkModel *)result;
            
            if ([_delegate respondsToSelector:@selector(searchViewController:selectedDrink:)]) {
                [_delegate searchViewController:self selectedDrink:drink];
            }
            
        } else if ([result isKindOfClass:[SpotModel class]]) {
            SpotModel *spot = (SpotModel *)result;
            
            if ([_delegate respondsToSelector:@selector(searchViewController:selectedSpot:)]) {
                [_delegate searchViewController:self selectedSpot:spot];
            }
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55.0f;
}

#pragma mark - JHPullToRefresh

- (void)reloadTableViewDataPullDown {
    // Starts search over
    [self startSearch];
}

- (void)reloadTableViewDataPullUp {
    // Increments pages
    _page = [_page increment];
    
    // Does search
    [self doSearch];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

#pragma mark - Actions

- (void)onEditingChangeSearch:(id)sender {
    // Cancel and nil
    [_searchTimer invalidate];
    _searchTimer = nil;
    
    // Schedule timer
    _searchTimer = [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(startSearch) userInfo:nil repeats:NO];
}

- (IBAction)onClickPop:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Private

- (void)startSearch {
    [DrinkModel cancelGetDrinks];
    [SpotModel cancelGetSpots];
    
    // Resets pages and clears results
    _page = @1;
    [_results removeAllObjects];
    
    [self dataDidFinishRefreshing];
    
    if (_txtSearch.text.length) {
        [self doSearch];
    }
    else {
        [self dataDidFinishRefreshing];
    }
}

- (void)doSearch {
    [self hideHUD];
    [self showHUD:@"Searching"];
    
    Promise *spotsPromise = [[SpotModel fetchSpotsWithText:_txtSearch.text page:_page] then:^(NSArray *spots) {
        DebugLog(@"spots: %@", spots);
        [self.results addObjectsFromArray:spots];
    } fail:nil always:nil];
    
    Promise *drinksPromise = [[DrinkModel fetchDrinksWithText:_txtSearch.text page:_page] then:^(NSArray *drinks) {
        DebugLog(@"drinks: %@", drinks);
        [self.results addObjectsFromArray:drinks];
    } fail:nil always:nil];
    
    [When when:@[spotsPromise, drinksPromise] then:nil fail:nil always:^{
        [self hideHUD];

        [self.results sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            NSNumber *revObj1 = [obj1 valueForKey:@"relevance"];
            NSNumber *revObj2 = [obj2 valueForKey:@"relevance"];
            return [revObj2 compare:revObj1];
        }];
        
        [self dataDidFinishRefreshing];
    }];
}

@end
