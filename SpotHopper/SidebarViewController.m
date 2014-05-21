//
//  SidebarViewController.m
//  SpotHopper
//
//  Created by Josh Holtz on 1/3/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#define kAlreadyGaveProps @"alreadyGaveProps"

#import "SidebarViewController.h"

#import "UIAlertView+Block.h"
#import "UIView+AddBorder.h"
#import "UIViewController+Navigator.h"

#import "Tracker.h"

#import "ClientSessionManager.h"

@interface SidebarViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *txtSearch;

@property (weak, nonatomic) IBOutlet UIButton *btnSpots;
@property (weak, nonatomic) IBOutlet UIButton *btnDrinks;
@property (weak, nonatomic) IBOutlet UIButton *btnSpecials;
@property (weak, nonatomic) IBOutlet UIButton *btnReviews;
@property (weak, nonatomic) IBOutlet UIButton *btnCheckIn;
@property (weak, nonatomic) IBOutlet UIButton *btnAccount;
@property (weak, nonatomic) IBOutlet UIButton *btnLogin;
@property (weak, nonatomic) IBOutlet UIButton *btnGiveProps;


@end

@implementation SidebarViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    [super viewDidLoad:@[kDidLoadOptionsDontAdjustForIOS6, kDidLoadOptionsNoBackground]];
	
    // Increasing left inset of button titles
    UIEdgeInsets insets = UIEdgeInsetsMake(0, 15.0f, 0, 0);
    [_btnSpots setTitleEdgeInsets:insets];
    [_btnDrinks setTitleEdgeInsets:insets];
    [_btnSpecials setTitleEdgeInsets:insets];
    [_btnReviews setTitleEdgeInsets:insets];
    [_btnCheckIn setTitleEdgeInsets:insets];
    [_btnGiveProps setTitleEdgeInsets:insets];
    [_btnAccount setTitleEdgeInsets:insets];
    
    // Hide the give props button if already gave props
    [_btnGiveProps setHidden:[[NSUserDefaults standardUserDefaults] boolForKey:kAlreadyGaveProps]];
    
    // Add white borders
    [_btnSpots addTopBorder:[UIColor colorWithWhite:1.0f alpha:0.8f]];
    [_btnDrinks addTopBorder:[UIColor colorWithWhite:1.0f alpha:0.8f]];
    [_btnSpecials addTopBorder:[UIColor colorWithWhite:1.0f alpha:0.8f]];
    [_btnReviews addTopBorder:[UIColor colorWithWhite:1.0f alpha:0.8f]];
    [_btnCheckIn addTopBorder:[UIColor colorWithWhite:1.0f alpha:0.8f]];
    [_btnCheckIn addBottomBorder:[UIColor colorWithWhite:1.0f alpha:0.8f]];
    [_btnGiveProps addBottomBorder:[UIColor colorWithWhite:1.0f alpha:0.8f]];
    [_btnAccount addTopBorder:[UIColor colorWithWhite:1.0f alpha:0.8f]];
    [_btnLogin addTopBorder:[UIColor colorWithWhite:1.0f alpha:0.8f]];
    
    [self updateView:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSArray *)textfieldToHideKeyboard {
    return @[_txtSearch];
}

#pragma mark - Tracking

- (NSString *)screenName {
    return @"Sidebar";
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [self.sidebarViewController showRightSidebar:NO];
    if ([_delegate respondsToSelector:@selector(sidebarViewControllerClickedSearch:)]) {
        [_delegate sidebarViewControllerClickedSearch:self];
    }
    
    return NO;
}

#pragma mark - JHSidebarDelegate

- (void)sidebar:(JHSidebarSide)side stateChanged:(JHSidebarState)state {
    [self updateView:YES];
    [self.view endEditing:YES];
}

#pragma mark - Actions

- (IBAction)onClickClose:(id)sender {
    [self.sidebarViewController showRightSidebar:NO];
}

- (IBAction)onClickSpots:(id)sender {
    [self.sidebarViewController showRightSidebar:NO];
    if ([_delegate respondsToSelector:@selector(sidebarViewControllerClickedSpots:)]) {
        [_delegate sidebarViewControllerClickedSpots:self];
    }
}

- (IBAction)onClickDrinks:(id)sender {
    [self.sidebarViewController showRightSidebar:NO];
    if ([_delegate respondsToSelector:@selector(sidebarViewControllerClickedDrinks:)]) {
        [_delegate sidebarViewControllerClickedDrinks:self];
    }
}

- (IBAction)onClickSpecials:(id)sender {
    [self.sidebarViewController showRightSidebar:NO];
    if ([_delegate respondsToSelector:@selector(sidebarViewControllerClickedSpecials:)]) {
        [_delegate sidebarViewControllerClickedSpecials:self];
    }
}

- (IBAction)onClickReviews:(id)sender {
    [self.sidebarViewController showRightSidebar:NO];
    if ([_delegate respondsToSelector:@selector(sidebarViewControllerClickedReview:)]) {
        [_delegate sidebarViewControllerClickedReview:self];
    }
}

- (IBAction)onClickCheckIn:(id)sender {
    [self.sidebarViewController showRightSidebar:NO];
    if ([_delegate respondsToSelector:@selector(sidebarViewControllerClickedCheckin:)]) {
        [_delegate sidebarViewControllerClickedCheckin:self];
    }
}

- (IBAction)onClickGiveProps:(id)sender {
    [self giveProps];
}

- (IBAction)onClickAccountSettings:(id)sender {
    [self.sidebarViewController showRightSidebar:NO];
    if ([_delegate respondsToSelector:@selector(sidebarViewControllerClickedAccount:)]) {
        [_delegate sidebarViewControllerClickedAccount:self];
    }
}

- (IBAction)onClickLogin:(id)sender {
    [self.sidebarViewController showRightSidebar:NO];
    [self goToLaunch:YES];
}

#pragma mark - Private

- (void)updateView:(BOOL)animate {
    [_btnAccount setHidden:NO];
    [_btnLogin setHidden:NO];
    [UIView animateWithDuration:( animate ? 0.35f : 0.0f ) animations:^{
        [_btnAccount setAlpha:( [ClientSessionManager sharedClient].isLoggedIn ? 1.0f : 0.0f)];
        [_btnLogin setAlpha:( ![ClientSessionManager sharedClient].isLoggedIn ? 1.0f : 0.0f)];
    } completion:^(BOOL finished) {
        [_btnAccount setHidden:( _btnAccount.alpha < 0.5f )];
        [_btnLogin setHidden:( _btnLogin.alpha < 0.5f )];
    }];

}

- (void)giveProps {
    // Show alert with textfield to enter code for props
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Who told you about SpotHopper?" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
    [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [[alertView textFieldAtIndex:0] setPlaceholder:@"Enter Code"];
    [alertView showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            
            // Make sure code is entered
            NSString *code = [alertView textFieldAtIndex:0].text;
            if (code.length > 0) {
                
                // Send props tracking code up to analytics
                [Tracker track:@"Give Props" properties:@{ @"code" : code }];
                
                // Set user default saying props were given
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kAlreadyGaveProps];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                // Animate button to hidden
                [UIView animateWithDuration:0.35f animations:^{
                    [_btnGiveProps setAlpha:0.0f];
                } completion:^(BOOL finished) {
                    [_btnGiveProps setHidden:YES];
                }];
            }
            
            
        }
    }];
}

@end
