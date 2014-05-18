//
//  DrinksNearbyViewController.m
//  SpotHopper
//
//  Created by Josh Holtz on 3/13/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "DrinksNearbyViewController.h"

#import "SHButtonLatoLightLocation.h"
#import "TellMeMyLocation.h"

#import "UIViewController+Navigator.h"

#import "SHNavigationController.h"
#import "DrinkListMenuViewController.h"

#import "FindSimilarViewController.h"

#import "ErrorModel.h"
#import "SpotModel.h"
#import "CheckInModel.h"
#import "Tracker.h"

#import <CoreLocation/CoreLocation.h>

@interface DrinksNearbyViewController ()<SHButtonLatoLightLocationDelegate, FindSimilarViewControllerDelegate, CheckinViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *lblNear;
@property (weak, nonatomic) IBOutlet UIButton *btnNearBy;
@property (weak, nonatomic) IBOutlet SHButtonLatoLightLocation *btnLocation;

@property (weak, nonatomic) IBOutlet UILabel *lblFindingYou;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indFindingYou;
@property (weak, nonatomic) IBOutlet UILabel *lblAtPlace;

@property (nonatomic, strong) TellMeMyLocation *tellMeMyLocation;
@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, strong) CLLocation *location;

@property (nonatomic, strong) SpotModel *spotNearby;

@end

@implementation DrinksNearbyViewController {
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
    [self setTitle:@"Drinklists"];
    
    // Shows sidebar button in nav
    [self showSidebarButton:YES animated:YES];
    
    // Initializes stuff
    [_indFindingYou startAnimating];
    
    _updatedSearchNeeded = TRUE;
    
    // Find me
    _tellMeMyLocation = [[TellMeMyLocation alloc] init];
    [_tellMeMyLocation findMe:kCLLocationAccuracyNearestTenMeters found:^(CLLocation *newLocation) {
        _currentLocation = newLocation;
        [self fetchClosestSpot];
    } failure:^(NSError *error) {
        [_indFindingYou stopAnimating];
        [_lblFindingYou setText:@"Could not find you"];
        [Tracker logError:error class:[self class] trace:NSStringFromSelector(_cmd)];
    }];
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
        
        NSString *text = [_btnLocation titleForState:UIControlStateNormal];
        CGFloat textWidth = [self widthForString:text font:_btnLocation.titleLabel.font maxWidth:CGFLOAT_MAX];
        _btnLocation.imageEdgeInsets = UIEdgeInsetsMake(0, (textWidth + 15), 0, 0);
        _btnLocation.titleEdgeInsets = UIEdgeInsetsMake(0, -7, 0, 0);
        
    } else {
        
    }
    
    [_lblNear setFont:[UIFont fontWithName:@"Lato-Regular" size:_lblNear.font.pointSize]];
}

- (BOOL)footerViewController:(FooterViewController *)footerViewController clickedButton:(FooterViewButtonType)footerViewButtonType {
    if (FooterViewButtonRight == footerViewButtonType) {
        [self showAlert:@"Info" message:kInfoDrinklistNearby];
        return YES;
    }
    
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Tracking

- (NSString *)screenName {
    return @"Drinks Nearby";
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
    [self fetchClosestSpot];
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

#pragma mark - CheckinViewControllerDelegate

- (void)checkinViewController:(CheckinViewController *)viewController checkedIn:(CheckInModel *)checkIn {
    [self.navigationController popToViewController:self animated:YES];
    
    _spotNearby = checkIn.spot;
    [self updateView];
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
    [self goToCheckin:self];
}

#pragma mark - Private

- (void)updateView {
    [_indFindingYou stopAnimating];
    [_indFindingYou setHidden:YES];
    
    if (_spotNearby != nil) {
        [_lblFindingYou setHidden:YES];
        
        [_btnNearBy setEnabled:YES];
        [_lblAtPlace setText:[NSString stringWithFormat:@"At %@ ?", _spotNearby.name]];
    } else {
        [_btnNearBy setEnabled:YES];
        [_lblAtPlace setText:@""];
        [_lblFindingYou setText:@"No spots nearby"];
    }
}

- (void)fetchClosestSpot {
    _updatedSearchNeeded = FALSE;
 
    // Disable while loading
    [_btnNearBy setEnabled:NO];
    
    if (_currentLocation == nil) {
        [self showAlert:@"Oops" message:@"Please choose a location"];
        return;
    }
    
    // Params for location search
    NSDictionary *params = @{
                             kSpotModelParamQueryLatitude : [NSNumber numberWithFloat:_currentLocation.coordinate.latitude],
                             kSpotModelParamQueryLongitude : [NSNumber numberWithFloat:_currentLocation.coordinate.longitude],
                             kSpotModelParamsPageSize : @1
                             };
    
    // Getting first spot nearby
    [SpotModel getSpots:params success:^(NSArray *spotModels, JSONAPI *jsonApi) {
        [self hideHUD];
        
        _spotNearby = spotModels.firstObject;
        [self updateView];
        
    } failure:^(ErrorModel *errorModel) {
        [self hideHUD];
        [self showAlert:@"Oops" message:errorModel.human];
        [Tracker logError:errorModel class:[self class] trace:NSStringFromSelector(_cmd)];
    }];
}

@end
