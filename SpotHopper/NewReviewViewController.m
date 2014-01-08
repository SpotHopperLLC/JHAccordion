//
//  NewReviewViewController.m
//  SpotHopper
//
//  Created by Josh Holtz on 1/8/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#define kReviewTypes @[@"Select Review Type", @"Spot", @"Beer", @"Wine", @"Cocktail"]
#define kReviewTypeIcons @[@"", @"btn_sidebar_icon_spots", @"icon_beer", @"icon_wine", @"icon_cocktails"]

#import "MyReviewsViewController.h"

#import "UIViewController+Navigator.h"

#import "SectionHeaderView.h"
#import "DropdownOptionCell.h"
#import "ReviewSliderCell.h"

#import <JHAccordion/JHAccordion.h>

#import "NewReviewViewController.h"

@interface NewReviewViewController ()<UITableViewDataSource, UITableViewDelegate, JHAccordionDelegate, ReviewSliderCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tblReviews;

@property (nonatomic, strong) JHAccordion *accordion;
@property (nonatomic, strong) SectionHeaderView *sectionHeaderReviewType;

@property (nonatomic, assign) NSInteger selectedReviewType;

@end

@implementation NewReviewViewController

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
    [_accordion openSection:0];
    
    // Configures table
    [_tblReviews setTableFooterView:[[UIView alloc] init]];
    [_tblReviews registerNib:[UINib nibWithNibName:@"DropdownOptionCellView" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"DropdownOptionCell"];
    [_tblReviews registerNib:[UINib nibWithNibName:@"ReviewSliderCellView" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"ReviewSliderCell"];
    
    // Initializes states
    _selectedReviewType = 0;
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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return kReviewTypes.count;
    } else if (section == 1) {
        return 5;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        NSString *text = [kReviewTypes objectAtIndex:indexPath.row];
        
        DropdownOptionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DropdownOptionCell" forIndexPath:indexPath];
        [cell.lblText setText:text];
        
        return cell;
    } else if (indexPath.section == 1) {
        
        ReviewSliderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ReviewSliderCell" forIndexPath:indexPath];
        [cell setDelegate:self];
        [cell setReview:nil];
        
        return cell;
        
    }
    
    return nil;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        _selectedReviewType = indexPath.row;
        
        [self updateViewHeader:indexPath.section];
        
        [_accordion closeSection:indexPath.section];
        [_tblReviews deselectRowAtIndexPath:indexPath animated:NO];
    }
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [self sectionHeaderViewForSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 56.0f;
    }
    
    return 0.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // This sets all rows in the closed sections to a height of 0 (so they won't be shown)
    // and the opened section to a height of 44.0
    if (indexPath.section == 0) {
        return ( [_accordion isSectionOpened:indexPath.section] ? 44.0f : 0.0f);
    } else if (indexPath.section == 1) {
        if (_selectedReviewType > 0) {
            return 77.0f;
        }
    }
    
    return 0.0f;
}

#pragma mark - JHAccordionDelegate

- (void)accordionOpenedSection:(NSInteger)section {
    if (section == 0) [_sectionHeaderReviewType setSelected:YES];
}

- (void)accordionClosedSection:(NSInteger)section {
    if (section == 0) [_sectionHeaderReviewType setSelected:NO];
}

#pragma mark - ReviewSliderCellDelegate

- (void)reviewSliderCell:(ReviewSliderCell *)cell changedValue:(float)value {
    NSIndexPath *indexPath = [_tblReviews indexPathForCell:cell];
    
    NSLog(@"Value changed for row %d to %f", indexPath.row, value);
}

#pragma mark - Private

- (SectionHeaderView*)sectionHeaderViewForSection:(NSInteger)section {
    if (section == 0) {
        if (_sectionHeaderReviewType == nil) {
            _sectionHeaderReviewType = [[SectionHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(_tblReviews.frame), 56.0f)];
            [_sectionHeaderReviewType setBackgroundColor:[UIColor whiteColor]];
            
            // Sets up for accordion
            [_sectionHeaderReviewType.btnBackground setTag:section];
            [_sectionHeaderReviewType.btnBackground addTarget:_accordion action:@selector(onClickSection:) forControlEvents:UIControlEventTouchUpInside];
            
            [self updateViewHeader:section];
        }
        
        return _sectionHeaderReviewType;
    }
    return nil;
}

- (void)updateViewHeader:(NSInteger)section {
    if (section == 0) {
        [_sectionHeaderReviewType setIconImage:[UIImage imageNamed:[kReviewTypeIcons objectAtIndex:_selectedReviewType]]];
        [_sectionHeaderReviewType setText:[kReviewTypes objectAtIndex:_selectedReviewType]];
    }
}

@end
