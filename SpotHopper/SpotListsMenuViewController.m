//
//  SpotListsMenuViewController.m
//  SpotHopper
//
//  Created by Josh Holtz on 3/4/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#define kSpotListsMenuViewControllerViewedAlready @"kSpotListsMenuViewControllerViewedAlready"

#import "SpotListsMenuViewController.h"

#import "TTTAttributedLabel+QuickFonting.h"
#import "UIViewController+Navigator.h"

#import "SectionHeaderView.h"
#import "SHButtonLatoLightLocation.h"

#import "CreateListCell.h"
#import "ListCell.h"

#import "SHNavigationController.h"
#import "AdjustSpotListSliderViewController.h"
#import "FindSimilarViewController.h"
#import "SpotListViewController.h"

#import "ClientSessionManager.h"
#import "AverageReviewModel.h"
#import "ErrorModel.h"
#import "SliderModel.h"
#import "SliderTemplateModel.h"
#import "SpotModel.h"
#import "SpotListModel.h"
#import "UserModel.h"

#import <JHAccordion/JHAccordion.h>
#import <Promises/Promise.h>

#import <CoreLocation/CoreLocation.h>

@interface SpotListsMenuViewController ()<UITableViewDataSource, UITableViewDelegate, FindSimilarViewControllerDelegate, AdjustSliderListSliderViewControllerDelegate, JHAccordionDelegate, SHButtonLatoLightLocationDelegate>

@property (weak, nonatomic) IBOutlet UIView *containerAdjustSliders;

@property (weak, nonatomic) IBOutlet SHButtonLatoLightLocation *btnLocation;

@property (weak, nonatomic) IBOutlet UITableView *tblMenu;

@property (nonatomic, strong) JHAccordion *accordion;
@property (nonatomic, strong) SectionHeaderView *sectionHeader0;
@property (nonatomic, strong) SectionHeaderView *sectionHeader1;
@property (nonatomic, strong) SectionHeaderView *sectionHeader2;

@property (nonatomic, strong) AdjustSpotListSliderViewController *adjustSpotListSliderViewController;

@property (nonatomic, strong) CLLocation *location;

@property (nonatomic, strong) NSArray *featuredSpotLists;
@property (nonatomic, strong) NSArray *mySpotLists;

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
    [_accordion openSection:0];
    
    // Configures table
    [_tblMenu registerNib:[UINib nibWithNibName:@"CreateListCellView" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"CreateListCell"];
    [_tblMenu registerNib:[UINib nibWithNibName:@"ListCellView" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"ListCell"];
    [_tblMenu setTableFooterView:[[UIView alloc] init]];
    
    [self showAdjustSlidersView:NO animated:NO];

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
        [self fetchSpotLists];
    }
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString * segueName = segue.identifier;
    if ([segueName isEqualToString: @"EmbedAdjustSpotListSliderViewController"]) {
        _adjustSpotListSliderViewController = (AdjustSpotListSliderViewController*)[segue destinationViewController];
        [_adjustSpotListSliderViewController setDelegate:self];
    }
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
        return _featuredSpotLists.count;
    } else if (section == 2) {
        return _mySpotLists.count;
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
        
        SpotListModel *spotList = [_featuredSpotLists objectAtIndex:indexPath.row];
        [cell.lblName setText:spotList.name];
        
        return cell;
    } else if (indexPath.section == 2) {
        ListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ListCell" forIndexPath:indexPath];
        
        SpotListModel *spotList = [_mySpotLists objectAtIndex:indexPath.row];
        [cell.lblName setText:spotList.name];
        
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
            [self showAdjustSlidersView:YES animated:YES];
        } else if (indexPath.row == 1) {
            [self goToFindSimilarSpots:self];
        }
    } else if (indexPath.section == 1) {
        SpotListModel *spotList = [_featuredSpotLists objectAtIndex:indexPath.row];
        [self goToSpotList:spotList createdWithAdjustSliders:NO];
    } else if (indexPath.section == 2) {
        SpotListModel *spotList = [_mySpotLists objectAtIndex:indexPath.row];
        [self goToSpotList:spotList createdWithAdjustSliders:NO];
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
    SHNavigationController *navController = [[SHNavigationController alloc] initWithRootViewController:viewController];
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)locationUpdate:(SHButtonLatoLightLocation *)button location:(CLLocation *)location name:(NSString *)name {
    _location = location;
    [_adjustSpotListSliderViewController setLocation:_location];
    [self fetchSpotLists];
}

