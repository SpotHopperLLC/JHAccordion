//
//  TonightsSpecialsViewController.m
//  SpotHopper
//
//  Created by Josh Holtz on 3/26/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#define kPageSize @20

#import "NSNumber+Helpers.h"

#import "TonightsSpecialsViewController.h"

#import "SHButtonLatoLightLocation.h"

#import "SHNavigationController.h"

#import "SpecialsCell.h"

#import "ErrorModel.h"
#import "SpotModel.h"

#import <CoreLocation/CoreLocation.h>

@interface TonightsSpecialsViewController ()<UITableViewDataSource, UITableViewDelegate, SHButtonLatoLightLocationDelegate>

@property (weak, nonatomic) IBOutlet SHButtonLatoLightLocation *btnLocation;

@property (weak, nonatomic) IBOutlet UITableView *tblSpecials;

@property (nonatomic, strong) NSNumber *page;
@property (nonatomic, strong) NSMutableArray *spots;

@property (nonatomic, strong) CLLocation *location;

@end

@implementation TonightsSpecialsViewController

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
    [self setTitle:@"Tonight's Specials"];
    
    // Shows sidebar button in nav
    [self showSidebarButton:YES animated:YES];
    
    // Register pull to refresh
    [self registerRefreshTableView:_tblSpecials withReloadType:kPullRefreshTypeBoth];
    
    // Initializes stuff
    _page = @1;
    _spots = [NSMutableArray array];
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _spots.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SpecialsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SpecialsCell" forIndexPath:indexPath];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 125.0f;
}

#pragma mark - JHPullToRefresh

- (void)reloadTableViewDataPullDown {
    // Resets pages and clears results
    _page = @1;
    [_spots removeAllObjects];
    
    [self fetchSpecials];
}

- (void)reloadTableViewDataPullUp {
    // Increments pages
    _page = [_page increment];
    
    // Fetches more specials
    [self fetchSpecials];
}

#pragma mark - SHButtonLatoLightLocationDelegate

- (void)locationRequestsUpdate:(SHButtonLatoLightLocation *)button location:(LocationChooserViewController *)viewController {
    SHNavigationController *navController = [[SHNavigationController alloc] initWithRootViewController:viewController];
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)locationUpdate:(SHButtonLatoLightLocation *)button location:(CLLocation *)location name:(NSString *)name {
    _location = location;
    [self fetchSpecials];
}

- (void)locationError:(SHButtonLatoLightLocation *)button error:(NSError *)error {
    [self showAlert:error.localizedDescription message:error.localizedRecoverySuggestion];
}

#pragma mark - Private

- (void)fetchSpecials {
    
    /*
     * Searches spots for specials
     */
    NSMutableDictionary *params = @{
                                         kSpotModelParamPage : _page,
                                         kSpotModelParamsPageSize : kPageSize,
                                         kSpotModelParamSources : kSpotModelParamSourcesSpotHopper
                                         }.mutableCopy;
    
    // Setting location parameters
    if (_location != nil) {
        [params setObject:[NSNumber numberWithFloat:_location.coordinate.latitude] forKey:kSpotModelParamQueryLatitude];
        [params setObject:[NSNumber numberWithFloat:_location.coordinate.longitude] forKey:kSpotModelParamQueryLongitude];
    }
    
    [self showHUD:@"Finding specials"];
    [SpotModel getSpots:params success:^(NSArray *spotModels, JSONAPI *jsonApi) {
        [self hideHUD];
        
        // Adds spots to results
        [_spots addObjectsFromArray:spotModels];
        [self dataDidFinishRefreshing];
        
    } failure:^(ErrorModel *errorModel) {
        [self dataDidFinishRefreshing];
        
        [self hideHUD];
        [self showAlert:@"Oops" message:errorModel.human];
    }];
    
}

@end
