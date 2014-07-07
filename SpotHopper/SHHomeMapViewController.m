//
//  SHHomeMapViewController.m
//  SpotHopper
//
//  Created by Brennan Stehling on 5/13/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "SHHomeMapViewController.h"

#import "UIViewController+Navigator.h"
#import "UIView+AutoLayout.h"
#import "SHStyleKit.h"
#import "SHStyleKit+Additions.h"

#import "SHSidebarViewController.h"
#import "SHLocationMenuBarViewController.h"
#import "SHHomeNavigationViewController.h"
#import "SHSlidersSearchViewController.h"
#import "SHMapOverlayCollectionViewController.h"
#import "SHMapFooterNavigationViewController.h"
#import "SHSpotProfileViewController.h"
#import "SHDrinkProfileViewController.h"

#import "SpotAnnotationCallout.h"
#import "MatchPercentAnnotation.h"
#import "MatchPercentAnnotationView.h"
#import "SpotCalloutView.h"

#import "SHButtonLatoBold.h"

#import "TellMeMyLocation.h"
#import "Tracker.h"

#import "UserModel.h"
#import "SpotModel.h"
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

#import "UIImage+BlurredFrame.h"
#import "UIImage+ImageEffects.h"

#import "TTTAttributedLabel.h"
#import "TTTAttributedLabel+QuickFonting.h"

#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <QuartzCore/QuartzCore.h>

#define kMeterToMile 0.000621371f
#define kDebugAnnotationViewPositions NO

#define kCollectionContainerViewHeight 200.0f
#define kCollectionViewHeight 150.0f
#define kFooterNavigationViewHeight 50.0f

#define kBlurRadius 2.5f
#define kBlurSaturation 1.5f

#define kModalAnimationDuration 0.35f

#define kMapPadding 4000.0f

NSString* const HomeMapToSpotProfile = @"HomeMapToSpotProfile";
NSString* const HomeMapToDrinkProfile = @"HomeMapToDrinkProfile";

@interface SHHomeMapViewController ()
    <SHSidebarDelegate,
    SHLocationMenuBarDelegate,
    SHHomeNavigationDelegate,
    SHMapOverlayCollectionDelegate,
    SHMapFooterNavigationDelegate,
    SHSpotsCollectionViewManagerDelegate,
    SpotAnnotationCalloutDelegate,
    SHSlidersSearchDelegate,
    MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *btnLeft;
@property (weak, nonatomic) IBOutlet UIButton *btnRight;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIView *containerView;

@property (weak, nonatomic) UIView *blurredView;
@property (weak, nonatomic) UIImageView *blurredImageView;
@property (weak, nonatomic) IBOutlet SHButtonLatoBold *btnUpdateSearchResults;

@property (strong, nonatomic) SHSidebarViewController *sideBarViewController;
@property (strong, nonatomic) SHLocationMenuBarViewController *locationMenuBarViewController;
@property (strong, nonatomic) SHHomeNavigationViewController *homeNavigationViewController;
@property (strong, nonatomic) SHMapOverlayCollectionViewController *mapOverlayCollectionViewController;
@property (strong, nonatomic) SHMapFooterNavigationViewController *mapFooterNavigationViewController;
@property (strong, nonatomic) SHSlidersSearchViewController *slidersSearchViewController;

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

@property (weak, nonatomic) IBOutlet UIView *searchThisAreaView;
@property (weak, nonatomic) IBOutlet UIButton *searchThisAreaButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchThisAreaBottomConstraint;

@property (assign, nonatomic) SHMode mode;

@property (strong, nonatomic) SpotListModel *spotListModel;
@property (strong, nonatomic) NSArray *specialsSpotModels;
@property (strong, nonatomic) DrinkListModel *drinkListModel;
@property (strong, nonatomic) SpotModel *selectedSpot;
@property (strong, nonatomic) SpotListRequest *spotListRequest;
@property (strong, nonatomic) DrinkListRequest *drinkListRequest;
@property (strong, nonatomic) DrinkModel *selectedDrink;

@property (strong, nonatomic) NSArray *spotsForDrink;

@property (assign, nonatomic) NSUInteger currentIndex;
@property (strong, nonatomic) NSArray *nearbySpots;

@property (strong, nonatomic) NSDate *lastAreYouHerePrompt;

@end

@implementation SHHomeMapViewController {
    CLLocation *_currentLocation;
    BOOL _isRepositioningMap;
    BOOL _doNotMoveMap;
    BOOL _isShowingSliderSearchView;
    BOOL _isSpotDrinkList;
    BOOL _isOverlayAnimating;
}

#pragma mark - View Lifecyle
#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad:@[kDidLoadOptionsNoBackground]];
    
    self.sideBarViewController = [[self spotHopperStoryboard] instantiateViewControllerWithIdentifier:@"SHSidebarViewController"];
    self.sideBarViewController.delegate = self;
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
    
    self.title = @"New Search";
    
    [self repositionOnCurrentDeviceLocation:NO];
    
    self.mapView.showsUserLocation = TRUE;
    
    self.view.backgroundColor = [UIColor clearColor];
    
    [self hideAreYouHerePrompt:FALSE withCompletionBlock:nil];
    
    if ([UserModel isLoggedIn]) {
        [[SpotListModel fetchMySpotLists] then:^(NSArray *spotlists) {
            NSLog(@"Spotlists: %@", spotlists);
        } fail:^(ErrorModel *errorModel) {
            [Tracker logError:errorModel class:[self class] trace:NSStringFromSelector(_cmd)];
        } always:nil];
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
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // TODO: ensure the user is logged in (just while testing)
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

#pragma mark - View Management
#pragma mark -

- (void)embedChildViewControllers {
    
    if (!self.locationMenuBarViewController.view.superview) {
        [self embedViewController:self.locationMenuBarViewController intoView:self.view placementBlock:^(UIView *view) {
            [view pinToSuperviewEdges:JRTViewPinTopEdge inset:0.0f usingLayoutGuidesFrom:self];
            [view pinToSuperviewEdges:JRTViewPinLeftEdge | JRTViewPinRightEdge inset:0.0];
            [view constrainToHeight:40.0f];
        }];
    }
    
    if (!self.homeNavigationViewController.view.superview) {
        [self embedViewController:self.homeNavigationViewController intoView:self.view placementBlock:^(UIView *view) {
            NSArray *bottomConstaints = [view pinToSuperviewEdges:JRTViewPinBottomEdge inset:0.0f usingLayoutGuidesFrom:self];
            NSAssert(bottomConstaints.count == 1, @"There should be only 1 bottom constraint.");
            self.homeNavigationViewBottomConstraint = bottomConstaints[0];
            [view pinToSuperviewEdges:JRTViewPinLeftEdge | JRTViewPinRightEdge inset:0.0];
            [view constrainToHeight:180.0f];
        }];
    }
    
    if (!self.sideBarViewController.view.superview) {
        [self embedViewController:self.sideBarViewController intoView:self.view placementBlock:^(UIView *view) {
            [view pinToSuperviewEdges:JRTViewPinTopEdge | JRTViewPinBottomEdge  inset:0.0f usingLayoutGuidesFrom:self];
            NSArray *rightEdgesConstraints = [view pinToSuperviewEdges:JRTViewPinRightEdge inset:0.0];
            [view constrainToWidth:CGRectGetWidth(self.view.frame)];
            NSCAssert(rightEdgesConstraints.count == 1, @"There should only be 1 constraint for the right edge");
            if (rightEdgesConstraints.count) {
                self.sideBarRightEdgeConstraint = rightEdgesConstraints[0];
            }
            [self hideSideBar:FALSE withCompletionBlock:nil];
        }];
    }

    if (!self.collectionContainerView && !self.mapOverlayCollectionViewController.view.superview && !self.mapFooterNavigationViewController.view.superview) {
        UIView *collectionContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), kCollectionContainerViewHeight)];
        collectionContainerView.translatesAutoresizingMaskIntoConstraints = NO;
        collectionContainerView.backgroundColor = [UIColor clearColor];
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
        
        [self hideCollectionContainerView:FALSE withCompletionBlock:^{
            NSLog(@"Collection container view is hidden");
        }];
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
    
}