- (void)locationError:(SHButtonLatoLightLocation *)button error:(NSError *)error {
    [self showAlert:error.localizedDescription message:error.localizedRecoverySuggestion];
}

#pragma mark - FindSimilarViewControllerDelegate

- (void)findSimilarViewController:(FindSimilarViewController *)viewController selectedDrink:(DrinkModel *)drink {
    
}

- (void)findSimilarViewController:(FindSimilarViewController *)viewController selectedSpot:(SpotModel *)spot {
    
    [self showHUD:@"Creating spotlist"];
    [spot getSpot:Nil success:^(SpotModel *spotModel, JSONAPI *jsonApi) {
        [self hideHUD];
        
        [SpotListModel postSpotList:spotModel.name latitude:spotModel.latitude longitude:spotModel.longitude sliders:spot.averageReview.sliders successBlock:^(SpotListModel *spotListModel, JSONAPI *jsonApi) {
            [self hideHUD];
            [self showHUDCompleted:@"Spotlist created!" block:^{
                
                NSMutableArray *viewControllers = self.navigationController.viewControllers.mutableCopy;
                [viewControllers removeLastObject];
                
                SpotListViewController *viewController = [self.spotsStoryboard instantiateViewControllerWithIdentifier:@"SpotListViewController"];
                [viewController setSpotList:spotListModel];
                [viewControllers addObject:viewController];
                
                [self.navigationController setViewControllers:viewControllers animated:YES];
                
                
            }];
            
        } failure:^(ErrorModel *errorModel) {
            [self hideHUD];
            [self showAlert:@"Oops" message:errorModel.human];
        }];
        
    } failure:^(ErrorModel *errorModel) {
        [self hideHUD];
        [self showAlert:@"Oops" message:errorModel.human];
    }];
}

#pragma mark - AdjustSliderListSliderViewControllerDelegate

- (void)adjustSliderListSliderViewControllerDelegateClickClose:(AdjustSpotListSliderViewController *)viewController {
    [self showAdjustSlidersView:NO animated:YES];
}

- (void)adjustSliderListSliderViewControllerDelegate:(AdjustSpotListSliderViewController *)viewController createdSpotList:(SpotListModel *)spotList {
    [self showAdjustSlidersView:NO animated:YES];
    
    [self goToSpotList:spotList createdWithAdjustSliders:YES];
}

#pragma mark - Private

- (void)fetchSpotLists {
    
    if (_location == nil) {
        return;
    }
    
    [self showHUD:@"Fetching spot lists"];
    NSMutableArray *promises = [NSMutableArray array];
    
    NSDictionary *params = @{
                             kSpotListModelQueryParamLat : [NSNumber numberWithFloat:_location.coordinate.latitude],
                             kSpotListModelQueryParamLng : [NSNumber numberWithFloat:_location.coordinate.longitude]
                             };
    
    /*
     * Featured spot lists
     */
    Promise *promiseFeaturedSpotLists = [SpotListModel getFeaturedSpotLists:params success:^(NSArray *spotListModels, JSONAPI *jsonApi) {
        _featuredSpotLists = spotListModels;
    } failure:^(ErrorModel *errorModel) {
        
    }];
    [promises addObject:promiseFeaturedSpotLists];
    
    /*
     * My spot lists
     */
    if ([ClientSessionManager sharedClient].isLoggedIn == YES) {
        UserModel *user = [ClientSessionManager sharedClient].currentUser;
        Promise *promiseMySpotLists = [user getSpotLists:params success:^(NSArray *spotListsModels, JSONAPI *jsonApi) {
            _mySpotLists = spotListsModels;
        } failure:^(ErrorModel *errorModel) {
            
        }];
        [promises addObject:promiseMySpotLists];
    }
    
    /*
     * When
     */
    [When when:promises then:^{
        
    } fail:^(id error) {
        
    } always:^{
        
        // Reload table and hide HUD
        [_tblMenu reloadData];
        [self hideHUD];
        
        BOOL hasSeenBefore = [[NSUserDefaults standardUserDefaults] boolForKey:kSpotListsMenuViewControllerViewedAlready];
        if (hasSeenBefore == NO) {
            
            // Sets has seen before
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kSpotListsMenuViewControllerViewedAlready
             ];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [_accordion openSection:0];
            [_accordion closeSection:1];
            [_accordion closeSection:2];
            
        } else {
            
            // Opens up only section
            if (_mySpotLists.count > 0) {
                [_accordion closeSection:0];
                [_accordion closeSection:1];
                [_accordion openSection:2];
            } else {
                [_accordion openSection:0];
                [_accordion openSection:1];
                [_accordion closeSection:2];
            }
            
        }
        
    }];
    
}

