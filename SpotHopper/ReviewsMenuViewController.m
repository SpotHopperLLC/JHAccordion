//
//  ReviewsMenuViewController.m
//  SpotHopper
//
//  Created by Josh Holtz on 1/3/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#define kPageSize @15

#import "SHAppContext.h"
#import "ReviewsMenuViewController.h"

#import "NSNumber+Helpers.h"
#import "UIViewController+Navigator.h"

#import "FooterShadowCell.h"
#import "SearchCell.h"

#import "SHNavigationController.h"

#import "SectionHeaderView.h"
#import "SHButtonLatoLightLocation.h"

#import "MyReviewsViewController.h"

#import "TellMeMyLocation.h"
#import "ErrorModel.h"
#import "Tracker.h"

#import "ClientSessionManager.h"

#import <CoreLocation/CoreLocation.h>

@interface ReviewsMenuViewController ()<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, SHButtonLatoLightLocationDelegate>

@property (weak, nonatomic) IBOutlet UITextField *txtSearch;
@property (weak, nonatomic) IBOutlet SHButtonLatoLightLocation *btnLocation;
@property (weak, nonatomic) IBOutlet UITableView *tblMenu;

@property (nonatomic, assign) CGRect tblMenuInitialFrame;
@property (nonatomic, assign) BOOL keyboardShowing;

@property (nonatomic, strong) SectionHeaderView *sectionHeader0;
@property (nonatomic, strong) SectionHeaderView *sectionHeader1;

// Timer used for when to search when typing halts
@property (nonatomic, strong) NSTimer *searchTimer;

@property (nonatomic, strong) NSMutableArray *results;
@property (nonatomic, strong) NSNumber *drinkPage;
@property (nonatomic, strong) NSNumber *spotPage;
@property (nonatomic, strong) CLLocation *location;

@property (nonatomic, strong) UIStoryboard *commonStoryboard;

@end