- (void)toggleSideBar:(BOOL)animated withCompletionBlock:(void (^)())completionBlock {
    if (self.sideBarRightEdgeConstraint.constant == CGRectGetWidth(self.view.frame)) {
        [self showSideBar:animated withCompletionBlock:completionBlock];
    }
    else {
        [self hideSideBar:animated withCompletionBlock:completionBlock];
    }
}

- (void)hideSideBar:(BOOL)animated withCompletionBlock:(void (^)())completionBlock {
    NSLog(@"Hiding Side Bar");
    
    [self.sideBarViewController viewWillDisappear:animated];
    
    UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState;
    [UIView animateWithDuration:(animated ? 0.25 : 0.0) delay:0.0 options:options animations:^{
        self.sideBarRightEdgeConstraint.constant = CGRectGetWidth(self.view.frame);
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.sideBarViewController.view.hidden = TRUE;
        [self.sideBarViewController viewDidDisappear:animated];
        if (completionBlock) {
            completionBlock();
        }
    }];
}

- (void)showSideBar:(BOOL)animated withCompletionBlock:(void (^)())completionBlock {
    NSLog(@"Showing Side Bar");

    [self.view bringSubviewToFront:self.sideBarViewController.view];
    [self.sideBarViewController viewWillAppear:animated];
    self.sideBarViewController.view.hidden = FALSE;
    
    UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState;
    [UIView animateWithDuration:(animated ? 0.25 : 0.0) delay:0.0 options:options animations:^{
        self.sideBarRightEdgeConstraint.constant = CGRectGetWidth(self.view.frame) * 0.2;
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self.sideBarViewController viewDidAppear:animated];
        if (finished && completionBlock) {
            completionBlock();
        }
    }];
}

- (void)hideHomeNavigation:(BOOL)animated withCompletionBlock:(void (^)())completionBlock {
    DebugLog(@"%@ (%0.2f)", NSStringFromSelector(_cmd), CGRectGetHeight(self.homeNavigationViewController.view.frame));
    
    if (!self.searchThisAreaView.hidden) {
        [self hideSearchThisArea:animated withCompletionBlock:nil];
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
    DebugLog(@"%@ (%0.2f)", NSStringFromSelector(_cmd), CGRectGetHeight(self.homeNavigationViewController.view.frame));
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
    LOG_FRAME(@"collectionContainerView", self.collectionContainerView.frame);

    if (!self.searchThisAreaView.hidden) {
        [self hideSearchThisArea:animated withCompletionBlock:nil];
    }

    CGFloat duration = animated ? 0.25f : 0.0f;
    UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState;
    [UIView animateWithDuration:duration delay:0.0f usingSpringWithDamping:0.8f initialSpringVelocity:10.f options:options animations:^{
        self.collectionContainerViewBottomConstraint.constant = CGRectGetHeight(self.collectionContainerView.frame);
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.collectionContainerView.hidden = TRUE;
        if (completionBlock) {
            completionBlock();
        }
    }];
}

- (void)showCollectionContainerView:(BOOL)animated withCompletionBlock:(void (^)())completionBlock {
    // set the bottom constraint to 0
    self.collectionContainerView.hidden = FALSE;
    
    CGFloat duration = animated ? 0.25f : 0.0f;
    UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState;
    [UIView animateWithDuration:duration delay:0.0f usingSpringWithDamping:0.8f initialSpringVelocity:10.f options:options animations:^{
        self.collectionContainerViewBottomConstraint.constant = 0.0f;
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        if (completionBlock) {
            completionBlock();
        }
    }];
}

- (void)showSearch:(BOOL)animated withCompletionBlock:(void (^)())completionBlock {
    NSAssert(self.navigationItem, @"Navigation Item is required");
    
    UIButton *cancelButton = [self makeButtonWithTitle:@"cancel" target:self action:@selector(searchCancelButtonTapped:)];
    CGRect cancelButtonFrame = cancelButton.frame;
    cancelButtonFrame.origin.x = 248.0f;
    cancelButtonFrame.origin.y = 6.0f;
    cancelButton.frame = cancelButtonFrame;
    // (20 * 2) for leading/trailing minus width of cancel button
    CGFloat textFieldWidth = CGRectGetWidth(self.view.frame) - 40.0f - CGRectGetWidth(cancelButton.frame);

    CGRect searchFrame = CGRectMake(16.0f, 7.0f, 30.0f, 30.0f);
    UITextField *searchTextField = [[UITextField alloc] initWithFrame:searchFrame];
    searchTextField.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.1f];
    [SHStyleKit setTextField:searchTextField textColor:SHStyleKitColorMyWhiteColor];
    searchTextField.alpha = 0.1f;
    searchTextField.font = [UIFont fontWithName:@"Lato-Light" size:14.0f];
    searchTextField.tintColor = [[SHStyleKit myWhiteColor] colorWithAlphaComponent:0.75f];
    searchTextField.autocapitalizationType = UITextAutocapitalizationTypeWords;

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
        
    } completion:^(BOOL finished) {
        searchTextField.placeholder = @"Find spot/drink or similar...";
        [searchTextField becomeFirstResponder];
        if (completionBlock) {
            completionBlock();
        }
    }];
}

