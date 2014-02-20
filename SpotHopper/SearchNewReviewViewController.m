//
//  SearchNewReviewViewController.m
//  SpotHopper
//
//  Created by Josh Holtz on 1/15/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#define kPageSize @20

#import "NSNumber+Helpers.h"
#import "UIViewController+Navigator.h"

#import "TellMeMyLocation.h"

#import "SHButtonLatoLightLocation.h"

#import "SearchNewReviewViewController.h"

#import "FooterShadowCell.h"
#import "SearchCell.h"

#import "DrinkModel.h"
#import "ErrorModel.h"
#import "SpotModel.h"

#import <CoreLocation/CoreLocation.h>
#import <QuartzCore/QuartzCore.h>

@interface SearchNewReviewViewController ()<UITableViewDataSource, UITableViewDelegate, SHButtonLatoLightLocationDelegate>

@property (weak, nonatomic) IBOutlet UITextField *txtSearch;
@property (weak, nonatomic) IBOutlet SHButtonLatoLightLocation *btnLocation;
@property (weak, nonatomic) IBOutlet UITableView *tblSearches;

@property (nonatomic, assign) CGRect tblSearchesInitalFrame;

// Timer used for when to search when typing halts
@property (nonatomic, strong) NSTimer *searchTimer;

@property (nonatomic, strong) NSMutableArray *results;
@property (nonatomic, strong) NSNumber *drinkPage;
@property (nonatomic, strong) NSNumber *spotPage;

@property (nonatomic, strong) TellMeMyLocation *tellMeMyLocation;
@property (nonatomic, strong) CLLocation *location;

@end

