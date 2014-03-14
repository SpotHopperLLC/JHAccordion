//
//  DrinkListMenuViewController.m
//  SpotHopper
//
//  Created by Josh Holtz on 3/13/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "DrinkListMenuViewController.h"

#import "SHButtonLatoLightLocation.h"
#import "SectionHeaderView.h"

#import "CreateListCell.h"
#import "ListCell.h"

#import "ClientSessionManager.h"
#import "DrinkListModel.h"
#import "ErrorModel.h"

#import <JHAccordion/JHAccordion.h>

@interface DrinkListMenuViewController ()<UITableViewDataSource, UITableViewDelegate, JHAccordionDelegate, SHButtonLatoLightLocationDelegate>

@property (weak, nonatomic) IBOutlet SHButtonLatoLightLocation *btnLocation;
@property (weak, nonatomic) IBOutlet UITableView *tblMenu;
@property (weak, nonatomic) IBOutlet UIView *containerAdjustSliders;

@property (nonatomic, strong) JHAccordion *accordion;
@property (nonatomic, strong) SectionHeaderView *sectionHeader0;
@property (nonatomic, strong) SectionHeaderView *sectionHeader1;
@property (nonatomic, strong) SectionHeaderView *sectionHeader2;

@property (nonatomic, strong) CLLocation *location;

@property (nonatomic, strong) NSArray *featuredDrinkLists;
@property (nonatomic, strong) NSArray *myDrinkLists;

@end

@implementation DrinkListMenuViewController

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
    [self setTitle:@"Drinklists"];
    
    // Shows sidebar button in nav
    [self showSidebarButton:YES animated:YES];
    
    // Configures accordion
    _accordion = [[JHAccordion alloc] initWithTableView:_tblMenu];
    [_accordion setDelegate:self];
    [_accordion openSection:0];
    
    // Configures table
    [_tblMenu registerNib:[UINib nibWithNibName:@"CreateListCellView" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"CreateListCell"];
    [_tblMenu registerNib:[UINib nibWithNibName:@"ListCellView" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"ListCell"];
    [_tblMenu setTableFooterView:[[UIView alloc] init]];
    
//    [self showAdjustSlidersView:NO animated:NO];
    
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
    
    // Bring container to front so its slides over footer
    [self.view bringSubviewToFront:_containerAdjustSliders];
    
    // Fetching spot lists
    if (_location == nil) {
        // Locations
        [_btnLocation setDelegate:self];
        [_btnLocation updateWithLastLocation];
    } else {
        [self fetchDrinkLists];
    }
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString * segueName = segue.identifier;
//    if ([segueName isEqualToString: @"EmbedAdjustSpotListSliderViewController"]) {
//        _adjustSpotListSliderViewController = (AdjustSpotListSliderViewController*)[segue destinationViewController];
//        [_adjustSpotListSliderViewController setDelegate:self];
//    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Don't show my reviews if no logged in
    if ([ClientSessionManager sharedClient].isLoggedIn == NO) {
        return 2;
    }
    
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 2;
    } else if (section == 1) {
        return _featuredDrinkLists.count;
    } else if (section == 2) {
        return _featuredDrinkLists.count;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        CreateListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CreateListCell" forIndexPath:indexPath];
        
        if (indexPath.row == 0) {
            [cell.lblText setText:@"Adjust Sliders"];
            [cell.lblSubtext setText:@"chill vs raging, age, drink selection, etc"];
        } else if (indexPath.row == 1) {
            [cell.lblText setText:@"or Name a Favorite Spot"];
            [cell.lblSubtext setText:@"Find bars similarto it, wherever you go"];
        }
        
        return cell;
    } else if (indexPath.section == 1) {
        ListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ListCell" forIndexPath:indexPath];
        
        DrinkListModel *drinkList = [_featuredDrinkLists objectAtIndex:indexPath.row];
        [cell.lblName setText:drinkList.name];
        
        return cell;
    } else if (indexPath.section == 2) {
        ListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ListCell" forIndexPath:indexPath];
        
        DrinkListModel *drinkList = [_myDrinkLists objectAtIndex:indexPath.row];
        [cell.lblName setText:drinkList.name];
        
        return cell;
    }
    
    return nil;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        
        if ([ClientSessionManager sharedClient].isLoggedIn == NO) {
            [self showAlert:@"Login Required" message:@"Cannot create a spotlist without logging in"];
            return;
        }
        
        if (indexPath.row == 0) {
//            [self showAdjustSlidersView:YES animated:YES];
        } else if (indexPath.row == 1) {
//            [self goToFindSimilarSpots:self];
        }
    } else if (indexPath.section == 1) {
//        SpotListModel *spotList = [_featuredSpotLists objectAtIndex:indexPath.row];
//        [self goToSpotList:spotList createdWithAdjustSliders:NO];
    } else if (indexPath.section == 2) {
//        SpotListModel *spotList = [_mySpotLists objectAtIndex:indexPath.row];
//        [self goToSpotList:spotList createdWithAdjustSliders:NO];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return ( [_accordion isSectionOpened:indexPath.section] ? 58.0f : 0.0f);
    } else if (indexPath.section == 1) {
        return ( [_accordion isSectionOpened:indexPath.section] ? 48.0f : 0.0f);
    } else if (indexPath.section == 2) {
        return ( [_accordion isSectionOpened:indexPath.section] ? 48.0f : 0.0f);
    }
    
    return 0.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [self sectionHeaderViewForSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0 || section == 1 || section == 2) {
        return 65.0f;
    }
    
    return 0.0f;
}

#pragma mark - Private

- (void)fetchDrinkLists {
    
}

@end
