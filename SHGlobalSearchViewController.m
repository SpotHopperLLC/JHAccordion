//
//  SHGlobalSearchViewController.m
//  SpotHopper
//
//  Created by Brennan Stehling on 7/26/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "SHGlobalSearchViewController.h"

#import "DrinkModel.h"
#import "SpotModel.h"
#import "ErrorModel.h"
#import "SHStyleKit+Additions.h"

#import "Tracker.h"
#import "Tracker+Events.h"

#import "NSNumber+Helpers.h"

#define kTagImageViewIcon 1
#define kTagNameLabel 2
#define kTagNotWhatLookingForLabel 3
#define kTagMainTitleLabel 4
#define kTagSubtitleLabel 5

@interface SHGlobalSearchViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (copy, nonatomic) NSString *searchText;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSNumber *page;
@property (nonatomic, strong) NSMutableArray *results;

@end

@implementation SHGlobalSearchViewController {
    NSUInteger _isSearchRunningCount;
    CGFloat _keyboardHeight;
}

#pragma mark - View Lifecycle
#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad:@[kDidLoadOptionsNoBackground]];
    
    NSAssert(self.tableView, @"Outlet is required");
    NSAssert(self.tableView.dataSource, @"DataSource is required");
    NSAssert(self.tableView.delegate, @"Delegate is required");
    
    // Register pull to refresh
    [self registerRefreshTableView:self.tableView withReloadType:kPullRefreshTypeBoth];
    
    self.results = @[].mutableCopy;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - Tracking
#pragma mark -

- (NSString *)screenName {
    return @"Search";
}

#pragma mark - Keyboard
#pragma mark -

- (void)keyboardWillShow:(NSNotification *)notification {
	_keyboardHeight = [self getKeyboardHeight:notification forBeginning:TRUE];
    UIEdgeInsets inset = self.tableView.contentInset;
    inset.bottom = _keyboardHeight;
    self.tableView.contentInset = inset;
    self.tableView.scrollIndicatorInsets = inset;
}

- (void)keyboardWillHide:(NSNotification *)notification {
    _keyboardHeight = 0.0f;
    UIEdgeInsets inset = self.tableView.contentInset;
    inset.bottom = 0;
    self.tableView.contentInset = inset;
    self.tableView.scrollIndicatorInsets = inset;
}

#pragma mark - Public
#pragma mark -

- (void)scheduleSearchWithText:(NSString *)text {
    DebugLog(@"%@", NSStringFromSelector(_cmd));
    
    self.searchText = text;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startSearch) object:nil];
    [self performSelector:@selector(startSearch) withObject:nil afterDelay:0.5f];
}

- (void)clearSearch {
    [self.results removeAllObjects];
    [self dataDidFinishRefreshing];
}

- (void)cancelSearch {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startSearch) object:nil];
    
    if ([self isSearchRunning]) {
        [DrinkModel cancelGetDrinks];
        [SpotModel cancelGetSpots];
    }
}

- (void)adjustForKeyboardHeight:(CGFloat)height duration:(NSTimeInterval)duration {
    UIEdgeInsets contentInset = self.tableView.contentInset;
    UIEdgeInsets scrollIndicatorInsets = self.tableView.scrollIndicatorInsets;
    contentInset.bottom = height;
    scrollIndicatorInsets.bottom = height;
    
    UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState;
    [UIView animateWithDuration:duration delay:0.0 options:options animations:^{
        self.tableView.contentInset = contentInset;
        self.tableView.scrollIndicatorInsets = scrollIndicatorInsets;
    } completion:^(BOOL finished) {
    }];
}

#pragma mark - Private
#pragma mark -

- (void)setIsSearchRunning:(BOOL)isSearchRunning {
    _isSearchRunningCount += isSearchRunning ? 1 : -1;
}

- (BOOL)isSearchRunning {
    return _isSearchRunningCount > 0;
}

- (void)dataDidFinishRefreshing {
    [super dataDidFinishRefreshing];
    
    UIEdgeInsets inset = self.tableView.contentInset;
    inset.bottom = _keyboardHeight;
    self.tableView.contentInset = inset;
    self.tableView.scrollIndicatorInsets = inset;
}

