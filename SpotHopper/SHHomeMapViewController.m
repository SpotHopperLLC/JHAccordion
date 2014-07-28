//
//  SHHomeMapViewController.m
//  SpotHopper
//
//  Created by Brennan Stehling on 5/13/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "SHHomeMapViewController.h"

#import "UIViewController+Navigator.h"
#import "JHSidebarViewController.h"
#import "UIView+AutoLayout.h"
#import "SHStyleKit.h"
#import "SHStyleKit+Additions.h"
#import "SVPulsingAnnotationView.h"

#import "SHSidebarViewController.h"
#import "SHLocationMenuBarViewController.h"
#import "SHHomeNavigationViewController.h"
#import "SHSlidersSearchViewController.h"
#import "SHMapOverlayCollectionViewController.h"
#import "SHMapFooterNavigationViewController.h"
#import "SHSpotProfileViewController.h"
#import "SHDrinkProfileViewController.h"
#import "SHLocationPickerViewController.h"
#import "SHGlobalSearchViewController.h"
#import "SearchViewController.h"
#import "ShareViewController.h"

#import "SHNotifications.h"

#import "SpotAnnotationCallout.h"
#import "MatchPercentAnnotation.h"
#import "MatchPercentAnnotationView.h"
#import "SpotCalloutView.h"

#import "SHButtonLatoBold.h"

#import "TellMeMyLocation.h"
#import "Tracker.h"

#import "UserModel.h"
#import "SpotModel.h"
#import "SpotTypeModel.h"
#import "DrinkModel.h"
#import "DrinkTypeModel.h"
#import "DrinkSubTypeModel.h"
#import "SliderModel.h"
#import "SliderTemplateModel.h"
#import "SpotListRequest.h"
#import "SpotListModel.h"
#import "DrinkListRequest.h"
#import "DrinkListModel.h"
#import "ErrorModel.h"
#import "SpotTypeModel.h"
#import "AverageReviewModel.h"
#import "MenuModel.h"
#import "MenuItemModel.h"
#import "PriceModel.h"

#import "UIImage+BlurredFrame.h"
#import "UIImage+ImageEffects.h"

#import "UIAlertView+Block.h"
#import "TTTAttributedLabel.h"
#import "TTTAttributedLabel+QuickFonting.h"

#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <QuartzCore/QuartzCore.h>

#define kDefaultTitle @"What do you feel like?"
#define kTodaysSpecialsTitle @"Today's Specials"

#define kTagSearchTextField 501

#define kMeterToMile 0.000621371f
#define kDebugAnnotationViewPositions NO

#define kCollectionContainerViewHeight 200.0f
#define kCollectionViewHeight 150.0f
#define kFooterNavigationViewHeight 50.0f

#define kBlurRadius 2.5f
#define kBlurSaturation 1.5f

#define kModalAnimationDuration 0.35f

#define kAlreadyGaveProps @"alreadyGaveProps"

#define kMapPadding 14000.0f

#define kEnteredBackgroundDateKey @"EnteredBackgroundDate"

#define kLastRepositioningToDeviceLocationKey @"LastRepositioningToDeviceLocation"

#define kLastSelectedLocationKey @"LastSelectedLocation"

#ifndef NDEBUG
#define kResetCooldownPeriodInSeconds 30
#else
#define kResetCooldownPeriodInSeconds 1200
#endif

NSString* const HomeMapToSpotProfile = @"HomeMapToSpotProfile";
NSString* const HomeMapToDrinkProfile = @"HomeMapToDrinkProfile";

@interface SHHomeMapViewController ()
    <SHSidebarDelegate,
    SHLocationMenuBarDelegate,
    SHHomeNavigationDelegate,
    SHMapOverlayCollectionDelegate,
    SHMapFooterNavigationDelegate,
    SHSpotsCollectionViewManagerDelegate,
    SHSlidersSearchDelegate,
    SHLocationPickerDelegate,
    SearchViewControllerDelegate,
    SpotCalloutViewDelegate,
    ShareViewControllerDelegate,
    SHGlobalSearchViewControllerDelegate,
    UITextFieldDelegate,
    MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *btnLeft;
@property (weak, nonatomic) IBOutlet UIButton *btnRight;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIView *containerView;

@property (readonly, nonatomic) CGFloat topEdgePadding;
@property (readonly, nonatomic) CGFloat bottomEdgePadding;

@property (weak, nonatomic) UIView *blurredView;
@property (weak, nonatomic) UIImageView *blurredImageView;
@property (weak, nonatomic) IBOutlet SHButtonLatoBold *btnUpdateSearchResults;

@property (strong, nonatomic) SHSidebarViewController *mySideBarViewController;
@property (strong, nonatomic) SHLocationMenuBarViewController *locationMenuBarViewController;
@property (strong, nonatomic) SHHomeNavigationViewController *homeNavigationViewController;
@property (strong, nonatomic) SHMapOverlayCollectionViewController *mapOverlayCollectionViewController;
@property (strong, nonatomic) SHMapFooterNavigationViewController *mapFooterNavigationViewController;
@property (strong, nonatomic) SHSlidersSearchViewController *slidersSearchViewController;
@property (strong, nonatomic) SHGlobalSearchViewController *globalSearchViewController;

@property (weak, nonatomic) NSLayoutConstraint *sideBarRightEdgeConstraint;
@property (weak, nonatomic) NSLayoutConstraint *blurredViewHeightConstraint;
@property (weak, nonatomic) NSLayoutConstraint *slidersSearchViewTopConstraint;

@property (weak, nonatomic) NSLayoutConstraint *homeNavigationViewBottomConstraint;
@property (weak, nonatomic) NSLayoutConstraint *collectionContainerViewBottomConstraint;

@property (weak, nonatomic) UIView *collectionContainerView;

@property (weak, nonatomic) IBOutlet UIView *areYouHerePromptView;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *areYouHerePromptLabel;
@property (weak, nonatomic) IBOutlet UIButton *areYouHereYesButton;
@property (weak, nonatomic) IBOutlet UIButton *areYouHereNoButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *areYouHereViewBottomConstraint;

@property (weak, nonatomic) IBOutlet UIView *statusView;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *statusBottomConstraint;

@property (weak, nonatomic) IBOutlet UIView *searchThisAreaView;
@property (weak, nonatomic) IBOutlet UIButton *searchThisAreaButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchThisAreaBottomConstraint;

@property (nonatomic, weak) MKAnnotationView *selectedAnnotationView;
@property (nonatomic, weak) UIView *calloutView;

@property (assign, nonatomic) SHMode mode;

@property (strong, nonatomic) SpotListModel *spotListModel;
@property (strong, nonatomic) NSArray *specialsSpotModels;
@property (strong, nonatomic) DrinkListModel *drinkListModel;
@property (strong, nonatomic) SpotModel *selectedSpot;
@property (strong, nonatomic) SpotModel *scopedSpot;
@property (readonly, nonatomic) BOOL isScopedToSpot;
@property (strong, nonatomic) SpotListRequest *spotListRequest;
@property (strong, nonatomic) DrinkListRequest *drinkListRequest;
@property (strong, nonatomic) DrinkModel *selectedDrink;

@property (strong, nonatomic) NSArray *spotsForDrink;

@property (assign, nonatomic) NSUInteger currentIndex;
@property (strong, nonatomic) NSArray *nearbySpots;

@property (strong, nonatomic) NSDate *lastAreYouHerePrompt;

@property (assign, nonatomic, getter = isRepositioningMap) BOOL repositioningMap;

@property (strong, nonatomic) NSDate *enteredBackgroundDate;
@property (strong, nonatomic) NSDate *lastRepositioningToDeviceLocationDate;
@property (strong, nonatomic) CLLocation *lastSelectedLocation;

@end

@implementation SHHomeMapViewController {
    CLLocation *_currentLocation;
    BOOL _doNotMoveMap;
    BOOL _isShowingSearchView;
    BOOL _isOverlayAnimating;
    BOOL _isValidLocation;
    NSInteger _repositioningMapCount;
}

#pragma mark - View Lifecyle
#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad:@[kDidLoadOptionsNoBackground]];
    
    NSAssert(self.navigationController.sidebarViewController, @"Sidebar controller must be defined");
    NSAssert(self.navigationController.sidebarViewController.rightViewController, @"Right VC on sidebar must be defined");
    
    self.mySideBarViewController = (SHSidebarViewController *)self.navigationController.sidebarViewController.rightViewController;
    self.mySideBarViewController.delegate = self;
    
    NSAssert(self.mySideBarViewController.delegate == self, @"My sidebar delegate must be self");
    NSAssert([self.mySideBarViewController.delegate isKindOfClass:[SHHomeMapViewController class]], @"My sidebar delegate must be this class");
    
    self.locationMenuBarViewController = [[self spotHopperStoryboard] instantiateViewControllerWithIdentifier:@"SHLocationMenuBarViewController"];
    self.locationMenuBarViewController.delegate = self;
    self.homeNavigationViewController = [[self spotHopperStoryboard] instantiateViewControllerWithIdentifier:@"SHHomeNavigationViewController"];
    self.homeNavigationViewController.delegate = self;
    
    self.mapOverlayCollectionViewController = [[self spotHopperStoryboard] instantiateViewControllerWithIdentifier:@"SHMapOverlayCollectionViewController"];
    self.mapOverlayCollectionViewController.delegate = self;
    self.mapFooterNavigationViewController = [[self spotHopperStoryboard] instantiateViewControllerWithIdentifier:@"SHMapFooterNavigationViewController"];
    self.mapFooterNavigationViewController.delegate = self;
    
    self.slidersSearchViewController = [[self spotHopperStoryboard] instantiateViewControllerWithIdentifier:@"SHSlidersSearchViewController"];
    self.slidersSearchViewController.delegate = self;
    
    self.globalSearchViewController = [[self spotHopperStoryboard] instantiateViewControllerWithIdentifier:@"SHGlobalSearchViewController"];
    self.globalSearchViewController.delegate = self;
    
    self.title = @"New Search";
    
    [self repositionOnCurrentDeviceLocation:NO];
    
    self.mapView.showsUserLocation = TRUE;
    
    self.view.backgroundColor = [UIColor clearColor];

    [self hideStatus:FALSE withCompletionBlock:nil];
    [self hideAreYouHerePrompt:FALSE withCompletionBlock:nil];
    
    [self observeNotifications];

    // pre-cache the lists
    if ([UserModel isLoggedIn]) {
        [SpotListModel fetchMySpotLists];
        [DrinkListModel fetchMyDrinkLists];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setNeedsStatusBarAppearanceUpdate];
    
    [self.view sendSubviewToBack:self.containerView];
    
    [self styleBars];
    [self styleAreYouHerePrompt];
    [self styleSearchThisArea];
    
    [self embedChildViewControllers];
    
    [self hideSearch:FALSE withCompletionBlock:nil];
    [self hideSearchThisArea:FALSE withCompletionBlock:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    // update location name again once the map settles
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self updateLocationName];
    });
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[SHSpotProfileViewController class]]) {
        SHSpotProfileViewController *vc = segue.destinationViewController;
        NSAssert(self.selectedSpot, @"Selected Spot should be defined");
        vc.spot = self.selectedSpot;
    }
    
    else if ([segue.destinationViewController isKindOfClass:[SHDrinkProfileViewController class]]) {
        SHDrinkProfileViewController *vc = segue.destinationViewController;
        NSAssert(self.selectedDrink, @"Selected Spot should be defined");
        vc.drink = self.selectedDrink;
    }
}

#pragma mark - Properties
#pragma mark -

- (void)setRepositioningMap:(BOOL)repositioningMap {
    _repositioningMapCount += repositioningMap ? 1 : -1;
}

- (BOOL)isRepositioningMap {
    return _repositioningMapCount > 0;
}

- (NSDate *)enteredBackgroundDate {
    NSDate *date = (NSDate *)[[NSUserDefaults standardUserDefaults] objectForKey:kEnteredBackgroundDateKey];
    if (!date) {
        return [NSDate distantPast];
    }
    return date;
}

