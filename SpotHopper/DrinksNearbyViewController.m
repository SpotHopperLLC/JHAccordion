//
//  DrinksNearbyViewController.m
//  SpotHopper
//
//  Created by Josh Holtz on 3/13/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "DrinksNearbyViewController.h"

#import "SHButtonLatoLightLocation.h"

#import "UIViewController+Navigator.h"

#import "SHNavigationController.h"
#import "DrinkListMenuViewController.h"

#import "FindSimilarViewController.h"

#import "ErrorModel.h"
#import "SpotModel.h"

#import <CoreLocation/CoreLocation.h>

@interface DrinksNearbyViewController ()<SHButtonLatoLightLocationDelegate, FindSimilarViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *btnNearBy;
@property (weak, nonatomic) IBOutlet SHButtonLatoLightLocation *btnLocation;

@property (weak, nonatomic) IBOutlet UILabel *lblAtPlace;

@property (nonatomic, strong) CLLocation *location;

@property (nonatomic, strong) SpotModel *spotNearby;

@end

@implementation DrinksNearbyViewController

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
    [self setTitle:@"Drinklists"];
    
    // Shows sidebar button in nav
    [self showSidebarButton:YES animated:YES];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    
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
        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - SHButtonLatoLightLocationDelegate

- (void)locationRequestsUpdate:(SHButtonLatoLightLocation *)button location:(LocationChooserViewController *)viewController {
    SHNavigationController *navController = [[SHNavigationController alloc] initWithRootViewController:viewController];
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)locationUpdate:(SHButtonLatoLightLocation *)button location:(CLLocation *)location name:(NSString *)name {
    _location = location;
    [self fetchClosetSpot];
}

- (void)locationError:(SHButtonLatoLightLocation *)button error:(NSError *)error {
    [self showAlert:error.localizedDescription message:error.localizedRecoverySuggestion];
}

#pragma mark - FindSimilarViewControllerDelegate

- (void)findSimilarViewController:(FindSimilarViewController *)viewController selectedDrink:(DrinkModel *)drink {
    
}

- (void)findSimilarViewController:(FindSimilarViewController *)findSimilarViewController selectedSpot:(SpotModel *)spot {
    NSMutableArray *viewControllers = self.navigationController.viewControllers.mutableCopy;
    [viewControllers removeLastObject];
    
    DrinkListMenuViewController *viewController = [self.drinksStoryboard instantiateViewControllerWithIdentifier:@"DrinkListMenuViewController"];
    [viewController setSpot:spot];
    [viewControllers addObject:viewController];
    
    [self.navigationController setViewControllers:viewControllers animated:YES];
}

#pragma mark - Actions

- (IBAction)onClickDrinksHere:(id)sender {
    if (_spotNearby != nil) {
        [self goToDrinkListMenuAtSpot:_spotNearby];
    } else {
        [self showAlert:@"Oops" message:@"Couldn't find any spot nearby"];
    }
}

- (IBAction)onClickDrinksNearby:(id)sender {
    [self goToDrinkListMenu];
}

- (IBAction)onClickNotHere:(id)sender {
    [self goToFindSimilarSpots:self];
}

#pragma mark - Private

- (void)updateView {
    if (_spotNearby != nil) {
        [_btnNearBy setEnabled:YES];
        [_lblAtPlace setText:[NSString stringWithFormat:@"At %@ ?", _spotNearby.name]];
    } else {
        [_btnNearBy setEnabled:YES];
        [_lblAtPlace setText:@""];
    }
}

- (void)fetchClosetSpot {
 
    // Disable while loading
    [_btnNearBy setEnabled:NO];
    
    if (_location == nil) {
        [self showAlert:@"Oops" message:@"Please choose a location"];
        return;
    }
    
    // Params for location search
    NSDictionary *params = @{
                             kSpotModelParamQueryLatitude : [NSNumber numberWithFloat:_location.coordinate.latitude],
                             kSpotModelParamQueryLongitude : [NSNumber numberWithFloat:_location.coordinate.longitude]
                             };
    
//    [self showHUD:@"Finding nearby spot"];
    // Getting first spot nearby
    [SpotModel getSpots:params success:^(NSArray *spotModels, JSONAPI *jsonApi) {
        [self hideHUD];
        
        _spotNearby = spotModels.firstObject;
        [self updateView];
        
    } failure:^(ErrorModel *errorModel) {
        [self hideHUD];
        [self showAlert:@"Oops" message:errorModel.human];
    }];
    
}

@end
