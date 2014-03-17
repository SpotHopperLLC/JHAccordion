//
//  DrinkMenuOfferingsViewController.m
//  SpotHopper
//
//  Created by Josh Holtz on 3/14/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "DrinkMenuOfferingsViewController.h"

#import "UIViewController+Navigator.h""

#import "SectionHeaderView.h"

#import "MenuItemCell.h"

#import "ErrorModel.h"
#import "DrinkModel.h"
#import "DrinkTypeModel.h"
#import "DrinkSubtypeModel.h"
#import "MenuItemModel.h"
#import "SpotModel.h"

@interface DrinkMenuOfferingsViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tblMenu;

@property (nonatomic, strong) SectionHeaderView *sectionHeader;

@end

@implementation DrinkMenuOfferingsViewController

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
    
    // Sets title
    [self setTitle:@"Full Drink Menu"];
    
    // Shows sidebar button in nav
    [self showSidebarButton:YES animated:YES];
    
    // Configures table
    [_tblMenu setTableFooterView:[[UIView alloc] init]];
    
    // Adding table header
    UILabel *labelHeader = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(_tblMenu.frame), 72.0f)];
    [labelHeader setBackgroundColor:[UIColor clearColor]];
    [labelHeader setFont:[UIFont fontWithName:@"Lato-Light" size:26.0f]];
    [labelHeader setTextColor:[UIColor darkGrayColor]];
    [labelHeader setMinimumScaleFactor:0.5];
    [labelHeader setTextAlignment:NSTextAlignmentCenter];
    [labelHeader setText:_spot.name];
    [_tblMenu setTableHeaderView:labelHeader];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    
    // Deselects cell
    [_tblMenu deselectRowAtIndexPath:[_tblMenu indexPathForSelectedRow] animated:NO];
    
    // Adds contextual footer view
    [self addFooterViewController:^(FooterViewController *footerViewController) {
        [footerViewController showHome:YES];
        [footerViewController setRightButton:@"Info" image:[UIImage imageNamed:@"btn_context_info"]];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _menuItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        
        MenuItemModel *menuItem = [_menuItems objectAtIndex:indexPath.row];
        
        MenuItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MenuItemCell" forIndexPath:indexPath];
        [cell setDrink:menuItem.drink];
        
        return cell;
    }
    
    return nil;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MenuItemModel *menuItem = [_menuItems objectAtIndex:indexPath.row];
    [self goToDrinkProfile:menuItem.drink];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [self sectionHeaderViewForSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 65.0f;
}

#pragma mark - Private

- (SectionHeaderView*)sectionHeaderViewForSection:(NSInteger)section {
    
    if (_sectionHeader == nil) {
        _sectionHeader = [[SectionHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(_tblMenu.frame), 56.0f)];
        [_sectionHeader setIconImage:[UIImage imageNamed:@"img_arrow_west_circle"]];
        [_sectionHeader.imgArrow setHidden:YES];
        
        [_sectionHeader.lblText setText:[NSString stringWithFormat:@"%@ > %@", _drinkType.name, _drinkSubtype.name]];
    }
    
    return _sectionHeader;

}

@end