- (void)hideSearch:(BOOL)animated withCompletionBlock:(void (^)())completionBlock {
    NSAssert(self.navigationItem, @"Navigation Item is required");
    
    [self restoreNormalNavigationItems:animated withCompletionBlock:completionBlock];
}

- (void)showSlidersSearch:(BOOL)animated forMode:(SHMode)mode withCompletionBlock:(void (^)())completionBlock {
    [self.slidersSearchViewController viewWillAppear:animated];
    
    [self prepareBlurredScreen];
    
    UIButton *cancelButton = [self makeButtonWithTitle:@"cancel" target:self action:@selector(searchSlidersCancelButtonTapped:)];
    CGRect cancelButtonFrame = cancelButton.frame;
    cancelButtonFrame.origin.x = 16.0f;
    cancelButtonFrame.origin.y = 6.0f;
    cancelButton.frame = cancelButtonFrame;
    UIBarButtonItem *searchSlidersCancelBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
    
    UIImageView *rightImageView = [[UIImageView alloc] initWithFrame:CGRectMake(274.0f, 7.0f, 30.0f, 30.0f)];
    
    switch (mode) {
        case SHModeSpots:
            [SHStyleKit setImageView:rightImageView withDrawing:SHStyleKitDrawingSpotIcon color:SHStyleKitColorMyWhiteColor];
            break;
        case SHModeBeer:
            [SHStyleKit setImageView:rightImageView withDrawing:SHStyleKitDrawingBeerIcon color:SHStyleKitColorMyWhiteColor];
            break;
        case SHModeCocktail:
            [SHStyleKit setImageView:rightImageView withDrawing:SHStyleKitDrawingCocktailIcon color:SHStyleKitColorMyWhiteColor];
            break;
        case SHModeWine:
            [SHStyleKit setImageView:rightImageView withDrawing:SHStyleKitDrawingWineIcon color:SHStyleKitColorMyWhiteColor];
            break;
            
        default:
            [SHStyleKit setImageView:rightImageView withDrawing:SHStyleKitDrawingSpotIcon color:SHStyleKitColorMyWhiteColor];
    }
    
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightImageView];
    
    // ensure the display order is correct
    [self.view bringSubviewToFront:self.blurredView];
    [self.view bringSubviewToFront:self.containerView];
    
    UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState;
    [UIView animateWithDuration:(animated ? kModalAnimationDuration : 0.0f) delay:0.1f options:options animations:^{
        
        self.blurredViewHeightConstraint.constant = CGRectGetHeight(self.view.frame);
        self.slidersSearchViewTopConstraint.constant = 0.0f;
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
        
        [self.navigationItem setLeftBarButtonItem:searchSlidersCancelBarButtonItem animated:animated];
        [self.navigationItem setRightBarButtonItem:rightBarButtonItem animated:animated];
        self.navigationItem.title = @"What do you feel like?";
        
        _isShowingSliderSearchView = TRUE;
        
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
    
    _isShowingSliderSearchView = FALSE;
    
    [self restoreNormalNavigationItems:animated withCompletionBlock:^{
        UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState;
        [UIView animateWithDuration:(animated ? kModalAnimationDuration : 0.0f) delay:0.1f options:options animations:^{
            
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
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
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
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.areYouHerePromptView.hidden = TRUE;
        self.areYouHerePromptLabel.text = nil;
        
        if (completionBlock) {
            completionBlock();
        }
    }];
}

- (void)showSearchThisArea:(BOOL)animated withCompletionBlock:(void (^)())completionBlock {
    // Note: it will be necessary to hide another view if it is visible while this button is shown
    
    if (!self.areYouHerePromptView.hidden) {
        [self hideAreYouHerePrompt:TRUE withCompletionBlock:nil];
    }
    
    self.searchThisAreaView.alpha = 0.0f;
    self.searchThisAreaView.hidden = FALSE;
    [self.view bringSubviewToFront:self.searchThisAreaView];

    CGRect bottomFrame = [self bottomFrame];
    CGFloat distanceFromBottom = CGRectGetHeight(bottomFrame) + self.bottomLayoutGuide.length;
    self.searchThisAreaBottomConstraint.constant = distanceFromBottom + 10.0f;
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];

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
    } completion:^(BOOL finished) {
        self.searchThisAreaView.hidden = TRUE;
        if (completionBlock) {
            completionBlock();
        }
    }];
}

#pragma mark - User Actions
#pragma mark -

- (IBAction)sideBarButtonTapped:(id)sender {
    [self toggleSideBar:TRUE withCompletionBlock:^{
        NSLog(@"Toggled Side Bar");
    }];
}

- (IBAction)searchButtonTapped:(id)sender {
    [self showSearch:TRUE withCompletionBlock:nil];
}

- (IBAction)searchThisAreaButtonTapped:(id)sender {
    DebugLog(@"%@", NSStringFromSelector(_cmd));
    
    [self hideSearchThisArea:TRUE withCompletionBlock:^{
        if ([self canSearchAgain]) {
            [self searchAgain];
        }
    }];
}

- (IBAction)areYouHereYesButtonTapped:(id)sender {
    if (self.nearbySpots.count) {
        SpotModel *spot = self.nearbySpots[0];
        [self displaySpotDrinkListForSpot:spot];
    }
}

- (IBAction)areYouHereNoButtonTapped:(id)sender {
    _isSpotDrinkList = FALSE;
    [self hideAreYouHerePrompt:TRUE withCompletionBlock:nil];
}

- (IBAction)compassButtonTapped:(id)sender {
    [self repositionOnCurrentDeviceLocation:YES];
}

- (IBAction)searchCancelButtonTapped:(id)sender {
    [self hideSearch:TRUE withCompletionBlock:^{
    }];
}

- (IBAction)searchSlidersCancelButtonTapped:(id)sender {
    [self hideSlidersSearch:TRUE forMode:self.mode withCompletionBlock:^{
        NSLog(@"Slider search should now be hidden");

        if (self.mode == SHModeNone) {
            [self showHomeNavigation:TRUE withCompletionBlock:nil];
        }
        else {
            [self showCollectionContainerView:TRUE withCompletionBlock:nil];
        }
    }];
}

- (IBAction)cancelBackToHomeMap:(UIStoryboardSegue *)segue {
    // get back to the home map view
    [self restoreNavigationIfNeeded];
}

#pragma mark - Navigation
#pragma mark -

- (void)goToSpots {
    // updating the location is redundant, but necessary to ensure it is current
    
    NSAssert(FALSE, @"This method should no longer be called");
    
    if ([self promptLoginNeeded:@"Please log in before creating a Spotlist"] == NO) {
        [self prepareToDisplaySliderSearchWithCompletionBlock:^{
            TellMeMyLocation *tellMeMyLocation = [[TellMeMyLocation alloc] init];
            [tellMeMyLocation findMe:kCLLocationAccuracyHundredMeters found:^(CLLocation *newLocation) {
                _currentLocation = newLocation;
                [self performSegueWithIdentifier:@"HomeMapToSpots" sender:self];
            } failure:^(NSError *error) {
                [Tracker logError:error class:[self class] trace:NSStringFromSelector(_cmd)];
            }];
        }];
    }
}

