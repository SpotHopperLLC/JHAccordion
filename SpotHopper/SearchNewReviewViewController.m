//
//  SearchNewReviewViewController.m
//  SpotHopper
//
//  Created by Josh Holtz on 1/15/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "SearchNewReviewViewController.h"

#import "SearchCell.h"

#import <QuartzCore/QuartzCore.h>

@interface SearchNewReviewViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *txtSearch;
@property (weak, nonatomic) IBOutlet UITableView *tblSearches;

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
    
    // Initializes states

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Deselects table row
    [_tblSearches deselectRowAtIndexPath:_tblSearches.indexPathForSelectedRow animated:NO];
    
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
        return 10;
    } else if (section == 1) {
        return 1;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        SearchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchCell" forIndexPath:indexPath];
        [cell setDrink:nil];
    //    [cell setDelegate:self];
    //    [cell setReview:nil];
    //    
        return cell;
    } else if (indexPath.section == 1) {
        static NSString *cellIdentifier = @"cell_identifier";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if(cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
            [cell setBackgroundColor:[UIColor clearColor]];
            [cell.contentView setBackgroundColor:[UIColor clearColor]];
            
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tableView.frame), 10.0f)];
            [view setBackgroundColor:[UIColor clearColor]];
            
            CAGradientLayer *topShadow = [CAGradientLayer layer];
            topShadow.frame = CGRectMake(0, 0, view.bounds.size.width, 10);
            topShadow.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithWhite:0.0 alpha:0.1f] CGColor], (id)[[UIColor colorWithWhite:0.0 alpha:0.0f] CGColor], nil];
            [view.layer insertSublayer:topShadow atIndex:0];
            
            [cell addSubview:view];
            
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

@end