- (void)showAdjustSlidersView:(BOOL)show animated:(BOOL)animated {
    
    if (show == YES) {
        
        // Sets currently selected location inthe adjust spotlist slider view controoler
        [_adjustSpotListSliderViewController setLocation:_location];
        [_adjustSpotListSliderViewController resetForm];

        [_containerAdjustSliders setHidden:NO];
        
        CGRect frame = _containerAdjustSliders.frame;
        frame.origin.y = CGRectGetMaxY(self.view.frame) - CGRectGetHeight(frame);
        
        [UIView animateWithDuration:( animated ? 0.35f : 0.0f ) animations:^{
            [_containerAdjustSliders setFrame:frame];
        } completion:^(BOOL finished) {
            
        }];
        
    } else {
        
        CGRect frame = _containerAdjustSliders.frame;
        frame.origin.y = CGRectGetMaxY(self.view.frame);

        [UIView animateWithDuration:( animated ? 0.35f : 0.0f ) animations:^{
            [_containerAdjustSliders setFrame:frame];
        } completion:^(BOOL finished) {
            [_containerAdjustSliders setHidden:YES];
        }];
        
    }
    
}

- (SectionHeaderView*)sectionHeaderViewForSection:(NSInteger)section {
    
    if (section == 0) {
        if (_sectionHeader0 == nil) {
            _sectionHeader0 = [[SectionHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(_tblMenu.frame), 56.0f)];
            [_sectionHeader0 setIconImage:[UIImage imageNamed:@"icon_plus"]];

            CGFloat fontSize = _sectionHeader0.lblText.font.pointSize;
            [_sectionHeader0.lblText setText:@"Create Personalized Lists" withFont:[UIFont fontWithName:@"Lato-Regular" size:fontSize] onString:@"Create"];
            
            [_sectionHeader0.btnBackground setTag:section];
            [_sectionHeader0.btnBackground addTarget:_accordion action:@selector(onClickSection:) forControlEvents:UIControlEventTouchUpInside];
            
            [_sectionHeader0 setSelected:[_accordion isSectionOpened:section]];
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
            
            [_sectionHeader1 setSelected:[_accordion isSectionOpened:section]];
        }
        
        return _sectionHeader1;
    } else if (section == 2) {
        if (_sectionHeader2 == nil) {
            _sectionHeader2 = [[SectionHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(_tblMenu.frame), 56.0f)];
            [_sectionHeader2 setIconImage:[UIImage imageNamed:@"icon_my_spotlists"]];
            [_sectionHeader2 setText:@"My Spotlists"];
            
            [_sectionHeader2.btnBackground setTag:section];
            [_sectionHeader2.btnBackground addTarget:_accordion action:@selector(onClickSection:) forControlEvents:UIControlEventTouchUpInside];
            
            [_sectionHeader2 setSelected:[_accordion isSectionOpened:section]];
        }
        
        return _sectionHeader2;
    }
    return nil;
}

@end
