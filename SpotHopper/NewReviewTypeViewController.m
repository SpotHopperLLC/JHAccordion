//
//  NewReviewTypeViewController.m
//  SpotHopper
//
//  Created by Josh Holtz on 2/26/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#define kReviewTypeIcons @[@"btn_sidebar_icon_spots", @"icon_beer", @"icon_cocktails", @"icon_wine"]

#import "NewReviewTypeViewController.h"

#import "UIViewController+Navigator.h"

#import "DropdownOptionCell.h"

#import "SectionHeaderView.h"

@interface NewReviewTypeViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tblReviewTypes;

@property (nonatomic, strong) SectionHeaderView *sectionHeaderReviewType;

@property (nonatomic, strong) UIStoryboard *commonStoryboard;

@end

@implementation NewReviewTypeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Sets title
    [self setTitle:@"New Reviews"];
    
    // Shows sidebar button in nav
    [self showSidebarButton:YES animated:YES];
	
    // Configures table
    [_tblReviewTypes setTableFooterView:[[UIView alloc] init]];
    [_tblReviewTypes registerNib:[UINib nibWithNibName:@"DropdownOptionCellView" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"DropdownOptionCell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Tracking

- (NSString *)screenName {
    return @"New Review Type";
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == _tblReviewTypes) {
        return 1;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == _tblReviewTypes) {
        if (section == 0) {
            return kReviewTypes.count;
        }
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _tblReviewTypes) {
        if (indexPath.section == 0) {
            NSString *text = [kReviewTypes objectAtIndex:indexPath.row];
            
            DropdownOptionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DropdownOptionCell" forIndexPath:indexPath];
            [cell.lblText setText:text];
            
            return cell;
        }
    }
    
    return nil;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _tblReviewTypes) {
        NSString *reviewType = [kReviewTypes objectAtIndex:indexPath.row];
        [self goToNewReviewWithType:reviewType delegate:_delegate];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (tableView == _tblReviewTypes) {
        if (section == 0) {
            return [self sectionHeaderViewForSection:section];
        }
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (tableView == _tblReviewTypes) {
        if (section == 0) {
            return 65.0f;
        }
    }
    
    return 0.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0f;
}

#pragma mark - Private

- (SectionHeaderView *)instantiateSectionHeaderView {
    // load the VC and get the view (to allow for easily laying out the custom section header)
    if (!_commonStoryboard) {
        _commonStoryboard = [UIStoryboard storyboardWithName:@"Common" bundle:nil];
    }
    UIViewController *vc = [_commonStoryboard instantiateViewControllerWithIdentifier:@"SectionHeaderScene"];
    SectionHeaderView *sectionHeaderView = (SectionHeaderView *)[vc.view viewWithTag:100];
    [sectionHeaderView removeFromSuperview];
    [sectionHeaderView prepareView];
    
    return sectionHeaderView;
}

- (SectionHeaderView*)sectionHeaderViewForSection:(NSInteger)section {
    if (section == 0) {
        if (_sectionHeaderReviewType == nil) {
            _sectionHeaderReviewType = [self instantiateSectionHeaderView];
            [_sectionHeaderReviewType setBackgroundColor:[UIColor whiteColor]];
            [_sectionHeaderReviewType setText:@"Select Review Type"];
        }
        
        return _sectionHeaderReviewType;
    }
    return nil;
}

@end