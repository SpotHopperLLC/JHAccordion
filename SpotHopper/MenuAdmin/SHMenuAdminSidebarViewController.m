//
//  SidebarViewController.m
//  SpotHopper
//
//  Created by Josh Holtz on 1/3/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//


#import "SHMenuAdminSidebarViewController.h"
#import "SpotModel.h"
#import "SHMenuAdminSearchViewController.h"

#import "UserModel.h"

#import "Tracker.h"
#import "ClientSessionManager.h"

#import "SHMenuAdminStyleSupport.h"
#import "UIButton+FilterStyling.h"

#define kTagLabelSpotName 1

#define kParamPage @"page_number"
#define kPageSize 5
#define kButtonHeight 50.0

@interface SHMenuAdminSidebarViewController ()

@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UIButton *btnSeeAllSpots;
@property (weak, nonatomic) IBOutlet UIButton *btnClose;
@property (weak, nonatomic) IBOutlet UIButton *btnLogout;
@property (weak, nonatomic) IBOutlet UILabel *lblInstructions;

@property (weak, nonatomic) IBOutlet UIView *btnContainer;
@property (strong, nonatomic) UserModel *user;

@end

@implementation SHMenuAdminSidebarViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self styleSidebar];
    
    //clear out prototype buttons 
    for (UIButton *button in self.btnContainer.subviews) {
        [button removeFromSuperview];
    }
    
    [self refreshSidebar];
}

- (NSArray *)viewOptions {
    return @[kDidLoadOptionsDontAdjustForIOS6, kDidLoadOptionsNoBackground];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Actions

- (IBAction)onClickClose:(id)sender {
    if ([self.delegate respondsToSelector:@selector(closeButtonTapped:)]) {
        [self.delegate closeButtonTapped:self];
    }
}

- (IBAction)seeAllSpotsTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(viewAllSpotsTapped:)]) {
        [self.delegate viewAllSpotsTapped:self];
    }
}

- (IBAction)logoutTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(logoutTapped:)]) {
        [self.delegate logoutTapped:self];
    }
}

- (void)spotButtonTapped:(id)sender {
    UIButton *button = (UIButton*)sender;
    button.backgroundColor = [SHMenuAdminStyleSupport sharedInstance].LIGHT_ORANGE;

    if ([self.delegate respondsToSelector:@selector(spotTapped:spot:)]){
        NSInteger index = [self.btnContainer.subviews indexOfObject:button];
        SpotModel *spot = [self.spots objectAtIndex:index];
        [self.delegate spotTapped:self spot:spot];
    }
}

#pragma mark -  Refresh
#pragma mark -
- (void)refreshSidebar {
    self.user = [ClientSessionManager sharedClient].currentUser;
    [self toggleSearchBasedOnUserRole];
    [self fillContainerWithSpotButtons];
}

#pragma mark - Private

- (void)fillContainerWithSpotButtons {
    
    //get rid of prototype views
    for (UIButton *button in self.btnContainer.subviews) {
        [button removeFromSuperview];
    }
    
    for (NSInteger i = 0; i < self.spots.count; i++) {

        SpotModel *spot = self.spots[i];
        UIButton *button;
        
        if (i == 0) {
            button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 320.0f, kButtonHeight)];
        }else {
            UIButton *previous = [self.btnContainer.subviews lastObject];
            button = [[UIButton alloc]initWithFrame:CGRectMake(0, (previous.frame.origin.y + kButtonHeight), 320.0f, kButtonHeight)];
        }
        
        [self styleButton:button title:spot.name];
        [button addTarget:self action:@selector(spotButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [button addTarget:self action:@selector(changeBackgroundColor:) forControlEvents:UIControlEventTouchDown];
        [self.btnContainer addSubview:button];
    }
    
}

- (void)toggleSearchBasedOnUserRole {
    if (![self.user.role isEqualToString:@"admin"]) {
        self.btnSeeAllSpots.hidden = TRUE;
    }else {
        if (self.btnSeeAllSpots.hidden) {
            self.btnSeeAllSpots.hidden = FALSE;
        }
    }
}

#pragma mark - Styling
#pragma mark -

- (void)changeBackgroundColor:(id)sender {
    UIButton *button = (UIButton*)sender;
    button.backgroundColor = [SHMenuAdminStyleSupport sharedInstance].DARK_ORANGE;
}

- (void)styleSidebar {

    self.backgroundView.backgroundColor = [UIColor colorWithRed:241.0f/255.0f green:142.0f/255.0f blue:108.0f/255.0f alpha:0.9f];
    
    self.lblInstructions.backgroundColor = [SHMenuAdminStyleSupport sharedInstance].DARK_ORANGE;
    self.lblInstructions.font = [UIFont fontWithName:@"Lato-Light" size:18.0f];
    
    self.btnLogout.titleLabel.font = [UIFont fontWithName:@"Lato-Light" size:18.0f];
    
    [self.btnSeeAllSpots addTopBorder];
    self.btnSeeAllSpots.backgroundColor = [UIColor clearColor];
    self.btnSeeAllSpots.titleLabel.font = [UIFont fontWithName:@"Lato-Bold" size:18.0f];
}

- (void)styleButton:(UIButton*)button title:(NSString*)title{
    [button setTitle:title forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont fontWithName:@"Lato-Light" size:18.0f];
    button.titleLabel.textColor = [UIColor whiteColor];
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    button.contentEdgeInsets = UIEdgeInsetsMake(0.0, 25.0f, 0.0, 0.0);
    [button addBottomBorder];
}



@end
