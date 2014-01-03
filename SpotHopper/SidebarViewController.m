//
//  SidebarViewController.m
//  SpotHopper
//
//  Created by Josh Holtz on 1/3/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "SidebarViewController.h"

@interface SidebarViewController ()

@property (weak, nonatomic) IBOutlet UITextField *txtSearch;

@property (weak, nonatomic) IBOutlet UIButton *btnSpots;
@property (weak, nonatomic) IBOutlet UIButton *btnDrinks;
@property (weak, nonatomic) IBOutlet UIButton *btnSpecials;
@property (weak, nonatomic) IBOutlet UIButton *btnReviews;
@property (weak, nonatomic) IBOutlet UIButton *btnCheckIn;
@property (weak, nonatomic) IBOutlet UIButton *btnAccount;

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
    [super viewDidLoad];
	
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

#pragma mark - Actions

- (IBAction)onClickClose:(id)sender {
}

- (IBAction)onClickSpots:(id)sender {
    
}

- (IBAction)onClickDrinks:(id)sender {
    
}

- (IBAction)onClickSpecials:(id)sender {
    
}

- (IBAction)onClickReviews:(id)sender {
    
}

- (IBAction)onClickCheckIn:(id)sender {
    
}

- (IBAction)onClickAccountSettings:(id)sender {
    
}

@end
