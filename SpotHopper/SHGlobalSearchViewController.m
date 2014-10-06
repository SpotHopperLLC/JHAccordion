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

#import "SHNotifications.h"
#import "SHStyleKit+Additions.h"

#import "Tracker.h"
#import "Tracker+Events.h"

#import "TTTAttributedLabel.h"
#import "TTTAttributedLabel+QuickFonting.h"

#import "NSNumber+Helpers.h"

#define kTagImageViewIcon 1
#define kTagNameLabel 2
#define kTagMainTitleLabel 3
#define kTagSubtitleLabel 4

#define kTagNotWhatLookingForLabel 1

@interface SHGlobalSearchViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (copy, nonatomic) NSString *searchText;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSNumber *page;
@property (nonatomic, strong) NSMutableArray *results;

@property (readonly, nonatomic) NSInteger totalRows;
@property (readonly, nonatomic) BOOL isSearchRunning;

@property (readwrite, strong, nonatomic) NSString *searchTerm;

@end

@implementation SHGlobalSearchViewController {
    NSUInteger _isSearchRunningCount;
    CGFloat _keyboardHeight;
}

#pragma mark - View Lifecycle
#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSAssert(self.tableView, @"Outlet is required");
    NSAssert(self.tableView.dataSource, @"DataSource is required");
    NSAssert(self.tableView.delegate, @"Delegate is required");
    
    // Register pull to refresh
    [self registerRefreshTableView:self.tableView withReloadType:kPullRefreshTypeBoth];
    
    self.results = nil;
}

- (NSArray *)viewOptions {
    return @[kDidLoadOptionsNoBackground];
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

#pragma mark - Public
#pragma mark -

- (NSString *)searchTerm {
    return _searchTerm;
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
    self.searchText = text;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startSearch) object:nil];
    [self performSelector:@selector(startSearch) withObject:nil afterDelay:0.5f];
}

- (void)clearSearch {
    self.searchTerm = nil;
    self.shouldKeepTitle = FALSE;
    [self.results removeAllObjects];
    self.results = nil;
    [self.tableView reloadData];
    [self dataDidFinishRefreshing];
}