- (IBAction)unwindFromProfileViewToHomeMapViewController:(UIStoryboardSegue*)unwindSegue {
}

- (IBAction)unwindFromSpotProfileToHomeMapViewControllerFindSimilar:(UIStoryboardSegue*)unwindSegue {
    NSLog(@"made it back!");
    
    if ([unwindSegue.sourceViewController isKindOfClass:[SHSpotProfileViewController class]]) {
        SHSpotProfileViewController *spotProfileViewController = unwindSegue.sourceViewController;
        SpotModel *spot __unused = spotProfileViewController.spot;
        
        //todo: api call to find similar spots and display
        NSString *name = [NSString stringWithFormat:@"Similar to %@", spot.name];
        
        [SpotListModel postSpotList:name spotId:spot.ID spotTypeId:spot.spotType.ID latitude:spot.latitude longitude:spot.longitude sliders:spot.averageReview.sliders successBlock:^(SpotListModel *spotListModel, JSONAPI *jsonApi) {
            [self hideHUD];
            
            if (spotListModel) {
                [self displaySpotlist:spotListModel];
            }
          
            
        } failure:^(ErrorModel *errorModel) {
            [self hideHUD];
            [self showAlert:@"Oops" message:errorModel.human];
            [Tracker logError:errorModel class:[self class] trace:NSStringFromSelector(_cmd)];
        }];
        
        
    }

}

#pragma mark - Private
#pragma mark -

- (void)restoreNavigationIfNeeded {
    if (self.homeNavigationViewController.view.hidden && self.collectionContainerView.hidden) {
        if (self.drinkListModel.drinks.count || self.specialsSpotModels.count || self.spotListModel.spots.count) {
            [self showCollectionContainerView:TRUE withCompletionBlock:nil];
        }
        else {
            [self showHomeNavigation:true withCompletionBlock:nil];
        }
    }
}

- (void)prepareToDisplaySliderSearchWithCompletionBlock:(void (^)())completionBlock {
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

- (void)showSpotsSearch {
    if (![self promptLoginNeeded:@"Cannot create a spotlist without logging in"]) {
        [self.slidersSearchViewController prepareForMode:SHModeSpots];
        
        [self prepareToDisplaySliderSearchWithCompletionBlock:^{
            [self showSlidersSearch:TRUE forMode:SHModeSpots withCompletionBlock:^{
            }];
        }];
    }
}

- (void)showBeersSearch {
    if (![self promptLoginNeeded:@"Cannot create a drinklist without logging in"]) {
        [self.slidersSearchViewController prepareForMode:SHModeBeer];
        
        [self prepareToDisplaySliderSearchWithCompletionBlock:^{
            [self showSlidersSearch:TRUE forMode:SHModeBeer withCompletionBlock:^{
            }];
        }];
    }
}

- (void)showCocktailsSearch {
    if (![self promptLoginNeeded:@"Cannot create a spotlist without logging in"]) {
        [self.slidersSearchViewController prepareForMode:SHModeCocktail];

        [self prepareToDisplaySliderSearchWithCompletionBlock:^{
            [self showSlidersSearch:TRUE forMode:SHModeCocktail withCompletionBlock:^{
            }];
        }];
    }
}

- (void)showWineSearch {
    if (![self promptLoginNeeded:@"Cannot create a spotlist without logging in"]) {
        [self.slidersSearchViewController prepareForMode:SHModeWine];
        
        [self prepareToDisplaySliderSearchWithCompletionBlock:^{
            [self showSlidersSearch:TRUE forMode:SHModeWine withCompletionBlock:^{
            }];
        }];
    }
}

- (void)displaySpotlist:(SpotListModel *)spotListModel {
    // hold onto the spotlist
    
    self.mode = SHModeSpots;
    
    self.drinkListModel = nil;
    self.specialsSpotModels = nil;
    self.spotListModel = spotListModel;
    
    self.navigationItem.title = spotListModel.name;
    
    self.currentIndex = 0;
    
    if (!self.spotListModel.spots.count) {
        [self showAlert:@"Oops" message:@"There are no spots which match in this location. Please try another search area."];
        [self showHomeNavigation:TRUE withCompletionBlock:nil];
        return;
    }
    
    [self.mapOverlayCollectionViewController displaySpotList:spotListModel];
    [self populateMapWithSpots:self.spotListModel.spots];

    if (!self.homeNavigationViewController.view.hidden) {
        [self hideHomeNavigation:FALSE withCompletionBlock:nil];
    }
    
    [self showCollectionContainerView:TRUE withCompletionBlock:^{
        // do nothing
    }];
}

- (void)displaySpecialsForSpots:(NSArray *)spots {
    NSLog(@"spots: %@", spots);
    
    self.mode = SHModeSpecials;
    
    self.spotListModel = nil;
    self.drinkListModel = nil;
    self.specialsSpotModels = spots;
    
    self.navigationItem.title = @"Specials";
    
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

- (void)displayDrinklist:(DrinkListModel *)drinkListModel {
    if (!drinkListModel.drinks.count) {
        [self showAlert:@"Oops" message:@"There are no drinks which match in this location. Please try another search area."];
        [self restoreNavigationIfNeeded];
        return;
    }

    // hold onto the drinklist
    self.spotListModel = nil;
    self.specialsSpotModels = nil;
    self.drinkListModel = drinkListModel;
    
    self.navigationItem.title = drinkListModel.name;
    
    self.currentIndex = 0;
    
    // clear the map right away because it may currently show other results
    [self.mapView removeAnnotations:[self.mapView annotations]];
    
    if (self.drinkListModel.drinks.count) {
        DrinkModel *drink = self.drinkListModel.drinks[0];
        [self updateMapWithCurrentDrink:drink];
    }
    
    if (!self.homeNavigationViewController.view.hidden) {
        [self hideHomeNavigation:FALSE withCompletionBlock:nil];
    }
    
    [self.mapOverlayCollectionViewController displayDrinklist:drinkListModel];
    
    [self showCollectionContainerView:TRUE withCompletionBlock:^{
        // prompt the user to select the nearest spot with a 1 hour period between prompts
        NSTimeInterval seconds = self.lastAreYouHerePrompt ? [[NSDate date] timeIntervalSinceDate:self.lastAreYouHerePrompt] : NSIntegerMax;

        // 20 minutes between prompts (does not account for last spot user selected)
        if (seconds > 1200 && self.nearbySpots.count) {
            SpotModel *nearestSpot = self.nearbySpots[0];
            CLLocation *nearestLocation = [[CLLocation alloc] initWithLatitude:nearestSpot.latitude.floatValue longitude:nearestSpot.longitude.floatValue];
            CLLocationDistance meters = [_currentLocation distanceFromLocation:nearestLocation];
            if (meters < 200) {
                [self showAreYouHerePromptForSpot:nearestSpot animated:TRUE withCompletionBlock:nil];
                self.lastAreYouHerePrompt = [NSDate date];
            }
        }
    }];
}

- (void)displaySpotDrinkListForSpot:(SpotModel *)spot {
    _isSpotDrinkList = TRUE;
    
    [self hideAreYouHerePrompt:TRUE withCompletionBlock:^{
        DrinkListRequest *request = [self.drinkListRequest copy];
        request.name = kDrinkListModelDefaultName;
        request.spotId = spot.ID;
        
        self.selectedSpot = spot;
        [self.locationMenuBarViewController selectSpotDrinkListForSpot:spot];
        
        [DrinkListModel fetchDrinkListWithRequest:request success:^(DrinkListModel *drinkListModel) {
            DebugLog(@"drinkListModel: %@", drinkListModel);
            [self displayDrinklist:drinkListModel];
        } failure:^(ErrorModel *errorModel) {
            [Tracker logError:errorModel class:[self class] trace:NSStringFromSelector(_cmd)];
            // TODO: tell the user about the error
        }];
        
        [self showSearchThisArea:TRUE withCompletionBlock:nil];
    }];
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
    
    // add a shadow
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:self.areYouHerePromptView.bounds];
    self.areYouHerePromptView.layer.masksToBounds = NO;
    self.areYouHerePromptView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.areYouHerePromptView.layer.shadowOffset = CGSizeMake(0.0f, 5.0f);
    self.areYouHerePromptView.layer.shadowOpacity = 0.35f;
    self.areYouHerePromptView.layer.shadowRadius = 10.0f;
    self.areYouHerePromptView.layer.shadowPath = shadowPath.CGPath;
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
            DebugLog("spots: %@", spots);
            self.nearbySpots = spots;
            
            [self hideAndShowPrompt];

        } fail:^(ErrorModel *errorModel) {
            [Tracker logError:errorModel class:[self class] trace:NSStringFromSelector(_cmd)];
        } always:^{
        }];
    }
}

