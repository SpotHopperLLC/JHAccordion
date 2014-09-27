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

@property (weak, nonatomic) IBOutlet UIButton *btnReviews;
@property (weak, nonatomic) IBOutlet UIButton *btnCheckIn;
@property (weak, nonatomic) IBOutlet UIButton *btnGiveProps;
@property (weak, nonatomic) IBOutlet UIButton *btnAccount;
@property (weak, nonatomic) IBOutlet UIButton *btnLogin;

@end

@implementation SHSidebarViewController

#pragma mark - View Lifecycle
#pragma mark -

- (void)viewDidLoad {
//    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
//        self.edgesForExtendedLayout = UIRectEdgeNone;
    [super viewDidLoad];
	
    // Increasing left inset of button titles
    UIEdgeInsets insets = UIEdgeInsetsMake(0, 15.0f, 0, 0);
    [self.btnReviews setTitleEdgeInsets:insets];
    [self.btnCheckIn setTitleEdgeInsets:insets];
    [self.btnGiveProps setTitleEdgeInsets:insets];
    [self.btnAccount setTitleEdgeInsets:insets];
    
    // Add white borders
    [self.btnReviews addTopBorder:[UIColor colorWithWhite:1.0f alpha:0.8f]];
    [self.btnCheckIn addTopBorder:[UIColor colorWithWhite:1.0f alpha:0.8f]];
    [self.btnGiveProps addTopBorder:[UIColor colorWithWhite:1.0f alpha:0.8f]];
    [self.btnGiveProps addBottomBorder:[UIColor colorWithWhite:1.0f alpha:0.8f]];
    [self.btnAccount addTopBorder:[UIColor colorWithWhite:1.0f alpha:0.8f]];
    [self.btnLogin addTopBorder:[UIColor colorWithWhite:1.0f alpha:0.8f]];
    
    [self updateView:NO];
}

- (NSArray *)viewOptions {
    return @[kDidLoadOptionsDontAdjustForIOS6, kDidLoadOptionsNoBackground];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self updateView:animated];
}

- (NSArray *)textfieldToHideKeyboard {
    return @[self.txtSearch];
}

#pragma mark - Tracking
#pragma mark -

- (NSString *)screenName {
    return @"Sidebar";
}

#pragma mark - Private
#pragma mark -

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

#pragma mark - UITextFieldDelegate
#pragma mark -

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(sidebarViewControllerDidRequestSearch:)]) {
        [self.delegate sidebarViewControllerDidRequestSearch:self];
    }
    
    return NO;
}

#pragma mark - User Actions
#pragma mark -

- (IBAction)closeButtonTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(sidebarViewControllerDidRequestClose:)]) {
        [self.delegate sidebarViewControllerDidRequestClose:self];
    }
}

- (IBAction)reviewsButtonTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(sidebarViewControllerDidRequestReviews:)]) {
        [self.delegate sidebarViewControllerDidRequestReviews:self];
    }
}

- (IBAction)checkInButtonTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(sidebarViewControllerDidRequestCheckin:)]) {
        [self.delegate sidebarViewControllerDidRequestCheckin:self];
    }
}

- (IBAction)givePropsButtonTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(sidebarViewControllerDidRequestGiveProps:)]) {
        [self.delegate sidebarViewControllerDidRequestGiveProps:sender];
    }
}

- (IBAction)accountSettingsButtonTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(sidebarViewControllerDidRequestAccount:)]) {
        [self.delegate sidebarViewControllerDidRequestAccount:self];
    }
}

- (IBAction)loginButtonTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(sidebarViewControllerDidRequestLogin:)]) {
        [self.delegate sidebarViewControllerDidRequestLogin:self];
    }
}

@end
