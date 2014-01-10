//
//  MyReviewsViewController.m
//  SpotHopper
//
//  Created by Josh Holtz on 1/6/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#define kFilters @[@"All Reviews", @"Spots", @"Beers", @"Cocktails", @"Wines"]
#define kFiltersIcons @[@"", @"icon_spot", @"icon_beer", @"icon_cocktails", @"icon_wine"]
#define kSorts @[@"Most Recent", @"Highest Rated"]
#define kSortsIcons @[@"icon_clock", @"icon_star"]

#import "MyReviewsViewController.h"

#import "UIViewController+Navigator.h"

#import "SectionHeaderView.h"
#import "DropdownOptionCell.h"

#import <JHAccordion/JHAccordion.h>

@interface MyReviewsViewController ()<UITableViewDataSource, UITableViewDelegate, JHAccordionDelegate>

@property (weak, nonatomic) IBOutlet UITextField *txtSearch;
@property (weak, nonatomic) IBOutlet UITableView *tblReviews;

@property (nonatomic, strong) JHAccordion *accordion;
@property (nonatomic, strong) SectionHeaderView *sectionHeaderFilter;
@property (nonatomic, strong) SectionHeaderView *sectionHeaderSort;

@property (nonatomic, assign) NSInteger selectedFilter;
@property (nonatomic, assign) NSInteger selectedSort;

@property (nonatomic, strong) NSMutableArray *reviews;

@end

@implementation MyReviewsViewController

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
    [self setTitle:@"My Reviews"];
    
    // Shows sidebar button in nav
    [self showSidebarButton:YES animated:YES];
    
    // Configures accordion
    _accordion = [[JHAccordion alloc] initWithTableView:_tblReviews];
    [_accordion setDelegate:self];
    
    // Configures table
    [_tblReviews setTableFooterView:[[UIView alloc] init]];
    [_tblReviews registerNib:[UINib nibWithNibName:@"DropdownOptionCellView" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"DropdownOptionCell"];
    
    // Initializes states
    _selectedFilter = 0;
    _selectedSort = 0;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Deselects table row
    [_tblReviews deselectRowAtIndexPath:_tblReviews.indexPathForSelectedRow animated:NO];
    
    // Adds contextual footer view
    [self addFooterViewController:^(FooterViewController *footerViewController) {
        [footerViewController showHome:YES];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return kFilters.count;
    } else if (section == 1) {
        return kSorts.count;
    } else if (section == 2) {
        return 5;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.section == 0) {
        NSString *text = [kFilters objectAtIndex:indexPath.row];
        
        DropdownOptionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DropdownOptionCell" forIndexPath:indexPath];
        [cell.lblText setText:text];
        
        return cell;
    } else if (indexPath.section == 1) {
        NSString *text = [kSorts objectAtIndex:indexPath.row];
        
        DropdownOptionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DropdownOptionCell" forIndexPath:indexPath];
        
        [cell.lblText setText:text];
        
        return cell;

    } else if (indexPath.section == 2) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ReviewCell" forIndexPath:indexPath];
        return cell;
    }
    
    return nil;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        _selectedFilter = indexPath.row;
        
        [self updateViewHeader:indexPath.section];
        
        [_accordion closeSection:indexPath.section];
        [_tblReviews deselectRowAtIndexPath:indexPath animated:NO];
    } else if (indexPath.section == 1) {
        _selectedSort = indexPath.row;
        
        [self updateViewHeader:indexPath.section];
        
        [_accordion closeSection:indexPath.section];
        [_tblReviews deselectRowAtIndexPath:indexPath animated:NO];
    } else if (indexPath.section == 2) {
        [self goToReview:nil];
    }
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [self sectionHeaderViewForSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0 || section == 1) {
        return 56.0f;
    }
    
    return 0.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // This sets all rows in the closed sections to a height of 0 (so they won't be shown)
    // and the opened section to a height of 44.0
    if (indexPath.section == 0 || indexPath.section == 1) {
        return ( [_accordion isSectionOpened:indexPath.section] ? 44.0f : 0.0f);
    } else if (indexPath.section == 2) {
        return 72.0f;
    }
    
    return 0.0f;
}

#pragma mark - JHAccordionDelegate

- (void)accordionOpeningSection:(NSInteger)section {
    if (section == 0) [_sectionHeaderFilter setSelected:YES];
    if (section == 1) [_sectionHeaderSort setSelected:YES];
}

- (void)accordionClosingSection:(NSInteger)section {
    if (section == 0) [_sectionHeaderFilter setSelected:NO];
    if (section == 1) [_sectionHeaderSort setSelected:NO];
}

- (void)accordionOpenedSection:(NSInteger)section {
    
}

- (void)accordionClosedSection:(NSInteger)section {
    
}

#pragma mark - Private

- (SectionHeaderView*)sectionHeaderViewForSection:(NSInteger)section {
    if (section == 0) {
        if (_sectionHeaderFilter == nil) {
            _sectionHeaderFilter = [[SectionHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(_tblReviews.frame), 56.0f)];
            
            // Sets up for accordion
            [_sectionHeaderFilter.btnBackground setTag:section];
            [_sectionHeaderFilter.btnBackground addTarget:_accordion action:@selector(onClickSection:) forControlEvents:UIControlEventTouchUpInside];

            [self updateViewHeader:section];
        }
        
        return _sectionHeaderFilter;
    } else if (section == 1) {
        if (_sectionHeaderSort == nil) {
            _sectionHeaderSort = [[SectionHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(_tblReviews.frame), 56.0f)];

            // Sets up for accordion
            [_sectionHeaderSort.btnBackground setTag:section];
            [_sectionHeaderSort.btnBackground addTarget:_accordion action:@selector(onClickSection:) forControlEvents:UIControlEventTouchUpInside];
            
            [self updateViewHeader:section];
        }
        
        return _sectionHeaderSort;
    }
    return nil;
}

- (void)updateViewHeader:(NSInteger)section {
    if (section == 0) {
        [_sectionHeaderFilter setIconImage:[UIImage imageNamed:[kFiltersIcons objectAtIndex:_selectedFilter]]];
        [_sectionHeaderFilter setText:[kFilters objectAtIndex:_selectedFilter]];
    } else if (section == 1) {
        [_sectionHeaderSort setIconImage:[UIImage imageNamed:[kSortsIcons objectAtIndex:_selectedSort]]];
        [_sectionHeaderSort setText:[kSorts objectAtIndex:_selectedSort]];
    }
}

@end
