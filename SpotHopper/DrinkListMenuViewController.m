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
#import "UIAlertView+Block.h"

#import "SHButtonLatoLightLocation.h"
#import "SectionHeaderView.h"

#import "CreateListCell.h"
#import "ListCell.h"

#import "SHNavigationController.h"
#import "FindSimilarViewController.h"
#import "FindSimilarDrinksViewController.h"
#import "AdjustDrinkListSliderViewController.h"
#import "DrinkListViewController.h"

#import "ClientSessionManager.h"
#import "AverageReviewModel.h"
#import "DrinkModel.h"
#import "DrinkTypeModel.h"
#import "DrinkSubtypeModel.h"
#import "DrinkListModel.h"
#import "ErrorModel.h"
#import "UserModel.h"

#import <JHAccordion/JHAccordion.h>

#import <CoreLocation/CoreLocation.h>

@interface DrinkListMenuViewController ()<UITableViewDataSource, UITableViewDelegate, JHAccordionDelegate, CheckinViewControllerDelegate, FindSimilarDrinksViewControllerDelegate, SHButtonLatoLightLocationDelegate, AdjustDrinkSliderListSliderViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *viewInfo;
@property (weak, nonatomic) IBOutlet UIImageView *imgWhiteScreen;
@property (weak, nonatomic) IBOutlet UILabel *lblInfo;

@property (weak, nonatomic) IBOutlet SHButtonLatoLightLocation *btnLocation;
@property (weak, nonatomic) IBOutlet SHButtonLatoLight *btnSpot;
@property (weak, nonatomic) IBOutlet UITableView *tblMenu;
@property (weak, nonatomic) IBOutlet UIView *containerAdjustSliders;

@property (weak, nonatomic) IBOutlet UIView *viewLocation;
@property (weak, nonatomic) IBOutlet UIView *viewSpot;

@property (nonatomic, strong) JHAccordion *accordion;
@property (nonatomic, strong) SectionHeaderView *sectionHeader0;
@property (nonatomic, strong) SectionHeaderView *sectionHeader1;
@property (nonatomic, strong) SectionHeaderView *sectionHeader2;

@property (nonatomic, strong) AdjustDrinkListSliderViewController *adjustDrinkListSliderViewController;

@property (nonatomic, strong) UIStoryboard *commonStoryboard;

@property (nonatomic, strong) CLLocation *location;

@property (nonatomic, strong) NSArray *featuredDrinkLists;
@property (nonatomic, strong) NSArray *myDrinkLists;

@end

