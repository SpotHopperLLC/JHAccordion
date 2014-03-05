//
//  SidebarViewController.m
//  SpotHopper
//
//  Created by Josh Holtz on 1/3/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "SidebarViewController.h"

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
    [self addTopBorder:_btnSpots];
    [self addTopBorder:_btnDrinks];
    [self addTopBorder:_btnSpecials];
    [self addTopBorder:_btnReviews];
    [self addTopBorder:_btnCheckIn];
    [self addBottomBorder:_btnCheckIn];
    [self addTopBorder:_btnAccount];
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

#pragma mark - Private

- (void)addTopBorder:(UIButton*)button {
    CAGradientLayer *border = [CAGradientLayer layer];
    border.frame = CGRectMake(0, 0, button.bounds.size.width, 1);
    border.backgroundColor = [[UIColor colorWithWhite:1.0 alpha:1.0f] CGColor];
    [button.layer addSublayer:border];
}

- (void)addBottomBorder:(UIButton*)button {
    CAGradientLayer *border = [CAGradientLayer layer];
    border.frame = CGRectMake(0, button.bounds.size.height-1, button.bounds.size.width, 1);
    border.backgroundColor = [[UIColor colorWithWhite:1.0 alpha:0.8f] CGColor];
    [button.layer addSublayer:border];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    NSLog(@"HERE");
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
    
}

- (IBAction)onClickDrinks:(id)sender {
    
}

- (IBAction)onClickSpecials:(id)sender {
    
}

- (IBAction)onClickReviews:(id)sender {
    [self.sidebarViewController showRightSidebar:NO];
    if ([_delegate respondsToSelector:@selector(sidebarViewControllerClickedReview:)]) {
        [_delegate sidebarViewControllerClickedReview:self];
    }
}

- (IBAction)onClickCheckIn:(id)sender {
    
}

- (IBAction)onClickAccountSettings:(id)sender {
    
}

@end