@implementation SearchNewReviewViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad:@[kDidLoadOptionsBlurredBackground,kDidLoadOptionsDontAdjustForIOS6]];
    
    // Sets title
    [self setTitle:@"New Reviews"];
    
    // Shows sidebar button in nav
    [self showSidebarButton:YES animated:YES];
    
    // Configures table
    [_tblSearches setTableFooterView:[[UIView alloc] init]];
    [_tblSearches registerNib:[UINib nibWithNibName:@"SearchCellView" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"SearchCell"];
    
    // Configures text search
    [_txtSearch addTarget:self action:@selector(onEditingChangeSearch:) forControlEvents:UIControlEventEditingChanged];
    
    // Register pull to refresh
    [self registerRefreshTableView:_tblSearches withReloadType:kPullRefreshTypeBoth];
    
    // Initializes states
    _tblSearchesInitalFrame = CGRectZero;
    _results = [NSMutableArray array];
    _drinkPage = @1;
    _spotPage = @1;
    
    [_txtSearch becomeFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Deselects table row
    [_tblSearches deselectRowAtIndexPath:_tblSearches.indexPathForSelectedRow animated:NO];
    
    // Gets table frame
    if (CGRectEqualToRect(_tblSearchesInitalFrame, CGRectZero)) {
        _tblSearchesInitalFrame = _tblSearches.frame;
    }
    
    // Keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    // Adds contextual footer view
    [self addFooterViewController:^(FooterViewController *footerViewController) {
        [footerViewController showHome:YES];
    }];
    
    [_btnLocation setDelegate:self];
    [_btnLocation updateWithLastLocation];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    CGRect frame = _tblSearches.frame;
    if (show == YES) {
        frame.size.height = CGRectGetHeight(self.view.frame) - CGRectGetMinY(frame) - CGRectGetHeight(keyboardFrame);
        if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
            frame.size.height -= 20.0f;
        }
    } else {
        frame = _tblSearchesInitalFrame;
    }
    
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionBeginFromCurrentState | curve animations:^{
        [_tblSearches setFrame:frame];
    } completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return _results.count;
    } else if (section == 1) {
        if (_txtSearch.text.length > 0) {
            if (_showSimilarList == YES && _showNotWhatLookingFor == YES) {
                return 3;
            } else if (_showSimilarList == YES) {
                return 2;
            } else if (_showNotWhatLookingFor == YES) {
                return 1;
            }
        }
    } else if (section == 2) {
        return 1;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
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
    } else if (indexPath.section == 1) {
        
        SearchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchCell" forIndexPath:indexPath];

        // Show both similar and not what looking for
        if (_showSimilarList == YES && _showNotWhatLookingFor == YES) {
            if (indexPath.row == 0) {
                [cell setDrinksSimilar:_txtSearch.text];
            } else if (indexPath.row == 1) {
                [cell setSpotsSimilar:_txtSearch.text];
            } else if (indexPath.row == 2) {
                [cell setNotWhatYoureLookingFor];
            }
        }
        // Show only similar
        else if (_showSimilarList == YES) {
            if (indexPath.row == 0) {
                [cell setDrinksSimilar:_txtSearch.text];
            } else if (indexPath.row == 1) {
                [cell setSpotsSimilar:_txtSearch.text];
            }
        }
        // Only show not what looking for
        else if (_showNotWhatLookingFor == YES) {
            if (indexPath.row == 0) {
                [cell setNotWhatYoureLookingFor];
            }
        }
        
        return cell;
    } else if (indexPath.section == 2) {
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
    if (indexPath.section == 0) {
        JSONAPIResource *result = [_results objectAtIndex:indexPath.row];
        if ([result isKindOfClass:[DrinkModel class]] == YES) {
            DrinkModel *drink = (DrinkModel*)result;
            
            // Create a review for this drink
            if (_createReview == YES) {
                [self goToNewReviewForDrink:drink];
            }
            // Go to drink profile
            else {
                
            }
        } else if ([result isKindOfClass:[SpotModel class]] == YES) {
            SpotModel *spot = (SpotModel*)result;
            
            // Create a review for this spot
            if (_createReview == YES) {
                [self goToNewReviewForSpot:spot];
            }
            // Go to spot profile
            else {
                [self goToSpotProfile:spot];
            }
        }
    } else if (indexPath.section == 1) {
        
        
        if (_showSimilarList == YES && _showNotWhatLookingFor == YES) {
            
        } else if (_showSimilarList == YES) {

        } else if (_showNotWhatLookingFor == YES) {
            if (indexPath.row == 0) {
                [self goToNewReview];
            }
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 || indexPath.section == 1) {
        return 45.0f;
    } else if (indexPath.section == 2) {
        return (_results.count == 0 ? 0.0f : 10.0f);
    }
    
    return 0.0f;
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
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)locationUpdate:(SHButtonLatoLightLocation *)button location:(CLLocation *)location name:(NSString *)name {
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

- (IBAction)onClickLocation:(id)sender {
    
}

#pragma mark - Private

- (void)startSearch {
    // Resets pages and clears results
    _drinkPage = @1;
    _spotPage = @1;
    [_results removeAllObjects];
    [_tblSearches reloadData];
    
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
        
    }];
    
    /*
     * Searches spots
     */
    NSMutableDictionary *paramsSpots = @{
                             kSpotModelParamQuery : _txtSearch.text,
                             kSpotModelParamPage : _spotPage,
                             kSpotModelParamsPageSize : kPageSize
                             }.mutableCopy;
    if (_location != nil) {
        [paramsSpots setObject:[NSNumber numberWithFloat:_location.coordinate.latitude] forKey:kSpotModelParamLatitude];
        [paramsSpots setObject:[NSNumber numberWithFloat:_location.coordinate.longitude] forKey:kSpotModelParamLongitude];
    }
    
    Promise *promiseSpots = [SpotModel getSpots:paramsSpots success:^(NSArray *spotModels, JSONAPI *jsonApi) {
        // Adds spots to results
        [_results addObjectsFromArray:spotModels];
    } failure:^(ErrorModel *errorModel) {
        
    }];
    
    /*
     * When
     */
    [When when:@[promiseDrinks, promiseSpots] then:^{
        
    } fail:^(id error) {
        
    } always:^{
        NSLog(@"Total stuffs - %d", _results.count);
        [self dataDidFinishRefreshing];
        [self hideHUD];
    }];
}

@end
