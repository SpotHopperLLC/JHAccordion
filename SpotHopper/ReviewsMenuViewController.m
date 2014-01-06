//
//  ReviewsMenuViewController.m
//  SpotHopper
//
//  Created by Josh Holtz on 1/3/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "ReviewsMenuViewController.h"

#import "SectionHeaderView.h"

@interface ReviewsMenuViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *txtSearch;
@property (weak, nonatomic) IBOutlet UITableView *tblMenu;

@end

@implementation ReviewsMenuViewController

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
    [super viewDidLoad:@[kDidLoadOptionsBlurredBackground,kDidLoadOptionsDontAdjustForIOS6]];
    
    // Shows sidebar button in nav
    [self showSidebarButton:YES animated:YES];
    
    // Configures table
    [_tblMenu setTableFooterView:[[UIView alloc] init]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    
    // Adds contextual footer view
    [self addFooterViewController:^(FooterViewController *footerViewController) {
        [footerViewController showHome:YES];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

#pragma mark - UITableViewDelegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    // Just setting up the section header view
    SectionHeaderView *view = [[SectionHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(tableView.frame), 65.0f)];
    [view setIconImage:[UIImage imageNamed:@"icon_view_my_reviews"]];
    [view setText:@"View My Reviews"];
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 65.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 0.0f;
}


@end
