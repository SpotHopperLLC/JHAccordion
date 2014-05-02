//
//  HomeViewController.m
//  SpotHopper
//
//  Created by Josh Holtz on 12/30/13.
//  Copyright (c) 2013 RokkinCat. All rights reserved.
//

#import "HomeViewController.h"

#import "UIViewController+Navigator.h"

#import "SHNavigationBar.h"

#import "LaunchViewController.h"

#import "ClientSessionManager.h"
#import "UserModel.h"

#import "Tracker.h"
#import "TellMeMyLocation.h"

#import "iRate.h"

@interface HomeViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewButtonContainer;
@property (weak, nonatomic) IBOutlet UIView *viewButtonContainer;

@property (nonatomic, strong) UINavigationBar *navigationBar;
@property (nonatomic, strong) UINavigationItem *item;

@property (nonatomic, assign) BOOL loaded;

@end

@implementation HomeViewController

#pragma mark - View Lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad:@[kDidLoadOptionsDontAdjustForIOS6, kDidLoadOptionsFocusedBackground]];

    // Shows sidebar button in nav
    [self showSidebarButton:YES animated:YES];
    
    if ([[ClientSessionManager sharedClient] hasSeenLaunch] == NO) {
        [self goToAgeVerification:FALSE];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    
    // Adds contextual footer view
    [self addFooterViewController:^(FooterViewController *footerViewController) {
        [footerViewController showHome:NO];
        [footerViewController setRightButton:@"Info" image:[UIImage imageNamed:@"btn_context_info"]];
    }];
    
    if (_loaded == NO) {
        _loaded = YES;
        
        _navigationBar = [[SHNavigationBar alloc] initWithFrame:CGRectMake(0.0f, 20.0f, 320.0f, 44.0f)];
        _item = [[UINavigationItem alloc] initWithTitle:nil];
        _navigationBar.items = @[_item];
        [self.view addSubview:_navigationBar];
    }

    [self showSidebarButton:YES animated:NO navigationItem:_item];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [Tracker track:@"View Main Menu" properties:@{@"Location" : [TellMeMyLocation lastLocationNameShort]}];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Tracking

- (NSString *)screenName {
    return @"Home";
}

#pragma mark - FooterViewControllerDelegate

- (BOOL)footerViewController:(FooterViewController *)footerViewController clickedButton:(FooterViewButtonType)footerViewButtonType {
    if (FooterViewButtonRight == footerViewButtonType) {
        [self goToTutorial:TRUE];
        return YES;
    }
    return NO;
}

#pragma mark - Actions

- (IBAction)onClickSpots:(id)sender {
    [Tracker track:@"Home to Spots" properties:@{@"Location" : [TellMeMyLocation lastLocationNameShort]}];
    [self goToSpotListMenu];
}

- (IBAction)onClickDrinks:(id)sender {
    [Tracker track:@"Home to Drinks" properties:@{@"Location" : [TellMeMyLocation lastLocationNameShort]}];
    [self goToDrinks];
}

- (IBAction)onClickSpecials:(id)sender {
    [Tracker track:@"Home to Specials" properties:@{@"Location" : [TellMeMyLocation lastLocationNameShort]}];
    [self goToTonightsSpecials];
}

- (IBAction)onClickReviews:(id)sender {
    [Tracker track:@"Home to Reviews" properties:@{@"Location" : [TellMeMyLocation lastLocationNameShort]}];
    if ([self promptLoginNeeded:@"Cannot add a review without logging in"] == NO) {
        [self goToSearchForNewReview:NO notWhatLookingFor:YES createReview:YES];
    }
}

@end
