//
//  ReviewsMenuViewController.m
//  SpotHopper
//
//  Created by Josh Holtz on 1/3/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "ReviewsMenuViewController.h"

#import "UIViewController+Navigator.h"

#import "SectionHeaderView.h"

#import "MyReviewsViewController.h"

@interface ReviewsMenuViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *txtSearch;
@property (weak, nonatomic) IBOutlet UITableView *tblMenu;

@property (nonatomic, strong) SectionHeaderView *sectionHeader0;
@property (nonatomic, strong) SectionHeaderView *sectionHeader1;

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

//TODO: The search button on the top takes the user to the information page for the spot/drink they are searching for (autofill), but autoscrolls down to the vibe/flavor profile
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
    return [self sectionHeaderViewForSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 65.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 0.0f;
}

#pragma mark - Private

- (SectionHeaderView*)sectionHeaderViewForSection:(NSInteger)section {
    __block ReviewsMenuViewController *this = self;
    
    if (section == 0) {
        if (_sectionHeader0 == nil) {
            _sectionHeader0 = [[SectionHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(_tblMenu.frame), 56.0f)];
            [_sectionHeader0 setIconImage:[UIImage imageNamed:@"icon_view_my_reviews"]];
            [_sectionHeader0 setText:@"View My Reviews"];
            [_sectionHeader0.btnBackground setActionWithBlock:^{
                [this goToMyReviews];
            }];
        }
        
        return _sectionHeader0;
    } else if (section == 1) {
        if (_sectionHeader1 == nil) {
            _sectionHeader1 = [[SectionHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(_tblMenu.frame), 56.0f)];
            [_sectionHeader1 setIconImage:[UIImage imageNamed:@"icon_plus"]];
            [_sectionHeader1 setText:@"Add New Review"];
            [_sectionHeader1.btnBackground setActionWithBlock:^{
                [this goToSearchForNewReview];
            }];
        }
        
        return _sectionHeader1;
    }
    return nil;
}


@end