- (void)fetchSpecials {
    [self showHUD:@"Finding specials"];
    
    self.spotListRequest = nil;
    self.drinkListRequest = nil;
    
    [self prepareToDisplaySliderSearchWithCompletionBlock:^{
        [SpotModel getSpotsWithSpecialsTodayForCoordinate:[self visibleMapCenterCoordinate] success:^(NSArray *spotModels, JSONAPI *jsonApi) {
            [self hideHUD];
            [self displaySpecialsForSpots:spotModels];
        } failure:^(ErrorModel *errorModel) {
            [Tracker logError:errorModel.human class:[self class] trace:NSStringFromSelector(_cmd)];
            // TODO: tell the user abou the error
        }];
    }];
}

- (void)hideAndShowPrompt {
    
//    if (self.nearbySpots.count) {
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
//            [self showAreYouHerePromptForSpot:self.nearbySpots[0] animated:TRUE withCompletionBlock:^{
//                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3.0f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
//                    [self hideAreYouHerePrompt:TRUE withCompletionBlock:nil];
//                    
//                    [self performSelector:@selector(hideAndShowPrompt) withObject:nil afterDelay:3.0f];
//                    
//                });
//            }];
//        });
//    }
    
//    [self hideHomeNavigation:TRUE withCompletionBlock:^{
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3.0f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
//            [self showHomeNavigation:TRUE withCompletionBlock:^{
//                [self performSelector:@selector(hideAndShowPrompt) withObject:nil afterDelay:3.0f];
//            }];
//        });
//    }];
    
//    [self hideHomeNavigation:FALSE withCompletionBlock:nil];
//    [self hideCollectionContainerView:TRUE withCompletionBlock:^{
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3.0f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
//            [self showCollectionContainerView:TRUE withCompletionBlock:^{
//                [self performSelector:@selector(hideAndShowPrompt) withObject:nil afterDelay:3.0f];
//            }];
//        });
//    }];
}

- (void)updateMapWithCurrentDrink:(DrinkModel *)drink {
    if (_isSpotDrinkList && self.selectedSpot) {
        [self populateMapWithSpots:@[self.selectedSpot]];
        self.spotsForDrink = @[self.selectedSpot];
    }
    else {
        CLLocationCoordinate2D coordinate = self.drinkListRequest.coordinate;
        CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
        
        self.selectedDrink = drink;
        [[drink fetchSpotsForLocation:location] then:^(NSArray *spots) {
            [self populateMapWithSpots:spots];
            self.spotsForDrink = spots;
        } fail:^(ErrorModel *errorModel) {
            [Tracker logError:errorModel.human class:[self class] trace:NSStringFromSelector(_cmd)];
        } always:nil];
    }
}

- (void)populateMapWithSpots:(NSArray *)spots {
    NSAssert(self.mapView, @"Map View is required");
    
    if (spots.count == 1) {
        NSUInteger matches = 0;
        NSUInteger otherMatches = 0;
        // skip if this spot is already the only one shown
        for (id<MKAnnotation>annotation in [self.mapView annotations]) {
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
    
    [self repositionMapOnAnnotations:self.mapView.annotations animated:TRUE];
    
    // TODO: fix issue for calling being shown when it should not (only for drinklists when selected)
    if (!self.drinkListModel || self.selectedSpot) {
        if ([spots containsObject:self.selectedSpot]) {
            [self selectSpot:self.selectedSpot];
        }
//        else if (spots.count) {
//            [self selectSpot:spots[0]];
//        }
    }
}

- (void)selectSpot:(SpotModel *)spot {
    for (id<MKAnnotation>annotation in self.mapView.annotations) {
        if ([annotation isKindOfClass:[MatchPercentAnnotation class]]) {
            MatchPercentAnnotation *matchAnnotation = (MatchPercentAnnotation *)annotation;
            if ([spot isEqual:matchAnnotation.spot]) {
                DebugLog(@"selecting spot: %@", spot.name);
                [self.mapView selectAnnotation:annotation animated:TRUE];
            }
        }
    }
}

- (void)repositionOnCurrentDeviceLocation:(BOOL)animated {
    [self.locationMenuBarViewController updateLocationTitle:@"Locating..."];
    
    TellMeMyLocation *tellMeMyLocation = [[TellMeMyLocation alloc] init];
    [tellMeMyLocation findMe:kCLLocationAccuracyNearestTenMeters found:^(CLLocation *newLocation) {
        _currentLocation = newLocation;
        [TellMeMyLocation setLastLocation:newLocation completionHandler:^{
            NSLog(@"lastLocationName: %@", [TellMeMyLocation lastLocationName]);
            [self.locationMenuBarViewController updateLocationTitle:[TellMeMyLocation lastLocationName]];
        }];
        [self repositionMapOnCoordinate:_currentLocation.coordinate animated:animated];
        [self fetchNearbySpotsAtLocation:_currentLocation];
    } failure:^(NSError *error) {
        [Tracker logError:error class:[self class] trace:NSStringFromSelector(_cmd)];
    }];
}

- (void)repositionMapOnCoordinate:(CLLocationCoordinate2D)coordinate animated:(BOOL)animated {
    _isRepositioningMap = TRUE;
    
    MKMapRect mapRect = MKMapRectNull;
    MKMapPoint mapPoint = MKMapPointForCoordinate(coordinate);
    
    CGFloat padding = kMapPadding;
    mapRect.origin.x = mapPoint.x - padding/2;
    mapRect.origin.y = mapPoint.y - padding/2;
    mapRect.size = MKMapSizeMake(MKMapRectGetWidth(mapRect) + padding, MKMapRectGetHeight(mapRect) + padding);
    
    UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState;
    [UIView animateWithDuration:0.5 delay:0.0 options:options animations:^{
        [self.mapView setVisibleMapRect:mapRect edgePadding:UIEdgeInsetsMake([self topEdgePadding], 45.0f, [self bottomEdgePadding], 45.0f) animated:animated];
    } completion:^(BOOL finished) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.25 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            _isRepositioningMap = FALSE;
        });
    }];
}