- (void)setEnteredBackgroundDate:(NSDate *)date {
    [[NSUserDefaults standardUserDefaults] setObject:date forKey:kEnteredBackgroundDateKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSDate *)lastRepositioningToDeviceLocationDate {
    NSDate *date = (NSDate *)[[NSUserDefaults standardUserDefaults] objectForKey:kLastRepositioningToDeviceLocationKey];
    if (!date) {
        return [NSDate distantPast];
    }
    return date;
}

- (void)setLastRepositioningToDeviceLocationDate:(NSDate *)date {
    [[NSUserDefaults standardUserDefaults] setObject:date forKey:kLastRepositioningToDeviceLocationKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (CLLocation *)lastSelectedLocation {
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:kLastSelectedLocationKey];
    if (dict) {
        CLLocation *date = [[CLLocation alloc] initWithLatitude:[dict[@"lat"] floatValue] longitude:[dict[@"long"] floatValue]];
        return date;
    }
    
    return nil;
}

- (void)setLastSelectedLocation:(CLLocation *)location {
    NSDictionary *dict = @{
                           @"lat" : [NSNumber numberWithFloat:location.coordinate.latitude],
                           @"long" : [NSNumber numberWithFloat:location.coordinate.longitude]
                          };
    
    [[NSUserDefaults standardUserDefaults] setObject:dict forKey:kLastSelectedLocationKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - View Management
#pragma mark -

- (void)embedChildViewControllers {
    if (!self.locationMenuBarViewController.view.superview) {
        [self embedViewController:self.locationMenuBarViewController intoView:self.view placementBlock:^(UIView *view) {
            [view pinToSuperviewEdges:JRTViewPinTopEdge inset:0.0f usingLayoutGuidesFrom:self];
            [view pinToSuperviewEdges:JRTViewPinLeftEdge | JRTViewPinRightEdge inset:0.0];
            [view constrainToHeight:40.0f];
        }];
        
        // TODO: fix the shadow effect
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
//            [self addShadowToView:self.locationMenuBarViewController.view];
//        });
    }
    
    if (!self.homeNavigationViewController.view.superview) {
        [self embedViewController:self.homeNavigationViewController intoView:self.view placementBlock:^(UIView *view) {
            NSArray *bottomConstaints = [view pinToSuperviewEdges:JRTViewPinBottomEdge inset:0.0f usingLayoutGuidesFrom:self];
            NSAssert(bottomConstaints.count == 1, @"There should be only 1 bottom constraint.");
            self.homeNavigationViewBottomConstraint = bottomConstaints[0];
            [view pinToSuperviewEdges:JRTViewPinLeftEdge | JRTViewPinRightEdge inset:0.0];
            [view constrainToHeight:180.0f];
            [self addShadowToView:view];
        }];
    }

    if (!self.collectionContainerView && !self.mapOverlayCollectionViewController.view.superview && !self.mapFooterNavigationViewController.view.superview) {
        UIView *collectionContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), kCollectionContainerViewHeight)];
        collectionContainerView.translatesAutoresizingMaskIntoConstraints = NO;
        collectionContainerView.backgroundColor = [UIColor clearColor];
        [self addShadowToView:collectionContainerView];
        
        [self.view addSubview:collectionContainerView];
        NSArray *bottomConstaints = [collectionContainerView pinToSuperviewEdges:JRTViewPinBottomEdge inset:0.0f usingLayoutGuidesFrom:self];
        NSAssert(bottomConstaints.count == 1, @"There should be only 1 bottom constraint.");
        self.collectionContainerViewBottomConstraint = bottomConstaints[0];
        [collectionContainerView pinToSuperviewEdges:JRTViewPinLeftEdge | JRTViewPinRightEdge inset:0.0];
        [collectionContainerView constrainToHeight:kCollectionContainerViewHeight];
        self.collectionContainerView = collectionContainerView;
        
        [self embedViewController:self.mapOverlayCollectionViewController intoView:self.collectionContainerView placementBlock:^(UIView *view) {
            [view pinToSuperviewEdges:JRTViewPinBottomEdge inset:kFooterNavigationViewHeight];
            [view pinToSuperviewEdges:JRTViewPinLeftEdge | JRTViewPinRightEdge inset:0.0];
            [view constrainToHeight:kCollectionViewHeight];
        }];
    
        [self embedViewController:self.mapFooterNavigationViewController intoView:self.collectionContainerView placementBlock:^(UIView *view) {
            [view pinToSuperviewEdges:JRTViewPinBottomEdge inset:0.0f];
            [view pinToSuperviewEdges:JRTViewPinLeftEdge | JRTViewPinRightEdge inset:0.0];
            [view constrainToHeight:kFooterNavigationViewHeight];
        }];
        
        [self hideCollectionContainerView:FALSE withCompletionBlock:nil];
    }
    
    if (!self.slidersSearchViewController.view.superview) {
        [self embedViewController:self.slidersSearchViewController intoView:self.containerView placementBlock:^(UIView *view) {
            [view pinToSuperviewEdges:JRTViewPinLeftEdge | JRTViewPinRightEdge inset:0.0f];
            CGFloat height = CGRectGetHeight(self.containerView.frame);
            [view constrainToHeight:height];
            NSArray *topConstraints = [view pinToSuperviewEdges:JRTViewPinTopEdge inset:CGRectGetHeight(self.containerView.frame)];
            NSCAssert(topConstraints.count == 1, @"There should be only 1 constraint for top");
            if (topConstraints.count) {
                NSLayoutConstraint *topConstraint = topConstraints[0];
                self.slidersSearchViewTopConstraint = topConstraint;
            }
        }];
    }
    
    if (!self.globalSearchViewController.view.superview) {
        [self embedViewController:self.globalSearchViewController intoView:self.view placementBlock:^(UIView *view) {
            NSArray *constraints = [view pinToSuperviewEdges:JRTViewPinAllEdges inset:0.0f usingLayoutGuidesFrom:self];
            DebugLog(@"constraints: %@", constraints);
        }];
    }

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        LOG_FRAME(@"global search frame", self.globalSearchViewController.view.frame);
    });
}

- (void)toggleSideBar:(BOOL)animated withCompletionBlock:(void (^)())completionBlock {
    NSAssert(self.navigationController.sidebarViewController.rightViewController == self.mySideBarViewController, @"Sidebar VC must match");
    [self.navigationController.sidebarViewController toggleRightSidebar];
}

- (void)hideSideBar:(BOOL)animated withCompletionBlock:(void (^)())completionBlock {
    [self.mySideBarViewController viewWillDisappear:animated];
    
    [self.navigationController.sidebarViewController toggleRightSidebar];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.45f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        if (completionBlock) {
            completionBlock();
        }
    });
}

- (void)showSideBar:(BOOL)animated withCompletionBlock:(void (^)())completionBlock {
    [self.mySideBarViewController viewWillAppear:animated];
    
    [self.navigationController.sidebarViewController toggleRightSidebar];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.45f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        if (completionBlock) {
            completionBlock();
        }
    });
}

- (void)hideHomeNavigation:(BOOL)animated withCompletionBlock:(void (^)())completionBlock {
    if (!self.searchThisAreaView.hidden) {
        [self hideSearchThisArea:animated withCompletionBlock:nil];
    }
    
    if (!self.statusView.hidden) {
        [self hideStatus:animated withCompletionBlock:nil];
    }
    
    CGFloat duration = animated ? 0.25f : 0.0f;
    UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState;
    [UIView animateWithDuration:duration delay:0.0f usingSpringWithDamping:0.8f initialSpringVelocity:5.f options:options animations:^{
        self.homeNavigationViewBottomConstraint.constant = CGRectGetHeight(self.homeNavigationViewController.view.frame);
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.homeNavigationViewController.view.hidden = TRUE;
        if (completionBlock) {
            completionBlock();
        }
    }];
}

- (void)showHomeNavigation:(BOOL)animated withCompletionBlock:(void (^)())completionBlock {
    self.homeNavigationViewController.view.hidden = FALSE;
    
    CGFloat duration = animated ? 0.25f : 0.0f;
    UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState;
    [UIView animateWithDuration:duration delay:0.0f usingSpringWithDamping:0.8f initialSpringVelocity:5.f options:options animations:^{
        self.homeNavigationViewBottomConstraint.constant = 0.0f;
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        if (completionBlock) {
            completionBlock();
        }
    }];
}

- (void)hideCollectionContainerView:(BOOL)animated withCompletionBlock:(void (^)())completionBlock {
    [self.mapOverlayCollectionViewController viewWillDisappear:animated];

    if (!self.searchThisAreaView.hidden) {
        [self hideSearchThisArea:animated withCompletionBlock:nil];
    }
    
    if (!self.statusView.hidden) {
        [self hideStatus:animated withCompletionBlock:nil];
    }

    CGFloat duration = animated ? 0.25f : 0.0f;
    UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState;
    [UIView animateWithDuration:duration delay:0.0f usingSpringWithDamping:0.8f initialSpringVelocity:10.f options:options animations:^{
        self.collectionContainerViewBottomConstraint.constant = CGRectGetHeight(self.collectionContainerView.frame);
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self.mapOverlayCollectionViewController viewDidDisappear:animated];
        self.collectionContainerView.hidden = TRUE;
        if (completionBlock) {
            completionBlock();
        }
    }];
}

- (void)showCollectionContainerView:(BOOL)animated withCompletionBlock:(void (^)())completionBlock {
    [self.mapOverlayCollectionViewController viewWillAppear:animated];
    
    // set the bottom constraint to 0
    self.collectionContainerView.hidden = FALSE;
    
    CGFloat duration = animated ? 0.25f : 0.0f;
    UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState;
    [UIView animateWithDuration:duration delay:0.0f usingSpringWithDamping:0.8f initialSpringVelocity:10.f options:options animations:^{
        self.collectionContainerViewBottomConstraint.constant = 0.0f;
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self.mapOverlayCollectionViewController viewDidAppear:animated];
        if (completionBlock) {
            completionBlock();
        }
    }];
}

- (void)showSearch:(BOOL)animated withCompletionBlock:(void (^)())completionBlock {
    NSAssert(self.navigationItem, @"Navigation Item is required");
    
//#ifdef kIntegrateDeprecatedScreens
//    SearchViewController *viewController = [[SearchViewController alloc] initWithNibName:@"SearchViewController" bundle:[NSBundle mainBundle]];
//    viewController.delegate = self;
//    [self.navigationController pushViewController:viewController animated:YES];
//
//#else
    
    [self hideBottomViewWithCompletionBlock:nil];
    
    _isShowingSearchView = TRUE;
    
    [self prepareBlurredScreen];
    
    self.blurredView.alpha = 0.0f;
    self.globalSearchViewController.view.alpha = 0.0f;
    self.globalSearchViewController.view.hidden = FALSE;
    
    [self.view bringSubviewToFront:self.globalSearchViewController.view];
    [self.view insertSubview:self.blurredView belowSubview:self.globalSearchViewController.view];
    
    self.blurredViewHeightConstraint.constant = CGRectGetHeight(self.view.frame);
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
    
    UIButton *cancelButton = [self makeButtonWithTitle:@"cancel" target:self action:@selector(searchCancelButtonTapped:)];
    CGRect cancelButtonFrame = cancelButton.frame;
    cancelButtonFrame.origin.x = 248.0f;
    cancelButtonFrame.origin.y = 6.0f;
    cancelButton.frame = cancelButtonFrame;
    // (20 * 2) for leading/trailing minus width of cancel button
    CGFloat textFieldWidth = CGRectGetWidth(self.view.frame) - 40.0f - CGRectGetWidth(cancelButton.frame);
    
    CGRect searchFrame = CGRectMake(16.0f, 7.0f, 30.0f, 30.0f);
    UITextField *searchTextField = [[UITextField alloc] initWithFrame:searchFrame];
    searchTextField.tag = kTagSearchTextField;
    searchTextField.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.1f];
    [SHStyleKit setTextField:searchTextField textColor:SHStyleKitColorMyWhiteColor];
    searchTextField.alpha = 0.1f;
    searchTextField.font = [UIFont fontWithName:@"Lato-Light" size:14.0f];
    searchTextField.tintColor = [[SHStyleKit myWhiteColor] colorWithAlphaComponent:0.75f];
    searchTextField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    searchTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    searchTextField.returnKeyType = UIReturnKeySearch;
    searchTextField.delegate = self;
    
    [searchTextField addTarget:self action:@selector(searchTextFieldEditingChanged:) forControlEvents:UIControlEventEditingChanged];

    // set the left view
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
    UIImageView *leftImageView = [[UIImageView alloc] initWithFrame:CGRectMake(8, 6, 16, 16)];
    leftImageView.alpha = 0.5f;
    [SHStyleKit setImageView:leftImageView withDrawing:SHStyleKitDrawingSearchIcon color:SHStyleKitColorMyWhiteColor];
    [leftView addSubview:leftImageView];
    
    searchTextField.leftView = leftView;
    searchTextField.leftViewMode = UITextFieldViewModeAlways;
    searchTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    searchTextField.layer.cornerRadius = 5.0f;
    searchTextField.clipsToBounds = TRUE;
    
    self.navigationItem.title = nil;
    
    UIBarButtonItem *searchCancelBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
    UIBarButtonItem *searchTextFieldBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:searchTextField];
    
    UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState;
    [UIView animateWithDuration:(animated ? 0.25f : 0.0f) delay:0.0 options:options animations:^{
        [self.navigationItem setLeftBarButtonItem:searchTextFieldBarButtonItem animated:animated];
        [self.navigationItem setRightBarButtonItem:searchCancelBarButtonItem animated:animated];
        searchTextField.alpha = 1.0f;
        searchTextField.frame = CGRectMake(0, 0, textFieldWidth, 30);
        
        self.blurredView.alpha = 1.0f;
        self.globalSearchViewController.view.alpha = 1.0f;
    } completion:^(BOOL finished) {
        searchTextField.placeholder = @"Find spot/drink or similar...";
        [searchTextField becomeFirstResponder];
        if (completionBlock) {
            completionBlock();
        }
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        LOG_FRAME(@"global search frame", self.globalSearchViewController.view.frame);
        DebugLog(@"constraints: %@", self.globalSearchViewController.view.constraints);
    });

    
//#endif
}

- (void)hideSearch:(BOOL)animated withCompletionBlock:(void (^)())completionBlock {
    NSAssert(self.navigationItem, @"Navigation Item is required");
    
    _isShowingSearchView = FALSE;
    UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState;
    [UIView animateWithDuration:(animated ? 0.25f : 0.0f) delay:0.0 options:options animations:^{
        self.blurredView.alpha = 0.0f;
        self.globalSearchViewController.view.alpha = 0.0f;
    } completion:^(BOOL finished) {
        self.blurredViewHeightConstraint.constant = 0;
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
        
        [self.globalSearchViewController clearSearch];
        
        self.globalSearchViewController.view.hidden = TRUE;
        [self restoreNormalNavigationItems:animated withCompletionBlock:completionBlock];
        [self restoreNavigationIfNeeded];
    }];
}

- (void)showSlidersSearch:(BOOL)animated forMode:(SHMode)mode withCompletionBlock:(void (^)())completionBlock {
    [self.slidersSearchViewController viewWillAppear:animated];
    
    _isShowingSearchView = TRUE;
    
    [self prepareBlurredScreen];
    
    UIButton *cancelButton = [self makeButtonWithTitle:@"cancel" target:self action:@selector(searchSlidersCancelButtonTapped:)];
    CGRect cancelButtonFrame = cancelButton.frame;
    cancelButtonFrame.origin.x = 16.0f;
    cancelButtonFrame.origin.y = 6.0f;
    cancelButton.frame = cancelButtonFrame;
    UIBarButtonItem *searchSlidersCancelBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
    
    NSString *title = nil;
    
    switch (mode) {
        case SHModeSpots:
            title = @"Find Spots";
            break;
        case SHModeBeer:
            title = @"Find Beers";
            break;
        case SHModeCocktail:
            title = @"Find Cocktails";
            break;
        case SHModeWine:
            title = @"Find Wines";
            break;
            
        default:
            // do nothing
            break;
    }
    
    [self.view bringSubviewToFront:self.containerView];
    [self.view insertSubview:self.blurredView belowSubview:self.containerView];
    
    UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState;
    [UIView animateWithDuration:(animated ? kModalAnimationDuration : 0.0f) delay:0.1f options:options animations:^{
        self.blurredView.alpha = 1.0f;
        self.blurredViewHeightConstraint.constant = CGRectGetHeight(self.view.frame);
        self.slidersSearchViewTopConstraint.constant = 0.0f;
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
        
        [self.navigationItem setLeftBarButtonItem:searchSlidersCancelBarButtonItem animated:animated];
        [self.navigationItem setRightBarButtonItem:nil animated:animated];
        self.navigationItem.title = title.length ? title : kDefaultTitle;
    } completion:^(BOOL finished) {
        [self refreshBlurredView];
        [self.slidersSearchViewController viewDidAppear:animated];
        
        if (completionBlock) {
            completionBlock();
        }
    }];
}

- (void)hideSlidersSearch:(BOOL)animated forMode:(SHMode)mode withCompletionBlock:(void (^)())completionBlock {
    [self.slidersSearchViewController viewWillDisappear:animated];
    [self updateBlurredView];
    
    _isShowingSearchView = FALSE;
    
    [self restoreNormalNavigationItems:animated withCompletionBlock:^{
        UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState;
        [UIView animateWithDuration:(animated ? kModalAnimationDuration : 0.0f) delay:0.1f options:options animations:^{
            self.blurredView.alpha = 0.0f;
            self.blurredViewHeightConstraint.constant = 0.0f;
            self.slidersSearchViewTopConstraint.constant = CGRectGetHeight(self.view.frame);
            [self.view setNeedsLayout];
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            [self.view sendSubviewToBack:self.containerView];
            [self.slidersSearchViewController viewDidDisappear:animated];
            
            if (completionBlock) {
                completionBlock();
            }
        }];
    }];
}