#pragma mark - UITableViewDataSource
#pragma mark -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.results.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchCell" forIndexPath:indexPath];
    
    UIView *backgroundView = [[UIView alloc] init];
    backgroundView.backgroundColor = [SHStyleKit color:SHStyleKitColorMyTintColorTransparent];
    cell.selectedBackgroundView = backgroundView;
    
    if (indexPath.row < self.results.count) {
        JSONAPIResource *result = [self.results objectAtIndex:indexPath.row];
        
        UIImageView *iconImageView = (UIImageView *)[cell viewWithTag:kTagImageViewIcon];
        UILabel *nameLabel = (UILabel *)[cell viewWithTag:kTagNameLabel];
        UILabel *notWhatLookingForLabel = (UILabel *)[cell viewWithTag:kTagNotWhatLookingForLabel];
        UILabel *mainTitleLabel = (UILabel *)[cell viewWithTag:kTagMainTitleLabel];
        UILabel *subtitleLabel = (UILabel *)[cell viewWithTag:kTagSubtitleLabel];
        
        // reset
        iconImageView.image = nil;
        nameLabel.hidden = TRUE;
        notWhatLookingForLabel.hidden = TRUE;
        mainTitleLabel.hidden = TRUE;
        subtitleLabel.hidden = TRUE;
        
        if ([result isKindOfClass:[DrinkModel class]]) {
            DrinkModel *drink = (DrinkModel *)result;
            
            NSString *title = drink.name;
            NSString *subtitle = drink.spot.name;
            
            // Sets image to drink type
            if (drink.isBeer) {
                iconImageView.image = [UIImage imageNamed:@"icon_search_beer"];
            }
            else if (drink.isCocktail) {
                iconImageView.image = [UIImage imageNamed:@"icon_search_cocktails"];
            }
            else if (drink.isWine) {
                iconImageView.image = [UIImage imageNamed:@"icon_search_wine"];
            }
            
            // Shows two lines if there is a spot name (brewery or winery)
            if (!subtitle.length) {
                nameLabel.text = title;
                nameLabel.hidden = FALSE;
            }
            else {
                if (drink.isWine && drink.vintage && ![drink isKindOfClass:[NSNull class]]) {
                    mainTitleLabel.text = [NSString stringWithFormat:@"%@ (%@)", title, drink.vintage];
                }
                else {
                    mainTitleLabel.text = title;
                }
                if (!title.length && subtitle.length) {
                    mainTitleLabel.text = subtitle;
                }
                else {
                    subtitleLabel.text = subtitle;
                }

                mainTitleLabel.hidden = FALSE;
                subtitleLabel.hidden = FALSE;
            }
            
        } else if ([result isKindOfClass:[SpotModel class]]) {
            SpotModel *spot = (SpotModel *)result;
            
            iconImageView.image = [UIImage imageNamed:@"icon_search_spot"];
            mainTitleLabel.text = spot.name;
            subtitleLabel.text =spot.addressCityState;
            
            mainTitleLabel.hidden = FALSE;
            subtitleLabel.hidden = FALSE;
        }
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate
#pragma mark -

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.results.count) {
        SHJSONAPIResource *result = [self.results objectAtIndex:indexPath.row];
        
        [Tracker trackGlobalSearchResultTapped:result searchText:self.searchText];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.25 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            
            if ([result isKindOfClass:[SpotModel class]]) {
                SpotModel *spot = (SpotModel *)result;
                
                if ([self.delegate respondsToSelector:@selector(globalSearchViewController:didSelectSpot:)]) {
                    [self.delegate globalSearchViewController:self didSelectSpot:spot];
                }
            }
            else if ([result isKindOfClass:[DrinkModel class]]) {
                DrinkModel *drink = (DrinkModel *)result;
                
                if ([self.delegate respondsToSelector:@selector(globalSearchViewController:didSelectDrink:)]) {
                    [self.delegate globalSearchViewController:self didSelectDrink:drink];
                }
            }
            
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        });
    }
}

#pragma mark - JHPullToRefresh

- (void)reloadTableViewDataPullDown {
    // Starts search over
    [self startSearch];
}

- (void)reloadTableViewDataPullUp {
    // Increments pages
    self.page = [self.page increment];
    
    // Does search
    [self doSearch];
}

#pragma mark - Search
#pragma mark -

- (void)startSearch {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startSearch) object:nil];
    
    if ([self isSearchRunning]) {
        DebugLog(@"Canceling searches...");
        [DrinkModel cancelGetDrinks];
        [SpotModel cancelGetSpots];
        [Tracker trackGlobalSearchRequestCancelled];
    }
    
    // Resets pages and clears results
    self.page = @1;
    [self.results removeAllObjects];
    
    if (self.searchText.length) {
        [self doSearch];
    }
    else {
        [self dataDidFinishRefreshing];
    }
}

- (void)doSearch {
    DebugLog(@"%@", NSStringFromSelector(_cmd));
    
    [self setIsSearchRunning:TRUE];
    
    DebugLog(@"_isSearchRunningCount: %lu", (unsigned long)_isSearchRunningCount);
    
    DebugLog(@"started");
    if ([self.delegate respondsToSelector:@selector(globalSearchViewControllerStartedSearching:)]) {
        [self.delegate globalSearchViewControllerStartedSearching:self];
    }
    
    Promise *spotsPromise = [[SpotModel fetchSpotsWithText:self.searchText page:self.page] then:^(NSArray *spots) {
        DebugLog(@"spots: %@", spots);
        [self.results addObjectsFromArray:spots];
    } fail:nil always:nil];
    
    Promise *drinksPromise = [[DrinkModel fetchDrinksWithText:self.searchText page:self.page] then:^(NSArray *drinks) {
        DebugLog(@"drinks: %@", drinks);
        [self.results addObjectsFromArray:drinks];
    } fail:nil always:nil];
    
    [Tracker trackGlobalSearchRequestStarted];
    
    [When when:@[spotsPromise, drinksPromise] then:nil fail:nil always:^{
        [self setIsSearchRunning:FALSE];
        
        if (![self isSearchRunning]) {
            DebugLog(@"stopped");
            if ([self.delegate respondsToSelector:@selector(globalSearchViewControllerStoppedSearching:)]) {
                [self.delegate globalSearchViewControllerStoppedSearching:self];
            }
        }
        
        [Tracker trackGlobalSearchRequestCompleted];
        [Tracker trackGlobalSearchHappened:self.searchText];
        
        [self.results sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            NSNumber *revObj1 = [obj1 valueForKey:@"relevance"];
            NSNumber *revObj2 = [obj2 valueForKey:@"relevance"];
            return [revObj2 compare:revObj1];
        }];
        
        [self dataDidFinishRefreshing];
    }];
}

@end
