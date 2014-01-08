//
//  MyReviewsViewController.m
//  SpotHopper
//
//  Created by Josh Holtz on 1/6/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "MyReviewsViewController.h"

#import "UIViewController+Navigator.h"

#import "SectionHeaderView.h"

#import <JHAccordion/JHAccordion.h>

@interface MyReviewsViewController ()<UITableViewDataSource, UITableViewDelegate, JHAccordionDelegate>

@property (weak, nonatomic) IBOutlet UITextField *txtSearch;
@property (weak, nonatomic) IBOutlet UITableView *tblReviews;

@property (nonatomic, strong) JHAccordion *accordion;

@property (nonatomic, strong) SectionHeaderView *sectionHeaderBeer;
@property (nonatomic, strong) SectionHeaderView *sectionHeaderWine;
@property (nonatomic, strong) SectionHeaderView *sectionHeaderCocktails;
@property (nonatomic, strong) SectionHeaderView *sectionHeaderLiqour;
@property (nonatomic, strong) SectionHeaderView *sectionHeaderMostRecent;

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
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ReviewCell" forIndexPath:indexPath];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self goToReview:nil];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [self sectionHeaderViewForSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 56.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // This sets all rows in the closed sections to a height of 0 (so they won't be shown)
    // and the opened section to a height of 44.0
    return ( [_accordion isSectionOpened:indexPath.section] ? 72.0f : 0.0f);
}

#pragma mark - JHAccordionDelegate

- (void)accordionOpenedSection:(NSInteger)section {
    if (section == 0) [_sectionHeaderBeer setSelected:YES];
    if (section == 1) [_sectionHeaderWine setSelected:YES];
    if (section == 2) [_sectionHeaderCocktails setSelected:YES];
    if (section == 3) [_sectionHeaderLiqour setSelected:YES];
    if (section == 4) [_sectionHeaderMostRecent setSelected:YES];
}

- (void)accordionClosedSection:(NSInteger)section {
    if (section == 0) [_sectionHeaderBeer setSelected:NO];
    if (section == 1) [_sectionHeaderWine setSelected:NO];
    if (section == 2) [_sectionHeaderCocktails setSelected:NO];
    if (section == 3) [_sectionHeaderLiqour setSelected:NO];
    if (section == 4) [_sectionHeaderMostRecent setSelected:NO];
}

#pragma mark - Private

- (SectionHeaderView*)sectionHeaderViewForSection:(NSInteger)section {
    if (section == 0) {
        if (_sectionHeaderBeer == nil) {
            _sectionHeaderBeer = [[SectionHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(_tblReviews.frame), 56.0f)];
            [_sectionHeaderBeer setIconImage:[UIImage imageNamed:@"icon_beer"]];
            [_sectionHeaderBeer setText:@"Beer"];
            
            // Sets up for accordion
            [_sectionHeaderBeer.btnBackground setTag:section];
            [_sectionHeaderBeer.btnBackground addTarget:_accordion action:@selector(onClickSection:) forControlEvents:UIControlEventTouchUpInside];

        }
        
        return _sectionHeaderBeer;
    } else if (section == 1) {
        if (_sectionHeaderWine == nil) {
            _sectionHeaderWine = [[SectionHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(_tblReviews.frame), 56.0f)];
            [_sectionHeaderWine setIconImage:[UIImage imageNamed:@"icon_wine"]];
            [_sectionHeaderWine setText:@"Wine"];

            // Sets up for accordion
            [_sectionHeaderWine.btnBackground setTag:section];
            [_sectionHeaderWine.btnBackground addTarget:_accordion action:@selector(onClickSection:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        return _sectionHeaderWine;
    } else if (section == 2) {
        if (_sectionHeaderCocktails == nil) {
            _sectionHeaderCocktails = [[SectionHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(_tblReviews.frame), 56.0f)];
            [_sectionHeaderCocktails setIconImage:[UIImage imageNamed:@"icon_cocktails"]];
            [_sectionHeaderCocktails setText:@"Cocktail"];

            // Sets up for accordion
            [_sectionHeaderCocktails.btnBackground setTag:section];
            [_sectionHeaderCocktails.btnBackground addTarget:_accordion action:@selector(onClickSection:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        return _sectionHeaderCocktails;
    } else if (section == 3) {
        if (_sectionHeaderLiqour == nil) {
            _sectionHeaderLiqour = [[SectionHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(_tblReviews.frame), 56.0f)];
            [_sectionHeaderLiqour setIconImage:[UIImage imageNamed:@"icon_liquor"]];
            [_sectionHeaderLiqour setText:@"Liquor"];

            // Sets up for accordion
            [_sectionHeaderLiqour.btnBackground setTag:section];
            [_sectionHeaderLiqour.btnBackground addTarget:_accordion action:@selector(onClickSection:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        return _sectionHeaderLiqour;
    } else if (section == 4) {
        if (_sectionHeaderMostRecent == nil) {
            _sectionHeaderMostRecent = [[SectionHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(_tblReviews.frame), 56.0f)];
            [_sectionHeaderMostRecent setIconImage:[UIImage imageNamed:@"icon_clock"]];
            [_sectionHeaderMostRecent setText:@"Most Recent"];

            // Sets up for accordion
            [_sectionHeaderMostRecent.btnBackground setTag:section];
            [_sectionHeaderMostRecent.btnBackground addTarget:_accordion action:@selector(onClickSection:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        return _sectionHeaderMostRecent;
    }
    return nil;
}

@end