- (BOOL)isLocationAccurateEnough:(CLLocation *)location {
    return location && CLLocationCoordinate2DIsValid(location.coordinate) &&
        location.horizontalAccuracy < kCLLocationAccuracyHundredMeters;
}

- (void)showAreYouHerePromptForSpot:(SpotModel *)spot animated:(BOOL)animated withCompletionBlock:(void (^)())completionBlock {
    // 1) set the lable with attribututed text
    // 2) set view to not hidden
    // 3) set bottom constraint to be 20 points above the bottom view
    
    // set the label
    UIFont *font = [UIFont fontWithName:@"Lato-Regular" size:self.areYouHerePromptLabel.font.pointSize];
    NSString *name = spot.name;
    NSString *text = [NSString stringWithFormat:@"Are you at %@?", name];
    [self.areYouHerePromptLabel setText:text withFont:font onString:name];
    
    self.areYouHerePromptView.hidden = FALSE;
    
    // set the constraint and finish
    CGRect bottomFrame = [self bottomFrame];
    CGFloat duration = animated ? 0.35f : 0.0f;
    CGFloat distanceFromBottom = CGRectGetHeight(bottomFrame) + self.bottomLayoutGuide.length;
    UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState;
    [UIView animateWithDuration:duration delay:0.0f usingSpringWithDamping:0.75f initialSpringVelocity:10.f options:options animations:^{
        self.areYouHereViewBottomConstraint.constant = distanceFromBottom + 20.0f;
        [self repositionStatusView];
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:duration delay:0.0 options:options animations:^{
            [self repositionStatusView];
        } completion:^(BOOL finished) {
        }];

        if (completionBlock) {
            completionBlock();
        }
    }];
}

- (void)hideAreYouHerePrompt:(BOOL)animated withCompletionBlock:(void (^)())completionBlock {
    // 1) set the bottom constraint to the height of the view
    // 2) complete by setting view to hidden
    
    CGFloat duration = animated ? 0.35f : 0.0f;
    UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState;
    [UIView animateWithDuration:duration delay:0.0f usingSpringWithDamping:0.75f initialSpringVelocity:10.f options:options animations:^{
        self.areYouHereViewBottomConstraint.constant = CGRectGetHeight(self.view.frame);
        [self repositionStatusView];
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.areYouHerePromptView.hidden = TRUE;
        self.areYouHerePromptLabel.text = nil;
        [UIView animateWithDuration:duration delay:0.0 options:options animations:^{
            [self repositionStatusView];
        } completion:^(BOOL finished) {
        }];

        if (completionBlock) {
            completionBlock();
        }
    }];
}

- (void)repositionStatusView {
    //[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(repositionStatusView) object:nil];
    
    CGFloat padding = 8.0f;
    CGFloat lengthFromBottom = 0.0f;
    
//    if (!self.areYouHerePromptView.hidden) {
//        lengthFromBottom = CGRectGetHeight(self.view.frame) - self.areYouHerePromptView.frame.origin.y + padding;
//    }
//    else
    if (!self.searchThisAreaView.hidden) {
        lengthFromBottom = CGRectGetHeight(self.view.frame) - self.searchThisAreaView.frame.origin.y + padding;
    }
    else {
        lengthFromBottom = CGRectGetHeight([self bottomFrame]) + padding;
    }
    
    //[self flashBottomFrame];
    
    self.statusBottomConstraint.constant = lengthFromBottom;
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
    
    //[self performSelector:@selector(repositionStatusView) withObject:nil afterDelay:2.0f];
}

- (void)showStatus:(NSString *)text animated:(BOOL)animated withCompletionBlock:(void (^)())completionBlock {
    // 1) position view above bottom frame and above prompt view
    // 2) hide search this area view if it is visible
    // 3) set the text
    // 4) fade in status view

    // prepare view
    self.statusView.hidden = FALSE;
    
    // hide search this area view if it is visible
    if (!self.searchThisAreaView.hidden) {
        [self hideSearchThisArea:TRUE withCompletionBlock:nil];
    }
    
    // set the text
    if (text.length) {
        self.statusLabel.text = text;
    }
    
    // fade in status view
    CGFloat duration = animated ? 0.75f : 0.0f;
    UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState;
    [UIView animateWithDuration:duration delay:0.0f usingSpringWithDamping:0.75f initialSpringVelocity:10.f options:options animations:^{
        self.statusView.alpha = 1.0f;
        [self repositionStatusView];
    } completion:^(BOOL finished) {
        if (completionBlock) {
            completionBlock();
        }
    }];
}

- (void)hideStatus:(BOOL)animated withCompletionBlock:(void (^)())completionBlock {
    // 1) fade out the status view
    // 2) clear the text from the label
    
    CGFloat duration = animated ? 0.75f : 0.0f;
    UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState;
    [UIView animateWithDuration:duration delay:0.0f usingSpringWithDamping:0.75f initialSpringVelocity:10.f options:options animations:^{
        self.statusView.alpha = 0.0f;
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.statusLabel.text = nil;
        self.statusView.hidden = TRUE;
        self.statusBottomConstraint.constant = CGRectGetHeight(self.view.frame);
        
        if (completionBlock) {
            completionBlock();
        }
    }];
    
}

- (void)showSearchThisArea:(BOOL)animated withCompletionBlock:(void (^)())completionBlock {
    // Note: it will be necessary to hide another view if it is visible while this button is shown
    
    if (![self isDisplayingSearchResults]) {
        return;
    }
    
    if (_isShowingSearchView) {
        // do not show while sliders search view is displayed
        return;
    }
    
    if (!self.areYouHerePromptView.hidden) {
        [self hideAreYouHerePrompt:TRUE withCompletionBlock:nil];
    }
    
    self.searchThisAreaView.alpha = 0.0f;
    self.searchThisAreaView.hidden = FALSE;

    CGRect bottomFrame = [self bottomFrame];
    CGFloat distanceFromBottom = CGRectGetHeight(bottomFrame);
    self.searchThisAreaBottomConstraint.constant = distanceFromBottom + 10.0f;
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
    
    if (!self.statusView.hidden) {
        [self hideStatus:TRUE withCompletionBlock:nil];
    }

    // set the constraint and finish
    CGFloat duration = animated ? 0.75f : 0.0f;
    UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState;
    [UIView animateWithDuration:duration delay:0.0 options:options animations:^{
        self.searchThisAreaView.alpha = 1.0f;
    } completion:^(BOOL finished) {
        
        if (completionBlock) {
            completionBlock();
        }
    }];
}

- (void)hideSearchThisArea:(BOOL)animated withCompletionBlock:(void (^)())completionBlock {
    // set the constraint and finish
    CGFloat duration = animated ? 0.35f : 0.0f;
    UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState;
    [UIView animateWithDuration:duration delay:0.0 options:options animations:^{
        self.searchThisAreaView.alpha = 0.0f;
        [self repositionStatusView];
    } completion:^(BOOL finished) {
        self.searchThisAreaView.hidden = TRUE;
        
        [UIView animateWithDuration:duration delay:0.0 options:options animations:^{
            [self repositionStatusView];
        } completion:^(BOOL finished) {
        }];
        
        if (completionBlock) {
            completionBlock();
        }
    }];
}

#pragma mark - User Actions
#pragma mark -

- (IBAction)sideBarButtonTapped:(id)sender {
    [self showSideBar:TRUE withCompletionBlock:nil];
}

- (IBAction)searchButtonTapped:(id)sender {
    [self showSearch:TRUE withCompletionBlock:nil];
}

- (void)searchTextFieldEditingChanged:(UITextField *)textField {
    [self.globalSearchViewController scheduleSearchWithText:textField.text];
}

- (IBAction)searchThisAreaButtonTapped:(id)sender {
    [self hideSearchThisArea:TRUE withCompletionBlock:^{
        if ([self canSearchAgain]) {
            [self descope];
            [self showHUD:@"Updating for New Location"];
            [self searchAgainWithCompletionBlock:^{
                [self hideHUD];
            }];
        }
    }];
}

- (IBAction)areYouHereYesButtonTapped:(id)sender {
    [self hideAreYouHerePrompt:TRUE withCompletionBlock:nil];
    
    if (self.nearbySpots.count) {
        SpotModel *spot = self.nearbySpots[0];
        [self scopeToSpot:spot];
    }
}

- (IBAction)areYouHereNoButtonTapped:(id)sender {
    [self hideAreYouHerePrompt:TRUE withCompletionBlock:nil];
}

- (IBAction)compassButtonTapped:(id)sender {
    [self repositionOnCurrentDeviceLocation:YES];
    
    if (!self.isScopedToSpot && [self canSearchAgain]) {
        [self showSearchThisArea:TRUE withCompletionBlock:nil];
    }
}

- (IBAction)searchCancelButtonTapped:(id)sender {
    [self hideSearch:TRUE withCompletionBlock:^{
    }];
}

- (IBAction)searchSlidersCancelButtonTapped:(id)sender {
    [self hideSlidersSearch:TRUE forMode:self.mode withCompletionBlock:^{
        if (self.mode == SHModeNone) {
            [self showHomeNavigation:TRUE withCompletionBlock:nil];
        }
        else {
            [self showCollectionContainerView:TRUE withCompletionBlock:nil];
        }
    }];
}

- (IBAction)searchThisAreaSwipedDown:(id)sender {
    UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState;
    [UIView animateWithDuration:0.25f delay:0.0 options:options animations:^{
        self.searchThisAreaBottomConstraint.constant = 0.0f;
    } completion:^(BOOL finished) {
        [self hideSearchThisArea:TRUE withCompletionBlock:nil];
    }];
}

#pragma mark - Keyboard
#pragma mark -

- (void)keyboardWillShow:(NSNotification *)notification {
    LOG_FRAME(@"global search frame", self.globalSearchViewController.view.frame);
    
	CGFloat height = [self getKeyboardHeight:notification forBeginning:TRUE];
	NSTimeInterval duration = [self getKeyboardDuration:notification];
    
    if (_isShowingSearchView) {
        [self.globalSearchViewController adjustForKeyboardHeight:height duration:duration];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        LOG_FRAME(@"global search frame", self.globalSearchViewController.view.frame);
    });
}

- (void)keyboardWillHide:(NSNotification *)notification {
    CGFloat height = 0;
	NSTimeInterval duration = [self getKeyboardDuration:notification];
    
    if (_isShowingSearchView) {
        [self.globalSearchViewController adjustForKeyboardHeight:height duration:duration];
    }
}

#pragma mark - Private
#pragma mark -

- (void)observeNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleApplicationDidEnterBackgroundNotification:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleApplicationWillEnterForegroundNotification:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleGoToHomeMapNotification:)
                                                 name:SHGoToHomeMapNotificationName
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleFetchDrinklistRequestNotification:)
                                                 name:SHFetchDrinklistRequestNotificationName
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleFetchSpotlistRequestNotification:)
                                                 name:SHFetchSpotlistRequestNotificationName
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleDisplayDrinkNotification:)
                                                 name:SHDisplayDrinkNotificationName
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleDisplaySpotNotification:)
                                                 name:SHDisplaySpotNotificationName
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleFindSimilarToDrinkNotification:)
                                                 name:SHFindSimilarToDrinkNotificationName
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleReviewDrinkNotification:)
                                                 name:SHReviewDrinkNotificationName
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleFindSimilarToSpotNotification:)
                                                 name:SHFindSimilarToSpotNotificationName
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleReviewSpotNotification:)
                                                 name:SHReviewSpotNotificationName
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleOpenMenuForSpotNotification:)
                                                 name:SHOpenMenuForSpotNotificationName
                                               object:nil];
}

- (void)resetSearch {
    DebugLog(@"%@", NSStringFromSelector(_cmd));
    self.drinkListRequest = nil;
    self.spotListRequest = nil;
    
    self.drinkListModel = nil;
    self.spotListModel = nil;
    self.specialsSpotModels = nil;
    
    [self hideStatus:TRUE withCompletionBlock:nil];
}

- (BOOL)isDisplayingSearchResults {
    return (self.drinkListModel.drinks.count || self.specialsSpotModels.count || self.spotListModel.spots.count);
}

- (void)restoreTitle {
    if (self.spotListModel.spots.count) {
        self.navigationItem.title = self.spotListModel.name;
    }
    else if (self.drinkListModel.drinks.count) {
        self.navigationItem.title = self.drinkListModel.name;
        
    }
    else if (self.specialsSpotModels.count) {
        self.navigationItem.title = kTodaysSpecialsTitle;
    }
    else {
        self.navigationItem.title = kDefaultTitle;
    }
}

- (void)restoreNavigationIfNeeded {
    if (self.homeNavigationViewController.view.hidden && self.collectionContainerView.hidden) {
        if ([self isDisplayingSearchResults]) {
            [self showCollectionContainerView:TRUE withCompletionBlock:nil];
        }
        else {
            [self showHomeNavigation:true withCompletionBlock:nil];
        }
    }
}

- (void)hideBottomViewWithCompletionBlock:(void (^)())completionBlock {
    if (!self.homeNavigationViewController.view.hidden) {
        [self hideHomeNavigation:TRUE withCompletionBlock:completionBlock];
    }
    else if (!self.collectionContainerView.hidden) {
        [self hideCollectionContainerView:TRUE withCompletionBlock:completionBlock];
    }
    else if (completionBlock) {
        completionBlock();
    }
}

- (void)promptUserToCheckIn {
    if (!self.isScopedToSpot && self.drinkListRequest) {
        // prompt the user to select the nearest spot with a 1 hour period between prompts
        NSTimeInterval seconds = 5000.0f;
        if (self.lastAreYouHerePrompt) {
            seconds = [[NSDate date] timeIntervalSinceDate:self.lastAreYouHerePrompt];
        }
        
        // 20 minutes between prompts (does not account for last spot user selected)
        if (seconds > 1200 && self.nearbySpots.count) {
            SpotModel *nearestSpot = self.nearbySpots[0];
            CLLocation *nearestLocation = [[CLLocation alloc] initWithLatitude:nearestSpot.latitude.floatValue longitude:nearestSpot.longitude.floatValue];
            CLLocationDistance meters = [_currentLocation distanceFromLocation:nearestLocation];
            if (meters < 150) {
                DrinkListRequest *request = [self.drinkListRequest copy];
                request.name = kDrinkListModelDefaultName;
                request.drinkListId = nil;
                request.spotId = nearestSpot.ID;
                request.coordinate = [self visibleMapCenterCoordinate];
                request.radius = [self searchRadius];
                
                [DrinkListModel fetchDrinkListWithRequest:request success:^(DrinkListModel *drinkListModel) {
                    if (!self.isScopedToSpot && drinkListModel.drinks.count) {
                        [self showAreYouHerePromptForSpot:nearestSpot animated:TRUE withCompletionBlock:nil];
                        self.lastAreYouHerePrompt = [NSDate date];
                    }
                } failure:^(ErrorModel *errorModel) {
#ifndef NDEBUG
                    [self oops:errorModel caller:_cmd message:[NSString stringWithFormat:@"Error in %@", NSStringFromSelector(_cmd)]];
#endif
                }];
            }
        }
    }
}

