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
#import "ReviewCell.h"

#import "ClientSessionManager.h"
#import "ErrorModel.h"
#import "ReviewModel.h"
#import "UserModel.h"

#import <JHAccordion/JHAccordion.h>

@interface MyReviewsViewController ()<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, JHAccordionDelegate>

@property (weak, nonatomic) IBOutlet UITextField *txtSearch;
@property (weak, nonatomic) IBOutlet UITableView *tblReviews;

@property (nonatomic, strong) JHAccordion *accordion;
@property (nonatomic, strong) SectionHeaderView *sectionHeaderFilter;
@property (nonatomic, strong) SectionHeaderView *sectionHeaderSort;

@property (nonatomic, assign) NSInteger selectedFilter;
@property (nonatomic, assign) NSInteger selectedSort;

@property (nonatomic, strong) NSMutableArray *reviews;
@property (nonatomic, strong) NSArray *reviewsFiltered;

@property (nonatomic, assign) CGRect tblReviewsInitialFrame;
@property (nonatomic, assign) BOOL keyboardShowing;

@property (nonatomic, strong) UIStoryboard *commonStoryboard;

@end

@implementation MyReviewsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
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
    [_tblReviews registerNib:[UINib nibWithNibName:@"ReviewCellView" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"ReviewCell"];
    [_tblReviews registerNib:[UINib nibWithNibName:@"DropdownOptionCellView" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"DropdownOptionCell"];
    
    // Configures text search
    [_txtSearch addTarget:self action:@selector(onEditingChangeSearch:) forControlEvents:UIControlEventEditingChanged];
    
    // Initializes states
    _selectedFilter = 0;
    _selectedSort = 0;
    _tblReviewsInitialFrame = CGRectZero;
    _keyboardShowing = NO;
    
    // Fetch reviews
    [self fetchReviews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Deselects table row
    [_tblReviews deselectRowAtIndexPath:_tblReviews.indexPathForSelectedRow animated:NO];
    
    // Gets table frame
    if (CGRectEqualToRect(_tblReviewsInitialFrame, CGRectZero)) {
        _tblReviewsInitialFrame = _tblReviews.frame;
    }
    
    // Keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    // Adds contextual footer view
    [self addFooterViewController:^(FooterViewController *footerViewController) {
        [footerViewController showHome:YES];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Tracking

- (NSString *)screenName {
    return @"My Reviews";
}

#pragma mark - Keyboard

- (NSArray *)textfieldToHideKeyboard {
    return @[_txtSearch];
}

- (void)keyboardWillShow:(NSNotification*)notification {
    _keyboardShowing = YES;
    [self keyboardWillHideOrShow:notification show:YES];
}

- (void)keyboardWillHide:(NSNotification*)notification {
    _keyboardShowing = NO;
    [self keyboardWillHideOrShow:notification show:NO];
}

- (void)keyboardWillHideOrShow:(NSNotification*)notification show:(BOOL)show {
    NSDictionary *userInfo = notification.userInfo;
    NSTimeInterval duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    
    CGRect keyboardFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGRect frame = _tblReviews.frame;
    if (show == YES) {
        frame.size.height = CGRectGetHeight(self.view.frame) - CGRectGetMinY(frame) - CGRectGetHeight(keyboardFrame);
        if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
            frame.size.height -= 20.0f;
        }
    } else {
        frame = _tblReviewsInitialFrame;
    }
    
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionBeginFromCurrentState | curve animations:^{
        [_tblReviews setFrame:frame];
    } completion:^(BOOL finished) {
        [_tblReviews reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)] withRowAnimation:UITableViewRowAnimationAutomatic];
    }];
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
        return _reviewsFiltered.count;
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
        ReviewModel *review = [_reviewsFiltered objectAtIndex:indexPath.row];
        
        ReviewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ReviewCell" forIndexPath:indexPath];
        [cell setReview:review];
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
        ReviewModel *review = [_reviewsFiltered objectAtIndex:indexPath.row];
        [self goToReview:review];
    }
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [self sectionHeaderViewForSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0 || section == 1) {
        if (_keyboardShowing == NO) {
            return 65.0f;
        }
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

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

#pragma mark - JHAccordionDelegate

- (void)accordion:(JHAccordion *)accordion openingSection:(NSInteger)section {
    if (section == 0) [_sectionHeaderFilter setSelected:YES];
    if (section == 1) [_sectionHeaderSort setSelected:YES];
}

- (void)accordion:(JHAccordion *)accordion closingSection:(NSInteger)section {
    if (section == 0) [_sectionHeaderFilter setSelected:NO];
    if (section == 1) [_sectionHeaderSort setSelected:NO];
}

- (void)accordion:(JHAccordion *)accordion openedSection:(NSInteger)section {
    
}

- (void)accordion:(JHAccordion *)accordion closedSection:(NSInteger)section {
    [self updateFilter];
    [_tblReviews reloadData];
}

#pragma mark - Actions

- (void)onEditingChangeSearch:(id)sender {
    [self updateFilter];
    [_tblReviews reloadData];
}

#pragma mark - Private - API

- (void)fetchReviews {
    [self showHUD:@"Fetching reviews"];
    UserModel *user = [ClientSessionManager sharedClient].currentUser;
    [user getReviews:nil success:^(NSArray *reviewModels, JSONAPI *jsonApi) {
        [self hideHUD];
        
        if (_reviews == nil) _reviews = [NSMutableArray array];
        
        [_reviews addObjectsFromArray:reviewModels];
        
        [self updateFilter];
        [_tblReviews reloadData];
        
    } failure:^(ErrorModel *errorModel) {
        [self hideHUD];
        [self showAlert:@"Oops" message:errorModel.human];
    }];
}

#pragma mark - Private - UI

- (void)updateFilter {
    
    // All
    if (_selectedFilter == 0) {
        _reviewsFiltered = [NSArray arrayWithArray:_reviews];
    }
    // Spots
    else if (_selectedFilter == 1) {
        _reviewsFiltered = [_reviews filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"spot != NULL"]];
    }
    // Beers
    else if (_selectedFilter == 2) {
        _reviewsFiltered = [_reviews filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"drink.drinkType.name ==[c] %@", kDrinkTypeNameBeer]];
    }
    // Cocktails
    else if (_selectedFilter == 3) {
        _reviewsFiltered = [_reviews filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"drink.drinkType.name ==[c] %@", kDrinkTypeNameCocktail]];
    }
    // Wines
    else if (_selectedFilter == 4) {
        _reviewsFiltered = [_reviews filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"drink.drinkType.name ==[c] %@", kDrinkTypeNameWine]];
    }
    
    // Searches for query
    NSString *query = _txtSearch.text;
    if (query.length > 0) {
        _reviewsFiltered = [_reviewsFiltered filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"drink.name CONTAINS[cd] %@ OR spot.name CONTAINS[c] %@", query, query]];
    }
    
    // Sort
    if (_selectedSort == 0) {
        _reviewsFiltered = [_reviewsFiltered sortedArrayUsingComparator:^NSComparisonResult(ReviewModel *obj1, ReviewModel *obj2) {
            NSDate *obj1Date = ( obj1.updatedAt == nil ? obj1.createdAt : obj1.updatedAt );
            NSDate *obj2Date = ( obj2.updatedAt == nil ? obj2.createdAt : obj2.updatedAt );
            
            return [obj2Date compare:obj1Date];
        }];
    } else if (_selectedSort == 1) {
        _reviewsFiltered = [_reviewsFiltered sortedArrayUsingComparator:^NSComparisonResult(ReviewModel *obj1, ReviewModel *obj2) {
            return [obj2.rating compare:obj1.rating];
        }];
    }
}

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
        if (_sectionHeaderFilter == nil) {
            _sectionHeaderFilter = [self instantiateSectionHeaderView];
            
            // Sets up for accordion
            [_sectionHeaderFilter.btnBackground setTag:section];
            [_sectionHeaderFilter.btnBackground addTarget:_accordion action:@selector(onClickSection:) forControlEvents:UIControlEventTouchUpInside];

            [self updateViewHeader:section];
        }
        
        return _sectionHeaderFilter;
    } else if (section == 1) {
        if (_sectionHeaderSort == nil) {
            _sectionHeaderSort = [self instantiateSectionHeaderView];

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
