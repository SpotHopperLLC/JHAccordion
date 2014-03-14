//
//  DrinkListMenuViewController.m
//  SpotHopper
//
//  Created by Josh Holtz on 3/13/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#define kDrinkListsMenuViewControllerViewedAlready @"kDrinkListsMenuViewControllerViewedAlready"

#import "DrinkListMenuViewController.h"

#import "TTTAttributedLabel+QuickFonting.h"
#import "UIViewController+Navigator.h"

#import "SHButtonLatoLightLocation.h"
#import "SectionHeaderView.h"

#import "CreateListCell.h"
#import "ListCell.h"

#import "SHNavigationController.h"
#import "FindSimilarDrinksViewController.h"
#import "AdjustDrinkListSliderViewController.h"

#import "ClientSessionManager.h"
#import "AverageReviewModel.h"
#import "DrinkModel.h"
#import "DrinkListModel.h"
#import "ErrorModel.h"
#import "UserModel.h"

#import <JHAccordion/JHAccordion.h>

#import <CoreLocation/CoreLocation.h>

@interface DrinkListMenuViewController ()<UITableViewDataSource, UITableViewDelegate, JHAccordionDelegate, FindSimilarDrinksViewControllerDelegate, SHButtonLatoLightLocationDelegate, AdjustDrinkSliderListSliderViewControllerDelegate>

@property (weak, nonatomic) IBOutlet SHButtonLatoLightLocation *btnLocation;
@property (weak, nonatomic) IBOutlet UITableView *tblMenu;
@property (weak, nonatomic) IBOutlet UIView *containerAdjustSliders;

@property (nonatomic, strong) JHAccordion *accordion;
@property (nonatomic, strong) SectionHeaderView *sectionHeader0;
@property (nonatomic, strong) SectionHeaderView *sectionHeader1;
@property (nonatomic, strong) SectionHeaderView *sectionHeader2;