- (void)showSpotsSearch {
    if (![self promptLoginNeeded:@"Cannot create a spotlist without logging in"]) {
        [self.slidersSearchViewController prepareForMode:SHModeSpots];
        
        [self hideBottomViewWithCompletionBlock:^{
            [self showSlidersSearch:TRUE forMode:SHModeSpots withCompletionBlock:^{
            }];
        }];
    }
}

- (void)showBeersSearch {
    if (![self promptLoginNeeded:@"Cannot create a drinklist without logging in"]) {
        [self.slidersSearchViewController prepareForMode:SHModeBeer];
        
        [self hideBottomViewWithCompletionBlock:^{
            [self showSlidersSearch:TRUE forMode:SHModeBeer withCompletionBlock:^{
            }];
        }];
    }
}

- (void)showCocktailsSearch {
    if (![self promptLoginNeeded:@"Cannot create a spotlist without logging in"]) {
        [self.slidersSearchViewController prepareForMode:SHModeCocktail];

        [self hideBottomViewWithCompletionBlock:^{
            [self showSlidersSearch:TRUE forMode:SHModeCocktail withCompletionBlock:^{
            }];
        }];
    }
}

- (void)showWineSearch {
    if (![self promptLoginNeeded:@"Cannot create a spotlist without logging in"]) {
        [self.slidersSearchViewController prepareForMode:SHModeWine];
        
        [self hideBottomViewWithCompletionBlock:^{
            [self showSlidersSearch:TRUE forMode:SHModeWine withCompletionBlock:^{
            }];
        }];
    }
}

- (void)displaySpecialsForSpots:(NSArray *)spots {
    self.navigationItem.title = kTodaysSpecialsTitle;
    
    self.currentIndex = 0;

    [self.mapOverlayCollectionViewController displaySpecialsForSpots:spots];
    [self populateMapWithSpots:spots];
    
    if (!self.homeNavigationViewController.view.hidden) {
        [self hideHomeNavigation:FALSE withCompletionBlock:nil];
    }
    
    [self showCollectionContainerView:TRUE withCompletionBlock:^{
        // do nothing
    }];
}

- (void)displaySpotlist:(SpotListModel *)spotlistModel {
    self.navigationItem.title = spotlistModel.name;
    
    self.currentIndex = 0;
    
    [self.mapOverlayCollectionViewController displaySpotList:spotlistModel];
    [self populateMapWithSpots:spotlistModel.spots];

    if (!self.homeNavigationViewController.view.hidden) {
        [self hideHomeNavigation:FALSE withCompletionBlock:nil];
    }
    
    [self showCollectionContainerView:TRUE withCompletionBlock:^{
        // do nothing
    }];
}

- (void)displayDrinklist:(DrinkListModel *)drinklistModel forMode:(SHMode)mode {
    self.navigationItem.title = drinklistModel.name;
    
    self.currentIndex = 0;
    
    // clear the map right away because it may currently show other results
    [self.mapView removeAnnotations:[self.mapView annotations]];
    
    if (drinklistModel.drinks.count) {
        DrinkModel *drink = drinklistModel.drinks[0];
        [self updateMapWithCurrentDrink:drink];
    }
    
    if (!self.homeNavigationViewController.view.hidden) {
        [self hideHomeNavigation:FALSE withCompletionBlock:nil];
    }
    
    [self.mapOverlayCollectionViewController displayDrinklist:drinklistModel];
    
    [self showCollectionContainerView:TRUE withCompletionBlock:^{
        [self promptUserToCheckIn];
        
        if (self.isScopedToSpot) {
            NSString *text = drinklistModel.drinks.count > 1 ? [NSString stringWithFormat:@"Found %lu matches at %@", (unsigned long)drinklistModel.drinks.count, self.scopedSpot.name] : [NSString stringWithFormat:@"Found 1 match at %@", self.scopedSpot.name];
            [self showStatus:text animated:TRUE withCompletionBlock:nil];
        }
    }];
}

- (void)displaySingleSpot:(SpotModel *)spot {
    [self resetSearch];
    [self.mapView removeAnnotations:self.mapView.annotations];
    self.selectedSpot = spot;
    self.navigationItem.title = spot.name;
    
    self.mode = SHModeSpots;
    
    self.currentIndex = 0;
    
    // ensure a drinklist is set to support interactions
    SpotListModel *spotlist = [[SpotListModel alloc] init];
    spotlist.spots = @[spot];
    self.spotListModel = spotlist;
    
    [self.mapOverlayCollectionViewController displaySingleSpot:spot];
    [self populateMapWithSpots:@[spot]];
    
    if (!self.homeNavigationViewController.view.hidden) {
        [self hideHomeNavigation:FALSE withCompletionBlock:nil];
    }
    
    [self showCollectionContainerView:TRUE withCompletionBlock:^{
        // do nothing
    }];
}

- (void)displaySingleDrink:(DrinkModel *)drink {
    [self resetSearch];
    [self.mapView removeAnnotations:self.mapView.annotations];
    self.selectedDrink = drink;
    self.navigationItem.title = drink.name;
    
    if (drink.isBeer) {
        self.mode = SHModeBeer;
    }
    if (drink.isCocktail) {
        self.mode = SHModeCocktail;
    }
    if (drink.isWine) {
        self.mode = SHModeWine;
    }
    
    self.currentIndex = 0;

    // ensure a drinklist is set to support interactions
    DrinkListModel *drinklist = [[DrinkListModel alloc] init];
    drinklist.drinks = @[drink];
    self.drinkListModel = drinklist;
    
    [self.mapOverlayCollectionViewController displaySingleDrink:drink];
    
    DrinkListRequest *request = [[DrinkListRequest alloc] init];
    request.drinkId = drink.ID;
    request.coordinate = [self visibleMapCenterCoordinate];
    request.radius = [self searchRadius];
    self.drinkListRequest = request;
    
    [self showStatus:@"Locating..." animated:TRUE withCompletionBlock:nil];
    [[drink fetchSpotsForDrinkListRequest:request] then:^(NSArray *spots) {
        [self populateMapWithSpots:spots];
        self.spotsForDrink = spots;
    } fail:^(ErrorModel *errorModel) {
        [self oops:errorModel caller:_cmd];
    } always:^{
        
    }];
    
    if (!self.homeNavigationViewController.view.hidden) {
        [self hideHomeNavigation:FALSE withCompletionBlock:nil];
    }
    
    [self showCollectionContainerView:TRUE withCompletionBlock:^{
        // do nothing
    }];
};

- (void)scopeToSpot:(SpotModel *)spot {
    if (!self.areYouHerePromptView.hidden) {
        [self hideAreYouHerePrompt:TRUE withCompletionBlock:nil];
    }
    
    [self.locationMenuBarViewController scopeToSpot:spot withCompletionBlock:nil];
    self.scopedSpot = spot;
    
    DrinkListRequest *request = [self.drinkListRequest copy];
    request.spotId = spot.ID;
    
    [self showHUD:@"Fetching drinks for Spot"];

    [self hideBottomViewWithCompletionBlock:^{
        [DrinkListModel fetchDrinkListWithRequest:request success:^(DrinkListModel *drinkListModel) {
            [self hideHUD];
            
            if (drinkListModel.drinks.count) {
                DrinkModel *drink = drinkListModel.drinks[0];
                SHMode mode = [self modeForDrink:drink];
                
                [self processDrinklistModel:drinkListModel withRequest:request forMode:mode];
            }
        } failure:^(ErrorModel *errorModel) {
            [self hideHUD];
            [self oops:errorModel caller:_cmd message:@"There was a problem while fetching drinks for this spot. Please try again."];
        }];
    }];
    
    [self showSearchThisArea:TRUE withCompletionBlock:nil];
}

- (void)descope {
    if (self.scopedSpot) {
        [self.locationMenuBarViewController descopeFromSpot:self.scopedSpot withCompletionBlock:nil];
        self.scopedSpot = nil;
    }
}

- (BOOL)isScopedToSpot {
    return self.scopedSpot != nil;
}

- (void)styleBars {
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    UIImage *backgroundImage = [SHStyleKit gradientBackgroundWithSize:self.view.frame.size];
    [self.navigationController.navigationBar setBackgroundImage:backgroundImage forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [SHStyleKit myWhiteColor]};
}

- (void)styleAreYouHerePrompt {
    UIColor *backgroundColor = [SHStyleKit color:SHStyleKitColorMyTintColorTransparent];
    UIColor *borderColor = [SHStyleKit color:SHStyleKitColorMyWhiteColor];
    UIColor *labelTextColor = [SHStyleKit color:SHStyleKitColorMyWhiteColor];
    UIColor *buttonTextColor = [SHStyleKit color:SHStyleKitColorMyTintColor];
    UIColor *buttonBackgroundColor = [SHStyleKit color:SHStyleKitColorMyWhiteColor];
    
    self.areYouHerePromptView.backgroundColor = backgroundColor;
    self.areYouHerePromptView.layer.borderColor = [borderColor CGColor];
    self.areYouHerePromptView.layer.borderWidth = 2.0f;
    self.areYouHerePromptView.layer.cornerRadius = 10.0f;
    self.areYouHerePromptView.clipsToBounds = YES;
    
    self.areYouHerePromptLabel.font = [UIFont fontWithName:@"Lato-Light" size:self.areYouHerePromptLabel.font.pointSize];
    self.areYouHerePromptLabel.textColor = labelTextColor;
    
    [self.areYouHereYesButton setTitleColor:buttonTextColor forState:UIControlStateNormal];
    [self.areYouHereNoButton setTitleColor:buttonTextColor forState:UIControlStateNormal];
    
    [self.areYouHereYesButton setBackgroundColor:buttonBackgroundColor];
    [self.areYouHereNoButton setBackgroundColor:buttonBackgroundColor];
    
    self.areYouHereYesButton.layer.cornerRadius = 5.0f;
    self.areYouHereNoButton.layer.cornerRadius = 5.0f;
    
    [self addShadowToView:self.areYouHerePromptView];
}

- (void)styleSearchThisArea {
    UIColor *tintColor = [SHStyleKit color:SHStyleKitColorMyTintColor];
    self.searchThisAreaButton.titleLabel.font = [UIFont fontWithName:@"Lato-Bold" size:self.areYouHerePromptLabel.font.pointSize];
    self.searchThisAreaButton.tintColor = tintColor;
    [self.searchThisAreaButton setTitleColor:tintColor forState:UIControlStateNormal];
    
    self.searchThisAreaView.layer.cornerRadius = 5.0f;
}

- (void)fetchNearbySpotsAtLocation:(CLLocation *)location {
    if (location && CLLocationCoordinate2DIsValid(location.coordinate)) {
        [[SpotModel fetchSpotsNearLocation:location] then:^(NSArray *spots) {
            self.nearbySpots = spots;
        } fail:^(ErrorModel *errorModel) {
#ifndef NDEBUG
            [self oops:errorModel caller:_cmd message:[NSString stringWithFormat:@"Error in %@", NSStringFromSelector(_cmd)]];
#endif
        } always:^{
        }];
    }
}

- (void)fetchSpecialsWithCompletionBlock:(void (^)())completionBlock {
    [self hideBottomViewWithCompletionBlock:^{
        [SpotModel getSpotsWithSpecialsTodayForCoordinate:[self visibleMapCenterCoordinate] success:^(NSArray *spotModels, JSONAPI *jsonApi) {
            
            [self processSpecialsWithSpots:spotModels];
            
            if (completionBlock) {
                completionBlock();
            }
        } failure:^(ErrorModel *errorModel) {
            [self oops:errorModel caller:_cmd message:@"There was a problem while fetching drink specials. Please try again."];
            
            if (completionBlock) {
                completionBlock();
            }
        }];
    }];
}

- (void)updateMapWithCurrentDrink:(DrinkModel *)drink {
    if (self.isScopedToSpot) {
        self.selectedDrink = drink;
        [self populateMapWithSpots:@[self.scopedSpot]];
        self.spotsForDrink = @[self.scopedSpot];
    }
    else {
        // remove existing annotations prior to waiting to load spots for this drink
        [self.mapView removeAnnotations:self.mapView.annotations];
        [self showStatus:@"Locating..." animated:TRUE withCompletionBlock:nil];
        
        self.selectedDrink = drink;
        
        __weak DrinkModel *weakDrink = drink;
        [[drink fetchSpotsForDrinkListRequest:self.drinkListRequest] then:^(NSArray *spots) {
            if ([weakDrink isEqual:self.selectedDrink]) {
                [self populateMapWithSpots:spots];
                self.spotsForDrink = spots;
            }
            else {
                DebugLog(@"The drink used to fetch spots and the currently selected spot do not match.");
            }
        } fail:^(ErrorModel *errorModel) {
#ifndef NDEBUG
            [self oops:errorModel caller:_cmd message:[NSString stringWithFormat:@"Error in %@", NSStringFromSelector(_cmd)]];
#endif
        } always:nil];
    }
}