- (void)repositionMapOnAnnotations:(NSArray *)annotations animated:(BOOL)animated {
    _isRepositioningMap = TRUE;
    
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
                [self.mapView setVisibleMapRect:mapRect edgePadding:UIEdgeInsetsMake([self topEdgePadding], 45.0, [self bottomEdgePadding], 45.0) animated:animated];
            } completion:^(BOOL finished) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.25 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                    _isRepositioningMap = FALSE;
                });

            }];
        });
    }
    else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.25 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            _isRepositioningMap = FALSE;
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
    return CGRectGetHeight(topFrame) + self.topLayoutGuide.length + 40.f;
}

- (CGFloat)bottomEdgePadding {
    CGRect bottomFrame = [self bottomFrame];
    return CGRectGetHeight(bottomFrame) + self.bottomLayoutGuide.length;
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
    self.navigationItem.title = self.title;
    
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
        [self.view addSubview:blurredView];
        
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
    
    if (_isShowingSliderSearchView && !_isOverlayAnimating) {
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

- (void)searchAgain {
    [self flashSearchRegion];
    
    if (self.mode == SHModeSpecials) {
        [self fetchSpecials];
    }
    else if (self.drinkListRequest) {
        DrinkListRequest *request = [self.drinkListRequest copy];
        request.spotId = nil;
        request.coordinate = [self visibleMapCenterCoordinate];
        request.radius = [self searchRadius];
        
        _isSpotDrinkList = FALSE;
        [self.locationMenuBarViewController deselectSpotDrinkList];
        
        [DrinkListModel fetchDrinkListWithRequest:request success:^(DrinkListModel *drinkListModel) {
            self.selectedSpot = nil;
            [self displayDrinklist:drinkListModel];
        } failure:^(ErrorModel *errorModel) {
            // TODO: track error
        }];
    }
    else if (self.spotListRequest) {
        SpotListRequest *request = [self.spotListRequest copy];
        request.coordinate = [self visibleMapCenterCoordinate];
        request.radius = [self searchRadius];
        
        [SpotListModel fetchSpotListWithRequest:request success:^(SpotListModel *spotListModel) {
            [self displaySpotlist:spotListModel];
        } failure:^(ErrorModel *errorModel) {
            // TODO: track error
        }];
    }
}

#pragma mark - SHSidebarDelegate
#pragma mark -

- (void)sidebarViewController:(SHSidebarViewController*)vc didTapSearchTextField:(id)sender {
    [self hideSideBar:TRUE withCompletionBlock:^{
        [self showSearch:TRUE withCompletionBlock:nil];
    }];
}

- (void)sidebarViewController:(SHSidebarViewController*)vc closeButtonTapped:(id)sender {
    [self hideSideBar:TRUE withCompletionBlock:^{
        NSLog(@"Closed Side Bar");
    }];
}

- (void)sidebarViewController:(SHSidebarViewController*)vc spotsButtonTapped:(id)sender {
    [self hideSideBar:TRUE withCompletionBlock:^{
        [self showSpotsSearch];
    }];
}

- (void)sidebarViewController:(SHSidebarViewController*)vc drinksButtonTapped:(id)sender {
    // TODO: break into beer, cocktail and wine
    [self hideSideBar:TRUE withCompletionBlock:^{
        [self showBeersSearch];
    }];
}

- (void)sidebarViewController:(SHSidebarViewController*)vc specialsButtonTapped:(id)sender {
    [self hideSideBar:true withCompletionBlock:^{
        [self fetchSpecials];
    }];
}

- (void)sidebarViewController:(SHSidebarViewController*)vc reviewButtonTapped:(id)sender {
    [self hideSideBar:TRUE withCompletionBlock:^{
        // TODO: implement
    }];
}

- (void)sidebarViewController:(SHSidebarViewController*)vc checkinButtonTapped:(id)sender {
    // TODO: implement
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)sidebarViewController:(SHSidebarViewController*)vc accountButtonTapped:(id)sender {
    [self hideSideBar:TRUE withCompletionBlock:^{
        [self goToAccountSettings:TRUE];
    }];
}

#pragma mark - SHLocationMenuBarDelegate
#pragma mark -

- (void)locationMenuBarViewControllerDidRequestLocationChange:(SHLocationMenuBarViewController *)vc {
    NSLog(@"Change Location!");
}

- (void)locationMenuBarViewController:(SHLocationMenuBarViewController *)vc didSelectSpot:(SpotModel *)spot {
    [self displaySpotDrinkListForSpot:spot];
}

- (void)locationMenuBarViewController:(SHLocationMenuBarViewController *)vc didDeselectSpot:(SpotModel *)spot {
    [self searchAgain];
}

#pragma mark - SHHomeNavigationDelegate
#pragma mark -

- (void)homeNavigationViewController:(SHHomeNavigationViewController *)vc spotsButtonTapped:(id)sender {
    [self showSpotsSearch];
}

- (void)homeNavigationViewController:(SHHomeNavigationViewController *)vc specialsButtonTapped:(id)sender {
    [self fetchSpecials];
}

- (void)homeNavigationViewController:(SHHomeNavigationViewController *)vc beersButtonTapped:(id)sender {
    [self showBeersSearch];
}

- (void)homeNavigationViewController:(SHHomeNavigationViewController *)vc cocktailsButtonTapped:(id)sender {
    [self showCocktailsSearch];
}

- (void)homeNavigationViewController:(SHHomeNavigationViewController *)vc winesButtonTapped:(id)sender {
    [self showWineSearch];
}

#pragma mark - SHMapOverlayCollectionDelegate   
#pragma mark -

- (void)mapOverlayCollectionViewController:(SHMapOverlayCollectionViewController *)vc didChangeToSpotAtIndex:(NSUInteger)index {
    DebugLog(@"%@ (%lu)", NSStringFromSelector(_cmd), (unsigned long)index);
    if (self.mode == SHModeSpots && index < self.spotListModel.spots.count) {
        SpotModel *spot = self.spotListModel.spots[index];
        NSLog(@"HomeMap: didChangeToSpotAtIndex: %@", spot.name);
        [self selectSpot:spot];
    }
    else if (self.mode == SHModeSpecials && index < self.specialsSpotModels.count) {
        SpotModel *spot = self.specialsSpotModels[index];
        NSLog(@"HomeMap: didChangeToSpotAtIndex: %@", spot.name);
        [self selectSpot:spot];
    }
}

- (void)mapOverlayCollectionViewController:(SHMapOverlayCollectionViewController *)vc didSelectSpotAtIndex:(NSUInteger)index {
    // Note: Do not focus on spot when spot is selected

    if (self.spotListModel && index < self.spotListModel.spots.count) {
        self.selectedSpot = self.spotListModel.spots[index];
        [self performSegueWithIdentifier:HomeMapToSpotProfile sender:self];
    }
    else if (self.specialsSpotModels && index < self.specialsSpotModels.count) {
        self.selectedSpot = self.specialsSpotModels[index];
        [self performSegueWithIdentifier:HomeMapToSpotProfile sender:self];
    }
    else if (self.drinkListModel && index < self.spotsForDrink.count) {
        self.selectedSpot = self.spotsForDrink[index];
        [self performSegueWithIdentifier:HomeMapToSpotProfile sender:self];
    }
}

- (void)mapOverlayCollectionViewController:(SHMapOverlayCollectionViewController *)vc didChangeToDrinkAtIndex:(NSUInteger)index {
    DebugLog(@"%@ (%lu)", NSStringFromSelector(_cmd), (unsigned long)index);
    
    if (self.drinkListModel.drinks.count && index < self.drinkListModel.drinks.count) {
        DrinkModel *drink = self.drinkListModel.drinks[index];
        [self updateMapWithCurrentDrink:drink];
    }
}

- (void)mapOverlayCollectionViewController:(SHMapOverlayCollectionViewController *)vc didSelectDrinkAtIndex:(NSUInteger)index {
    DebugLog(@"%@ (%lu)", NSStringFromSelector(_cmd), (unsigned long)index);
    
    if (self.drinkListModel.drinks.count && index < self.drinkListModel.drinks.count) {
        self.selectedDrink = self.drinkListModel.drinks[index];

        // TODO: do not perform a segue on itself (this makes no sense)
        [self performSegueWithIdentifier:HomeMapToDrinkProfile sender:self];
    }
    else {
        NSAssert(FALSE, @"Index should always be in bounds");
    }
}

#pragma mark - SHMapFooterNavigationDelegate
#pragma mark -

- (void)footerNavigationViewController:(SHMapFooterNavigationViewController *)vc spotsButtonTapped:(id)sender {
    [self showSpotsSearch];
}

- (void)footerNavigationViewController:(SHMapFooterNavigationViewController *)vc specialsButtonTapped:(id)sender {
    [self fetchSpecials];
}

- (void)footerNavigationViewController:(SHMapFooterNavigationViewController *)vc beersButtonTapped:(id)sender {
    [self showBeersSearch];
}

- (void)footerNavigationViewController:(SHMapFooterNavigationViewController *)vc cocktailsButtonTapped:(id)sender {
    [self showCocktailsSearch];
}

- (void)footerNavigationViewController:(SHMapFooterNavigationViewController *)vc winesButtonTapped:(id)sender {
    [self showWineSearch];
}

#pragma mark - SpotAnnotationCalloutDelegate
#pragma mark -

- (void)spotAnnotationCallout:(SpotAnnotationCallout*)spotAnnotationCallout clicked:(MatchPercentAnnotationView*)matchPercentAnnotationView {
    // only change context to Spot Drinklist if the drinklist request is defined
    if (self.drinkListRequest) {
        [self displaySpotDrinkListForSpot:matchPercentAnnotationView.spot];
    }
}

#pragma mark - SHSlidersSearchDelegate
#pragma mark -

- (void)slidersSearchViewController:(SHSlidersSearchViewController *)vc didPrepareSpotlist:(SpotListModel *)spotlist withRequest:(SpotListRequest *)request forMode:(SHMode)mode {
    self.mode = mode;
    _isSpotDrinkList = FALSE;
    self.spotListRequest = request;
    self.drinkListRequest = nil;
    [self hideSlidersSearch:TRUE forMode:mode withCompletionBlock:^{
        [self displaySpotlist:spotlist];
    }];
}

- (void)slidersSearchViewController:(SHSlidersSearchViewController *)vc didPrepareDrinklist:(DrinkListModel *)drinklist withRequest:(DrinkListRequest *)request forMode:(SHMode)mode {
    self.mode = mode;
    _isSpotDrinkList = FALSE;
    self.drinkListRequest = request;
    self.spotListRequest = nil;
    [self hideSlidersSearch:TRUE forMode:mode withCompletionBlock:^{
        [self displayDrinklist:drinklist];
    }];
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

#pragma mark - MKMapViewDelegate
#pragma mark -

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    MKAnnotationView *annotationView = nil;
    
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        // do nothing
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
                pin.drawing = SHStyleKitDrawingNone;
                break;
            case SHModeSpecials:
                pin.drawing = SHStyleKitDrawingSpecialsIcon;
                break;
            case SHModeBeer:
                pin.drawing = _isSpotDrinkList ? SHStyleKitDrawingBeerDrinklistIcon : SHStyleKitDrawingBeerIcon;
                break;
            case SHModeCocktail:
                pin.drawing = _isSpotDrinkList ? SHStyleKitDrawingCocktailDrinklistIcon : SHStyleKitDrawingCocktailIcon;
                break;
            case SHModeWine:
                pin.drawing = _isSpotDrinkList ? SHStyleKitDrawingWineIcon : SHStyleKitDrawingWineIcon;
                break;
                
            default:
                break;
        }
        
        pin.useLargeIcon = _isSpotDrinkList;
        [pin prepareForReuse];
        [pin setSpot:matchPercentAnnotation.spot highlighted:_isSpotDrinkList];
        
        pin.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        pin.canShowCallout = NO;
        
        // precache the menu details
        [pin.spot fetchMenu];
        
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
        
        circleView.strokeColor = [[SHStyleKit color:SHStyleKitColorMyTextColor] colorWithAlphaComponent:0.35f];
        circleView.fillColor = [[SHStyleKit color:SHStyleKitColorMyTintColor] colorWithAlphaComponent:0.1f];
        circleView.lineWidth = 1.0f;
        circleView.alpha = 1.0f;
        
        return circleView;
    }
    
    return nil;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    if ([view isKindOfClass:[MatchPercentAnnotationView class]] == YES) {
        MatchPercentAnnotationView *pin = (MatchPercentAnnotationView*) view;
        
        if (!pin.isHighlighted) {
            pin.highlighted = YES;
            
            if (self.mode == SHModeBeer || self.mode == SHModeCocktail || self.mode == SHModeWine) {
                DebugLog(@"showing filter");
                [self.locationMenuBarViewController selectSpot:pin.spot];
            }
            
            if (self.drinkListRequest && self.selectedDrink && [view isKindOfClass:[MatchPercentAnnotationView class]]) {
                MatchPercentAnnotationView *pin = (MatchPercentAnnotationView *)view;
                
                [[pin.spot fetchMenu] then:^(MenuModel *menu) {
                    // TODO: get drink
                    MenuItemModel *menuItem = [menu menuItemForDrink:self.selectedDrink];
                    NSArray *prices = [menu pricesForMenuItem:menuItem];
                    
                    NSString *spotName = [NSString stringWithFormat:@"%@ (%@)", pin.spot.name, pin.spot.spotType.name];
                    NSString *drink1 = prices.count > 0 ? prices[0] : nil;
                    NSString *drink2 = prices.count > 1 ? prices[1] : nil;
                    
                    BOOL isBeerOnTap = [menu isBeerOnTap:menuItem];
                    BOOL isBeerInBottle = [menu isBeerInBottle:menuItem];
                    BOOL isCocktail = [menu isCocktail:menuItem];
                    BOOL isWine = [menu isWine:menuItem];
                    
                    SpotCalloutIcon calloutIcon = SpotCalloutIconNone;
                    
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
                    
                    UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:SpotCalloutViewIdentifier];
                    
                    SpotCalloutView *calloutView = (SpotCalloutView *)vc.view;
                    calloutView.translatesAutoresizingMaskIntoConstraints = YES;
                    
                    calloutView.tag = NSIntegerMax;
                    calloutView.alpha = 0.0f;
                    
                    [view addSubview:calloutView];
                    [calloutView setIcon:calloutIcon spotNameText:spotName drink1Text:drink1 drink2Text:drink2];
                    calloutView.center = CGPointMake((CGRectGetWidth(view.bounds) / 2.0) + 2.0, -1.0 * CGRectGetHeight(calloutView.frame) / 2);
                    
                    _isRepositioningMap = TRUE;
                    UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState;
                    [UIView animateWithDuration:0.25f delay:0.0f usingSpringWithDamping:9.0 initialSpringVelocity:9.0 options:options animations:^{
                        calloutView.alpha = 1.0f;
                        [self.mapView setCenterCoordinate:view.annotation.coordinate animated:TRUE];
                    } completion:^(BOOL finished) {
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.25f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                            _isRepositioningMap = FALSE;
                        });
                    }];
                } fail:^(ErrorModel *errorModel) {
                    [self showAlert:@"Oops" message:errorModel.human];
                    [Tracker logError:errorModel class:[self class] trace:NSStringFromSelector(_cmd)];
                } always:nil];
            }
            
            CGPoint point = [mapView convertCoordinate:view.annotation.coordinate toPointToView:mapView];
            NSLog(@"point: %f, %f", point.x, point.y);
            
            // disable callout for now
