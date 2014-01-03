//
//  HomeViewController.m
//  SpotHopper
//
//  Created by Josh Holtz on 12/30/13.
//  Copyright (c) 2013 RokkinCat. All rights reserved.
//

#import "HomeViewController.h"

#import "LaunchViewController.h"

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
    
    if (_loaded == NO) {
        _loaded = YES;
        
        if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
            // Adjusts position of frame in scrollview
            CGRect frame = _viewButtonContainer.frame;
            frame.size.height += frame.origin.y;
            frame.origin.y = 0;
            [_viewButtonContainer setFrame:frame];
        }
    }
    
    [self addFooterViewController:^(FooterViewController *footerViewController) {
        [footerViewController showHome:NO];
        [footerViewController setRightButton:@"Info" image:[UIImage imageNamed:@"btn_context_info"]];
    }];
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
    
}

@end