- (void)populateMapWithSpots:(NSArray *)spots {
    NSAssert(self.mapView, @"Map View is required");
    
    if (!spots.count) {
        [self showAlert:@"Oops" message:@"There were no spots found. Please try another neighorhood."];
        return;
    }
    
    if (spots.count == 1) {
        NSUInteger matches = 0;
        NSUInteger otherMatches = 0;
        // skip if this spot is already the only one shown
        for (id<MKAnnotation>annotation in self.mapView.annotations) {
            if ([annotation isKindOfClass:[MatchPercentAnnotation class]]) {
                MatchPercentAnnotation *matchPercentAnnotation = (MatchPercentAnnotation *)annotation;
                if ([spots[0] isEqual:matchPercentAnnotation.spot]) {
                    matches++;
                }
                else {
                    // the map has annotation which are not the first spot (needs to be cleared)
                    otherMatches++;
                }
            }
        }
        
        if (matches == 1 && otherMatches == 0) {
            for (id<MKAnnotation>annotation in self.mapView.annotations) {
                if ([annotation isKindOfClass:[MatchPercentAnnotation class]]) {
                    MatchPercentAnnotation *matchPercentAnnotation = (MatchPercentAnnotation *)annotation;
                    if ([spots[0] isEqual:matchPercentAnnotation.spot]) {
                        MatchPercentAnnotationView *pin = (MatchPercentAnnotationView *)[self.mapView viewForAnnotation:annotation];
                        [self displayCalloutViewInPin:pin inMapView:self.mapView];
                    }
                }
            }
            
            return;
        }
    }
    
    // Update map by removing current annotations and adding given spots
    
    [self.mapView removeAnnotations:[self.mapView annotations]];
    for (SpotModel *spot in spots) {
        // Place pin
        if (spot.latitude != nil && spot.longitude != nil) {
            CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(spot.latitude.floatValue, spot.longitude.floatValue);
            
            MatchPercentAnnotation *annotation = [[MatchPercentAnnotation alloc] init];
            [annotation setSpot:spot];
            annotation.coordinate = coordinate;
            [self.mapView addAnnotation:annotation];
            
            if (kDebugAnnotationViewPositions) {
                MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
                point.coordinate = coordinate;
                [self.mapView addAnnotation:point];
            }
        }
    }
    
    if (spots.count > 1) {
        [self repositionMapOnAnnotations:self.mapView.annotations animated:TRUE];
    }
    else if (spots.count == 1) {
        SpotModel *spot = spots[0];
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(spot.latitude.floatValue, spot.longitude.floatValue);
        [self repositionMapOnCoordinate:coordinate animated:TRUE];
    }
    
    if (spots.count) {
        if (self.selectedSpot && [spots containsObject:self.selectedSpot]) {
            [self selectSpot:self.selectedSpot];
        }
        else if (self.spotListRequest) {
            [self selectSpot:spots[0]];
        }
        else if (self.drinkListRequest && spots.count == 1) {
            [self selectSpot:spots[0]];
        }
        else if (self.mode == SHModeSpecials) {
            [self selectSpot:spots[0]];
        }
    }
    
    if (!self.scopedSpot && !self.spotListRequest) {
        NSString *text = spots.count > 1 ? [NSString stringWithFormat:@"Found at %lu Spots nearby", (unsigned long)spots.count] : @"Found at 1 Spot nearby";
        [self showStatus:text animated:TRUE withCompletionBlock:nil];
    }
}

- (void)selectSpot:(SpotModel *)spot {
    for (id<MKAnnotation>annotation in self.mapView.annotations) {
        if ([annotation isKindOfClass:[MatchPercentAnnotation class]]) {
            MatchPercentAnnotation *matchAnnotation = (MatchPercentAnnotation *)annotation;
            if ([spot isEqual:matchAnnotation.spot]) {
                [self.mapView selectAnnotation:annotation animated:TRUE];
            }
        }
    }
}

- (void)pickLocation {
    SHLocationPickerViewController *locationPickerVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SHLocationPickerViewController"];
    
    locationPickerVC.initialRegion = self.mapView.region;
    
    locationPickerVC.delegate = self;
    [self.navigationController pushViewController:locationPickerVC animated:TRUE];
}

- (void)repositionOnCurrentDeviceLocation:(BOOL)animated {
    [self.locationMenuBarViewController updateLocationTitle:@"Locating..."];
    
    TellMeMyLocation *tellMeMyLocation = [[TellMeMyLocation alloc] init];
    [tellMeMyLocation findMe:kCLLocationAccuracyNearestTenMeters found:^(CLLocation *newLocation) {
        _currentLocation = newLocation;
        [self fetchNearbySpotsAtLocation:_currentLocation];
        [self repositionMapOnCoordinate:_currentLocation.coordinate animated:animated];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self updateLocationName];
        });
    } failure:^(NSError *error) {
        DebugLog(@"tellMeMyLocation: %@", tellMeMyLocation);
        if (!_currentLocation && self.lastSelectedLocation) {
            _currentLocation = self.lastSelectedLocation;
        }
        
        if (_currentLocation) {
            [self repositionMapOnCoordinate:_currentLocation.coordinate animated:animated];
        }
        else {
            [self repositionMapOnCoordinate:kCLLocationCoordinate2DInvalid animated:animated];
        }
    }];
}

- (void)repositionMapOnCoordinate:(CLLocationCoordinate2D)coordinate animated:(BOOL)animated {
    [self repositionMapOnCoordinate:coordinate animated:animated withCompletionBlock:nil];
}

- (void)repositionMapOnCoordinate:(CLLocationCoordinate2D)coordinate animated:(BOOL)animated withCompletionBlock:(void (^)())completionBlock {
    if (!CLLocationCoordinate2DIsValid(coordinate)) {
        _isValidLocation = FALSE;
        self.repositioningMap = TRUE;

        CLLocationCoordinate2D nationalMapCenterCoordinate = CLLocationCoordinate2DMake(kNationalMapCenterLatitude, kNationalMapCenterLongitude);
        
        MKMapRect mapRect = MKMapRectNull;
        MKMapPoint mapPoint = MKMapPointForCoordinate(nationalMapCenterCoordinate);
        
        CGFloat padding = 35000000;
        mapRect.origin.x = mapPoint.x - padding/2;
        mapRect.origin.y = mapPoint.y - padding/2;
        mapRect.size = MKMapSizeMake(MKMapRectGetWidth(mapRect) + padding, MKMapRectGetHeight(mapRect) + padding);
        
        UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState;
        [UIView animateWithDuration:0.5 delay:0.0 options:options animations:^{
            [self.mapView setVisibleMapRect:mapRect edgePadding:UIEdgeInsetsMake(self.topEdgePadding, 45.0f, self.bottomEdgePadding, 45.0f) animated:animated];
        } completion:^(BOOL finished) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.25 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                self.repositioningMap = FALSE;
                [self updateLocationName];
            });
        }];
    }
    else {
        _isValidLocation = TRUE;
        self.repositioningMap = TRUE;
        
        CGFloat widthPadding = MKMapRectGetHeight(self.mapView.visibleMapRect);
        CGFloat heightPadding = MKMapRectGetHeight(self.mapView.visibleMapRect);
        
        MKMapRect mapRect = MKMapRectNull;
        MKMapPoint mapPoint = MKMapPointForCoordinate(coordinate);
        mapRect.origin.x = mapPoint.x - kMapPadding/2;
        mapRect.origin.y = mapPoint.y - kMapPadding/2;
        mapRect.size = MKMapSizeMake(kMapPadding, kMapPadding);
        
        UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState;
        [UIView animateWithDuration:0.4f delay:0.0f options:options animations:^{
            if (widthPadding > kMapPadding/2 || heightPadding > kMapPadding/2) {
                [self.mapView setVisibleMapRect:mapRect edgePadding:UIEdgeInsetsMake(self.topEdgePadding, 45.0f, self.bottomEdgePadding, 45.0f) animated:animated];
            }
            else {
                [self.mapView setCenterCoordinate:coordinate animated:TRUE];
            }
        } completion:^(BOOL finished) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.25f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                self.repositioningMap = FALSE;
                [self updateLocationName];
            });
        }];
    }
}

- (void)repositionMapOnAnnotations:(NSArray *)annotations animated:(BOOL)animated {
    self.repositioningMap = TRUE;
    
    if (!self.searchThisAreaView.hidden) {
        [self hideSearchThisArea:TRUE withCompletionBlock:nil];
    }

    MKMapRect mapRect = MKMapRectNull;
    
    if (annotations.count) {
        for (id <MKAnnotation> annotation in annotations) {
            if (![annotation isKindOfClass:[MKUserLocation class]]) {
                
                MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
                MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0, 0);
                if (MKMapRectIsNull(mapRect)) {
                    mapRect = pointRect;
                } else {
                    mapRect = MKMapRectUnion(mapRect, pointRect);
                }
            }
        }
    }
    else {
        // use map center to zoom in closer
        MKMapPoint annotationPoint = MKMapPointForCoordinate(self.mapView.centerCoordinate);
        MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0, 0);
        if (MKMapRectIsNull(mapRect)) {
            mapRect = pointRect;
        } else {
            mapRect = MKMapRectUnion(mapRect, pointRect);
        }
    }
    
    if (!MKMapRectIsNull(mapRect)) {
        // ensure points are not positioned below the header by setting the edge padding
        
        // give it a little extra space
        if (MKMapRectGetWidth(mapRect) == 0.0f && MKMapRectGetHeight(mapRect) == 0.0f) {
            CGFloat padding = kMapPadding;
            mapRect.origin.x -= padding/2;
            mapRect.origin.y -= padding/2;
            mapRect.size = MKMapSizeMake(MKMapRectGetWidth(mapRect) + padding, MKMapRectGetHeight(mapRect) + padding);
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.25 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState;
            [UIView animateWithDuration:1.5 delay:0.0 options:options animations:^{
                // edgePadding must also account for the size and position of the annotation view
                [self.mapView setVisibleMapRect:mapRect edgePadding:UIEdgeInsetsMake(self.topEdgePadding, 45.0, self.bottomEdgePadding, 45.0) animated:animated];
            } completion:^(BOOL finished) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                    self.repositioningMap = FALSE;
                    [self updateLocationName];
                });

            }];
        });
    }
    else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.25 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            self.repositioningMap = FALSE;
        });
    }
    
    // HACK a bug somehow sets isUserInteractionEnabled to false when a map view animates
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.35 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        self.mapView.userInteractionEnabled = TRUE;
    });
}

- (CGRect)topFrame {
    return self.locationMenuBarViewController.view.frame;
}

- (CGRect)bottomFrame {
    if (!self.homeNavigationViewController.view.hidden) {
        return self.homeNavigationViewController.view.frame;
    }
    else {
        return self.collectionContainerView.frame;
    }
}

- (CGFloat)topEdgePadding {
    CGRect topFrame = [self topFrame];
    // 40 for height of the annotation view
    
    CGFloat padding = CGRectGetHeight(topFrame) + ([self hasFourInchDisplay] ? self.topLayoutGuide.length : 0.0f) + 40.f;
    DebugLog(@"padding: %f", padding);
    
    return padding;
}

- (CGFloat)bottomEdgePadding {
    CGRect bottomFrame = [self bottomFrame];
    return CGRectGetHeight(bottomFrame) + 50.0f + self.bottomLayoutGuide.length;
}

- (BOOL)hasFourInchDisplay {
    return ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone && [UIScreen mainScreen].bounds.size.height == 568.0);
}

- (CGRect)visibleMapFrame {
    // visible frame is the bottom of the overlay to the top of the bottom overlay
    
    CGRect topFrame = [self topFrame];
    CGRect bottomFrame = [self bottomFrame];
    CGFloat xPos = 0;
    CGFloat yPos = self.topLayoutGuide.length + CGRectGetHeight(topFrame);
    CGFloat height = CGRectGetHeight(self.mapView.frame) - yPos - CGRectGetHeight(bottomFrame) - self.bottomLayoutGuide.length;
    
    CGRect visibleFrame = CGRectMake(xPos, yPos, CGRectGetWidth(self.mapView.frame), height);
    
    return visibleFrame;
}

- (MKCoordinateRegion)visibleMapRegion {
    MKCoordinateRegion region = [self.mapView convertRect:[self visibleMapFrame] toRegionFromView:self.mapView];
    
    return region;
}

- (CLLocationCoordinate2D)visibleMapCenterCoordinate {
    MKCoordinateRegion visibleRegion = [self visibleMapRegion];

    return visibleRegion.center;
}

- (CLLocationCoordinate2D)adjustedCenterCoordinate {
    // the target coordinate is directly in the center horizontally
    // and just above the bottom of the status view by half of the
    // annotation view and a margin value of about 10 points.
    
    // the key is that the zoom level is not changing
    
    // weighted center is south of the visible center
    
    // 1) get the UIView position for the target position
    // 2) translate the target position to map coordinates
    // 3) calculate the latitude delta between center coord and target coord
    // 4) calcualate new center coord using new point
    
    return kCLLocationCoordinate2DInvalid;
}

- (CLLocationDistance)searchRadius {
    MKCoordinateRegion visibleRegion = [self visibleMapRegion];
    CLLocationCoordinate2D visibleCenter = visibleRegion.center;

    CLLocation *boundaryLocation = [[CLLocation alloc] initWithLatitude:(visibleCenter.latitude + visibleRegion.span.latitudeDelta) longitude:visibleCenter.longitude];
    CLLocation *centerLocation = [[CLLocation alloc] initWithLatitude:visibleCenter.latitude longitude:visibleCenter.longitude];
    
    CLLocationDistance distance = [centerLocation distanceFromLocation:boundaryLocation];
    CLLocationDistance radius = distance / 2;
    
    return radius;
}

- (void)restoreNormalNavigationItems:(BOOL)animated withCompletionBlock:(void (^)())completionBlock {
    UIButton *searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [searchButton addTarget:self action:@selector(searchButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    searchButton.frame = CGRectMake(0, 0, 30, 30);
    [SHStyleKit setButton:searchButton withDrawing:SHStyleKitDrawingSearchIcon normalColor:SHStyleKitColorMyWhiteColor highlightedColor:SHStyleKitColorMyTextColor];
    UIBarButtonItem *searchBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:searchButton];
    
    UIButton *sideBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [sideBarButton addTarget:self action:@selector(sideBarButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    sideBarButton.frame = CGRectMake(0, 0, 30, 30);
    [SHStyleKit setButton:sideBarButton withDrawing:SHStyleKitDrawingSpotSideBarIcon normalColor:SHStyleKitColorMyWhiteColor highlightedColor:SHStyleKitColorMyTextColor];
    UIBarButtonItem *sideBarBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:sideBarButton];
    
    [self restoreTitle];
    
    [CATransaction begin];
    [CATransaction setAnimationDuration:(animated ? 0.25f : 0.0f)];
    [CATransaction setCompletionBlock:^{
        if (completionBlock) {
            completionBlock();
        }
    }];
    [self.view endEditing:YES];
    [self.navigationItem setLeftBarButtonItem:searchBarButtonItem animated:animated];
    [self.navigationItem setRightBarButtonItem:sideBarBarButtonItem animated:animated];
    [CATransaction commit];
}

- (UIButton *)makeButtonWithTitle:(NSString *)title target:(id)target action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:title forState:UIControlStateNormal];
    //button.titleLabel.font = [UIFont fontWithName:@"Lato-Light" size:button.titleLabel.font.pointSize];
    [SHStyleKit setButton:button normalTextColor:SHStyleKitColorMyWhiteColor highlightedTextColor:SHStyleKitColorMyTintColor];
    CGFloat buttonTextWidth = [self widthForString:button.titleLabel.text font:button.titleLabel.font maxWidth:150.0f];
    button.frame = CGRectMake(0, 0, buttonTextWidth + 10, 32);
    
    return button;
}