//            if (self.mode == SHModeBeer || self.mode == SHModeCocktail || self.mode == SHModeWine) {
//                SpotAnnotationCallout *callout = [SpotAnnotationCallout viewFromNib];
//                [callout setMatchPercentAnnotationView:pin];
//                [callout setDelegate:self];
//                [callout setFrame:CGRectMake(0.0f, -CGRectGetHeight(callout.frame), CGRectGetWidth(callout.frame), CGRectGetHeight(callout.frame))];
//                
//                [pin setCalloutView:callout];
//                
//                [pin setUserInteractionEnabled:YES];
//                [pin addSubview:callout];
//            }
            
            [pin setNeedsDisplay];

            NSLog(@"HomeMap - Did select spot on map: %@", pin.spot.name);
            [self.mapOverlayCollectionViewController displaySpot:pin.spot];
        }
    }
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    if ([view isKindOfClass:[MatchPercentAnnotationView class]] == YES) {
        MatchPercentAnnotationView *pin = (MatchPercentAnnotationView*) view;
        [pin setHighlighted:NO];
        [pin setNeedsDisplay];
        
        UIView *calloutView = [view viewWithTag:NSIntegerMax];
        [calloutView removeFromSuperview];
        
        DebugLog(@"hiding filter (and clearing label)");
        [self.locationMenuBarViewController deselectSpot:pin.spot];
    }
}

