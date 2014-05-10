//
//  TonightsSpecialsViewController.m
//  SpotHopper
//
//  Created by Josh Holtz on 3/26/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#define kPageSize @25

#import "NSNumber+Helpers.h"
#import "UIViewController+Navigator.h"

#import "TonightsSpecialsViewController.h"

#import "SHButtonLatoLightLocation.h"

#import "SHNavigationController.h"

#import "SpecialsCell.h"

#import "ErrorModel.h"
#import "SpotModel.h"

#import "TellMeMyLocation.h"
#import "Tracker.h"

#import <CoreLocation/CoreLocation.h>

@interface TonightsSpecialsViewController ()<UITableViewDataSource, UITableViewDelegate, SHButtonLatoLightLocationDelegate, SpecialsCellDelegate>

@property (weak, nonatomic) IBOutlet SHButtonLatoLightLocation *btnLocation;

@property (weak, nonatomic) IBOutlet UITableView *tblSpecials;
@property (weak, nonatomic) IBOutlet UIView *viewEmpty;

@property (nonatomic, strong) NSNumber *page;
@property (nonatomic, strong) NSMutableArray *spots;

@property (nonatomic, strong) CLLocation *location;

@end

@implementation TonightsSpecialsViewController {
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
    [super viewDidLoad:@[kDidLoadOptionsBlurredBackground,kDidLoadOptionsDontAdjustForIOS6]];
    
    // Sets title
    [self setTitle:@"Tonight's Specials"];
    
    // Shows sidebar button in nav
    [self showSidebarButton:YES animated:YES];
    
    // Register pull to refresh
    [self registerRefreshTableView:_tblSpecials withReloadType:kPullRefreshTypeBoth];
    
    // Initializes stuff
    _page = @1;
    _spots = [NSMutableArray array];
    
    _updatedSearchNeeded = TRUE;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    
    // Deselects cell
    [_tblSpecials deselectRowAtIndexPath:[_tblSpecials indexPathForSelectedRow] animated:NO];
    
    // Adds contextual footer view
    [self addFooterViewController:^(FooterViewController *footerViewController) {
        [footerViewController showHome:YES];
        [footerViewController setRightButton:@"Info" image:[UIImage imageNamed:@"btn_context_info"]];
    }];
    
    // Fetching spot lists
    if (_location == nil) {
        // Locations
        [_btnLocation setDelegate:self];
        [_btnLocation updateWithLastLocation];
    } else {
        [self fetchSpecials];
    }
    
    if (_updatedSearchNeeded) {
        _location = [TellMeMyLocation lastLocation];
        [self fetchSpecials];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Tracking

- (NSString *)screenName {
    return @"Tonight's Specials";
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _spots.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SpotModel *spot = [_spots objectAtIndex:indexPath.row];
    
    SpecialsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SpecialsCell" forIndexPath:indexPath];
    [cell setSpot:spot];
    [cell setDelegate:self];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SpotModel *spot = [_spots objectAtIndex:indexPath.row];
    [self goToSpotProfile:spot];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 125.0f;
}

#pragma mark - JHPullToRefresh

- (void)reloadTableViewDataPullDown {
    // Resets pages
    _page = @1;
    
    [self fetchSpecials];
}

- (void)reloadTableViewDataPullUp {
    // Increments pages
    _page = [_page increment];
    
    // Fetches more specials
    [self fetchSpecials];
}

#pragma mark - SpecialsCellDelegate

- (void)specialsCellClickedShare:(SpecialsCell *)cell {
    NSIndexPath *indexPath = [_tblSpecials indexPathForCell:cell];
    SpotModel *spot = [_spots objectAtIndex:indexPath.row];
    
    [self showShareViewControllerWithSpot:spot shareType:ShareViewControllerShareSpecial];
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
    [self fetchSpecials];
}

- (void)locationError:(SHButtonLatoLightLocation *)button error:(NSError *)error {
    [self showAlert:error.localizedDescription message:error.localizedRecoverySuggestion];
}

#pragma mark - Footer

- (BOOL)footerViewController:(FooterViewController *)footerViewController clickedButton:(FooterViewButtonType)footerViewButtonType {
    if (FooterViewButtonRight == footerViewButtonType) {
        [self showAlert:@"Info" message:kInfoTonightsSpecials];
        return YES;
    }
    
    return NO;
}

#pragma mark - Private

- (void)fetchSpecials {
    _updatedSearchNeeded = FALSE;
    
    // Day of week
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [gregorian components:NSWeekdayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit|NSDayCalendarUnit|NSTimeZoneCalendarUnit fromDate:[NSDate date]];
    
    // Get open and close time
    NSInteger dayOfWeek = [comps weekday] -1;
    
    /*
     * Searches spots for specials
     */
    NSMutableDictionary *params = @{
                                         kSpotModelParamPage : _page,
                                         kSpotModelParamQueryVisibleToUsers : @"true",
                                         kSpotModelParamsPageSize : kPageSize,
                                         kSpotModelParamSources : kSpotModelParamSourcesSpotHopper,
                                         kSpotModelParamQueryDayOfWeek : [NSNumber numberWithInteger:dayOfWeek]
                                         }.mutableCopy;
    
    // Setting location parameters
    if (_location != nil) {
        [params setObject:[NSNumber numberWithFloat:_location.coordinate.latitude] forKey:kSpotModelParamQueryLatitude];
        [params setObject:[NSNumber numberWithFloat:_location.coordinate.longitude] forKey:kSpotModelParamQueryLongitude];
    }
    
    [self showHUD:@"Finding specials"];
    [SpotModel getSpotsWithSpecials:params success:^(NSArray *spotModels, JSONAPI *jsonApi) {
        [self hideHUD];
        
        if ([_page isEqualToNumber:@1] == YES) {
            [_spots removeAllObjects];
        }
        
        // Adds spots to results
        [_spots addObjectsFromArray:spotModels];
        
        [_tblSpecials setHidden:( _spots.count == 0 )];
        [_viewEmpty setHidden:( _spots.count != 0 )];
        
        [self dataDidFinishRefreshing];
        
    } failure:^(ErrorModel *errorModel) {
        [self dataDidFinishRefreshing];
        
        [self hideHUD];
        [self showAlert:@"Oops" message:errorModel.human];
        [Tracker logError:errorModel.error];
    }];
    
}

@end