- (void)prepareBlurredScreen {
    // 1) initialize and add the views if necessary (view must be clipped)
    // 2) get the blurred screenshot and set the image view
    // 3) set the height constraint to put it out of view
    // 4) call the completion block when done
    
    if (!self.blurredView && !self.blurredImageView) {
        UIView *blurredView = [[UIView alloc] initWithFrame:self.view.frame];
        blurredView.translatesAutoresizingMaskIntoConstraints = NO;
        blurredView.clipsToBounds = TRUE;
        [self.view insertSubview:blurredView belowSubview:self.containerView];
        
        // this view contains the image view and must be docked to the bottom
        // the height constraint must start at zero and the view must be clipped
        NSLayoutConstraint *heightConstraint = [blurredView constrainToHeight:0.0f];
        [blurredView pinToSuperviewEdges:JRTViewPinLeftEdge | JRTViewPinRightEdge | JRTViewPinBottomEdge inset:0.0 usingLayoutGuidesFrom:self];
        self.blurredViewHeightConstraint = heightConstraint;
        
        UIImageView *blurredImageView = [[UIImageView alloc] initWithFrame:self.view.frame];
        blurredImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [blurredView addSubview:blurredImageView];
        
        // the blurred image view must be the same height and width as the main view
        // it should be pinned to every side but the top so it docked to the bottom with a unchanging height constraint (clipping hides the image)
        [blurredImageView constrainToHeight:CGRectGetHeight(self.view.frame)];
        [blurredImageView pinToSuperviewEdges:JRTViewPinLeftEdge | JRTViewPinRightEdge | JRTViewPinBottomEdge inset:0.0];
        
        self.blurredView = blurredView;
        self.blurredImageView = blurredImageView;
    }
    
    self.blurredViewHeightConstraint.constant = 0.0f;
    [self updateBlurredView];
}

- (void)refreshBlurredView {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone &&
        [[[UIDevice currentDevice] model] hasPrefix:@"iPad"]) {
        // do not refresh blurred view on the iPad due to an iOS bug
        return;
    }
    
    if (_isShowingSearchView && !_isOverlayAnimating) {
        [self updateBlurredView];
    }
}

- (void)updateBlurredView {
    if (self.blurredView && self.blurredImageView) {
        // blurring the screenshot takes a bit of time and currently could be done repeatedly to achive ~25 fps, not an ideal 60+ fps
        UIImage *blurredImage = [self blurredScreenshot];
        self.blurredImageView.image = blurredImage;
    }
}

- (UIImage *)blurredScreenshot {
    
    NSMutableArray *viewsToExclude = [@[] mutableCopy];
    
    if (self.blurredView) {
        [viewsToExclude addObject:self.blurredView];
    }
    if (self.slidersSearchViewController.view) {
        [viewsToExclude addObject:self.slidersSearchViewController.view];
    }
    
    UIImage *screenshot = [self screenshotOfView:self.view excludingViews:viewsToExclude];
    UIImage *blurredSnapshotImage = [screenshot applyBlurWithRadius:kBlurRadius tintColor:nil saturationDeltaFactor:kBlurSaturation maskImage:nil];
    
    return blurredSnapshotImage;
}

- (BOOL)canSearchAgain {
    // do not allow for searching again when a spot is selected
    return self.mode == SHModeSpecials || self.drinkListRequest != nil || self.spotListRequest != nil;
}

- (void)searchAgainWithCompletionBlock:(void (^)())completionBlock {
    //[self flashSearchRadius];
    
    if (self.mode == SHModeSpecials) {
        [self fetchSpecialsWithCompletionBlock:completionBlock];
    }
    else if (self.drinkListRequest) {
        DrinkListRequest *request = [self.drinkListRequest copy];
        request.spotId = nil;
        request.coordinate = [self visibleMapCenterCoordinate];
        request.radius = [self searchRadius];
        
        if (!request.isBasedOnSliders && [self.selectedDrink.ID isEqual:request.drinkId]) {
            DrinkListModel *drinklist = [[DrinkListModel alloc] init];
            drinklist.drinks = @[self.selectedDrink];
            
            [self processDrinklistModel:drinklist withRequest:request forMode:self.mode];
            
            if (completionBlock) {
                completionBlock();
            }
        }
        else {
            [DrinkListModel fetchDrinkListWithRequest:request success:^(DrinkListModel *drinkListModel) {
                [self processDrinklistModel:drinkListModel withRequest:request forMode:self.mode];
                
                if (completionBlock) {
                    completionBlock();
                }
            } failure:^(ErrorModel *errorModel) {
                [self oops:errorModel caller:_cmd message:@"There was a problem while fetching drinks for this spot. Please try again."];
                [self restoreNavigationIfNeeded];
                
                if (completionBlock) {
                    completionBlock();
                }
            }];
        }
    }
    else if (self.spotListRequest) {
        SpotListRequest *request = [self.spotListRequest copy];
        request.coordinate = [self visibleMapCenterCoordinate];
        request.radius = [self searchRadius];
        
        if (!request.isBasedOnSliders && [self.selectedSpot.ID isEqual:request.spotId]) {
            SpotListModel *spotlist = [[SpotListModel alloc] init];
            spotlist.spots = @[self.selectedSpot];
            
            [self processSpotlistModel:spotlist withRequest:request];
            
            if (completionBlock) {
                completionBlock();
            }
        }
        else {
            [SpotListModel fetchSpotListWithRequest:request success:^(SpotListModel *spotListModel) {
                [self processSpotlistModel:spotListModel withRequest:request];
                
                if (completionBlock) {
                    completionBlock();
                }
            } failure:^(ErrorModel *errorModel) {
                [self oops:errorModel caller:_cmd message:@"Request failed. Please try again."];
                [self restoreNavigationIfNeeded];
                
                if (completionBlock) {
                    completionBlock();
                }
            }];
        }
    }
}

- (void)flashBottomFrame {
    CGRect frame = [self bottomFrame];
    if (!self.areYouHerePromptView.hidden) {
        frame.origin.y = self.areYouHerePromptView.frame.origin.y;
        frame.size.height = CGRectGetHeight(self.view.frame) - self.areYouHerePromptView.frame.origin.y;
    }
    UIView *bottomView = [[UIView alloc] initWithFrame:frame];
    bottomView.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.5f];
    bottomView.alpha = 0.0f;
    bottomView.userInteractionEnabled = FALSE;
    [self.view addSubview:bottomView];
    
    UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState;
    [UIView animateWithDuration:0.25f delay:0.0f options:options animations:^{
        bottomView.alpha = 1.0f;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.25f delay:0.25f options:options animations:^{
            bottomView.alpha = 0.0f;
        } completion:^(BOOL finished) {
            [bottomView removeFromSuperview];
        }];
    }];
}

- (void)flashSearchRadius {
    CLLocationCoordinate2D center = [self visibleMapCenterCoordinate];
    CGFloat radius = [self searchRadius];
    
    MKCircle *circleOverlay = [MKCircle circleWithCenterCoordinate:center radius:radius];
    [self.mapView addOverlay:circleOverlay];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self.mapView removeOverlay:circleOverlay];
    });
}

- (void)flashMapBoxing {
    CGRect visibleFrame = [self.mapView convertRegion:[self visibleMapRegion] toRectToView:self.mapView];
    
    __block UIView *markerView = [[UIView alloc] initWithFrame:visibleFrame];
    markerView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.75f];
    markerView.alpha = 0.0f;
    [self.view insertSubview:markerView belowSubview:self.containerView];
    
    UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState;
    CGFloat duration = 0.25f;
    [UIView animateWithDuration:duration delay:0.0f options:options animations:^{
        markerView.alpha = 1.0f;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:duration delay:0.0f options:options animations:^{
            markerView.alpha = 0.0f;
        } completion:^(BOOL finished) {
            [markerView removeFromSuperview];
            markerView = nil;
        }];
    }];
    
}

- (void)updateLocationName {
    if (!_isValidLocation) {
        [self.locationMenuBarViewController updateLocationTitle:@"Where are you at?"];
    }
    else {
        CLLocationCoordinate2D coordinate = [self visibleMapCenterCoordinate];
        CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
        
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
            if (placemarks.count) {
                CLPlacemark *placemark = placemarks[0];
                [self.locationMenuBarViewController updateLocationTitle:[TellMeMyLocation locationNameFromPlacemark:placemark]];
            }
        }];
    }
}

- (void)giveProps {
    // Show alert with textfield to enter code for props
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Who told you about SpotHopper?" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [[alertView textFieldAtIndex:0] setPlaceholder:@"Enter Code"];
    [alertView showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            
            // Make sure code is entered
            NSString *code = [alertView textFieldAtIndex:0].text;
            if (code.length > 0) {
                
                // Send props tracking code up to analytics
                [Tracker track:@"Give Props" properties:@{ @"code" : code }];
                
                // Set user default saying props were given
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kAlreadyGaveProps];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }
    }];
}

- (void)shareSpecialForSpot:(SpotModel *)spot {
    [self showShareViewControllerWithSpot:spot shareType:ShareViewControllerShareSpecial];
}

- (void)addShadowToView:(UIView *)view {
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:view.bounds];
    view.layer.masksToBounds = NO;
    view.layer.shadowColor = [UIColor blackColor].CGColor;
    view.layer.shadowOffset = CGSizeMake(0.0f, 5.0f);
    view.layer.shadowOpacity = 0.45f;
    view.layer.shadowRadius = 10.0f;
    view.layer.shadowPath = shadowPath.CGPath;
    
//    http://stackoverflow.com/questions/23411390/masking-calayer-shadow-to-outside-of-rect-only
//    float radius = 8;
//    float opacity = 0.5f;
//    float x = 4;
//    float y = 6;
//    UIColor *color = [UIColor blackColor];
//    
//    // Shadow layer
//    CALayer *shadowLayer = [CALayer layer];
//    shadowLayer.shadowOffset = CGSizeMake(x, y);
//    shadowLayer.shadowRadius = radius;
//    shadowLayer.shadowOpacity = opacity;
//    shadowLayer.shadowColor = color.CGColor;
//    shadowLayer.shadowPath = [UIBezierPath bezierPathWithRect:view.frame].CGPath; // Or any other path
//    
//    // Shadow mask frame
//    CGRect frame = CGRectInset(view.layer.frame, -2*radius, -2*radius);
//    frame = CGRectOffset(frame, x, y);
//    
//    // Translate shadowLayer shadow path to mask layer's coordinate system
//    CGAffineTransform trans = CGAffineTransformMakeTranslation(-view.frame.origin.x-x+2*radius,
//                                                               -view.frame.origin.y-y+2*radius);
//    
//    // Mask path
//    CGMutablePathRef path = CGPathCreateMutable();
//    CGPathAddRect(path, nil, (CGRect){.origin={0,0}, .size=frame.size});
//    CGPathAddPath(path, &trans, shadowLayer.shadowPath);
//    CGPathCloseSubpath(path);
//    
//    // Mask layer
//    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
//    maskLayer.frame = frame;
//    maskLayer.fillRule = kCAFillRuleEvenOdd;
//    maskLayer.path = path;
//    
//    shadowLayer.mask = maskLayer;
//    
//    [view.layer.superlayer insertSublayer:shadowLayer below:view.layer];
}

- (SHMode)modeForDrink:(DrinkModel *)drink {
    SHMode mode = SHModeNone;
    
    if (drink.isBeer) {
        mode = SHModeBeer;
    }
    else if (drink.isCocktail) {
        mode = SHModeCocktail;
    }
    else if (drink.isWine) {
        mode = SHModeWine;
    }
    
    return mode;
}

- (void)displayCalloutViewInPin:(MatchPercentAnnotationView *)pin inMapView:(MKMapView *)mapView {
    if (self.drinkListRequest && self.selectedDrink) {
        NSString *spotName = pin.spot.spotType.name.length > 0 ? [NSString stringWithFormat:@"%@ (%@)", pin.spot.name, pin.spot.spotType.name] : pin.spot.name;
        
        if (![SpotCalloutView hasCalloutViewInAnnotationView:pin]) {
            // show a callout view before the menu is load which can take a long time
            
            SpotCalloutView *calloutView = [SpotCalloutView loadView];
            calloutView.delegate = self;
            
            calloutView.alpha = 0.0f;
            
            [calloutView setIcon:SpotCalloutIconLoading spotNameText:spotName drink1Text:nil drink2Text:nil];
            [calloutView placeInMapView:mapView insideAnnotationView:pin];
            
            [self repositionMapOnCoordinate:pin.annotation.coordinate animated:TRUE];
            
            DebugLog(@"showing callout view");
            
            UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState;
            [UIView animateWithDuration:0.25f delay:0.5f usingSpringWithDamping:9.0 initialSpringVelocity:9.0 options:options animations:^{
                calloutView.alpha = 1.0f;
            } completion:^(BOOL finished) {
            }];
        }
        
        [[pin.spot fetchMenu] then:^(MenuModel *menu) {
            DebugLog(@"loaded menu for callout view");
            // the pin may no longer be highlighted by the time the menu loads
            MenuItemModel *menuItem = [menu menuItemForDrink:self.selectedDrink];
            NSArray *prices = nil;
            SpotCalloutIcon calloutIcon = SpotCalloutIconNone;
            
            if (menuItem) {
                prices = [menu pricesForMenuItem:menuItem];
                
                BOOL isBeerOnTap = [menu isBeerOnTap:menuItem];
                BOOL isBeerInBottle = [menu isBeerInBottle:menuItem];
                BOOL isCocktail = [menu isCocktail:menuItem];
                BOOL isWine = [menu isWine:menuItem];
                
                if (isBeerOnTap && isBeerInBottle) {
                    calloutIcon = SpotCalloutIconBeerOnTapAndInBottle;
                }
                else if (isBeerOnTap) {
                    calloutIcon = SpotCalloutIconBeerOnTap;
                }
                else if (isBeerInBottle) {
                    calloutIcon = SpotCalloutIconBeerInBottle;
                }
                else if (isCocktail) {
                    calloutIcon = SpotCalloutIconCocktail;
                }
                else if (isWine) {
                    calloutIcon = SpotCalloutIconWine;
                }
            }
            else {
                prices = @[@"Not available"];
            }
            
            NSString *drink1 = prices.count > 0 ? prices[0] : nil;
            NSString *drink2 = prices.count > 1 ? prices[1] : nil;
            
            if (pin.highlighted) {
                SpotCalloutView *updatedCalloutView = [SpotCalloutView loadView];
                updatedCalloutView.delegate = self;
                [updatedCalloutView setIcon:calloutIcon spotNameText:spotName drink1Text:drink1 drink2Text:drink2];
                [updatedCalloutView placeInMapView:mapView insideAnnotationView:pin];
            }
        } fail:^(ErrorModel *errorModel) {
#ifndef NDEBUG
            [self oops:errorModel caller:_cmd message:[NSString stringWithFormat:@"Error in %@", NSStringFromSelector(_cmd)]];
#endif
        } always:nil];
    }
}