- (void)flashSearchRegion {
    CLLocationCoordinate2D center = [self visibleMapCenterCoordinate];
    CGFloat radius = [self searchRadius];
    
    DebugLog(@"center: %f, %f", center.latitude, center.longitude);
    DebugLog(@"radius: %f", radius);
    
    MKCircle *circleOverlay = [MKCircle circleWithCenterCoordinate:center radius:radius];
    [self.mapView addOverlay:circleOverlay];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self.mapView removeOverlay:circleOverlay];
    });
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    if (_isRepositioningMap) {
        return;
    }
    
    [self flashSearchRegion];
    
//    CGRect visibleFrame = [self.mapView convertRegion:[self visibleMapRegion] toRectToView:self.mapView];
//    __block UIView *markerView = [[UIView alloc] initWithFrame:visibleFrame];
//    markerView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.75f];
//    markerView.alpha = 0.0f;
//    [self.view addSubview:markerView];
//    [self.view bringSubviewToFront:markerView];
//    
//    UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState;
//    CGFloat duration = 0.25f;
//    [UIView animateWithDuration:duration delay:0.0f options:options animations:^{
//        markerView.alpha = 1.0f;
//    } completion:^(BOOL finished) {
//        [UIView animateWithDuration:duration delay:0.0f options:options animations:^{
//            markerView.alpha = 0.0f;
//        } completion:^(BOOL finished) {
//            [markerView removeFromSuperview];
//            markerView = nil;
//        }];
//    }];
    
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

@end