- (void)cancelSearch {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startSearch) object:nil];
    
    [self clearSearch];
    
    if (self.isSearchRunning) {
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

- (NSInteger)totalRows {
    if (self.results != nil) {
        return (self.results.count * 2) + 1;
    }
    else {
        return 0;
    }
}

- (NSInteger)resourceIndexForRowIndex:(NSInteger)rowIndex {
    NSInteger totalRows = self.totalRows;
    NSInteger rowNumber = rowIndex + 1;
    BOOL isLastRow = rowNumber == totalRows;
    
    if (isLastRow) {
        return NSNotFound;
    }
    
    // See spreadsheet in Google Drive named Find Similar Offsets
    // if(ISEVEN(rowIndex), rowIndex/2), (rowIndex - 1)/2
    NSInteger resourceIndex = rowIndex % 2 == 0 ? rowIndex/2 : (rowIndex - 1)/2;
    
    return resourceIndex;
}

#pragma mark - UITableViewDataSource
#pragma mark -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // For each result there will be an option for "Find Similar" plus a final row for "Don't see it? Add it to our database!"
    
    // results * 2 + 1
    // odd rows will be results (except for last row)
    // even rows will be Find Similar to result row ((row+1) / 2) // adjust for zero based index
    // for row 5 which is really 6 the index will be (6/2)-1.
    
    return self.totalRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger totalRows = self.totalRows;
    NSInteger rowNumber = indexPath.row + 1;
    BOOL isLastRow = rowNumber == totalRows;
    BOOL isFindSimilarRow = rowNumber % 2 == 0 && !isLastRow;
    
    NSInteger resourceIndex = [self resourceIndexForRowIndex:indexPath.row];
    
    UITableViewCell *cell = nil;
    
    if (indexPath.row < totalRows) {
        if (isLastRow) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"NotFoundCell" forIndexPath:indexPath];
        }
        else {
            cell = [tableView dequeueReusableCellWithIdentifier:@"SearchCell" forIndexPath:indexPath];
        }
        
        UIView *backgroundView = [[UIView alloc] init];
        backgroundView.backgroundColor = [SHStyleKit color:SHStyleKitColorMyTintTransparentColor];
        cell.selectedBackgroundView = backgroundView;
        
        if (!isLastRow) {
            NSAssert(resourceIndex < self.results.count, @"Index is out of range");
            
            JSONAPIResource *result = [self.results objectAtIndex:resourceIndex];
            
            UIImageView *iconImageView = (UIImageView *)[cell viewWithTag:kTagImageViewIcon];
            TTTAttributedLabel *nameLabel = (TTTAttributedLabel *)[cell viewWithTag:kTagNameLabel];
            TTTAttributedLabel *mainTitleLabel = (TTTAttributedLabel *)[cell viewWithTag:kTagMainTitleLabel];
            TTTAttributedLabel *subtitleLabel = (TTTAttributedLabel *)[cell viewWithTag:kTagSubtitleLabel];
            
            nameLabel.font = [UIFont fontWithName:@"Lato-Light" size:nameLabel.font.pointSize];
            mainTitleLabel.font = [UIFont fontWithName:@"Lato-Light" size:nameLabel.font.pointSize];
            subtitleLabel.font = [UIFont fontWithName:@"Lato-Light" size:nameLabel.font.pointSize];
            
            nameLabel.textColor = [SHStyleKit color:SHStyleKitColorMyTextColor];
            mainTitleLabel.textColor = [SHStyleKit color:SHStyleKitColorMyTextColor];
            subtitleLabel.textColor = [SHStyleKit color:SHStyleKitColorMyTextColor];
            
            // reset
            iconImageView.image = nil;
            nameLabel.hidden = TRUE;
            mainTitleLabel.hidden = TRUE;
            subtitleLabel.hidden = TRUE;
            
            if ([result isKindOfClass:[DrinkModel class]]) {
                DrinkModel *drink = (DrinkModel *)result;
                
                NSString *title = isFindSimilarRow ? [NSString stringWithFormat:@"Find Similar to %@", drink.name] : drink.name;
                NSString *subtitle = drink.spot.name;
                
                // Sets image to drink type
                if (drink.isBeer) {
                    SHStyleKitDrawing drawing = isFindSimilarRow ? SHStyleKitDrawingSimilarBeerIcon : SHStyleKitDrawingBeerIcon;
                    [SHStyleKit setImageView:iconImageView withDrawing:drawing color:SHStyleKitColorMyTintColor];
                }
                else if (drink.isCocktail) {
                    SHStyleKitDrawing drawing = isFindSimilarRow ? SHStyleKitDrawingSimilarCocktailIcon : SHStyleKitDrawingCocktailIcon;
                    [SHStyleKit setImageView:iconImageView withDrawing:drawing color:SHStyleKitColorMyTintColor];
                }
                else if (drink.isWine) {
                    SHStyleKitDrawing drawing = isFindSimilarRow ? SHStyleKitDrawingSimilarWineIcon : SHStyleKitDrawingWineIcon;
                    [SHStyleKit setImageView:iconImageView withDrawing:drawing color:SHStyleKitColorMyTintColor];
                }
                
                // Shows two lines if there is a spot name (brewery or winery)
                if (!subtitle.length) {
                    [nameLabel setText:title withFont:[UIFont fontWithName:@"Lato-Bold" size:nameLabel.font.pointSize] onString:drink.name];
                    nameLabel.hidden = FALSE;
                }
                else {
                    if (drink.isWine && drink.vintage && ![drink isKindOfClass:[NSNull class]]) {
                        NSString *wineText = [NSString stringWithFormat:@"%@ (%@)", title, drink.vintage];
                        [mainTitleLabel setText:wineText withFont:[UIFont fontWithName:@"Lato-Bold" size:nameLabel.font.pointSize] onString:drink.name];
                    }
                    else {
                        [mainTitleLabel setText:title withFont:[UIFont fontWithName:@"Lato-Bold" size:nameLabel.font.pointSize] onString:drink.name];
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
                
            }
            else if ([result isKindOfClass:[SpotModel class]]) {
                SpotModel *spot = (SpotModel *)result;
                
                SHStyleKitDrawing drawing = isFindSimilarRow ? SHStyleKitDrawingSimilarSpotIcon : SHStyleKitDrawingSpotIcon;
                [SHStyleKit setImageView:iconImageView withDrawing:drawing color:SHStyleKitColorMyTintColor];
                
                NSString *title = isFindSimilarRow ? [NSString stringWithFormat:@"Find Similar to %@", spot.name] : spot.name;
                [mainTitleLabel setText:title withFont:[UIFont fontWithName:@"Lato-Bold" size:nameLabel.font.pointSize] onString:spot.name];
                subtitleLabel.text =spot.addressCityState;
                
                mainTitleLabel.hidden = FALSE;
                subtitleLabel.hidden = FALSE;
            }
        }
    }
    
    NSAssert(cell, @"Cell must be defined");
    
    return cell;
}