- (void)resetView {
    // pop to the home map if necessary
    if (![self.navigationController.topViewController isEqual:self]) {
        [self.navigationController popToViewController:self animated:FALSE];
    }
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self resetSearch];
    
    [self hideCollectionContainerView:FALSE withCompletionBlock:^{
        [self showHomeNavigation:FALSE withCompletionBlock:nil];
    }];
    
    if (self.lastSelectedLocation) {
        _currentLocation = self.lastSelectedLocation;
    }
    
    [self repositionOnCurrentDeviceLocation:FALSE];
    [self restoreTitle];
}

#pragma mark - Processing Search Results
#pragma mark -

- (void)processSpecialsWithSpots:(NSArray *)spotModels {
    if (!spotModels.count) {
        [self showHomeNavigation:TRUE withCompletionBlock:^{
            [self showAlert:@"Oops" message:@"There are no drink specials which match in this location. Please try another search area."];
            [self restoreNavigationIfNeeded];
        }];
    }
    else {
        [self descope];
        [self resetSearch];
        self.mode = SHModeSpecials;
        self.specialsSpotModels = spotModels;
        
        [self displaySpecialsForSpots:spotModels];
    }
}

- (void)processSpotlistModel:(SpotListModel *)spotlistModel withRequest:(SpotListRequest *)request {
    if (!spotlistModel.spots.count) {
        [self hideSlidersSearch:TRUE forMode:SHModeSpots withCompletionBlock:^{
            [self showAlert:@"Oops" message:@"There are no spots which match in this location. Please try another search area."];
            [self restoreNavigationIfNeeded];
        }];
    }
    else {
        [self descope];
        [self resetSearch];
        self.spotListRequest = request;
        self.mode = SHModeSpots;
        self.spotListModel = spotlistModel;

        [self hideSlidersSearch:TRUE forMode:SHModeSpots withCompletionBlock:^{
            [self displaySpotlist:spotlistModel];
        }];
    }
}

- (void)processDrinklistModel:(DrinkListModel *)drinklistModel withRequest:(DrinkListRequest *)request forMode:(SHMode)mode {
    if (!drinklistModel.drinks.count) {
        [self hideSlidersSearch:TRUE forMode:SHModeSpots withCompletionBlock:^{
            [self showAlert:@"Oops" message:@"There are no drinks which match in this location. Please try another search area."];
            [self restoreNavigationIfNeeded];
        }];
    }
    else {
        [self resetSearch];
        self.drinkListRequest = request;
        self.mode = mode;
        self.drinkListModel = drinklistModel;
        
        [self hideSlidersSearch:TRUE forMode:mode withCompletionBlock:^{
            [self displayDrinklist:drinklistModel forMode:mode];
        }];
    }
}

#pragma mark - SHSidebarDelegate
#pragma mark -

- (void)sidebarViewControllerDidRequestSearch:(SHSidebarViewController*)vc {
    [self hideSideBar:TRUE withCompletionBlock:^{
        [self showSearch:TRUE withCompletionBlock:nil];
    }];
}

- (void)sidebarViewControllerDidRequestClose:(SHSidebarViewController*)vc {
    [self hideSideBar:TRUE withCompletionBlock:nil];
}

- (void)sidebarViewControllerDidRequestReviews:(SHSidebarViewController*)vc {
    [self hideSideBar:TRUE withCompletionBlock:^{
        [self goToReviewMenu];
    }];
}

- (void)sidebarViewControllerDidRequestGiveProps:(SHSidebarViewController*)vc {
    [self hideSideBar:TRUE withCompletionBlock:^{
        [self giveProps];
    }];
}

- (void)sidebarViewControllerDidRequestCheckin:(SHSidebarViewController*)vc {
    [self hideSideBar:TRUE withCompletionBlock:^{
        if ([self promptLoginNeeded:@"Cannot checkin without logging in"] == NO) {
            [self goToCheckin:nil];
        }
    }];
}

- (void)sidebarViewControllerDidRequestAccount:(SHSidebarViewController*)vc {
    [self hideSideBar:TRUE withCompletionBlock:^{
        [self goToAccountSettings:TRUE];
    }];
}

- (void)sidebarViewControllerDidRequestLogin:(SHSidebarViewController*)vc {
    [self hideSideBar:TRUE withCompletionBlock:^{
        [self goToLaunch:YES];
    }];
}

#pragma mark - SHLocationMenuBarDelegate
#pragma mark -

- (void)locationMenuBarViewControllerDidRequestLocationChange:(SHLocationMenuBarViewController *)vc {
    [self pickLocation];
}

- (void)locationMenuBarViewController:(SHLocationMenuBarViewController *)vc didScopeToSpot:(SpotModel *)spot {
    [self scopeToSpot:spot];
}

- (void)locationMenuBarViewControllerDidDescope:(SHLocationMenuBarViewController *)vc {
    self.scopedSpot = nil;
    
    [self showHUD:@"Searching Neighborhood"];
    [self hideBottomViewWithCompletionBlock:^{
        [self searchAgainWithCompletionBlock:^{
            [self hideHUD];
        }];
    }];
}

#pragma mark - SHHomeNavigationDelegate
#pragma mark -

- (void)homeNavigationViewController:(SHHomeNavigationViewController *)vc spotsButtonTapped:(id)sender {
    [self checkLocationAndFinishWithCompletionBlock:^{
        [self showSpotsSearch];
    }];
}

- (void)homeNavigationViewController:(SHHomeNavigationViewController *)vc specialsButtonTapped:(id)sender {
    [self checkLocationAndFinishWithCompletionBlock:^{
        [self showHUD:@"Finding Today's Specials"];
        [self fetchSpecialsWithCompletionBlock:^{
            [self hideHUD];
        }];
    }];
}

- (void)homeNavigationViewController:(SHHomeNavigationViewController *)vc beersButtonTapped:(id)sender {
    [self checkLocationAndFinishWithCompletionBlock:^{
        [self showBeersSearch];
    }];
}

- (void)homeNavigationViewController:(SHHomeNavigationViewController *)vc cocktailsButtonTapped:(id)sender {
    [self checkLocationAndFinishWithCompletionBlock:^{
        [self showCocktailsSearch];
    }];
}

- (void)homeNavigationViewController:(SHHomeNavigationViewController *)vc winesButtonTapped:(id)sender {
    [self checkLocationAndFinishWithCompletionBlock:^{
        [self showWineSearch];
    }];
}

#pragma mark - SHMapOverlayCollectionDelegate
#pragma mark -

- (void)mapOverlayCollectionViewController:(SHMapOverlayCollectionViewController *)vc didChangeToSpotAtIndex:(NSUInteger)index {
    if (self.mode == SHModeSpots && index < self.spotListModel.spots.count) {
        SpotModel *spot = self.spotListModel.spots[index];
        [self selectSpot:spot];
    }
    else if (self.mode == SHModeSpecials && index < self.specialsSpotModels.count) {
        SpotModel *spot = self.specialsSpotModels[index];
        [self selectSpot:spot];
    }
}

- (void)mapOverlayCollectionViewController:(SHMapOverlayCollectionViewController *)vc didSelectSpotAtIndex:(NSUInteger)index {
    // Note: Do not focus on spot when spot is selected

//#ifdef kIntegrateDeprecatedScreens
    SpotModel *spot = nil;
    
    if (self.spotListModel && index < self.spotListModel.spots.count) {
        spot = self.spotListModel.spots[index];
    }
    else if (self.drinkListModel && index < self.spotsForDrink.count) {
        spot = self.spotsForDrink[index];
    }
    else if (self.specialsSpotModels && index < self.specialsSpotModels.count) {
        spot = self.specialsSpotModels[index];
    }
    
    if (spot) {
        self.selectedSpot = spot;
        [self performSegueWithIdentifier:HomeMapToSpotProfile sender:self];
    }
//#else
//    if (self.spotListModel && index < self.spotListModel.spots.count) {
//        self.selectedSpot = self.spotListModel.spots[index];
//        [self performSegueWithIdentifier:HomeMapToSpotProfile sender:self];
//    }
//    else if (self.drinkListModel && index < self.spotsForDrink.count) {
//        self.selectedDrink = self.spotsForDrink[index];
//        [self performSegueWithIdentifier:HomeMapToSpotProfile sender:self];
//    }
//    else if (self.specialsSpotModels && index < self.specialsSpotModels.count) {
//        self.selectedSpot = self.specialsSpotModels[index];
//        [self performSegueWithIdentifier:HomeMapToSpotProfile sender:self];
//    }
//#endif
    
}

- (void)mapOverlayCollectionViewController:(SHMapOverlayCollectionViewController *)vc didRequestShareSpecialForSpotAtIndex:(NSUInteger)index {
    if (index < self.specialsSpotModels.count) {
        SpotModel *spot = self.specialsSpotModels[index];
        [self shareSpecialForSpot:spot];
    }
}

- (void)mapOverlayCollectionViewController:(SHMapOverlayCollectionViewController *)vc didChangeToDrinkAtIndex:(NSUInteger)index {
    if (self.drinkListModel.drinks.count && index < self.drinkListModel.drinks.count) {
        DrinkModel *drink = self.drinkListModel.drinks[index];
        [self updateMapWithCurrentDrink:drink];
    }
}

- (void)mapOverlayCollectionViewController:(SHMapOverlayCollectionViewController *)vc didSelectDrinkAtIndex:(NSUInteger)index {

#ifdef kIntegrateDeprecatedScreens
    if (self.drinkListModel.drinks.count && index < self.drinkListModel.drinks.count) {
        self.selectedDrink = self.drinkListModel.drinks[index];
        [self performSegueWithIdentifier:HomeMapToDrinkProfile sender:self];
    }
    else {
        NSAssert(FALSE, @"Index should always be in bounds");
    }
#else
    if (self.drinkListModel.drinks.count && index < self.drinkListModel.drinks.count) {
        self.selectedDrink = self.drinkListModel.drinks[index];
        [self performSegueWithIdentifier:HomeMapToDrinkProfile sender:self];
    }
    else {
        NSAssert(FALSE, @"Index should always be in bounds");
    }
#endif
    
}

#pragma mark - SHMapFooterNavigationDelegate
#pragma mark -

- (void)checkLocationAndFinishWithCompletionBlock:(void (^)())completionBlock {
    if (!_isValidLocation) {
        // prompt user to chooser their location manually
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"What is your location?" message:@"We are unable to determine your location. Would you like to select your location?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
        [alertView showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                [self pickLocation];
            }
        }];
    }
    else if (completionBlock) {
        completionBlock();
    }
}

- (void)footerNavigationViewController:(SHMapFooterNavigationViewController *)vc spotsButtonTapped:(id)sender {
    [self checkLocationAndFinishWithCompletionBlock:^{
        [self showSpotsSearch];
    }];
}

- (void)footerNavigationViewController:(SHMapFooterNavigationViewController *)vc specialsButtonTapped:(id)sender {
    [self checkLocationAndFinishWithCompletionBlock:^{
        [self showHUD:@"Finding Today's Specials"];
        [self fetchSpecialsWithCompletionBlock:^{
            [self hideHUD];
        }];
    }];
}

- (void)footerNavigationViewController:(SHMapFooterNavigationViewController *)vc beersButtonTapped:(id)sender {
    [self checkLocationAndFinishWithCompletionBlock:^{
        [self showBeersSearch];
    }];
}

- (void)footerNavigationViewController:(SHMapFooterNavigationViewController *)vc cocktailsButtonTapped:(id)sender {
    [self checkLocationAndFinishWithCompletionBlock:^{
        [self showCocktailsSearch];
    }];
}

- (void)footerNavigationViewController:(SHMapFooterNavigationViewController *)vc winesButtonTapped:(id)sender {
    [self checkLocationAndFinishWithCompletionBlock:^{
        [self showWineSearch];
    }];
}

#pragma mark - SHSlidersSearchDelegate
#pragma mark -

- (void)slidersSearchViewController:(SHSlidersSearchViewController *)vc didPrepareSpotlist:(SpotListModel *)spotlistModel withRequest:(SpotListRequest *)request forMode:(SHMode)mode {
    [self processSpotlistModel:spotlistModel withRequest:request];
}

- (void)slidersSearchViewController:(SHSlidersSearchViewController *)vc didPrepareDrinklist:(DrinkListModel *)drinkListModel withRequest:(DrinkListRequest *)request forMode:(SHMode)mode {
    [self processDrinklistModel:drinkListModel withRequest:request forMode:mode];
}

- (void)slidersSearchViewControllerWillAnimate:(SHSlidersSearchViewController *)vc {
    _isOverlayAnimating = TRUE;
}

- (void)slidersSearchViewControllerDidAnimate:(SHSlidersSearchViewController *)vc {
    _isOverlayAnimating = FALSE;
}

- (CLLocationCoordinate2D)searchCoordinateForSlidersSearchViewController:(SHSlidersSearchViewController *)vc {
    return [self visibleMapCenterCoordinate];
}

- (CLLocationDistance)searchRadiusForSlidersSearchViewController:(SHSlidersSearchViewController *)vc {
    return [self searchRadius];
}

- (SpotModel *)slidersSearchViewControllerScopedSpot:(SHSlidersSearchViewController *)vc {
    return self.scopedSpot;
}

#pragma mark - SHLocationPickerDelegate
#pragma mark -

- (void)locationPickerViewController:(SHLocationPickerViewController*)viewController didSelectRegion:(MKCoordinateRegion)region {
    _isValidLocation = TRUE;
    
    [self.navigationController popViewControllerAnimated:TRUE];
    
    self.repositioningMap = TRUE;
    
    CLLocation *selectedLocation = [[CLLocation alloc] initWithLatitude:region.center.latitude longitude:region.center.longitude];
    
    _currentLocation = selectedLocation;
    self.lastSelectedLocation = selectedLocation;
    
    UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState;
    [UIView animateWithDuration:0.25 delay:0.0 options:options animations:^{
        [self.mapView setRegion:region animated:FALSE];
    } completion:^(BOOL finished) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.25f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            self.repositioningMap = FALSE;
            [self updateLocationName];
            
            if ([self canSearchAgain]) {
                [self showHUD:@"Updating for New Location"];
                [self searchAgainWithCompletionBlock:^{
                    [self hideHUD];
                }];
            }
        });
    }];
}

#pragma mark - SearchViewControllerDelegate
#pragma mark -

- (void)searchViewController:(SearchViewController*)viewController selectedDrink:(DrinkModel*)drink {
    self.selectedDrink = drink;
    [self performSegueWithIdentifier:HomeMapToDrinkProfile sender:self];
}

- (void)searchViewController:(SearchViewController*)viewController selectedSpot:(SpotModel*)spot {
    self.selectedSpot = spot;
    [self performSegueWithIdentifier:HomeMapToSpotProfile sender:self];
}

#pragma mark - SpotCalloutViewDelegate
#pragma mark -

