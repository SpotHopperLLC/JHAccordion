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
#import "UIAlertView+Block.h"

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
#import "SpotTypeModel.h"
#import "SpotListModel.h"
#import "UserModel.h"

#import "TellMeMyLocation.h"

#import "JHAccordion.h"
#import <Promises/Promise.h>

#import <CoreLocation/CoreLocation.h>

@interface SpotListsMenuViewController ()<UITableViewDataSource, UITableViewDelegate, FindSimilarViewControllerDelegate, AdjustSliderListSliderViewControllerDelegate, JHAccordionDelegate, SHButtonLatoLightLocationDelegate>

@property (weak, nonatomic) IBOutlet UIView *viewInfo;
@property (weak, nonatomic) IBOutlet UIImageView *imgWhiteScreen;
@property (weak, nonatomic) IBOutlet UILabel *lblInfo;

@property (weak, nonatomic) IBOutlet UIView *containerAdjustSliders;

@property (weak, nonatomic) IBOutlet UILabel *lblNear;
@property (weak, nonatomic) IBOutlet SHButtonLatoLightLocation *btnLocation;

@property (weak, nonatomic) IBOutlet UITableView *tblMenu;

@property (nonatomic, strong) JHAccordion *accordion;

@property (nonatomic, strong) SectionHeaderView *sectionHeader0;
@property (nonatomic, strong) SectionHeaderView *sectionHeader1;
@property (nonatomic, strong) SectionHeaderView *sectionHeader2;

@property (nonatomic, strong) AdjustSpotListSliderViewController *adjustSpotListSliderViewController;

@property (nonatomic, strong) UIStoryboard *commonStoryboard;

@property (nonatomic, strong) CLLocation *location;

@property (nonatomic, strong) NSArray *featuredSpotLists;
@property (nonatomic, strong) NSArray *mySpotLists;

@property (nonatomic, strong) NSArray *featuredSpotListsUpdate;
@property (nonatomic, strong) NSArray *mySpotListsUpdate;

@property (nonatomic, assign) BOOL triedLoadingAfterFailure;

@end

