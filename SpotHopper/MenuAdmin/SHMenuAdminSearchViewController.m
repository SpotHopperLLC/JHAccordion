//
//  SHMenuAdminSearchViewController.m
//  SpotHopper
//
//  Created by Josh Holtz on 4/1/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import <Crashlytics/Crashlytics.h>

#import "SHMenuAdminSearchViewController.h"
#import "SHMenuAdminAddNewBeerViewController.h"

#import "NSNumber+Helpers.h"

#import "UserModel.h"
#import "DrinkModel.h"
#import "DrinkTypeModel.h"
#import "DrinkSubtypeModel.h"
#import "MenuItemModel.h"
#import "SpotModel.h"
#import "ErrorModel.h"

#import "Tracker.h"

#import "SHMenuAdminDrinkTableViewCell.h"
#import "SHMenuAdminSpotTableViewCell.h"

//#import "AppConstants.h"

#import "SHMenuAdminNetworkManager.h"
#import "ImageUtil.h"
#import "ClientSessionManager.h"

#import "SHMenuAdminStyleSupport.h"

#define kDrinkModelParamManufacturer @"manufacturer_id"
#define kPageSize @15

#define kMaxAddressWidth 200.0f

@interface SHMenuAdminSearchViewController ()<SHMenuAdminAddNewBeerDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableviewBottomConstraint;
@property (nonatomic, assign) CGFloat startingTableviewBottomConstraint;

@property (weak, nonatomic) IBOutlet UITextField *txtSearch;
@property (weak, nonatomic) IBOutlet UITableView *tblResults;
@property (weak, nonatomic) IBOutlet UILabel *lblSearch;

@property (nonatomic, strong) NSTimer *searchTimer;

@property (nonatomic, assign) CGRect tblResultsInitialFrame;

@property (nonatomic, strong) NSNumber *page;
@property (nonatomic, strong) NSMutableArray *results;

@property (nonatomic, strong) NSMutableDictionary *drinkTypeMap;

@end

@implementation SHMenuAdminSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Register pull to refresh
    [self registerRefreshTableView:_tblResults withReloadType:kPullRefreshTypeBoth];
    
    [self styleView];
    
    self.startingTableviewBottomConstraint = self.tableviewBottomConstraint.constant;
    
    // Initializes stuff
    _tblResultsInitialFrame = CGRectZero;
    _results = [NSMutableArray array];
    
    if (self.isHouseCocktail && !self.spot) {
        NSAssert(self.spot, @"spot must be defined if searching for house cocktails");
    }
    
    if (self.isWine && !self.menuType) {
        NSAssert(self.menuType, @"menu type must be defined if searching wines");
    }
    
    if (self.isSpotSearch) {
        self.txtSearch.placeholder = @"Search for spot named...";
    }
    
    self.drinkTypeMap = [NSMutableDictionary dictionary];
    [self createTypeDictionary];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //hide navbar
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    
    [_txtSearch becomeFirstResponder];
    
    // Configures text search
    [_txtSearch addTarget:self action:@selector(onEditingChangeSearch:) forControlEvents:UIControlEventEditingChanged];
    
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    DebugLog(@"segue: %@", segue.identifier);
    
    if ([@"SearchToNewBeerModal" isEqualToString:segue.identifier]) {
        if ([segue.destinationViewController isKindOfClass:[UINavigationController class]]) {
            UINavigationController *nc = (UINavigationController *)segue.destinationViewController;
            if ([nc.topViewController isKindOfClass:[SHMenuAdminAddNewBeerViewController class]]) {
                SHMenuAdminAddNewBeerViewController *vc = (SHMenuAdminAddNewBeerViewController *)nc.topViewController;
                vc.delegate = self;
            }
        }
    }
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
    //CGRect frame = _tblResults.frame;
    
    CGFloat height;
    
    if (show == YES) {
        height  = CGRectGetHeight(self.view.frame) - CGRectGetMinY(self.tblResults.frame) - CGRectGetHeight(keyboardFrame);
        //        frame.size.height = CGRectGetHeight(self.view.frame) - CGRectGetMinY(frame) - CGRectGetHeight(keyboardFrame);

        
        if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
            height -= 20.0f;
        }
        
    } else {
        //set bottom constraint to original position
        height = self.startingTableviewBottomConstraint;
    }
    
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionBeginFromCurrentState | curve animations:^{
        //set bottom constraint to above the keyboard
        self.tableviewBottomConstraint.constant = height;
    } completion:^(BOOL finished) {
        [self dataDidFinishRefreshing];
    }];

}