#pragma mark - UITableViewDelegate
#pragma mark -

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger resourceIndex = [self resourceIndexForRowIndex:indexPath.row];
    
    if (resourceIndex == NSNotFound) {
        // go to Add New Review screen
        [SHNotifications reviewSpot:nil];
    }
    else if (resourceIndex < self.results.count) {
        SHJSONAPIResource *result = [self.results objectAtIndex:resourceIndex];
        
        NSInteger totalRows = self.totalRows;
        NSInteger rowNumber = indexPath.row + 1;
        BOOL isLastRow = rowNumber == totalRows;
        BOOL isFindSimilarRow = rowNumber % 2 == 0 && !isLastRow;
        
        [Tracker trackGlobalSearchResultTapped:result searchText:self.searchText];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.25 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            
            if ([result isKindOfClass:[SpotModel class]]) {
                SpotModel *spot = (SpotModel *)result;
                
                self.searchTerm = spot.name;
                self.shouldKeepTitle = TRUE;
                
                if (isFindSimilarRow) {
                    // find similar spots
                    if ([self.delegate respondsToSelector:@selector(globalSearchViewController:didSelectSimilarToSpot:)]) {
                        [self.delegate globalSearchViewController:self didSelectSimilarToSpot:spot];
                    }
                }
                else {
                    if ([self.delegate respondsToSelector:@selector(globalSearchViewController:didSelectSpot:)]) {
                        [self.delegate globalSearchViewController:self didSelectSpot:spot];
                    }
                }
            }
            else if ([result isKindOfClass:[DrinkModel class]]) {
                DrinkModel *drink = (DrinkModel *)result;
                
                self.searchTerm = drink.name;
                self.shouldKeepTitle = TRUE;
                
                if (isFindSimilarRow) {
                    // find similar drinks
                    if ([self.delegate respondsToSelector:@selector(globalSearchViewController:didSelectSimilarToDrink:)]) {
                        [self.delegate globalSearchViewController:self didSelectSimilarToDrink:drink];
                    }
                }
                else {
                    if ([self.delegate respondsToSelector:@selector(globalSearchViewController:didSelectDrink:)]) {
                        [self.delegate globalSearchViewController:self didSelectDrink:drink];
                    }
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
    
    if (self.isSearchRunning) {
        [DrinkModel cancelGetDrinks];
        [SpotModel cancelGetSpots];
        [Tracker trackGlobalSearchRequestCancelled];
    }
    
    // Resets pages and clears results
    self.page = @1;
    
    if (self.searchText.length) {
        [self doSearch];
    }
    else {
        [self dataDidFinishRefreshing];
    }
}

- (void)doSearch {
    [self setIsSearchRunning:TRUE];
    
    __block NSArray *matchedSpots = nil;
    __block NSArray *matchedDrinks = nil;
    
    if ([self.delegate respondsToSelector:@selector(globalSearchViewControllerStartedSearching:)]) {
        [self.delegate globalSearchViewControllerStartedSearching:self];
    }
    
    Promise *spotsPromise = [[SpotModel fetchSpotsWithText:self.searchText page:self.page] then:^(NSArray *spots) {
        matchedSpots = spots;
    } fail:nil always:nil];
    
    Promise *drinksPromise = [[DrinkModel fetchDrinksWithText:self.searchText page:self.page] then:^(NSArray *drinks) {
        matchedDrinks = drinks;
    } fail:nil always:nil];
    
    [Tracker trackGlobalSearchRequestStarted];
    
    [When when:@[spotsPromise, drinksPromise] then:nil fail:nil always:^{
        [self setIsSearchRunning:FALSE];
        
        if (!self.isSearchRunning) {
            if ([self.delegate respondsToSelector:@selector(globalSearchViewControllerStoppedSearching:)]) {
                [self.delegate globalSearchViewControllerStoppedSearching:self];
            }
        }
        
        [Tracker trackGlobalSearchHappened:self.searchText];

        self.results = @[].mutableCopy;
        [self.results addObjectsFromArray:matchedSpots];
        [self.results addObjectsFromArray:matchedDrinks];

        [self.results sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            NSNumber *revObj1 = [obj1 valueForKey:@"relevance"];
            NSNumber *revObj2 = [obj2 valueForKey:@"relevance"];
            return [revObj2 compare:revObj1];
        }];
        
        self.tableView.contentOffset = CGPointMake(0, 0);
        
        [self dataDidFinishRefreshing];
    }];
}

@end