@implementation ReviewsMenuViewController {
    BOOL _updatedSearchNeeded;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Shows sidebar button in nav
//    [self showSidebarButton:YES animated:YES];
    
    // Configures table
    [_tblMenu registerNib:[UINib nibWithNibName:@"SearchCellView" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"SearchCell"];
    [_tblMenu setTableFooterView:[[UIView alloc] init]];
    
    // Initializes things
    _results = [NSMutableArray array];
    
    _updatedSearchNeeded = TRUE;
}

- (NSArray *)viewOptions {
    return @[kDidLoadOptionsBlurredBackground,kDidLoadOptionsDontAdjustForIOS6];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    
    // Configures text search
    [_txtSearch addTarget:self action:@selector(onEditingChangeSearch:) forControlEvents:UIControlEventEditingChanged];
    
    // Gets table frame
    if (CGRectEqualToRect(_tblMenuInitialFrame, CGRectZero)) {
        _tblMenuInitialFrame = _tblMenu.frame;
    }
    
    // Keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    // Adds contextual footer view
    [self addFooterViewController:^(FooterViewController *footerViewController) {
        [footerViewController showHome:YES];
    }];
    
    // Locations
    // TODO: change this button to not need a delegate
    [_btnLocation setDelegate:self];
    [_btnLocation updateWithLastLocation];
    
    if (_updatedSearchNeeded) {
        _location = [SHAppContext lastLocation];
        [self startSearch];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    // Configures text search
    [_txtSearch addTarget:self action:@selector(onEditingChangeSearch:) forControlEvents:UIControlEventEditingChanged];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super viewWillDisappear:animated];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - Tracking

- (NSString *)screenName {
    return @"Reviews Menu";
}

#pragma mark - Keyboard

- (NSArray *)textfieldToHideKeyboard {
    return @[_txtSearch];
}

- (void)keyboardWillShow:(NSNotification*)notification {
    _keyboardShowing = YES;
    
    // Register pull to refresh
    [self registerRefreshTableView:_tblMenu withReloadType:kPullRefreshTypeBoth];
    
    [self keyboardWillHideOrShow:notification show:YES];
}

- (void)keyboardWillHide:(NSNotification*)notification {
    _keyboardShowing = NO;
    
    // No more refresh
    [self unregisterRefreshTableView];
    
    [self keyboardWillHideOrShow:notification show:NO];
}

- (void)keyboardWillHideOrShow:(NSNotification*)notification show:(BOOL)show {
    NSDictionary *userInfo = notification.userInfo;
    NSTimeInterval duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    
    CGRect keyboardFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGRect frame = _tblMenu.frame;
    if (show == YES) {
        frame.size.height = CGRectGetHeight(self.view.frame) - CGRectGetMinY(frame) - CGRectGetHeight(keyboardFrame);
        if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
            frame.size.height -= 20.0f;
        }
    } else {
        frame = _tblMenuInitialFrame;
    }
    
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionBeginFromCurrentState | curve animations:^{
        [_tblMenu setFrame:frame];
    } completion:^(BOOL finished) {
        [_tblMenu reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 5)] withRowAnimation:UITableViewRowAnimationAutomatic];
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_keyboardShowing == YES) {
        if (section == 2) {
            return _results.count;
        } else if (section == 3) {
            if (_txtSearch.text.length > 0) {
                return 1;
            }
        } else if (section == 4) {
            return 1;
        }
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 2) {
        JSONAPIResource *result = [_results objectAtIndex:indexPath.row];
        
        SearchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchCell" forIndexPath:indexPath];
        if ([result isKindOfClass:[DrinkModel class]] == YES) {
            DrinkModel *drink = (DrinkModel*)result;
            [cell setDrink:drink];
        } else if ([result isKindOfClass:[SpotModel class]] == YES) {
            SpotModel *spot = (SpotModel*)result;
            [cell setSpot:spot];
        }
        
        return cell;
    } else if (indexPath.section == 3) {
        
        SearchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchCell" forIndexPath:indexPath];

        // Only show not what looking for
        if (indexPath.row == 0) {
            [cell setNotWhatYoureLookingFor];
        }
        
        return cell;
    } else if (indexPath.section == 4) {
        static NSString *cellIdentifier = @"FooterShadowCell";
        
        FooterShadowCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if(cell == nil) {
            cell = [[FooterShadowCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        
        return cell;
    }
    
    return nil;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 2) {
        JSONAPIResource *result = [_results objectAtIndex:indexPath.row];
        if ([result isKindOfClass:[DrinkModel class]] == YES) {
            DrinkModel *drink = (DrinkModel*)result;
            [self goToDrinkProfile:drink];
        } else if ([result isKindOfClass:[SpotModel class]] == YES) {
            SpotModel *spot = (SpotModel*)result;
            [self goToSpotProfile:spot];
        }
    } else if (indexPath.section == 3) {
        if (indexPath.row == 0) {
            [self goToNewReview];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 2 || indexPath.section == 3) {
        return 55.0f;
    } else if (indexPath.section == 2) {
        return (_results.count == 0 ? 0.0f : 10.0f);
    }
    
    return 0.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [self sectionHeaderViewForSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0 || section == 1) {
        if (_keyboardShowing == NO) {
            return 65.0f;
        }
    }
    
    return 0.0f;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

#pragma mark - JHPullToRefresh

- (void)reloadTableViewDataPullDown {
    // Starts search over
    [self startSearch];
}

- (void)reloadTableViewDataPullUp {
    // Increments pages
    _drinkPage = [_drinkPage increment];
    _spotPage = [_spotPage increment];
    
    // Does search
    [self doSearch];
}

#pragma mark - SHButtonLatoLightLocationDelegate

- (void)locationRequestsUpdate:(SHButtonLatoLightLocation *)button location:(LocationChooserViewController *)viewController {
    SHNavigationController *navController = [[SHNavigationController alloc] initWithRootViewController:viewController];
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)locationUpdate:(SHButtonLatoLightLocation *)button location:(CLLocation *)location name:(NSString *)name {
    _updatedSearchNeeded = TRUE;
}

- (void)locationDidChooseLocation:(CLLocation *)location {
    _location = location;
    [self startSearch];
}

- (void)locationError:(SHButtonLatoLightLocation *)button error:(NSError *)error {
    [self showAlert:error.localizedDescription message:error.localizedRecoverySuggestion];
}

#pragma mark - Actions

- (void)onEditingChangeSearch:(id)sender {
    // Cancel and nil
    [_searchTimer invalidate];
    _searchTimer = nil;
    
    // Schedule timer
    _searchTimer = [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(startSearch) userInfo:nil repeats:NO];
}

#pragma mark - Private

- (void)startSearch {
    _updatedSearchNeeded = FALSE;
    
    [DrinkModel cancelGetDrinks];
    [SpotModel cancelGetSpots];
    
    // Resets pages and clears results
    _drinkPage = @1;
    _spotPage = @1;
    [_results removeAllObjects];
    
    [self dataDidFinishRefreshing];
    
    if (_txtSearch.text.length > 0) {
        [self doSearch];
    } else {
        [self dataDidFinishRefreshing];
    }
}

- (void)doSearch {
    
    [self showHUD:@"Searching"];
    
    /*
     * Searches drinks
     */
    NSDictionary *paramsDrinks = @{
                                   kDrinkModelParamQuery : _txtSearch.text,
                                   kDrinkModelParamPage : _drinkPage,
                                   kDrinkModelParamsPageSize : kPageSize
                                   };
    
    Promise *promiseDrinks = [DrinkModel getDrinks:paramsDrinks success:^(NSArray *drinkModels, JSONAPI *jsonApi) {
        // Adds drinks to results
        [_results addObjectsFromArray:drinkModels];
    } failure:^(ErrorModel *errorModel) {
        [Tracker logError:errorModel class:[self class] trace:NSStringFromSelector(_cmd)];
    }];
    
    /*
     * Searches spots
     */
    NSMutableDictionary *paramsSpots = @{
                                         kSpotModelParamQuery : _txtSearch.text,
                                         kSpotModelParamQueryVisibleToUsers : @"true",
                                         kSpotModelParamPage : _spotPage,
                                         kSpotModelParamsPageSize : kPageSize
                                         }.mutableCopy;
    
    [paramsSpots setObject:kSpotModelParamSourcesSpotHopper forKey:kSpotModelParamSources];
    
    if (_location != nil) {
        [paramsSpots setObject:[NSNumber numberWithFloat:_location.coordinate.latitude] forKey:kSpotModelParamQueryLatitude];
        [paramsSpots setObject:[NSNumber numberWithFloat:_location.coordinate.longitude] forKey:kSpotModelParamQueryLongitude];
    }
    
    Promise *promiseSpots = [SpotModel getSpots:paramsSpots success:^(NSArray *spotModels, JSONAPI *jsonApi) {
        // Adds spots to results
        [_results addObjectsFromArray:spotModels];
    } failure:^(ErrorModel *errorModel) {
        [Tracker logError:errorModel class:[self class] trace:NSStringFromSelector(_cmd)];
    }];
    
    /*
     * When
     */
    [When when:@[promiseDrinks, promiseSpots] then:^{
        
    } fail:^(id error) {
        
    } always:^{
        [self hideHUD];
        
        [_results sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            NSNumber *revObj1 = [obj1 valueForKey:@"relevance"];
            NSNumber *revObj2 = [obj2 valueForKey:@"relevance"];
            return [revObj2 compare:revObj1];
        }];
        
        [self dataDidFinishRefreshing];
    }];
}

- (SectionHeaderView *)instantiateSectionHeaderView {
    // load the VC and get the view (to allow for easily laying out the custom section header)
    if (!_commonStoryboard) {
        _commonStoryboard = [UIStoryboard storyboardWithName:@"Common" bundle:nil];
    }
    UIViewController *vc = [_commonStoryboard instantiateViewControllerWithIdentifier:@"SectionHeaderScene"];
    SectionHeaderView *sectionHeaderView = (SectionHeaderView *)[vc.view viewWithTag:100];
    [sectionHeaderView removeFromSuperview];
    [sectionHeaderView prepareView];
    
    return sectionHeaderView;
}

- (SectionHeaderView*)sectionHeaderViewForSection:(NSInteger)section {
//    __block ReviewsMenuViewController *this = self;
    __weak ReviewsMenuViewController *weakSelf = self;
    
    if (section == 0) {
        if (_sectionHeader0 == nil) {
            _sectionHeader0 = [self instantiateSectionHeaderView];
            [_sectionHeader0 setIconImage:[UIImage imageNamed:@"icon_view_my_reviews"]];
            [_sectionHeader0 setText:@"View My Reviews"];
            [_sectionHeader0.imgArrow setImage:[UIImage imageNamed:@"img_expand_east"]];
            
            [_sectionHeader0.btnBackground setActionWithBlock:^{
                __strong __typeof(weakSelf)strongSelf = weakSelf;
                if ([strongSelf promptLoginNeeded:@"Cannot view your reviews without logging in"] == NO) {
                    [strongSelf goToMyReviews];
                }
            }];
        }
        
        return _sectionHeader0;
    } else if (section == 1) {
        if (_sectionHeader1 == nil) {
            _sectionHeader1 = [self instantiateSectionHeaderView];
            [_sectionHeader1 setIconImage:[UIImage imageNamed:@"icon_plus"]];
            [_sectionHeader1 setText:@"Add New Review"];
            [_sectionHeader1.imgArrow setImage:[UIImage imageNamed:@"img_expand_east"]];
            [_sectionHeader1.btnBackground setActionWithBlock:^{
                __strong __typeof(weakSelf)strongSelf = weakSelf;
                if ([strongSelf promptLoginNeeded:@"Cannot add a review without logging in"] == NO) {
                    [strongSelf goToSearchForNewReview:NO notWhatLookingFor:YES createReview:YES];
                }
            }];
        }
        
        return _sectionHeader1;
    }
    return nil;
}

@end
