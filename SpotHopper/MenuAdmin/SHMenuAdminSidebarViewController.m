//
//  SidebarViewController.m
//  SpotHopper
//
//  Created by Josh Holtz on 1/3/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "SHMenuAdminSidebarViewController.h"

#import "SpotModel.h"
#import "UserModel.h"
#import "Tracker.h"
#import "ClientSessionManager.h"

//#import "SHMenuAdminSearchViewController.h"
#import "SHMenuAdminStyleSupport.h"
#import "UIButton+FilterStyling.h"

#define kTagLabelSpotName 1

#define kParamPage @"page_number"
#define kPageSize 5
#define kButtonHeight 50.0

@interface SHMenuAdminSidebarViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UIButton *seeAllSpotsButton;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;
@property (weak, nonatomic) IBOutlet UILabel *instructionsLabel;

@property (strong, nonatomic) UserModel *user;

@end

@implementation SHMenuAdminSidebarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    MAAssert(self.tableView, @"Outlet must be connected");
    MAAssert([self.tableView.delegate isEqual:self], @"Delegate must be connected");
    MAAssert([self.tableView.dataSource isEqual:self], @"DataSource must be connected");

    [self styleSidebar];
}

- (NSArray *)viewOptions {
    return @[kDidLoadOptionsDontAdjustForIOS6, kDidLoadOptionsNoBackground];
}

#pragma mark - Actions
#pragma mark -

- (IBAction)closeButtonTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(closeButtonTapped:)]) {
        [self.delegate closeButtonTapped:self];
    }
}

- (IBAction)seeAllSpotsTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(viewAllSpotsTapped:)]) {
        [self.delegate viewAllSpotsTapped:self];
    }
}

- (IBAction)logoutTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(logoutTapped:)]) {
        [self.delegate logoutTapped:self];
    }
}

#pragma mark -  Refresh
#pragma mark -

- (void)changeSpots:(NSArray *)spots {
    self.spots = spots;
    [self.tableView reloadData];
    self.user = [ClientSessionManager sharedClient].currentUser;
    [self toggleSearchBasedOnUserRole];
}

#pragma mark - Private
#pragma mark -

- (SpotModel *)spotForIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.spots.count) {
        return self.spots[indexPath.row];
    }
    
    return nil;
}

- (void)selectSpot:(SpotModel *)spot {
    if ([self.delegate respondsToSelector:@selector(spotTapped:spot:)]){
        [self.delegate spotTapped:self spot:spot];
    }
}

- (void)toggleSearchBasedOnUserRole {
    if (![@"admin" isEqualToString:self.user.role]) {
        self.seeAllSpotsButton.hidden = TRUE;
    }
    else if (self.seeAllSpotsButton.hidden) {
        self.seeAllSpotsButton.hidden = FALSE;
    }
}

#pragma mark - Styling
#pragma mark -

- (void)styleSidebar {
    self.backgroundView.backgroundColor = [[SHMenuAdminStyleSupport sharedInstance].LIGHT_ORANGE colorWithAlphaComponent:0.9];
    self.instructionsLabel.backgroundColor = [SHMenuAdminStyleSupport sharedInstance].DARK_ORANGE;
    [self.seeAllSpotsButton addTopBorder];
}

#pragma mark - UITableViewDataSource
#pragma mark -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.spots.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"SpotCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    SpotModel *spot = [self spotForIndexPath:indexPath];
    
    UIView *selectedBackgroundView = [[UIView alloc] init];
    selectedBackgroundView.backgroundColor = [[SHMenuAdminStyleSupport sharedInstance].DARK_ORANGE colorWithAlphaComponent:0.75];
    cell.selectedBackgroundView = selectedBackgroundView;
    
    UILabel *label = (UILabel *)[cell viewWithTag:1];
    label.text = spot.name;
    
    return cell;
}

#pragma mark - UITableViewDelegate
#pragma mark -

//- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    DebugLog(@"%@", NSStringFromSelector(_cmd));
//    return indexPath;
//}
//
//- (NSIndexPath *)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
//    DebugLog(@"%@", NSStringFromSelector(_cmd));
//    return indexPath;
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SpotModel *spot = [self spotForIndexPath:indexPath];
    [self selectSpot:spot];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [tableView deselectRowAtIndexPath:indexPath animated:TRUE];
    });
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

@end
