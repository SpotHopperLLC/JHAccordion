//
//  HomeViewController.m
//  SpotHopper
//
//  Created by Josh Holtz on 12/30/13.
//  Copyright (c) 2013 RokkinCat. All rights reserved.
//

#import "HomeViewController.h"

@interface HomeViewController ()

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
    [super viewDidLoad:NO];

    [self showSidebarButton:YES animated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self addFooterViewController];
    if (_loaded == NO) {
        _loaded = YES;
        
        if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
            CGRect frame = _viewButtonContainer.frame;
            frame.size.height += frame.origin.y;
            frame.origin.y = 0;
            [_viewButtonContainer setFrame:frame];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Actions

- (IBAction)onClickSpots:(id)sender {
    
}

- (IBAction)onClickDrinks:(id)sender {
    
}

- (IBAction)onClickSpecials:(id)sender {
    
}

- (IBAction)onClickReviews:(id)sender {
    
}

@end