@implementation SpotListsMenuViewController {
    BOOL _updatedSearchNeeded;
    BOOL _isUpdatingTableView;
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
    [self setTitle:@"Spotlists"];
    
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

    _imgWhiteScreen.image = [self whiteScreenImageForFrame:_imgWhiteScreen.frame];
    [self changeLabelToLatoLight:_lblInfo];
    CGRect frame = _lblInfo.frame;
    frame.size.height = [self heightForString:_lblInfo.text font:_lblInfo.font maxWidth:CGRectGetWidth(_lblInfo.frame)];
    _lblInfo.frame = frame;
    
    _updatedSearchNeeded = TRUE;
    
    [self hideInfo:FALSE];
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
    if (_location == nil) {
        // Locations
        [_btnLocation setDelegate:self];
        [_btnLocation updateWithLastLocation];
        // place the image after the text
        NSString *text = [_btnLocation titleForState:UIControlStateNormal];
        CGFloat textWidth = [self widthForString:text font:_btnLocation.titleLabel.font maxWidth:CGFLOAT_MAX];
        _btnLocation.imageEdgeInsets = UIEdgeInsetsMake(0, (textWidth + 15), 0, 0);
        _btnLocation.titleEdgeInsets = UIEdgeInsetsMake(0, -7, 0, 0);
    } else {
        [self fetchSpotLists];
    }
    
    [_lblNear setFont:[UIFont fontWithName:@"Lato-Regular" size:_lblNear.font.pointSize]];
    
    if (_updatedSearchNeeded) {
        _location = [TellMeMyLocation lastLocation];
        [_adjustSpotListSliderViewController setLocation:_location];
        [self fetchSpotLists];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if ([[ClientSessionManager sharedClient] hasSeenSpotlists] == NO) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self createSpotlistWithSliders];
        });
        
        [[ClientSessionManager sharedClient] setHasSeenSpotlists:TRUE];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // Setting has seen before
    if ([self hasBeenSeenBefore] == NO) {
        
        // Sets has seen before
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kSpotListsMenuViewControllerViewedAlready
         ];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString * segueName = segue.identifier;
    if ([segueName isEqualToString:@"EmbedAdjustSpotListSliderViewController"]) {
        _adjustSpotListSliderViewController = (AdjustSpotListSliderViewController*)[segue destinationViewController];
        [_adjustSpotListSliderViewController setDelegate:self];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Tracking

- (NSString *)screenName {
    return @"Spotlists";
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Don't show my reviews if no logged in
    if ([self isShowingMySpots]) {
        return 3;
    }
    else {
        return 2;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0 || section == 1) {
        return 0;
    } else if (section == 2) {
        return _mySpotLists.count;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 2) {
        ListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ListCell" forIndexPath:indexPath];
        
        SpotListModel *spotList = [_mySpotLists objectAtIndex:indexPath.row];
        [cell.lblName setText:spotList.name];
        
        return cell;
    }
    
    return nil;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 2) {
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
    if (section < 2) {
        return 65.0f;
    } else if ( section == 2 && [self hasBeenSeenBefore] == YES && _mySpotLists.count > 0 ) {
        return 65.0f;
    }
    
    return 0.0f;
}

#pragma mark - JHAccordionDelegate

- (void)accordion:(JHAccordion *)accordion openingSection:(NSInteger)section {
    if (section == 2) [_sectionHeader2 setSelected:YES];
}

- (void)accordion:(JHAccordion *)accordion closingSection:(NSInteger)section {
    if (section == 2) [_sectionHeader2 setSelected:NO];
}

- (void)accordion:(JHAccordion *)accordion openedSection:(NSInteger)section {
    
}

- (void)accordion:(JHAccordion *)accordion closedSection:(NSInteger)section {
    [_tblMenu reloadData];
}

- (void)accordion:(JHAccordion*)accordion willUpdateTableView:(UITableView *)tableView {
    _isUpdatingTableView = TRUE;
}

- (void)accordion:(JHAccordion*)accordion didUpdateTableView:(UITableView *)tableView {
    _isUpdatingTableView = FALSE;
    [self updateFeaturedSpotlists];
    [self updateMySpotlists];
}

#pragma mark - SHButtonLatoLightLocationDelegate

- (void)locationRequestsUpdate:(SHButtonLatoLightLocation *)button location:(LocationChooserViewController *)viewController {
    SHNavigationController *navController = [[SHNavigationController alloc] initWithRootViewController:viewController];
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)locationUpdate:(SHButtonLatoLightLocation *)button location:(CLLocation *)location name:(NSString *)name {
    _updatedSearchNeeded = TRUE;
}

- (void)locationDidChooseLocation:(CLLocation *)location {
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
    
    // Cannot create spoitlist if no average review - so prompt to create review
    if (spot.averageReview == nil) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Reviews" message:@"This spot doesn't have any reviews. Would you like to create one?" delegate:nil cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                [self goToNewReviewForSpot:spot];
            }
        }];
        
        return;
    }
    
    [self showHUD:@"Creating spotlist"];
    [spot getSpot:nil success:^(SpotModel *spotModel, JSONAPI *jsonApi) {
        
        NSNumber *latitude = [NSNumber numberWithFloat:_location.coordinate.latitude];
        NSNumber *longitude = [NSNumber numberWithFloat:_location.coordinate.longitude];
        
        // If location has no chooses a location, default to spots location
        if (_location == nil) {
            latitude = spotModel.latitude;
            longitude = spotModel.longitude;
        }
        
        [SpotListModel postSpotList:[NSString stringWithFormat:@"Similar to %@", spotModel.name] spotId:spotModel.ID spotTypeId:spotModel.spotType.ID latitude:latitude longitude:longitude sliders:spot.averageReview.sliders successBlock:^(SpotListModel *spotListModel, JSONAPI *jsonApi) {
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

#pragma mark - FooterViewControllerDelegate

- (BOOL)footerViewController:(FooterViewController *)footerViewController clickedButton:(FooterViewButtonType)footerViewButtonType {
    if (FooterViewButtonRight == footerViewButtonType) {
        [self showInfo:TRUE];
        return YES;
    }
    return NO;
}

#pragma mark - Actions

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

- (BOOL)isShowingMySpots {
    return [ClientSessionManager sharedClient].isLoggedIn;
}

- (BOOL)hasBeenSeenBefore {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kSpotListsMenuViewControllerViewedAlready];
}

- (void)fetchSpotLists {
    _updatedSearchNeeded = FALSE;
    
    if (_location == nil) {
        return;
    }
    
//    [self showHUD:@"Fetching spot lists"];
    NSMutableArray *promises = [NSMutableArray array];
    
    NSDictionary *params = @{
                             kSpotListModelQueryParamLat : [NSNumber numberWithFloat:_location.coordinate.latitude],
                             kSpotListModelQueryParamLng : [NSNumber numberWithFloat:_location.coordinate.longitude]
                             };
    
    /*
     * Featured spot lists
     */
    Promise *promiseFeaturedSpotLists = [SpotListModel getFeaturedSpotLists:params success:^(NSArray *spotListModels, JSONAPI *jsonApi) {
        _featuredSpotListsUpdate = [spotListModels sortedArrayUsingComparator:^NSComparisonResult(SpotListModel* obj1, SpotListModel* obj2) {
            return [obj1.name caseInsensitiveCompare:obj2.name];
        }];
        [self updateFeaturedSpotlists];
    } failure:^(ErrorModel *errorModel) {
        
    }];
    [promises addObject:promiseFeaturedSpotLists];
    
    /*
     * My spot lists
     */
    if ([ClientSessionManager sharedClient].isLoggedIn == YES) {
        UserModel *user = [ClientSessionManager sharedClient].currentUser;
        Promise *promiseMySpotLists = [user getSpotLists:nil success:^(NSArray *spotListsModels, JSONAPI *jsonApi) {
            _mySpotListsUpdate = [spotListsModels sortedArrayUsingComparator:^NSComparisonResult(SpotListModel* obj1, SpotListModel* obj2) {
                return [obj1.name caseInsensitiveCompare:obj2.name];
            }];
            [self updateMySpotlists];
        } failure:^(ErrorModel *errorModel) {
            
        }];
        [promises addObject:promiseMySpotLists];
    }
    
    /*
     * When
     */
    __block BOOL failed = NO;
    [When when:promises then:^{
        
    } fail:^(id error) {
        failed = YES;
    } always:^{
        
        // Reload table and hide HUD
        [_tblMenu reloadData];
        [self hideHUD];
        
        // Checks so see if a failure had happened
        if (failed == YES && _triedLoadingAfterFailure == NO) {
            _triedLoadingAfterFailure = YES;
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Failed to load spotlists" message:@"Would you like to try loading again?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
            [alertView showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
                if (buttonIndex == 1) {
                    [self fetchSpotLists];
                }
            }];
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
        frame.origin.y = CGRectGetMinY(_tblMenu.frame);
        
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
            [_sectionHeader0 setIconImage:[UIImage imageNamed:@"icon_sliders"]];
            
            UIFont *font = _sectionHeader0.lblText.font;
            [_sectionHeader0.lblText setFont:[UIFont fontWithName:font.fontName size:15.0]];
            CGFloat fontSize = _sectionHeader0.lblText.font.pointSize;
            [_sectionHeader0.lblText setText:@"Search by Sliders" withFont:[UIFont fontWithName:@"Lato-Regular" size:fontSize] onString:@"Sliders"];
            
            [_sectionHeader0.btnBackground setTag:section];
            [_sectionHeader0.btnBackground addTarget:self action:@selector(onClickSection:) forControlEvents:UIControlEventTouchUpInside];
            
            // point arrow right
            _sectionHeader0.imgArrow.transform = CGAffineTransformMakeRotation(-M_PI/2);
        }
        
        return _sectionHeader0;
    } else if (section == 1) {
        if (_sectionHeader1 == nil) {
            _sectionHeader1 = [self instantiateSectionHeaderView];
            [_sectionHeader1 setIconImage:[UIImage imageNamed:@"icon_search"]];
            
            UIFont *font = _sectionHeader1.lblText.font;
            [_sectionHeader1.lblText setFont:[UIFont fontWithName:font.fontName size:15.0]];
            CGFloat fontSize = _sectionHeader1.lblText.font.pointSize;
            [_sectionHeader1.lblText setText:@"Name a favorite, find similar" withFont:[UIFont fontWithName:@"Lato-Regular" size:fontSize] onStrings:@[@"favorite", @"similar"]];
            
            [_sectionHeader1.btnBackground setTag:section];
            [_sectionHeader1.btnBackground addTarget:self action:@selector(onClickSection:) forControlEvents:UIControlEventTouchUpInside];
            
            // point arrow right
            _sectionHeader1.imgArrow.transform = CGAffineTransformMakeRotation(-M_PI/2);
        }
        
        return _sectionHeader1;
    } else if (section == 2) {
        if (_sectionHeader2 == nil) {
            
            _sectionHeader2 = [self instantiateSectionHeaderView];
            
            UIFont *font = _sectionHeader2.lblText.font;
            [_sectionHeader2.lblText setFont:[UIFont fontWithName:font.fontName size:15.0]];
            
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

- (void)onClickSection:(UIView *)view {
    if (view.tag == 0) {
        [self createSpotlistWithSliders];
    }
    else if (view.tag == 1) {
        [self createSpotlistForSimilar];
    }
}

- (void)createSpotlistWithSliders {
    if ([ClientSessionManager sharedClient].isLoggedIn == NO) {
        [self showAlert:@"Login Required" message:@"Cannot create a spotlist without logging in"];
        return;
    }
    
    [self showAdjustSlidersView:YES animated:YES];
}

- (void)createSpotlistForSimilar {
    if ([ClientSessionManager sharedClient].isLoggedIn == NO) {
        [self showAlert:@"Login Required" message:@"Cannot create a spotlist without logging in"];
        return;
    }
    
    [self goToFindSimilarSpots:self];
}

- (void)updateFeaturedSpotlists {
    if (!_isUpdatingTableView && _featuredSpotLists) {
        _featuredSpotLists = _featuredSpotListsUpdate;
        _featuredSpotListsUpdate = nil;
        [_tblMenu reloadData];
    }
    else if (_isUpdatingTableView && _featuredSpotLists) {
        // update later when the table may be done updating
        [self performSelector:@selector(updateFeaturedSpotlists) withObject:nil afterDelay:0.25];
    }
}

- (void)updateMySpotlists {
    if (!_isUpdatingTableView && _mySpotListsUpdate) {
        _mySpotLists = _mySpotListsUpdate;
        _mySpotListsUpdate = nil;
        [_tblMenu reloadData];
     }
    else if (_isUpdatingTableView && _mySpotListsUpdate) {
        // update later when the table may be done updating
        [self performSelector:@selector(updateMySpotlists) withObject:nil afterDelay:0.25];
    }
}

@end
