//
//  SpotListsMenuViewController.m
//  SpotHopper
//
//  Created by Josh Holtz on 3/4/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "SpotListsMenuViewController.h"

#import "TTTAttributedLabel+QuickFonting.h"

#import "SectionHeaderView.h"
#import "SHButtonLatoLightLocation.h"

#import "CreateListCell.h"

#import <JHAccordion/JHAccordion.h>

@interface SpotListsMenuViewController ()<UITableViewDataSource, UITableViewDelegate, JHAccordionDelegate, SHButtonLatoLightLocationDelegate>

@property (weak, nonatomic) IBOutlet SHButtonLatoLightLocation *btnLocation;

@property (weak, nonatomic) IBOutlet UITableView *tblMenu;

@property (nonatomic, strong) JHAccordion *accordion;
@property (nonatomic, strong) SectionHeaderView *sectionHeader0;
@property (nonatomic, strong) SectionHeaderView *sectionHeader1;
@property (nonatomic, strong) SectionHeaderView *sectionHeader2;

@property (nonatomic, strong) CLLocation *location;

@end

@implementation SpotListsMenuViewController

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
    [self setTitle:@"Spotlists"];
    
    // Shows sidebar button in nav
    [self showSidebarButton:YES animated:YES];
    
    // Configures accordion
    _accordion = [[JHAccordion alloc] initWithTableView:_tblMenu];
    [_accordion setDelegate:self];
    
    // Configures table
    [_tblMenu registerNib:[UINib nibWithNibName:@"CreateListCellView" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"CreateListCell"];
    [_tblMenu setTableFooterView:[[UIView alloc] init]];
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
    
    // Locations
    [_btnLocation setDelegate:self];
    [_btnLocation updateWithLastLocation];
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
        return 2;
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
    }
    
//        static NSString *cellIdentifier = @"FooterShadowCell";
//        
//        FooterShadowCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
//        if(cell == nil) {
//            cell = [[FooterShadowCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
//        }
//        
//        return cell;
    
    return nil;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            NSLog(@"Go to adjust");
        } else if (indexPath.row == 1) {
            NSLog(@"Go to name favorite spot");
        }
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return ( [_accordion isSectionOpened:indexPath.section] ? 58.0f : 0.0f);
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

#pragma mark - JHAccordionDelegate

- (void)accordion:(JHAccordion *)accordion openingSection:(NSInteger)section {
    if (section == 0) [_sectionHeader0 setSelected:YES];
    else if (section == 1) [_sectionHeader1 setSelected:YES];
    else if (section == 2) [_sectionHeader2 setSelected:YES];
}

- (void)accordion:(JHAccordion *)accordion closingSection:(NSInteger)section {
    if (section == 0) [_sectionHeader0 setSelected:NO];
    else if (section == 1) [_sectionHeader1 setSelected:NO];
    else if (section == 2) [_sectionHeader2 setSelected:NO];
}

- (void)accordion:(JHAccordion *)accordion openedSection:(NSInteger)section {
    
}

- (void)accordion:(JHAccordion *)accordion closedSection:(NSInteger)section {
    [_tblMenu reloadData];
}

#pragma mark - SHButtonLatoLightLocationDelegate

- (void)locationRequestsUpdate:(SHButtonLatoLightLocation *)button location:(LocationChooserViewController *)viewController {
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)locationUpdate:(SHButtonLatoLightLocation *)button location:(CLLocation *)location name:(NSString *)name {
    _location = location;

}

- (void)locationError:(SHButtonLatoLightLocation *)button error:(NSError *)error {
    [self showAlert:error.localizedDescription message:error.localizedRecoverySuggestion];
}

#pragma mark - Private

- (SectionHeaderView*)sectionHeaderViewForSection:(NSInteger)section {
    
    if (section == 0) {
        if (_sectionHeader0 == nil) {
            _sectionHeader0 = [[SectionHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(_tblMenu.frame), 56.0f)];
            [_sectionHeader0 setIconImage:[UIImage imageNamed:@"icon_plus"]];

            CGFloat fontSize = _sectionHeader0.lblText.font.pointSize;
            [_sectionHeader0.lblText setText:@"Create Personalized Lists" withFont:[UIFont fontWithName:@"Lato-Regular" size:fontSize] onString:@"Create"];
            
            [_sectionHeader0.btnBackground setTag:section];
            [_sectionHeader0.btnBackground addTarget:_accordion action:@selector(onClickSection:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        return _sectionHeader0;
    } else if (section == 1) {
        if (_sectionHeader1 == nil) {
            _sectionHeader1 = [[SectionHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(_tblMenu.frame), 56.0f)];
            [_sectionHeader1 setIconImage:[UIImage imageNamed:@"icon_featured_lists"]];
            
            CGFloat fontSize = _sectionHeader1.lblText.font.pointSize;
            [_sectionHeader1.lblText setText:@"Featured Spotlists" withFont:[UIFont fontWithName:@"Lato-Regular" size:fontSize] onString:@"Featured"];
            
            [_sectionHeader1.btnBackground setTag:section];
            [_sectionHeader1.btnBackground addTarget:_accordion action:@selector(onClickSection:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        return _sectionHeader1;
    } else if (section == 2) {
        if (_sectionHeader2 == nil) {
            _sectionHeader2 = [[SectionHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(_tblMenu.frame), 56.0f)];
            [_sectionHeader2 setIconImage:[UIImage imageNamed:@"icon_my_spotlists"]];
            [_sectionHeader2 setText:@"My Spotlists"];
            
            [_sectionHeader2.btnBackground setTag:section];
            [_sectionHeader2.btnBackground addTarget:_accordion action:@selector(onClickSection:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        return _sectionHeader2;
    }
    return nil;
}

@end