- (void)spotCalloutView:(SpotCalloutView *)spotCalloutView didSelectAnnotationView:(MKAnnotationView *)annotationView {
    if ([annotationView isKindOfClass:[MatchPercentAnnotationView class]]) {
        MatchPercentAnnotationView *pin = (MatchPercentAnnotationView *)annotationView;
        if (pin.spot) {
            self.selectedSpot = pin.spot;
            [self performSegueWithIdentifier:HomeMapToSpotProfile sender:self];
        }
    }
}

#pragma mark - ShareViewControllerDelegate
#pragma mark -

- (void)shareViewControllerClickedClose:(ShareViewController*)viewController {
    DebugLog(@"%@", NSStringFromSelector(_cmd));
    
    [self hideShareViewController:nil];
}

- (void)shareViewControllerDidFinish:(ShareViewController*)viewController {
    DebugLog(@"%@", NSStringFromSelector(_cmd));
    
    [self hideShareViewController:nil];
}

#pragma mark - SHGlobalSearchViewControllerDelegate
#pragma mark -

- (void)globalSearchViewController:(SHGlobalSearchViewController *)vc didSelectSpot:(SpotModel *)spot {
    [self hideSearch:TRUE withCompletionBlock:^{
        [self displaySingleSpot:spot];
    }];
}

- (void)globalSearchViewController:(SHGlobalSearchViewController *)vc didSelectDrink:(DrinkModel *)drink {
    [self hideSearch:TRUE withCompletionBlock:^{
        [self displaySingleDrink:drink];
    }];
}

#pragma mark - UITextFieldDelegate
#pragma mark -

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.tag == kTagSearchTextField) {
        [textField resignFirstResponder];
    }
    
    return TRUE;
}

#pragma mark - MKMapViewDelegate
#pragma mark -

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    MKAnnotationView *annotationView = nil;
    
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        static NSString *identifier = @"CurrentLocation";
        SVPulsingAnnotationView *pulsingView = (SVPulsingAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        
        if (!pulsingView) {
            pulsingView = [[SVPulsingAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            pulsingView.annotationColor = [SHStyleKit color:SHStyleKitColorMyTintColor];
        }
        
        pulsingView.canShowCallout = YES;
        
        annotationView = pulsingView;
    }
    else if ([annotation isKindOfClass:[MatchPercentAnnotation class]]) {
        static NSString *MatchPercentAnnotationIdentifier = @"MatchPercentAnnotationView";
        MatchPercentAnnotation *matchPercentAnnotation = (MatchPercentAnnotation *)annotation;
        MatchPercentAnnotationView *pin = (MatchPercentAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:MatchPercentAnnotationIdentifier];
        
        if (!pin) {
            pin = [[MatchPercentAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:MatchPercentAnnotationIdentifier];
        }
        
        switch (self.mode) {
            case SHModeSpots:
                // setting to none shows match percentage label
                pin.drawing = matchPercentAnnotation.spot.matchPercent.length ? SHStyleKitDrawingNone : SHStyleKitDrawingSpotIcon;
                break;
            case SHModeSpecials:
                pin.drawing = SHStyleKitDrawingSpecialsIcon;
                break;
            case SHModeBeer:
                pin.drawing = self.selectedSpot ? SHStyleKitDrawingBeerDrinklistIcon : SHStyleKitDrawingBeerIcon;
                break;
            case SHModeCocktail:
                pin.drawing = self.selectedSpot ? SHStyleKitDrawingCocktailDrinklistIcon : SHStyleKitDrawingCocktailIcon;
                break;
            case SHModeWine:
                pin.drawing = self.selectedSpot ? SHStyleKitDrawingWineIcon : SHStyleKitDrawingWineIcon;
                break;
                
            default:
                break;
        }
        
        pin.useLargeIcon = self.isScopedToSpot;
        [pin prepareForReuse];
        [pin setSpot:matchPercentAnnotation.spot highlighted:[self.selectedSpot isEqual:pin.spot]];
        
        pin.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        pin.canShowCallout = NO;
        
        // precache the menu details (turned off to see if it fixes #861)
        //[pin.spot fetchMenu];
        
        annotationView = pin;
    }
    else if ([annotation isKindOfClass:[MKPointAnnotation class]]) {
        static NSString *PinIdentifier = @"Pin";
        MKPinAnnotationView *pin = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:PinIdentifier];
        if (!pin) {
            pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:PinIdentifier];
        }
        
        [pin prepareForReuse];
        
        annotationView = pin;
    }
    
    return annotationView;
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    if ([overlay isKindOfClass:[MKCircle class]]) {
        MKCircleRenderer *circleView = [[MKCircleRenderer alloc] initWithCircle:overlay];
        
        circleView.strokeColor = [[SHStyleKit color:SHStyleKitColorMyWhiteColor] colorWithAlphaComponent:0.1f];
        circleView.fillColor = [[SHStyleKit color:SHStyleKitColorMyWhiteColor] colorWithAlphaComponent:0.25f];
        circleView.lineWidth = 1.0f;
        circleView.alpha = 1.0f;
        
        return circleView;
    }
    
    return nil;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)annotationView {
    if ([annotationView isKindOfClass:[MatchPercentAnnotationView class]]) {
        self.selectedAnnotationView = annotationView;
        
        MatchPercentAnnotationView *pin = (MatchPercentAnnotationView*) annotationView;
        
        pin.highlighted = YES;
        
        if (self.mode == SHModeBeer || self.mode == SHModeCocktail || self.mode == SHModeWine) {
            [self.locationMenuBarViewController selectSpot:pin.spot withCompletionBlock:nil];
        }
        
        if ([annotationView isKindOfClass:[MatchPercentAnnotationView class]]) {
            MatchPercentAnnotationView *pin = (MatchPercentAnnotationView *)annotationView;
            [self displayCalloutViewInPin:pin inMapView:mapView];
        }

        if (!self.isScopedToSpot) {
            [self.mapOverlayCollectionViewController displaySpot:pin.spot];
        }
    }
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)annotationView {
    self.selectedAnnotationView = nil;
    
    if ([annotationView isKindOfClass:[MatchPercentAnnotationView class]] == YES) {
        MatchPercentAnnotationView *pin = (MatchPercentAnnotationView*) annotationView;
        [pin setHighlighted:NO];
        [pin setNeedsDisplay];
        
        [self.locationMenuBarViewController deselectSpot:pin.spot withCompletionBlock:nil];
        
        [SpotCalloutView removeCalloutViewFromAnnotationView:annotationView];
    }
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    if (self.repositioningMap) {
        return;
    }
    
    //[self flashSearchRadius];
    //[self flashMapBoxing];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.25f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self updateLocationName];
    });
    
    if ([self canSearchAgain]) {
        [self showSearchThisArea:TRUE withCompletionBlock:nil];
    }
    
    if (kDebugAnnotationViewPositions) {
        [self.mapView removeAnnotations:self.mapView.annotations];
        // add an annotation for the current visible map center
        MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
        point.coordinate = [self visibleMapCenterCoordinate];
        [self.mapView addAnnotation:point];
    }
}

#pragma mark - Notifications
#pragma mark -

- (void)handleApplicationDidEnterBackgroundNotification:(NSNotification *)notification {
    self.enteredBackgroundDate = [NSDate date];
}

- (void)handleApplicationWillEnterForegroundNotification:(NSNotification *)notification {
    // if has been more than 20 minutes since the app repositioned
    NSTimeInterval seconds = [[NSDate date] timeIntervalSinceDate:self.enteredBackgroundDate];
    
    // 20 minutes is 1200 seconds
    if (seconds > kResetCooldownPeriodInSeconds) {
        [self resetView];
    }
}

- (void)handleGoToHomeMapNotification:(NSNotification *)notification {
    NSAssert([self.navigationController.viewControllers containsObject:self], @"Home Map must be on the view controllers stack");
    [self.navigationController popToViewController:self animated:TRUE];
}

- (void)handleFetchDrinklistRequestNotification:(NSNotification *)notification {
    DrinkListRequest *request = notification.userInfo[SHFetchDrinklistRequestNotificationKey];
    
    [self.navigationController popToViewController:self animated:TRUE];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [[DrinkListModel fetchDrinkListWithRequest:request] then:^(DrinkListModel *drinklist) {
            DrinkModel *drink = nil;
            SHMode mode = SHModeNone;
            if (drinklist.drinks.count > 0) {
                drink = drinklist.drinks[0];
                mode = [self modeForDrink:self.selectedDrink];
            }
            
            [self processDrinklistModel:drinklist withRequest:request forMode:mode];
        } fail:^(ErrorModel *errorModel) {
#ifndef NDEBUG
            [self oops:errorModel caller:_cmd message:[NSString stringWithFormat:@"Error in %@", NSStringFromSelector(_cmd)]];
#endif
        } always:nil];
    });
}

- (void)handleFetchSpotlistRequestNotification:(NSNotification *)notification {
    SpotListRequest *request = notification.userInfo[SHFetchSpotlistRequestNotificationKey];
    
    [self.navigationController popToViewController:self animated:TRUE];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [[SpotListModel fetchSpotListWithRequest:request] then:^(SpotListModel *spotlist) {
            [self processSpotlistModel:spotlist withRequest:request];
        } fail:^(ErrorModel *errorModel) {
#ifndef NDEBUG
            [self oops:errorModel caller:_cmd message:[NSString stringWithFormat:@"Error in %@", NSStringFromSelector(_cmd)]];
#endif
        } always:nil];
    });
}

- (void)handleDisplayDrinkNotification:(NSNotification *)notification {
    DrinkModel *drink = notification.userInfo[SHDisplayDrinkNotificationKey];
    
    [self.navigationController popToViewController:self animated:TRUE];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        DrinkListRequest *request = [[DrinkListRequest alloc] init];
        request.name = kDrinkListModelDefaultName;
        request.coordinate = [self visibleMapCenterCoordinate];
        request.radius = [self searchRadius];
        request.drinkId = self.selectedDrink.ID;
    
        DrinkListModel *drinklist = [[DrinkListModel alloc] init];
        drinklist.drinks = @[drink];

        SHMode mode = [self modeForDrink:drink];
        
        [self processDrinklistModel:drinklist withRequest:request forMode:mode];
        
    });
}

- (void)handleDisplaySpotNotification:(NSNotification *)notification {
    SpotModel *selectedSpot = notification.userInfo[SHDisplaySpotNotificationKey];
    
    [self.navigationController popToViewController:self animated:TRUE];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        SpotListModel *spotlist = [[SpotListModel alloc] init];
        spotlist.spots = @[selectedSpot];
            
        SpotListRequest *request = [[SpotListRequest alloc] init];
        request.name = kSpotListModelDefaultName;
        request.coordinate = [self visibleMapCenterCoordinate];
        request.radius = [self searchRadius];
        request.spotId = self.selectedSpot.ID;

        [self processSpotlistModel:spotlist withRequest:request];
    });
}

- (void)handleFindSimilarToDrinkNotification:(NSNotification *)notification {
    DrinkModel *drink = notification.userInfo[SHFindSimilarToDrinkNotificationKey];
    
    [self.navigationController popToViewController:self animated:TRUE];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.25f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self showHUD:@"Finding Similar Drinks"];
        
        NSString *name = [NSString stringWithFormat:@"Similar to %@", drink.name];
        
        // fetch the full details for a spot to get the sliders
        [[drink fetchDrink] then:^(DrinkModel *drinkModel) {
            
            DrinkListRequest *request = [[DrinkListRequest alloc] init];
            request.name = name;
            request.coordinate = [self visibleMapCenterCoordinate];
            request.radius = [self searchRadius];
            request.sliders = drinkModel.averageReview.sliders;
            request.drinkId = drinkModel.ID;
            request.drinkTypeId = drinkModel.drinkType.ID;
            request.drinkSubTypeId = drinkModel.drinkSubtype.ID;
            
            if (self.isScopedToSpot) {
                request.spotId = self.scopedSpot.ID;
            }
            
            SHMode mode = [self modeForDrink:drinkModel];
            
            [[DrinkListModel fetchDrinkListWithRequest:request] then:^(DrinkListModel *drinklist) {
                [self hideHUD];
                
                [self processDrinklistModel:drinklist withRequest:request forMode:mode];
            } fail:^(ErrorModel *errorModel) {
                [self hideHUD];
#ifndef NDEBUG
                [self oops:errorModel caller:_cmd message:[NSString stringWithFormat:@"Error in %@", NSStringFromSelector(_cmd)]];
#endif
            } always:nil];
            
        } fail:^(ErrorModel *errorModel) {
            [self hideHUD];
#ifndef NDEBUG
            [self oops:errorModel caller:_cmd message:[NSString stringWithFormat:@"Error in %@", NSStringFromSelector(_cmd)]];
#endif
        } always:nil];
    });
}

- (void)handleReviewDrinkNotification:(NSNotification *)notification {
    DrinkModel *drink = notification.userInfo[SHReviewDrinkNotificationKey];
    [self goToNewReviewForDrink:drink];
}

- (void)handleFindSimilarToSpotNotification:(NSNotification *)notification {
    SpotModel *spot = notification.userInfo[SHFindSimilarToSpotNotificationKey];
    
    [self.navigationController popToViewController:self animated:TRUE];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self showHUD:@"Finding Similar Spots"];
        
        // fetch the full details for a spot to get the sliders
        [[spot fetchSpot] then:^(SpotModel *spotModel) {
            SpotListRequest *request = [[SpotListRequest alloc] init];
            request.name = [NSString stringWithFormat:@"Similar to %@", spotModel.name];
            request.coordinate = [self visibleMapCenterCoordinate];
            request.radius = [self searchRadius];
            request.sliders = spotModel.averageReview.sliders;
            request.spotId = spotModel.ID;
            request.spotTypeId = spotModel.spotType.ID;
            
            [[SpotListModel fetchSpotListWithRequest:request] then:^(SpotListModel *spotlist) {
                [self hideHUD];
                [self processSpotlistModel:spotlist withRequest:request];
            } fail:^(ErrorModel *errorModel) {
                [self hideHUD];
#ifndef NDEBUG
                [self oops:errorModel caller:_cmd message:[NSString stringWithFormat:@"Error in %@", NSStringFromSelector(_cmd)]];
#endif
            } always:nil];
            
        } fail:^(ErrorModel *errorModel) {
            [self hideHUD];
#ifndef NDEBUG
            [self oops:errorModel caller:_cmd message:[NSString stringWithFormat:@"Error in %@", NSStringFromSelector(_cmd)]];
#endif
        } always:nil];
    });
}

- (void)handleReviewSpotNotification:(NSNotification *)notification {
    SpotModel *spot = notification.userInfo[SHReviewSpotNotificationKey];
    [self goToNewReviewForSpot:spot];
}

- (void)handleOpenMenuForSpotNotification:(NSNotification *)notification {
    SpotModel *spot = notification.userInfo[SHOpenMenuForSpotNotificationKey];
    [self goToMenu:spot];
}

@end
