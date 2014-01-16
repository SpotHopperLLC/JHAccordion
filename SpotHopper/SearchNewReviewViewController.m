//
//  SearchNewReviewViewController.m
//  SpotHopper
//
//  Created by Josh Holtz on 1/15/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "SearchNewReviewViewController.h"

#import "FooterShadowCell.h"
#import "SearchCell.h"

#import "DrinkModel.h"
#import "ErrorModel.h"
#import "SpotModel.h"

#import <QuartzCore/QuartzCore.h>

@interface SearchNewReviewViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *txtSearch;
@property (weak, nonatomic) IBOutlet UITableView *tblSearches;

@property (nonatomic, assign) CGRect tblSearchesInitalFrame;

// Timer used for when to search when typing halts
@property (nonatomic, strong) NSTimer *searchTimer;

@property (nonatomic, strong) NSMutableArray *results;

@end

@implementation SearchNewReviewViewController

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
    [self setTitle:@"New Reviews"];
    
    // Shows sidebar button in nav
    [self showSidebarButton:YES animated:YES];
    
    // Configures table
    [_tblSearches setTableFooterView:[[UIView alloc] init]];
    [_tblSearches registerNib:[UINib nibWithNibName:@"SearchCellView" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"SearchCell"];
    
    // Configures text search
    [_txtSearch addTarget:self action:@selector(onEditingChangeSearch:) forControlEvents:UIControlEventEditingChanged];
    
    // Initializes states
    _tblSearchesInitalFrame = CGRectZero;
    _results = [NSMutableArray array];
    [self updateView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Deselects table row
    [_tblSearches deselectRowAtIndexPath:_tblSearches.indexPathForSelectedRow animated:NO];
    
    // Gets table frame
    if (CGRectEqualToRect(_tblSearchesInitalFrame, CGRectZero)) {
        _tblSearchesInitalFrame = _tblSearches.frame;
    }
    
    // Keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    // Adds contextual footer view
    [self addFooterViewController:^(FooterViewController *footerViewController) {
        [footerViewController showHome:YES];
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Keyboard

- (NSArray *)textfieldToHideKeyboard {
    return @[_txtSearch];
}

- (void)keyboardWillShow:(NSNotification*)notification {
    [self keyboardWillHideOrShow:notification show:NO];
}

- (void)keyboardWillHide:(NSNotification*)notification {
    [self keyboardWillHideOrShow:notification show:NO];
}

- (void)keyboardWillHideOrShow:(NSNotification*)notification show:(BOOL)show {
    NSDictionary *userInfo = notification.userInfo;
    NSTimeInterval duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    
    CGRect keyboardFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGRect frame = _tblSearches.frame;
    if (show == YES) {
        frame.size.height = CGRectGetHeight(self.view.frame) - CGRectGetMinY(frame) - CGRectGetHeight(keyboardFrame);
    } else {
        frame = _tblSearchesInitalFrame;
    }
    
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionBeginFromCurrentState | curve animations:^{
        [_tblSearches setFrame:frame];
    } completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return _results.count;
    } else if (section == 1) {
        return 1;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        JSONAPIResource *result = [_results objectAtIndex:indexPath.row];
        
        SearchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchCell" forIndexPath:indexPath];
        if ([result isKindOfClass:[DrinkModel class]] == YES) {
            DrinkModel *drink = (DrinkModel*)result;
            [cell setDrink:drink];
        } else if ([result isKindOfClass:[SpotModel class]] == YES) {
            SpotModel *spot = (SpotModel*)result;
            [cell setSpot:spot];
        }

        return cell;
    } else if (indexPath.section == 1) {
        static NSString *cellIdentifier = @"FooterShadowCell";
        
        FooterShadowCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if(cell == nil) {
            cell = [[FooterShadowCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        
        return cell;
    }
    
    return nil;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 45.0f;
    } else if (indexPath.section == 1) {
        return 10.f;
    }
    
    return 0.0f;
}

#pragma mark - Actions

- (void)onEditingChangeSearch:(id)sender {
    // Cancel and nil
    [_searchTimer invalidate];
    _searchTimer = nil;
    
    // Schedule timer
    _searchTimer = [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(doSearch) userInfo:nil repeats:NO];
}

#pragma mark - Private

- (void)updateView {
    [_tblSearches setHidden:(_results.count == 0)];
}

- (void)doSearch {
    NSLog(@"Doing search now");
    
    [self showHUD:@"Searching"];
    [_results removeAllObjects];

    // Creates dispatch group
    dispatch_group_t group = dispatch_group_create();
    
    // Searches drinks
    dispatch_group_enter(group);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        [DrinkModel getDrinks:nil success:^(NSArray *drinkModels) {
            // Adds drinks to results
            [_results addObject:drinkModels];
            
            // Leaves group
            dispatch_group_leave(group);
        } failure:^(ErrorModel *errorModel) {
            
            // Leaves group
            dispatch_group_leave(group);
        }];
        
    });
    
    // Searches spots
    dispatch_group_enter(group);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        [SpotModel getSpots:nil success:^(NSArray *spotModels) {
            // Adds spots to results
            [_results addObject:spotModels];
            
            // Leaves group
            dispatch_group_leave(group);
        } failure:^(ErrorModel *errorModel) {
            
            // Leaves group
            dispatch_group_leave(group);
        }];
        
    });
    
    // Waits for drinks and spots to complete before continueing on
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [_tblSearches reloadData];
            [self updateView];
            [self hideHUD];
        });
    });
}

@end
