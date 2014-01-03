//
//  HomeViewController.m
//  SpotHopper
//
//  Created by Josh Holtz on 12/30/13.
//  Copyright (c) 2013 RokkinCat. All rights reserved.
//

#import "HomeViewController.h"

#import "UIViewController+Navigator.h"

#import "LaunchViewController.h"

#import "SHNavigationBar.h"

@interface HomeViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewButtonContainer;
@property (weak, nonatomic) IBOutlet UIView *viewButtonContainer;

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

    [self showSidebarButton:YES animated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    
    [self addFooterViewController:^(FooterViewController *footerViewController) {
        [footerViewController showHome:NO];
        [footerViewController setRightButton:@"Info" image:[UIImage imageNamed:@"btn_context_info"]];
    }];
    
    if (_loaded == NO) {
        _loaded = YES;
        
        SHNavigationBar *navigationBar = [[SHNavigationBar alloc] initWithFrame:CGRectMake(0.0f, ( SYSTEM_VERSION_LESS_THAN(@"7.0") ? 0.0f : 20.0f ), 320.0f, 44.0f)];
        UINavigationItem *item = [[UINavigationItem alloc] initWithTitle:nil];
        [navigationBar pushNavigationItem:item animated:NO];
        [self showSidebarButton:YES animated:NO navigationItem:item];
        [self.view addSubview:navigationBar];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - FooterViewControllerDelegate

- (void)footerViewController:(FooterViewController *)footerViewController clickedButton:(FooterViewButtonType)footerViewButtonType {
    if (FooterViewButtonRight == footerViewButtonType) {
        [self showAlert:@"Nothing here yet" message:nil];
    }
}

#pragma mark - Actions

- (IBAction)onClickSpots:(id)sender {
    
}

- (IBAction)onClickDrinks:(id)sender {
    
}

- (IBAction)onClickSpecials:(id)sender {
    LaunchViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"LaunchViewController"];
    [self presentViewController:viewController animated:YES completion:nil];
}

- (IBAction)onClickReviews:(id)sender {
    [self goToReviews];
}

@end
