//
//  SHSidebarViewController.m
//  SpotHopper
//
//  Created by Brennan Stehling on 5/19/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "SHSidebarViewController.h"

#import "UIView+AddBorder.h"
#import "UIViewController+Navigator.h"

#import "SHStyleKit+Additions.h"

#import "ClientSessionManager.h"

@interface SHSidebarViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *txtSearch;

// TODO: change to use StyleKit for button images (different than just showing the icons)

@property (weak, nonatomic) IBOutlet UIButton *btnSpots;
@property (weak, nonatomic) IBOutlet UIButton *btnDrinks;
@property (weak, nonatomic) IBOutlet UIButton *btnSpecials;
@property (weak, nonatomic) IBOutlet UIButton *btnReviews;
@property (weak, nonatomic) IBOutlet UIButton *btnCheckIn;
@property (weak, nonatomic) IBOutlet UIButton *btnAccount;
@property (weak, nonatomic) IBOutlet UIButton *btnLogin;

@end

@implementation SHSidebarViewController

- (void)viewDidLoad {
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    [super viewDidLoad:@[kDidLoadOptionsDontAdjustForIOS6, kDidLoadOptionsNoBackground]];
	
    // Increasing left inset of button titles
    UIEdgeInsets insets = UIEdgeInsetsMake(0, 15.0f, 0, 0);
    [self.btnSpots setTitleEdgeInsets:insets];
    [self.btnDrinks setTitleEdgeInsets:insets];
    [self.btnSpecials setTitleEdgeInsets:insets];
    [self.btnReviews setTitleEdgeInsets:insets];
    [self.btnCheckIn setTitleEdgeInsets:insets];
    [self.btnAccount setTitleEdgeInsets:insets];
    
    // Set button icons
    
    CGSize iconSize = CGSizeMake(40, 40);
    [SHStyleKit setButton:self.btnSpots withDrawing:SHStyleKitDrawingSpotIcon normalColor:SHStyleKitColorMyWhiteColor highlightedColor:SHStyleKitColorMyTextColor size:iconSize];
    [SHStyleKit setButton:self.btnDrinks withDrawing:SHStyleKitDrawingDrinksIcon normalColor:SHStyleKitColorMyWhiteColor highlightedColor:SHStyleKitColorMyTextColor size:iconSize];
    [SHStyleKit setButton:self.btnSpecials withDrawing:SHStyleKitDrawingSpecialsIcon normalColor:SHStyleKitColorMyWhiteColor highlightedColor:SHStyleKitColorMyTextColor size:iconSize];
    // TODO: add missing icon drawing
    //[SHStyleKit setButton:self.btnReviews withDrawing:SHStyleKitDrawingReviewsIcon normalColor:SHStyleKitColorMyWhiteColor highlightedColor:SHStyleKitColorMyTextColor];
    //[SHStyleKit setButton:self.btnCheckIn withDrawing:SHStyleKitDrawingCheckInIcon normalColor:SHStyleKitColorMyWhiteColor highlightedColor:SHStyleKitColorMyTextColor];
    //[SHStyleKit setButton:self.btnAccount withDrawing:SHStyleKitDrawingAccountIcon normalColor:SHStyleKitColorMyWhiteColor highlightedColor:SHStyleKitColorMyTextColor];
    //[SHStyleKit setButton:self.btnLogin withDrawing:SHStyleKitDrawingLoginIcon normalColor:SHStyleKitColorMyWhiteColor highlightedColor:SHStyleKitColorMyTextColor];
    
    // Add white borders
    [self.btnSpots addTopBorder:[UIColor colorWithWhite:1.0f alpha:0.8f]];
    [self.btnDrinks addTopBorder:[UIColor colorWithWhite:1.0f alpha:0.8f]];
    [self.btnSpecials addTopBorder:[UIColor colorWithWhite:1.0f alpha:0.8f]];
    [self.btnReviews addTopBorder:[UIColor colorWithWhite:1.0f alpha:0.8f]];
    [self.btnCheckIn addTopBorder:[UIColor colorWithWhite:1.0f alpha:0.8f]];
    [self.btnCheckIn addBottomBorder:[UIColor colorWithWhite:1.0f alpha:0.8f]];
    [self.btnAccount addTopBorder:[UIColor colorWithWhite:1.0f alpha:0.8f]];
    [self.btnLogin addTopBorder:[UIColor colorWithWhite:1.0f alpha:0.8f]];
    
    [self updateView:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self updateView:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSArray *)textfieldToHideKeyboard {
    return @[self.txtSearch];
}

#pragma mark - Tracking

- (NSString *)screenName {
    return @"Sidebar";
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    // TODO: change to work differently
    //[self.sidebarViewController showRightSidebar:NO];
    if ([_delegate respondsToSelector:@selector(sidebarViewController:didTapSearchTextField:)]) {
        [_delegate sidebarViewController:self didTapSearchTextField:textField];
    }
    
    return NO;
}

#pragma mark - JHSidebarDelegate

// TODO: replace
//- (void)sidebar:(JHSidebarSide)side stateChanged:(JHSidebarState)state {
//    [self updateView:YES];
//    [self.view endEditing:YES];
//}

#pragma mark - Actions

- (IBAction)closeButtonTapped:(id)sender {
    // TODO: replace call to sidebar
    //[self.sidebarViewController showRightSidebar:NO];
    
    [self closeSideBar:sender];
    
}

- (IBAction)spotsButtonTapped:(id)sender {
    // TODO: replace call to sidebar
    //[self.sidebarViewController showRightSidebar:NO];
    if ([_delegate respondsToSelector:@selector(sidebarViewController:spotsButtonTapped:)]) {
        [_delegate sidebarViewController:self spotsButtonTapped:sender];
    }
}

- (IBAction)drinksButtonTapped:(id)sender {
    // TODO: replace call to sidebar
    //[self.sidebarViewController showRightSidebar:NO];
    if ([_delegate respondsToSelector:@selector(sidebarViewController:drinksButtonTapped:)]) {
        [_delegate sidebarViewController:self drinksButtonTapped:sender];
    }
}

- (IBAction)specialsButtonTapped:(id)sender {
    // TODO: replace call to sidebar
    //[self.sidebarViewController showRightSidebar:NO];
    if ([_delegate respondsToSelector:@selector(sidebarViewController:specialsButtonTapped:)]) {
        [_delegate sidebarViewController:self specialsButtonTapped:sender];
    }
}

- (IBAction)reviewsButtonTapped:(id)sender {
    // TODO: replace call to sidebar
    //[self.sidebarViewController showRightSidebar:NO];
    if ([_delegate respondsToSelector:@selector(sidebarViewController:reviewButtonTapped:)]) {
        [_delegate sidebarViewController:self reviewButtonTapped:sender];
    }
}

- (IBAction)checkInButtonTapped:(id)sender {
    // TODO: replace call to sidebar
    //[self.sidebarViewController showRightSidebar:NO];
    if ([_delegate respondsToSelector:@selector(sidebarViewController:checkinButtonTapped:)]) {
        [_delegate sidebarViewController:self checkinButtonTapped:sender];
    }
}

- (IBAction)accountSettingsButtonTapped:(id)sender {
    // TODO: replace call to sidebar
    //[self.sidebarViewController showRightSidebar:NO];
    if ([_delegate respondsToSelector:@selector(sidebarViewController:accountButtonTapped:)]) {
        [_delegate sidebarViewController:self accountButtonTapped:sender];
    }
}

- (IBAction)loginButtonTapped:(id)sender {
    // TODO: replace call to sidebar
    //[self.sidebarViewController showRightSidebar:NO];
    [self closeButtonTapped:nil];
    [self goToLaunch:YES];
}

#pragma mark - Private

- (void)closeSideBar:(id)sender {
    if ([_delegate respondsToSelector:@selector(sidebarViewController:closeButtonTapped:)]) {
        [_delegate sidebarViewController:self closeButtonTapped:sender];
    }
}

- (void)updateView:(BOOL)animate {
    [self.btnAccount setHidden:NO];
    [self.btnLogin setHidden:NO];
    BOOL isLoggedIn = [ClientSessionManager sharedClient].isLoggedIn;
    [UIView animateWithDuration:( animate ? 0.35f : 0.0f ) animations:^{
        [self.btnAccount setAlpha:( isLoggedIn ? 1.0f : 0.0f)];
        [self.btnLogin setAlpha:( !isLoggedIn ? 1.0f : 0.0f)];
    } completion:^(BOOL finished) {
        [self.btnAccount setHidden:( self.btnAccount.alpha < 0.5f )];
        [self.btnLogin setHidden:( self.btnLogin.alpha < 0.5f )];
    }];
}

@end
