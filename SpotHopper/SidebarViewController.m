//
//  SidebarViewController.m
//  SpotHopper
//
//  Created by Josh Holtz on 1/3/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "SidebarViewController.h"

#import "UIView+AddBorder.h"
#import "UIViewController+Navigator.h"

#import <FXBlurView/FXBlurView.h>

@interface SidebarViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *txtSearch;

@property (weak, nonatomic) IBOutlet UIButton *btnSpots;
@property (weak, nonatomic) IBOutlet UIButton *btnDrinks;
@property (weak, nonatomic) IBOutlet UIButton *btnSpecials;
@property (weak, nonatomic) IBOutlet UIButton *btnReviews;
@property (weak, nonatomic) IBOutlet UIButton *btnCheckIn;
@property (weak, nonatomic) IBOutlet UIButton *btnAccount;

@property (nonatomic, strong) FXBlurView *blurView;

@end

@implementation SidebarViewController

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
    [_btnAccount setTitleEdgeInsets:insets];
    
    // Add white borders
    [_btnSpots addTopBorder:[UIColor colorWithWhite:1.0f alpha:0.8f]];
    [_btnDrinks addTopBorder:[UIColor colorWithWhite:1.0f alpha:0.8f]];
    [_btnSpecials addTopBorder:[UIColor colorWithWhite:1.0f alpha:0.8f]];
    [_btnReviews addTopBorder:[UIColor colorWithWhite:1.0f alpha:0.8f]];
    [_btnCheckIn addTopBorder:[UIColor colorWithWhite:1.0f alpha:0.8f]];
    [_btnCheckIn addBottomBorder:[UIColor colorWithWhite:1.0f alpha:0.8f]];
    [_btnAccount addTopBorder:[UIColor colorWithWhite:1.0f alpha:0.8f]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (_blurView == nil) {
//        _blurView = [[FXBlurView alloc] initWithFrame:self.view.frame];
//        [_blurView setDynamic:YES];
//        [self.view insertSubview:_blurView atIndex:0];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSArray *)textfieldToHideKeyboard {
    return @[_txtSearch];
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
    [self.view endEditing:YES];
}

#pragma mark - Actions

- (IBAction)onClickClose:(id)sender {
    [self.sidebarViewController showRightSidebar:NO];
}

- (IBAction)onClickLogout:(id)sender {
    [self.sidebarViewController showRightSidebar:NO];
    [self goToLaunch:YES];
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

- (IBAction)onClickAccountSettings:(id)sender {
    [self.sidebarViewController showRightSidebar:NO];
    if ([_delegate respondsToSelector:@selector(sidebarViewControllerClickedAccount:)]) {
        [_delegate sidebarViewControllerClickedAccount:self];
    }
}

@end