@property (nonatomic, strong) AdjustDrinkListSliderViewController *adjustDrinkListSliderViewController;

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
        [self fetchDrinkLists];
    }
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString * segueName = segue.identifier;
    if ([segueName isEqualToString: @"EmbedAdjustDrinkListSliderViewController"]) {
        _adjustDrinkListSliderViewController = (AdjustDrinkListSliderViewController*)[segue destinationViewController];
        [_adjustDrinkListSliderViewController setDelegate:self];
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
        return _featuredDrinkLists.count;
    } else if (section == 2) {
        return _myDrinkLists.count;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        CreateListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CreateListCell" forIndexPath:indexPath];
        
        if (indexPath.row == 0) {
            [cell.lblText setText:@"Adjust Sliders"];
            [cell.lblSubtext setText:@"smooth vs boozy, fruitiness, bitterness, etc"];
        } else if (indexPath.row == 1) {
            [cell.lblText setText:@"or Name a Favorite Drink"];
            [cell.lblSubtext setText:@"Find drinks similar to it, wherever you go"];
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
            [self showAdjustSlidersView:YES animated:YES];
        } else if (indexPath.row == 1) {
            [self goToFindSimilarDrinks:self];
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
//    [_adjustSpotListSliderViewController setLocation:_location];
    [self fetchDrinkLists];
}

- (void)locationError:(SHButtonLatoLightLocation *)button error:(NSError *)error {
    [self showAlert:error.localizedDescription message:error.localizedRecoverySuggestion];
}

#pragma mark - FindSimilarDrinksViewController

- (void)findSimilarDrinksViewController:(FindSimilarDrinksViewController *)viewController selectedDrink:(DrinkModel *)drink {

    [self showHUD:@"Creating drinklist"];
    [drink getDrink:Nil success:^(DrinkModel *drinkModel, JSONAPI *jsonApi) {
        [self hideHUD];
        
        [DrinkListModel postDrinkList:[NSString stringWithFormat:@"Similar to %@", drinkModel.name] latitude:[NSNumber numberWithFloat:_location.coordinate.latitude] longitude:[NSNumber numberWithFloat:_location.coordinate.longitude] sliders:drinkModel.averageReview.sliders successBlock:^(DrinkListModel *drinkListModel, JSONAPI *jsonApi) {
            
            [self hideHUD];
            [self showHUDCompleted:@"Drinklist created!" block:^{
                
//                NSMutableArray *viewControllers = self.navigationController.viewControllers.mutableCopy;
//                [viewControllers removeLastObject];
//                
//                SpotListViewController *viewController = [self.spotsStoryboard instantiateViewControllerWithIdentifier:@"SpotListViewController"];
//                [viewController setSpotList:spotListModel];
//                [viewControllers addObject:viewController];
//                
//                [self.navigationController setViewControllers:viewControllers animated:YES];
                
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

#pragma mark - AdjustDrinkSliderListSliderViewControllerDelegate

- (void)adjustDrinkSliderListSliderViewControllerDelegate:(AdjustDrinkListSliderViewController *)viewController createdDrinkList:(DrinkListModel *)spotList {
    [self showAdjustSlidersView:NO animated:YES];
    
//    [self goToSpotList:spotList createdWithAdjustSliders:YES];
}

- (void)adjustDrinkSliderListSliderViewControllerDelegateClickClose:(AdjustDrinkListSliderViewController *)viewController {
    [self showAdjustSlidersView:NO animated:YES];
}

#pragma mark - Private

- (void)fetchDrinkLists {
    
    if (_location == nil) {
        return;
    }
    
    [self showHUD:@"Fetching drinklists"];
    NSMutableArray *promises = [NSMutableArray array];
    
    NSDictionary *params = @{
                             kDrinkListModelQueryParamLat : [NSNumber numberWithFloat:_location.coordinate.latitude],
                             kDrinkListModelQueryParamLng : [NSNumber numberWithFloat:_location.coordinate.longitude]
                             };
    
    /*
     * Featured spot lists
     */
    Promise *promiseFeaturedSpotLists = [DrinkListModel getFeaturedDrinkLists:params success:^(NSArray *drinkListsModels, JSONAPI *jsonApi) {
        _featuredDrinkLists = [drinkListsModels sortedArrayUsingComparator:^NSComparisonResult(DrinkListModel* obj1, DrinkListModel* obj2) {
            return [obj1.name caseInsensitiveCompare:obj2.name];
        }];
    } failure:^(ErrorModel *errorModel) {
        
    }];
    [promises addObject:promiseFeaturedSpotLists];
    
    /*
     * My spot lists
     */
    if ([ClientSessionManager sharedClient].isLoggedIn == YES) {
        UserModel *user = [ClientSessionManager sharedClient].currentUser;
        Promise *promiseMySpotLists = [user getDrinkLists:nil success:^(NSArray *drinkListsModels, JSONAPI *jsonApi) {
            _myDrinkLists = [drinkListsModels sortedArrayUsingComparator:^NSComparisonResult(DrinkListModel* obj1, DrinkListModel* obj2) {
                return [obj1.name caseInsensitiveCompare:obj2.name];
            }];
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
        
        BOOL hasSeenBefore = [[NSUserDefaults standardUserDefaults] boolForKey:kDrinkListsMenuViewControllerViewedAlready];
        if (hasSeenBefore == NO) {
            
            // Sets has seen before
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kDrinkListsMenuViewControllerViewedAlready
             ];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [_accordion openSection:0];
            [_accordion closeSection:1];
            [_accordion closeSection:2];
            
        } else {
            
            // Opens up only section
            if (_myDrinkLists.count > 0) {
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
        [_adjustDrinkListSliderViewController setLocation:_location];
        [_adjustDrinkListSliderViewController resetForm];
        
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
            
            UIFont *font = _sectionHeader0.lblText.font;
            [_sectionHeader0.lblText setFont:[UIFont fontWithName:font.fontName size:15.0]];
            CGFloat fontSize = _sectionHeader0.lblText.font.pointSize;
            [_sectionHeader0.lblText setText:@"Create Personalized Drinklist" withFont:[UIFont fontWithName:@"Lato-Regular" size:fontSize] onString:@"Create"];
            
            [_sectionHeader0.btnBackground setTag:section];
            [_sectionHeader0.btnBackground addTarget:_accordion action:@selector(onClickSection:) forControlEvents:UIControlEventTouchUpInside];
            
            [_sectionHeader0 setSelected:[_accordion isSectionOpened:section]];
        }
        
        return _sectionHeader0;
    } else if (section == 1) {
        if (_sectionHeader1 == nil) {
            _sectionHeader1 = [[SectionHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(_tblMenu.frame), 56.0f)];
            [_sectionHeader1 setIconImage:[UIImage imageNamed:@"icon_featured_lists"]];
            
            UIFont *font = _sectionHeader1.lblText.font;
            [_sectionHeader1.lblText setFont:[UIFont fontWithName:font.fontName size:15.0]];
            CGFloat fontSize = _sectionHeader1.lblText.font.pointSize;
            [_sectionHeader1.lblText setText:@"Jump In: Featured Drinklists" withFont:[UIFont fontWithName:@"Lato-Regular" size:fontSize] onString:@"Jump In:"];
            
            [_sectionHeader1.btnBackground setTag:section];
            [_sectionHeader1.btnBackground addTarget:_accordion action:@selector(onClickSection:) forControlEvents:UIControlEventTouchUpInside];
            
            [_sectionHeader1 setSelected:[_accordion isSectionOpened:section]];
        }
        
        return _sectionHeader1;
    } else if (section == 2) {
        if (_sectionHeader2 == nil) {
            _sectionHeader2 = [[SectionHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(_tblMenu.frame), 56.0f)];
            [_sectionHeader2 setIconImage:[UIImage imageNamed:@"icon_my_spotlists"]];
            
            UIFont *font = _sectionHeader2.lblText.font;
            [_sectionHeader2.lblText setFont:[UIFont fontWithName:font.fontName size:15.0]];
            [_sectionHeader2 setText:@"My Drinklists"];
            
            [_sectionHeader2.btnBackground setTag:section];
            [_sectionHeader2.btnBackground addTarget:_accordion action:@selector(onClickSection:) forControlEvents:UIControlEventTouchUpInside];
            
            [_sectionHeader2 setSelected:[_accordion isSectionOpened:section]];
        }
        
        return _sectionHeader2;
    }
    return nil;
}

@end