#pragma mark - SHMenuAdminAddNewBeerDelegate
#pragma mark -

- (void)addNewBeerViewController:(SHMenuAdminAddNewBeerViewController *)vc didCreateDrink:(DrinkModel *)drink {
    [vc.presentingViewController dismissViewControllerAnimated:TRUE completion:^{
        if ([self.delegate respondsToSelector:@selector(searchViewController:selectedDrink:)]) {
            [self.delegate searchViewController:self selectedDrink:drink];
        }
    }];
}

#pragma mark - UITableViewDataSource
#pragma mark -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _results.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    JSONAPIResource *result = [_results objectAtIndex:indexPath.row];
    
    if ([result isKindOfClass:[DrinkModel class]] == YES) {
        SHMenuAdminDrinkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DrinkCell" forIndexPath:indexPath];
        DrinkModel *drink = (DrinkModel*)result;
        [cell setDrink:drink];
        
        return cell;

        
    } else if ([result isKindOfClass:[SpotModel class]] == YES) {
        SHMenuAdminSpotTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SpotCell" forIndexPath:indexPath];
        SpotModel *spot = (SpotModel*)result;
        [cell setSpot:spot];
        
        return cell;

    }
    
    CLS_LOG(@"json result returned is neither a spot or drink");
    return nil;
    
}