@implementation DrinkListMenuViewController {
    BOOL _updatedSearchNeeded;
}

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
    [self setTitle:@"Drinklists"];
    
    // Shows sidebar button in nav
    [self showSidebarButton:YES animated:YES];
    
    // Configures accordion
    _accordion = [[JHAccordion alloc] initWithTableView:_tblMenu];
    [_accordion setDelegate:self];
    [_accordion openSection:0];
    [_accordion openSection:1];
    [_accordion openSection:2];
    
    // Configures table
    [_tblMenu registerNib:[UINib nibWithNibName:@"CreateListCellView" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"CreateListCell"];
    [_tblMenu registerNib:[UINib nibWithNibName:@"ListCellView" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"ListCell"];
    [_tblMenu setTableFooterView:[[UIView alloc] init]];
    
    [self showAdjustSlidersView:NO animated:NO];
    
    [self updateView];
    
    _imgWhiteScreen.image = [self whiteScreenImageForFrame:_imgWhiteScreen.frame];
    [self changeLabelToLatoLight:_lblInfo];
    CGRect frame = _lblInfo.frame;
    frame.size.height = [self heightForString:_lblInfo.text font:_lblInfo.font maxWidth:CGRectGetWidth(_lblInfo.frame)];
    _lblInfo.frame = frame;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    
    // Open when the view appears
    [_accordion openSection:0];
    
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
    if (_spot == nil && _location == nil) {
        // Locations
        _updatedSearchNeeded = TRUE;
        [_btnLocation setDelegate:self];
        [_btnLocation updateWithLastLocation];
    } else {
        [self fetchDrinkLists];
    }
    
    if ([[ClientSessionManager sharedClient] hasSeenDrinklists] == NO) {
        [self showInfo:FALSE];
        [[ClientSessionManager sharedClient] setHasSeenDrinklists:TRUE];
    }
    else {
        [self hideInfo:FALSE];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // Setting has seen before
    if ([self hasBeenSeenBefore] == NO) {
        
        // Sets has seen before
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kDrinkListsMenuViewControllerViewedAlready
         ];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString * segueName = segue.identifier;
    if ([segueName isEqualToString: @"EmbedAdjustDrinkListSliderViewController"]) {
        _adjustDrinkListSliderViewController = (AdjustDrinkListSliderViewController*)[segue destinationViewController];
        [_adjustDrinkListSliderViewController setDelegate:self];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Tracking

- (NSString *)screenName {
    return @"Drink List Menu";
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
        // Only show if not a drinklist at a spot
        if (_spot == nil && [self hasBeenSeenBefore] == YES) {
            return _featuredDrinkLists.count;
        }
    } else if (section == 2) {
        if ([self hasBeenSeenBefore] == YES) {
            return _myDrinkLists.count;
        }
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
        DrinkListModel *drinkList = [_featuredDrinkLists objectAtIndex:indexPath.row];
        [self goToDrinkList:drinkList createdWithAdjustSliders:NO atSpot:_spot];
    } else if (indexPath.section == 2) {
        DrinkListModel *drinkList = [_myDrinkLists objectAtIndex:indexPath.row];
        [self goToDrinkList:drinkList createdWithAdjustSliders:NO atSpot:_spot];
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
    if (section == 0) {
        return 65.0f;
    } if (section == 1  && [self hasBeenSeenBefore] == YES && _featuredDrinkLists.count > 0) {
        // Only show if not a drinklist at a spot
        if (_spot == nil) {
            return 65.0f;
        }
    } if (section == 2 && [self hasBeenSeenBefore] == YES && _myDrinkLists.count > 0) {
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
    // do nothing
    _location = location;
    if (_updatedSearchNeeded) {
        [self fetchDrinkLists];
    }
}

- (void)locationDidChooseLocation:(CLLocation *)location {
    _location = location;
    [_adjustDrinkListSliderViewController setLocation:_location];
    [self fetchDrinkLists];
}

- (void)locationError:(SHButtonLatoLightLocation *)button error:(NSError *)error {
    [self showAlert:error.localizedDescription message:error.localizedRecoverySuggestion];
}

#pragma mark - CheckinViewControllerDelegate

- (void)checkinViewController:(CheckinViewController *)viewController checkedInToSpot:(SpotModel *)spot {
    [self.navigationController popToViewController:self animated:YES];
    
    _spot = spot;
    [self updateView];
    [self fetchDrinkLists];
}

#pragma mark - FindSimilarDrinksViewController

- (void)findSimilarDrinksViewController:(FindSimilarDrinksViewController *)viewController selectedDrink:(DrinkModel *)drink {
    
    // Cannot create drinklist if no average review - so prompt to create review
    if (drink.averageReview == nil) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Reviews" message:@"This drink doesn't have any reviews. Would you like to create one?" delegate:nil cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                [self goToNewReviewForDrink:drink];
            }
        }];
        
        return;
    }

    [self showHUD:@"Creating drinklist"];
    [drink getDrink:Nil success:^(DrinkModel *drinkModel, JSONAPI *jsonApi) {
        
        [DrinkListModel postDrinkList:[NSString stringWithFormat:@"Similar to %@", drinkModel.name]
                             latitude:[NSNumber numberWithFloat:_location.coordinate.latitude]
                            longitude:[NSNumber numberWithFloat:_location.coordinate.longitude]
                              sliders:drinkModel.averageReview.sliders drinkId:drinkModel.ID
                          drinkTypeId:drinkModel.drinkType.ID
                       drinkSubtypeId:drinkModel.drinkSubtype.ID
                        baseAlcoholId:nil
                               spotId:_spot.ID
                         successBlock:^(DrinkListModel *drinkListModel, JSONAPI *jsonApi) {
            
            [self hideHUD];
            [self showHUDCompleted:@"Drinklist created!" block:^{
                
                NSMutableArray *viewControllers = self.navigationController.viewControllers.mutableCopy;
                [viewControllers removeLastObject];
                
                DrinkListViewController *viewController = [self.drinksStoryboard instantiateViewControllerWithIdentifier:@"DrinkListViewController"];
                [viewController setDrinkList:drinkListModel];
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

#pragma mark - AdjustDrinkSliderListSliderViewControllerDelegate

- (void)adjustDrinkSliderListSliderViewControllerDelegate:(AdjustDrinkListSliderViewController *)viewController createdDrinkList:(DrinkListModel *)drinkList {
    [self showAdjustSlidersView:NO animated:YES];
    
    [self goToDrinkList:drinkList createdWithAdjustSliders:YES atSpot:_spot];
}

- (void)adjustDrinkSliderListSliderViewControllerDelegateClickClose:(AdjustDrinkListSliderViewController *)viewController {
    [self showAdjustSlidersView:NO animated:YES];
}

#pragma mark - FooterViewControllerDelegate

- (BOOL)footerViewController:(FooterViewController *)footerViewController clickedButton:(FooterViewButtonType)footerViewButtonType {
    if (FooterViewButtonRight == footerViewButtonType) {
        [self showInfo:TRUE];
        return YES;
    }
    return NO;
}

#pragma mark - Actions

- (IBAction)onClickChooseSpot:(id)sender {
    [self goToCheckin:self];
}

- (IBAction)onScreenTap:(id)sender {
    [self hideInfo:TRUE];
}

#pragma mark - Private

- (void)hideInfo:(BOOL)animated {
    CGFloat duration = animated ? 0.25f : 0.0f;
    
    UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState;
    [UIView animateWithDuration:duration delay:0.0 options:options animations:^{
        _viewInfo.alpha = 0.0f;
    } completion:^(BOOL finished) {
        _viewInfo.hidden = TRUE;
    }];
}

- (void)showInfo:(BOOL)animated {
    [self.view bringSubviewToFront:_viewInfo];
    _viewInfo.hidden = FALSE;
    
    CGFloat duration = animated ? 0.25f : 0.0f;
    UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState;
    [UIView animateWithDuration:duration delay:0.0 options:options animations:^{
        _viewInfo.alpha = 1.0f;
    } completion:^(BOOL finished) {
    }];
}

- (BOOL)hasBeenSeenBefore {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kDrinkListsMenuViewControllerViewedAlready];
}

- (void)updateView {
    
    [_viewLocation setHidden:(_spot != nil)];
    [_viewSpot setHidden:(_spot == nil)];
    
    NSString *title = _spot.name;
    [_btnSpot setTitle:title forState:UIControlStateNormal];
    [_btnSpot setImage:[UIImage imageNamed:@"img_arrow_east.png"] forState:UIControlStateNormal];
    CGFloat textWidth = [self widthForString:title font:_btnSpot.titleLabel.font maxWidth:CGFLOAT_MAX];
    _btnSpot.imageEdgeInsets = UIEdgeInsetsMake(0, (textWidth + 10), 0, 0);
    _btnSpot.titleEdgeInsets = UIEdgeInsetsMake(0, -7, 0, 0);
}

- (void)fetchDrinkLists {
    _updatedSearchNeeded = FALSE;
    
    if (_location == nil && _spot == nil) {
        return;
    }
    
//    [self showHUD:@"Fetching drinklists"];
    NSMutableArray *promises = [NSMutableArray array];
    
    if (_location != nil) {
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
    }
    
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
        
    }];
    
}

- (void)showAdjustSlidersView:(BOOL)show animated:(BOOL)animated {
    
    if (show == YES) {
        
        // Sets currently selected location inthe adjust spotlist slider view controoler
        [_adjustDrinkListSliderViewController setLocation:_location];
        [_adjustDrinkListSliderViewController setSpot:_spot];
        [_adjustDrinkListSliderViewController resetForm];
        
        [_containerAdjustSliders setHidden:NO];
        
        CGRect frame = _containerAdjustSliders.frame;
        frame.origin.y = CGRectGetMinY(_tblMenu.frame);
        
        [UIView animateWithDuration:( animated ? 0.35f : 0.0f ) animations:^{
            [_containerAdjustSliders setFrame:frame];
        } completion:^(BOOL finished) {
            [_adjustDrinkListSliderViewController openSection:0];
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
        if (_sectionHeader0 == nil) {
            _sectionHeader0 = [self instantiateSectionHeaderView];
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
            _sectionHeader1 = [self instantiateSectionHeaderView];
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
            _sectionHeader2 = [self instantiateSectionHeaderView];
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
