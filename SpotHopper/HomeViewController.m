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

@interface HomeViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewButtonContainer;
@property (weak, nonatomic) IBOutlet UIView *viewButtonContainer;

@property (nonatomic, strong) UINavigationBar *navigationBar;
@property (nonatomic, strong) UINavigationItem *item;

@property (nonatomic, assign) BOOL loaded;

@end

@implementation HomeViewController

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
    [super viewDidLoad:@[kDidLoadOptionsDontAdjustForIOS6, kDidLoadOptionsFocusedBackground]];

    // Shows sidebar button in nav
    [self showSidebarButton:YES animated:YES];
    
    // Do this in view did load if iOS 7
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        if ([[ClientSessionManager sharedClient] hasSeenLaunch] == NO) {
            [self goToLaunch:NO];
        }
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
        
        _navigationBar = [[SHNavigationBar alloc] initWithFrame:CGRectMake(0.0f, ( SYSTEM_VERSION_LESS_THAN(@"7.0") ? 0.0f : 20.0f ), 320.0f, 44.0f)];
        _item = [[UINavigationItem alloc] initWithTitle:nil];
        _navigationBar.items = @[_item];
        [self.view addSubview:_navigationBar];
    }

    [self showSidebarButton:YES animated:NO navigationItem:_item];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Do this in view did appear if iOS 6
    if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        if ([[ClientSessionManager sharedClient] hasSeenLaunch] == NO) {
            [self goToLaunch:animated];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - FooterViewControllerDelegate

- (BOOL)footerViewController:(FooterViewController *)footerViewController clickedButton:(FooterViewButtonType)footerViewButtonType {
    if (FooterViewButtonRight == footerViewButtonType) {
        UserModel *user = [ClientSessionManager sharedClient].currentUser;
        [self showAlert:user.description message:nil];
        return YES;
    }
    return NO;
}

#pragma mark - Actions

- (IBAction)onClickSpots:(id)sender {
    [self goToSpotListMenu];
}

- (IBAction)onClickDrinks:(id)sender {
    [self goToDrinksNearBy];
}

- (IBAction)onClickSpecials:(id)sender {
    [self goToTonightsSpecials];
}

- (IBAction)onClickReviews:(id)sender {
    if ([ClientSessionManager sharedClient].isLoggedIn == YES) {
        [self goToSearchForNewReview:NO notWhatLookingFor:YES createReview:YES];
    } else {
        [self showAlert:@"Login Required" message:@"Cannot add a review without logging in"];
    }
}

@end