#pragma mark - UITableViewDelegate
#pragma mark -

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    JSONAPIResource *result = [_results objectAtIndex:indexPath.row];
    if ([result isKindOfClass:[DrinkModel class]] == YES) {
        DrinkModel *drink = (DrinkModel*)result;
        
        for (MenuItemModel *menuItem in self.filteredMenuItems) {
            if ([menuItem.drink isEqual:drink]) {
                //display
                [self showAlert:[NSString stringWithFormat:@"Duplicate %@", self.drinkType] message:[NSString stringWithFormat:@"%@ is already a part of your %@ selection.", menuItem.drink.name, self.menuType]];
                
                [tableView deselectRowAtIndexPath:indexPath animated:YES];

                return;
            }
        }
        
        //delegate to the homeviewcontroller to add a new cell with the DrinkModel info
        if ([self.delegate respondsToSelector:@selector(searchViewController:selectedDrink:)]) {
            [self.delegate searchViewController:self selectedDrink:drink];
        }
        
    } else if ([result isKindOfClass:[SpotModel class]] == YES) {
        SpotModel *spot = (SpotModel*)result;
        
        if ([self.delegate respondsToSelector:@selector(searchViewController:selectedSpot:)]) {
            //delegate to the homeviewcontroller to
            //1. fetch menu items w/ new spot's id
            //2. display menu items
            [self.delegate searchViewController:self selectedSpot:spot];
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 68.0f;

    if (self.isSpotSearch) {
//        SpotModel *spot = [_results objectAtIndex:indexPath.row];
//       
//        if (spot.addressCityState) {
//             height += [self heightForString:spot.addressCityState font:[UIFont fontWithName:@"Lato-Italic" size:14.0f] maxWidth:kMaxAddressWidth];
//        }
//        else {
//            height = 85.0f;
//        }
        
        height = 80.0f;
    }
    
    return height;
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

#pragma mark - User Actions

- (void)onEditingChangeSearch:(id)sender {
    // Cancel and nil
    [_searchTimer invalidate];
    _searchTimer = nil;
    
    // Schedule timer
    _searchTimer = [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(startSearch) userInfo:nil repeats:NO];
}

- (IBAction)backButtonTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)newDrinkButtonTapped:(id)sender {
    DebugLog(@"%@", NSStringFromSelector(_cmd));
    [self performSegueWithIdentifier:@"SearchToNewBeerModal" sender:self];
}

#pragma mark - Private

- (void)createTypeDictionary {
    
    [[SHMenuAdminNetworkManager sharedInstance] fetchDrinkTypes:^(NSArray *drinkTypes) {
        for (DrinkTypeModel *drinkType in drinkTypes) {
            [self.drinkTypeMap setObject:drinkType.ID forKey:drinkType.name];
        }
    } failure:^(ErrorModel *error) {
       
        CLS_LOG(@"network error seacrching for drink types.f Error: %@", error.humanValidations);
        //attempt to fetch types again
        [self createTypeDictionary];
    }];
    
}

- (void)startSearch {
    [self cancelRequests];
    // Resets pages and clears results
    _page = @1;
        
    if (_txtSearch.text.length > 0) {
        [self doSearch];
    } else {
        [self dataDidFinishRefreshing];
    }
}

- (void)doSearch {
    
    [self hideHUD];
    [self showHUD:@"Searching"];
    
    if (_isSpotSearch) {
        UserModel *user = [ClientSessionManager sharedClient].currentUser;

        //search spots
        [[SHMenuAdminNetworkManager sharedInstance] fetchUserSpots:user queryParam:self.txtSearch.text page:@1 pageSize:kPageSize success:^(NSArray *spots) {
           
            [_results removeAllObjects];
            [self.results addObjectsFromArray:spots];

            [self hideHUD];
            [self sortResultsAfterFetch];
            [self dataDidFinishRefreshing];

        } failure:^(ErrorModel *error) {
            [self showAlert:@"Network error" message:@"Please try again"];
            
            CLS_LOG(@"network error searching for spots. Error: %@", error.humanValidations);
        }];
    }
    else {
        //search drinks
        id drinkTypeID = [self.drinkTypeMap objectForKey:self.drinkType];
        NSMutableDictionary *extraParams = [NSMutableDictionary dictionary];

        if (self.isHouseCocktail) {
           [extraParams setValue:self.spot.ID forKey:kDrinkModelParamManufacturer];
        }
        
        [[SHMenuAdminNetworkManager sharedInstance] fetchDrinks:drinkTypeID queryParam:self.txtSearch.text page:self.page pageSize:kPageSize extraParams:extraParams success:^(NSArray *drinks) {
            
            [_results removeAllObjects];
            
            //if a wine, only show wines with the correct drink type
            if (_isWine) {
                for (DrinkModel *drink in drinks) {
                    if ([drink.drinkSubtype.name isEqualToString:self.menuType]) {
                        [_results addObject:drink];
                    }
                }
            }
            else {
                // Adds drinks to results
                [_results addObjectsFromArray:drinks];
            }
            
            [self hideHUD];
            [self sortResultsAfterFetch];
            [self dataDidFinishRefreshing];
            
        } failure:^(ErrorModel *error) {
            //[self showAlert:@"Network error" message:@"Please try again"];
            CLS_LOG(@"network error seacrching for drinks. Error: %@", error.humanValidations);
        }];
        
    }
}

- (void)cancelRequests {
    [DrinkModel cancelGetDrinks];
    [[ClientSessionManager sharedClient] cancelAllHTTPOperationsWithMethod:@"GET" path:@"/api/users" parameters:nil ignoreParams:YES];
}

- (void)sortResultsAfterFetch {
    [_results sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSNumber *revObj1 = [obj1 valueForKey:@"relevance"];
        NSNumber *revObj2 = [obj2 valueForKey:@"relevance"];
        return [revObj2 compare:revObj1];
    }];
}

#pragma mark - Styling
#pragma mark -

- (void)styleView {
    self.headerView.backgroundColor = [SHMenuAdminStyleSupport sharedInstance].LIGHT_ORANGE;
    
    self.txtSearch.placeholder = [NSString stringWithFormat:@"Find %@ named...", [self.drinkType lowercaseString]];
    self.txtSearch.font = [UIFont fontWithName:@"Lato-Regular" size:14.0f];
    self.txtSearch.backgroundColor = [SHMenuAdminStyleSupport sharedInstance].DARK_ORANGE;
    self.txtSearch.textColor = [UIColor whiteColor];
    
    self.lblSearch.font = [UIFont fontWithName:@"Lato-Regular" size:20.0f];

}

@end
