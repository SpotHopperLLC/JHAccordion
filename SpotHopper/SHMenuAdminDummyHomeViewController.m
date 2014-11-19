//
//  SHMenuAdminDummyHomeViewController.m
//  SpotHopper
//
//  Created by Brennan Stehling on 11/6/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "SHMenuAdminDummyHomeViewController.h"

#import "JHSidebarViewController.h"
#import "SHMenuAdminNetworkManager.h"
#import "SHMenuAdminSidebarViewController.h"
#import "ClientSessionManager.h"
#import "UserModel.h"
#import "ErrorModel.h"
#import "SpotModel.h"

@interface SHMenuAdminDummyHomeViewController () <SHMenuAdminSidebarViewControllerDelegate>

@property (strong, nonatomic) UserModel *user;
@property (strong, nonatomic) SpotModel *spot;

@property (nonatomic, strong) SHMenuAdminSidebarViewController *sidebarViewController;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *spotNameLabel;

@end

#define MAX_PRICES_SHOWN 5

@implementation SHMenuAdminDummyHomeViewController

#pragma mark - View Lifecycle
#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.user = [[ClientSessionManager sharedClient] currentUser];
    
    self.sidebarViewController = (SHMenuAdminSidebarViewController *)self.navigationController.sidebarViewController.rightViewController;
    self.sidebarViewController.delegate = self;
    
    self.spotNameLabel.text = nil;
    self.title = nil;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self.activityIndicator startAnimating];
    self.spotNameLabel.text = @"Loading spot...";
    [self fetchUserSpots:^{
        [self.activityIndicator stopAnimating];
    }];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - User Actions
#pragma mark -

- (IBAction)sidebarButtonTapped:(id)sender {
    [self.sidebarViewController.sidebarViewController toggleRightSidebar];
}

#pragma mark - Private
#pragma mark -

- (void)fetchUserSpots:(void(^)())successBlock {
    [UserModel fetchSpotsForUser:self.user query:nil page:@1 pageSize:@MAX_PRICES_SHOWN success:^(NSArray *spots) {
        if (spots.count > 1) {
            [self.sidebarViewController changeSpots:spots];
            [self.navigationController.sidebarViewController showRightSidebar:TRUE];
        }
        
        [self changeSpot:spots.firstObject];
        
        if (successBlock) {
            successBlock();
        }
    } failure:^(ErrorModel *errorModel) {
        //  [self showAlert:@"Network error" message:@"Please try again"];
        DebugLog(@"Error: %@", errorModel.human);
    }];
}

- (void)changeSpot:(SpotModel *)spot {
    self.spot = spot;
    self.title = self.spot.name;
    self.spotNameLabel.text = self.spot.name;
}

#pragma mark - SHMenuAdminSidebarViewControllerDelegate
#pragma mark -

- (void)closeButtonTapped:(SHMenuAdminSidebarViewController *)sidebarViewController {
    [self.sidebarViewController.sidebarViewController toggleRightSidebar];
}

- (void)spotTapped:(SHMenuAdminSidebarViewController *)sidebarViewController spot:(SpotModel *)spot {
    [self.sidebarViewController.sidebarViewController toggleRightSidebar];
    [self changeSpot:spot];
}

- (void)viewAllSpotsTapped:(SHMenuAdminSidebarViewController *)sidebarViewController {
    [self.sidebarViewController.sidebarViewController toggleRightSidebar];
}

- (void)logoutTapped:(SHMenuAdminSidebarViewController *)sidebarViewController {
    [self.sidebarViewController.sidebarViewController toggleRightSidebar];
}

@end
