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
#import "SHAdjustSpotListSliderViewController.h"
#import "SHSlidersSearchViewController.h"
#import "SHMapOverlayCollectionViewController.h"
#import "SHMapFooterNavigationViewController.h"
#import "SHSpotProfileViewController.h"

#import "SpotAnnotationCallout.h"
#import "MatchPercentAnnotation.h"
#import "MatchPercentAnnotationView.h"

#import "SHButtonLatoBold.h"

#import "TellMeMyLocation.h"
#import "Tracker.h"

#import "SpotModel.h"
#import "SliderModel.h"
#import "SliderTemplateModel.h"
#import "ErrorModel.h"

#import "UIImage+BlurredFrame.h"
#import "UIImage+ImageEffects.h"

#import "TTTAttributedLabel.h"
#import "TTTAttributedLabel+QuickFonting.h"

#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <QuartzCore/QuartzCore.h>

#define kMeterToMile 0.000621371f
#define kDebugAnnotationViewPositions FALSE

#define kCollectionContainerViewHeight 200.0f
#define kCollectionViewHeight 150.0f
#define kFooterNavigationViewHeight 50.0f

#define kBlurRadius 2.5f
#define kBlurSaturation 1.5f

#define kModalAnimationDuration 0.35f

NSString* const SpotSelectedSegueIdentifier = @"HomeMapToSpotProfile";

@interface SHHomeMapViewController ()
    <SHSidebarDelegate,
    SHLocationMenuBarDelegate,
    SHHomeNavigationDelegate,
    SHMapOverlayCollectionDelegate,
    SHMapFooterNavigationDelegate,
    SHSpotsCollectionViewManagerDelegate,
    SHAdjustSliderListSliderDelegate,
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

@property (weak, nonatomic) IBOutlet UIView *checkInPromptView;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *checkInPromptLabel;
@property (weak, nonatomic) IBOutlet UIButton *checkInYesButton;
@property (weak, nonatomic) IBOutlet UIButton *checkInNoButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *checkInViewBottomConstraint;

@property (assign, nonatomic) SHMode mode;

@property (strong, nonatomic) SpotListModel *spotListModel;
@property (strong, nonatomic) NSArray *specialsSpotModels;
@property (strong, nonatomic) DrinkListModel *drinkListModel;
@property (strong, nonatomic) SpotModel *selectedSpot;

@property (strong, nonatomic) NSArray *spotsForDrink;

@property (assign, nonatomic) NSUInteger currentIndex;
@property (strong, nonatomic) NSArray *nearbySpots;

@end

@implementation SHHomeMapViewController {
    CLLocation *_currentLocation;
    BOOL _isRepositioningMap;
    BOOL _doNotMoveMap;
    BOOL _isShowingSliderSearchView;
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
    
    [self.locationMenuBarViewController updateLocationTitle:@"Locating..."];
    
    // when the Home Map is first loaded it will focus the map on the current device location
    _currentLocation = [TellMeMyLocation currentDeviceLocation];
    if (_currentLocation && CLLocationCoordinate2DIsValid(_currentLocation.coordinate)) {
        [self repositionMapOnCoordinate:_currentLocation.coordinate animated:NO];
        [self fetchNearbySpotsAtLocation:_currentLocation];
    }
    else {
        TellMeMyLocation *tellMeMyLocation = [[TellMeMyLocation alloc] init];
        [tellMeMyLocation findMe:kCLLocationAccuracyNearestTenMeters found:^(CLLocation *newLocation) {
            _currentLocation = newLocation;
            [TellMeMyLocation setLastLocation:newLocation completionHandler:^{
                NSLog(@"lastLocationName: %@", [TellMeMyLocation lastLocationName]);
                [self.locationMenuBarViewController updateLocationTitle:[TellMeMyLocation lastLocationName]];
            }];
            [self repositionMapOnCoordinate:_currentLocation.coordinate animated:NO];
            [self fetchNearbySpotsAtLocation:_currentLocation];
        } failure:^(NSError *error) {
            [Tracker logError:error.description class:[self class] trace:NSStringFromSelector(_cmd)];
        }];
    }
    
    self.mapView.showsUserLocation = TRUE;
    
    self.view.backgroundColor = [UIColor clearColor];
    
    [self hideCheckInPromptForSpot:nil animated:FALSE withCompletionBlock:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setNeedsStatusBarAppearanceUpdate];
    
    [self.view sendSubviewToBack:self.containerView];
    
    [self styleBars];
    [self styleCheckInPrompt];
    
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
    
    [self hideSearch:FALSE withCompletionBlock:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // TODO: ensure the user is logged in (just while testing)
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nc = (UINavigationController *)segue.destinationViewController;
        if ([nc.topViewController isKindOfClass:[SHAdjustSpotListSliderViewController class]]) {
            SHAdjustSpotListSliderViewController *vc = (SHAdjustSpotListSliderViewController *)nc.topViewController;
            CLLocation *location = _currentLocation;
            vc.location = location;
            vc.delegate = self;
        }
    }
    
    if ([segue.destinationViewController isKindOfClass:[SHSpotProfileViewController class]]) {
        SHSpotProfileViewController *viewController = segue.destinationViewController;
        NSAssert(self.selectedSpot, @"Selected Spot should be defined");
        viewController.spot = self.selectedSpot;
    }
}

#pragma mark - View Management
#pragma mark -

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
        if (finished) {
            self.sideBarViewController.view.hidden = TRUE;
            [self.sideBarViewController viewDidDisappear:animated];
            if (completionBlock) {
                completionBlock();
            }
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
    
    CGFloat duration = animated ? 0.25f : 0.0f;
    UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState;
    [UIView animateWithDuration:duration delay:0.0f usingSpringWithDamping:0.9f initialSpringVelocity:5.f options:options animations:^{
        self.homeNavigationViewBottomConstraint.constant = CGRectGetHeight(self.homeNavigationViewController.view.frame);
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        if (finished) {
            self.homeNavigationViewController.view.hidden = TRUE;
            if (completionBlock) {
                completionBlock();
            }
        }
    }];
}

- (void)showHomeNavigation:(BOOL)animated withCompletionBlock:(void (^)())completionBlock {
    DebugLog(@"%@ (%0.2f)", NSStringFromSelector(_cmd), CGRectGetHeight(self.homeNavigationViewController.view.frame));
    self.homeNavigationViewController.view.hidden = FALSE;
    
    CGFloat duration = animated ? 0.25f : 0.0f;
    UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState;
    [UIView animateWithDuration:duration delay:0.0f usingSpringWithDamping:0.9f initialSpringVelocity:5.f options:options animations:^{
        self.homeNavigationViewBottomConstraint.constant = 0.0f;
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        if (finished) {
            if (completionBlock) {
                completionBlock();
            }
        }
    }];
}

- (void)hideCollectionContainerView:(BOOL)animated withCompletionBlock:(void (^)())completionBlock {
    LOG_FRAME(@"collectionContainerView", self.collectionContainerView.frame);
    
    CGFloat duration = animated ? 0.25f : 0.0f;
    UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState;
    [UIView animateWithDuration:duration delay:0.0f usingSpringWithDamping:0.9f initialSpringVelocity:10.f options:options animations:^{
        self.collectionContainerViewBottomConstraint.constant = CGRectGetHeight(self.collectionContainerView.frame);
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        if (finished) {
            self.collectionContainerView.hidden = TRUE;
            if (completionBlock) {
                completionBlock();
            }
        }
    }];
}

- (void)showCollectionContainerView:(BOOL)animated withCompletionBlock:(void (^)())completionBlock {
    // set the bottom constraint to 0
    self.collectionContainerView.hidden = FALSE;
    
    LOG_FRAME(@"collectionContainerView", self.collectionContainerView.frame);
    
    CGFloat duration = animated ? 0.25f : 0.0f;
    UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState;
    [UIView animateWithDuration:duration delay:0.0f usingSpringWithDamping:0.9f initialSpringVelocity:10.f options:options animations:^{
        self.collectionContainerViewBottomConstraint.constant = 0.0f;
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        if (finished) {
            if (completionBlock) {
                completionBlock();
            }
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
        if (finished) {
            searchTextField.placeholder = @"Find spot/drink or similar...";
            [searchTextField becomeFirstResponder];
            if (completionBlock) {
                completionBlock();
            }
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
            break;
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
        [self refreshBlurredView];
        
    } completion:^(BOOL finished) {
        if (finished) {
            [self updateBlurredView];
            [self.slidersSearchViewController viewDidAppear:animated];
            
            if (completionBlock) {
                completionBlock();
            }
        }
    }];
}

- (void)hideSlidersSearch:(BOOL)animated forMode:(SHMode)mode withCompletionBlock:(void (^)())completionBlock {
    [self.slidersSearchViewController viewWillDisappear:animated];
    [self updateBlurredView];
    
    [self restoreNormalNavigationItems:animated withCompletionBlock:^{
        UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState;
        [UIView animateWithDuration:(animated ? kModalAnimationDuration : 0.0f) delay:0.1f options:options animations:^{
            
            self.blurredViewHeightConstraint.constant = 0.0f;
            self.slidersSearchViewTopConstraint.constant = CGRectGetHeight(self.view.frame);
            [self.view setNeedsLayout];
            [self.view layoutIfNeeded];
            
        } completion:^(BOOL finished) {
            if (finished) {
                
                _isShowingSliderSearchView = FALSE;
                
                [self.view sendSubviewToBack:self.containerView];
                [self.slidersSearchViewController viewDidDisappear:animated];
                
                if (completionBlock) {
                    completionBlock();
                }
            }
        }];
    }];
}

- (void)showCheckInPromptForSpot:(SpotModel *)spot animated:(BOOL)animated withCompletionBlock:(void (^)())completionBlock {
    // 1) set the lable with attribututed text
    // 2) set view to not hidden
    // 3) set bottom constraint to be 20 points above the bottom view
    
    // set the label
    UIFont *font = [UIFont fontWithName:@"Lato-Regular" size:self.checkInPromptLabel.font.pointSize];
    NSString *name = spot.name;
    NSString *text = [NSString stringWithFormat:@"Are you at %@?", name];
    [self.checkInPromptLabel setText:text withFont:font onString:name];
    
    
    // ensure it is out of view and layout is updated before adding the shadow
//    self.checkInViewBottomConstraint.constant = CGRectGetHeight(self.view.frame);
//    [self.view setNeedsLayout];
//    [self.view layoutIfNeeded];
    
    self.checkInPromptView.hidden = FALSE;
    
    // set the constraint and finish
    CGRect bottomFrame = [self bottomFrame];
    CGFloat duration = animated ? 0.35f : 0.0f;
    UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState;
    [UIView animateWithDuration:duration delay:0.0f usingSpringWithDamping:0.7f initialSpringVelocity:10.f options:options animations:^{
        self.checkInViewBottomConstraint.constant = CGRectGetHeight(bottomFrame) + 20.0f;
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        if (finished) {
            if (completionBlock) {
                completionBlock();
            }
        }
    }];
}

- (void)hideCheckInPromptForSpot:(SpotModel *)spot animated:(BOOL)animated withCompletionBlock:(void (^)())completionBlock {
    
    // 1) set the bottom constraint to the height of the view
    // 2) complete by setting view to hidden
    
    CGFloat duration = animated ? 0.35f : 0.0f;
    UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState;
    [UIView animateWithDuration:duration delay:0.0f usingSpringWithDamping:0.7f initialSpringVelocity:10.f options:options animations:^{
        self.checkInViewBottomConstraint.constant = CGRectGetHeight(self.view.frame);
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        if (finished) {
            self.checkInPromptView.hidden = TRUE;
            self.checkInPromptLabel.text = nil;
            
            if (completionBlock) {
                completionBlock();
            }
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

- (IBAction)checkInYesButtonTapped:(id)sender {
    // TODO: implement by checking in the user at the nearest spot
    [self hideCheckInPromptForSpot:nil animated:TRUE withCompletionBlock:nil];
}

- (IBAction)checkInNoButtonTapped:(id)sender {
    [self hideCheckInPromptForSpot:nil animated:TRUE withCompletionBlock:nil];
}

- (IBAction)searchCancelButtonTapped:(id)sender {
    [self hideSearch:TRUE withCompletionBlock:^{
    }];
}

- (IBAction)searchSlidersCancelButtonTapped:(id)sender {
    [self hideSlidersSearch:TRUE forMode:self.mode withCompletionBlock:^{
        NSLog(@"Slider search should now be hidden");
        [self showHomeNavigation:TRUE withCompletionBlock:nil];
    }];
}

- (IBAction)cancelBackToHomeMap:(UIStoryboardSegue *)segue {
    // get back to the home map view
}

- (IBAction)finishCreatingSpotListForHomeMap:(UIStoryboardSegue *)segue {
    // TODO: get back to the home map view and get spotlist model
    // TODO: hide the home navigation and display the collection view of the spots and add the map annotations
    // TODO: remove this unwind segue since it does not dismiss the custom child view controller
    
    if ([segue.sourceViewController isKindOfClass:[SHAdjustSpotListSliderViewController class]]) {
        SHAdjustSpotListSliderViewController *vc = (SHAdjustSpotListSliderViewController *)segue.sourceViewController;
        [self displaySpotlist:vc.spotListModel];
    }
}

- (IBAction)finishCreatingDrinkListForHomeMap:(UIStoryboardSegue *)segue {
    // do nothing (handled by delegate method)
    // TODO: remove this unwind segue since it does not dismiss the custom child view controller
}

- (IBAction)childViewControllerDidRequestSimilarSpots:(UIStoryboardSegue *)segue {
    if ([segue.sourceViewController isKindOfClass:[NSObject class]]) {
    }
    
//    segue.sourceViewController
    
    // is Spot Profile View Controller
    // OK, get SpotModel from the property
    
//    SHSpotProfileViewController *vc;
//    vc.spotModel
    
}

#pragma mark - Navigation
#pragma mark -

- (void)goToSpots {
    // updating the location is redundant, but necessary to ensure it is current
    
    if ([self promptLoginNeeded:@"Please log in before creating a Spotlist"] == NO) {
        [self prepareToDisplaySliderSearchWithCompletionBlock:^{
            TellMeMyLocation *tellMeMyLocation = [[TellMeMyLocation alloc] init];
            [tellMeMyLocation findMe:kCLLocationAccuracyHundredMeters found:^(CLLocation *newLocation) {
                _currentLocation = newLocation;
                [self performSegueWithIdentifier:@"HomeMapToSpots" sender:self];
            } failure:^(NSError *error) {
                [Tracker logError:error.description class:[self class] trace:NSStringFromSelector(_cmd)];
            }];
        }];
    }
}

- (IBAction)unwindFromSpotProfileToHomeMapViewController:(UIStoryboardSegue*)unwindSegue {
    NSLog(@"made it back!");
    
    if ([unwindSegue.sourceViewController isKindOfClass:[SHSpotProfileViewController class]]) {
        SHSpotProfileViewController *spotProfileViewController = unwindSegue.sourceViewController;
        SpotModel *spot __unused = spotProfileViewController.spot;
        
        //todo: api call to find similar spots and display
        
//        [self showHUD:@"Finding similar"];
        
//        NSString *name = [NSString stringWithFormat:@"Similar to %@", _spot.name];
//        [SpotListModel postSpotList:name spotId:_spot.ID spotTypeId:_spot.spotType.ID latitude:_spot.latitude longitude:_spot.longitude sliders:_averageReview.sliders successBlock:^(SpotListModel *spotListModel, JSONAPI *jsonApi) {
//            [self hideHUD];
//            
//            SpotListViewController *viewController = [self.spotsStoryboard instantiateViewControllerWithIdentifier:@"SpotListViewController"];
//            [viewController setSpotList:spotListModel];
//            
//            [self.navigationController pushViewController:viewController animated:YES];
//            
//        } failure:^(ErrorModel *errorModel) {
//            [self hideHUD];
//            [self showAlert:@"Oops" message:errorModel.human];
//            [Tracker logError:errorModel class:[self class] trace:NSStringFromSelector(_cmd)];
//        }];
        
    }

}

#pragma mark - Private
#pragma mark -

- (void)prepareToDisplaySliderSearchWithCompletionBlock:(void (^)())completionBlock {
    if (completionBlock) {
        if (!self.homeNavigationViewController.view.hidden) {
            [self hideHomeNavigation:TRUE withCompletionBlock:completionBlock];
        }
        else if (!self.collectionContainerView.hidden) {
            [self hideCollectionContainerView:TRUE withCompletionBlock:completionBlock];
        }
        else {
            completionBlock();
            
        }
        
    }
}

- (void)showBeersSearch {
    [self.slidersSearchViewController prepareForMode:SHModeBeer];
    
    [self prepareToDisplaySliderSearchWithCompletionBlock:^{
        [self showSlidersSearch:TRUE forMode:SHModeBeer withCompletionBlock:^{
        }];
    }];
}

- (void)showCocktailsSearch {
    [self.slidersSearchViewController prepareForMode:SHModeCocktail];

    [self prepareToDisplaySliderSearchWithCompletionBlock:^{
        [self showSlidersSearch:TRUE forMode:SHModeCocktail withCompletionBlock:^{
        }];
    }];
}

- (void)showWineSearch {
    [self.slidersSearchViewController prepareForMode:SHModeWine];
    
    [self prepareToDisplaySliderSearchWithCompletionBlock:^{
        [self showSlidersSearch:TRUE forMode:SHModeWine withCompletionBlock:^{
        }];
    }];
}

- (void)displaySpotlist:(SpotListModel *)spotListModel {
    // hold onto the spotlist
    
    self.mode = SHModeSpots;
    
    self.drinkListModel = nil;
    self.specialsSpotModels = nil;
    self.spotListModel = spotListModel;
    
    self.currentIndex = 0;
    
    if (!self.spotListModel.spots.count) {
        [self showAlert:@"Oops" message:@"There are no spots which match in this location. Please try another search area."];
        [self showHomeNavigation:TRUE withCompletionBlock:nil];
        return;
    }
    
    [self populateMapWithSpots:self.spotListModel.spots];

    if (!self.homeNavigationViewController.view.hidden) {
        [self hideHomeNavigation:FALSE withCompletionBlock:nil];
    }
    
    [self.mapOverlayCollectionViewController displaySpotList:spotListModel];
    
    [self showCollectionContainerView:TRUE withCompletionBlock:^{
        // do nothing
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            DebugLog(@"Nothing?");
        });
    }];
}

- (void)displaySpecialsForSpots:(NSArray *)spots {
    NSLog(@"spots: %@", spots);
    
    self.mode = SHModeSpecials;
    
    self.spotListModel = nil;
    self.drinkListModel = nil;
    self.specialsSpotModels = spots;
    
    self.currentIndex = 0;

    [self populateMapWithSpots:spots];
    
    if (!self.homeNavigationViewController.view.hidden) {
        [self hideHomeNavigation:FALSE withCompletionBlock:nil];
    }
    
    [self.mapOverlayCollectionViewController displaySpecialsForSpots:spots];
    
    [self showCollectionContainerView:TRUE withCompletionBlock:^{
        // do nothing
    }];
}

- (void)displayDrinklist:(DrinkListModel *)drinkListModel {
    // hold onto the drinklist
    self.spotListModel = nil;
    self.specialsSpotModels = nil;
    self.drinkListModel = drinkListModel;
    
    self.currentIndex = 0;
    
    // clear the map right away because it may currently show other results
    [self.mapView removeAnnotations:[self.mapView annotations]];
    
    if (!self.drinkListModel.drinks.count) {
        [self showAlert:@"Oops" message:@"There are no drinks which match in this location. Please try another search area."];
        return;
    }
    
    if (self.drinkListModel.drinks.count) {
        DrinkModel *drink = self.drinkListModel.drinks[0];
        [self updateMapWithCurrentDrink:drink];
    }
    
    if (!self.homeNavigationViewController.view.hidden) {
        [self hideHomeNavigation:FALSE withCompletionBlock:nil];
    }
    
    [self.mapOverlayCollectionViewController displayDrinklist:drinkListModel];
    
    [self showCollectionContainerView:TRUE withCompletionBlock:^{
        // do nothing
        
        // TODO: check first if the user already recently checked in at this location or another location
        
        if (self.nearbySpots.count) {
            [self showCheckInPromptForSpot:self.nearbySpots[0] animated:TRUE withCompletionBlock:nil];
        }
        
    }];
}

- (void)styleBars {
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    UIImage *backgroundImage = [SHStyleKit gradientBackgroundWithSize:self.view.frame.size];
    [self.navigationController.navigationBar setBackgroundImage:backgroundImage forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [SHStyleKit myWhiteColor]};
}

- (void)styleCheckInPrompt {
    UIColor *backgroundColor = [SHStyleKit color:SHStyleKitColorMyTintColorTransparent];
    UIColor *borderColor = [SHStyleKit color:SHStyleKitColorMyWhiteColor];
    UIColor *labelTextColor = [SHStyleKit color:SHStyleKitColorMyWhiteColor];
    UIColor *buttonTextColor = [SHStyleKit color:SHStyleKitColorMyTintColor];
    UIColor *buttonBackgroundColor = [SHStyleKit color:SHStyleKitColorMyWhiteColor];
    
    self.checkInPromptView.backgroundColor = backgroundColor;
    self.checkInPromptView.layer.borderColor = [borderColor CGColor];
    self.checkInPromptView.layer.borderWidth = 2.0f;
    self.checkInPromptView.layer.cornerRadius = 10.0f;
    self.checkInPromptView.clipsToBounds = YES;
    
    self.checkInPromptLabel.font = [UIFont fontWithName:@"Lato-Light" size:self.checkInPromptLabel.font.pointSize];
    self.checkInPromptLabel.textColor = labelTextColor;
    
    [self.checkInYesButton setTitleColor:buttonTextColor forState:UIControlStateNormal];
    [self.checkInNoButton setTitleColor:buttonTextColor forState:UIControlStateNormal];
    
    [self.checkInYesButton setBackgroundColor:buttonBackgroundColor];
    [self.checkInNoButton setBackgroundColor:buttonBackgroundColor];
    
    self.checkInYesButton.layer.cornerRadius = 5.0f;
    self.checkInNoButton.layer.cornerRadius = 5.0f;
    
    // add a shadow
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:self.checkInPromptView.bounds];
    self.checkInPromptView.layer.masksToBounds = NO;
    self.checkInPromptView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.checkInPromptView.layer.shadowOffset = CGSizeMake(0.0f, 5.0f);
    self.checkInPromptView.layer.shadowOpacity = 0.35f;
    self.checkInPromptView.layer.shadowRadius = 10.0f;
    self.checkInPromptView.layer.shadowPath = shadowPath.CGPath;
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
    
    [self prepareToDisplaySliderSearchWithCompletionBlock:^{
        [SpotModel getSpotsWithSpecialsTodayForCoordinate:self.mapView.centerCoordinate success:^(NSArray *spotModels, JSONAPI *jsonApi) {
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
//            [self showCheckInPromptForSpot:self.nearbySpots[0] animated:TRUE withCompletionBlock:^{
//                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3.0f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
//                    [self hideCheckInPromptForSpot:self.nearbySpots[0] animated:TRUE withCompletionBlock:nil];
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
    [[drink fetchSpotsForLocation:self.drinkListModel.location] then:^(NSArray *spots) {
        [self populateMapWithSpots:spots];
        self.spotsForDrink = spots;
    } fail:^(ErrorModel *errorModel) {
        [Tracker logError:errorModel.human class:[self class] trace:NSStringFromSelector(_cmd)];
        // TODO: tell the user about the error
    } always:nil];
}

- (void)populateMapWithSpots:(NSArray *)spots {
    NSAssert(self.mapView, @"Map View is required");
    
    // Update map
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
    
    if (spots.count) {
        [self selectSpot:spots[0]];
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

- (void)repositionMapOnCoordinate:(CLLocationCoordinate2D)coordinate animated:(BOOL)animated {
    MKMapPoint mapPoint = MKMapPointForCoordinate(coordinate);
    MKMapRect mapRect = MKMapRectMake(mapPoint.x, mapPoint.y, 0.25, 0.25);
    [self.mapView setVisibleMapRect:mapRect edgePadding:UIEdgeInsetsMake(169.0, 45.0, 180.0, 45.0) animated:animated];
}

- (void)repositionMapOnAnnotations:(NSArray *)annotations animated:(BOOL)animated {
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
        if (MKMapRectGetWidth(mapRect) == 0.0 && MKMapRectGetHeight(mapRect) == 0.0) {
            mapRect.size = MKMapSizeMake(MKMapRectGetWidth(mapRect) + 20.0, MKMapRectGetHeight(mapRect) + 20.0);
        }
        
        CGRect topFrame = [self topFrame];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.25 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState;
            [UIView animateWithDuration:0.5 delay:0.0 options:options animations:^{
                // edgePadding must also account for the size and position of the annotation view
                [self.mapView setVisibleMapRect:mapRect edgePadding:UIEdgeInsetsMake(CGRectGetHeight(topFrame) + 30, 45.0, CGRectGetHeight(self.collectionContainerView.frame) + 30, 45.0) animated:animated];
            } completion:^(BOOL finished) {
            }];
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
    else if (!self.collectionContainerView.hidden) {
        return self.collectionContainerView.frame;
    }

    // default to returning a frame with 0 height which is at the very bottom
    CGRect frame = self.view.frame;
    frame.origin.x = CGRectGetHeight(frame);
    frame.size.height = 0.0f;
    
    return frame;
}

- (CGRect)visibleMapFrame {
    // visible frame is the bottom of the overlay to the top of the bottom overlay
    
    CGRect topFrame = [self topFrame];
    CGRect bottomFrame = [self bottomFrame];
    CGFloat xPos = 0;
    CGFloat yPos = CGRectGetHeight(topFrame);
    
    CGFloat height = CGRectGetHeight(self.mapView.frame) - CGRectGetHeight(topFrame) - CGRectGetHeight(bottomFrame);
    CGRect visibleFrame = CGRectMake(xPos, yPos, CGRectGetWidth(self.mapView.frame), height);

    return visibleFrame;
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
    
    if (_isShowingSliderSearchView) {
        [self updateBlurredView];
        [self performSelector:@selector(refreshBlurredView) withObject:nil afterDelay:0.1];
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
        [self goToSpots];
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

#pragma mark - SHHomeNavigationDelegate
#pragma mark -

- (void)homeNavigationViewController:(SHHomeNavigationViewController *)vc spotsButtonTapped:(id)sender {
    [self goToSpots];
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
        [self performSegueWithIdentifier:SpotSelectedSegueIdentifier sender:self];
    }
    else if (self.specialsSpotModels && index < self.specialsSpotModels.count) {
        self.selectedSpot = self.specialsSpotModels[index];
        [self performSegueWithIdentifier:SpotSelectedSegueIdentifier sender:self];
    }
    else if (self.drinkListModel && index < self.spotsForDrink.count) {
        self.selectedSpot = self.spotsForDrink[index];
        [self performSegueWithIdentifier:SpotSelectedSegueIdentifier sender:self];
    }
    else {
        NSAssert(FALSE, @"Index should always be in bounds");
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
}

#pragma mark - SHMapFooterNavigationDelegate
#pragma mark -

- (void)footerNavigationViewController:(SHMapFooterNavigationViewController *)vc spotsButtonTapped:(id)sender {
    [self goToSpots];
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

#pragma mark - SHAdjustSliderListSliderDelegate
#pragma mark -

- (void)adjustSpotListSliderViewController:(SHAdjustSpotListSliderViewController*)vc didCreateSpotList:(SpotListModel*)spotList {
    // do nothing (handled by unwind segue)
}

#pragma mark - SpotAnnotationCalloutDelegate
#pragma mark -

- (void)spotAnnotationCallout:(SpotAnnotationCallout*)spotAnnotationCallout clicked:(MatchPercentAnnotationView*)matchPercentAnnotationView {
    NSLog(@"Clicked?!");
}

#pragma mark - SHSlidersSearchDelegate
#pragma mark -

- (void)slidersSearchViewController:(SHSlidersSearchViewController *)vc didPrepareDrinklist:(DrinkListModel *)drinklist forMode:(SHMode)mode {
    self.mode = mode;
    [self hideSlidersSearch:TRUE forMode:mode withCompletionBlock:^{
        [self displayDrinklist:drinklist];
        
        // TODO: if there are nearby spots, prompt the user to check in at the nearest one (first in the array)
    }];
}

#pragma mark - MKMapViewDelegate
#pragma mark -

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    MKAnnotationView *annotationView = nil;
    
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        // do nothing
    }
    else if ([annotation isKindOfClass:[MatchPercentAnnotation class]] == YES) {
        static NSString *MatchPercentAnnotationIdentifier = @"MatchPercentAnnotationView";
        MatchPercentAnnotation *matchPercentAnnotation = (MatchPercentAnnotation *)annotation;
        MatchPercentAnnotationView *pin = (MatchPercentAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:MatchPercentAnnotationIdentifier];
        
        if (!pin) {
            pin = [[MatchPercentAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:MatchPercentAnnotationIdentifier];
        }
        
        switch (self.mode) {
            case SHModeSpots:
                // setting to none allows match percentage to appear
                pin.drawing = SHStyleKitDrawingNone;
                break;
            case SHModeSpecials:
                pin.drawing = SHStyleKitDrawingSpecialsIcon;
                break;
            case SHModeBeer:
                pin.drawing = SHStyleKitDrawingBeerIcon;
                break;
            case SHModeCocktail:
                pin.drawing = SHStyleKitDrawingCocktailIcon;
                break;
            case SHModeWine:
                pin.drawing = SHStyleKitDrawingWineIcon;
                break;
                
            default:
                break;
        }
        
        if (self.mode == SHModeSpots) {
        }
        else if (self.mode == SHModeSpecials) {
        }
        [pin setSpot:matchPercentAnnotation.spot];
        [pin setNeedsDisplay];
        annotationView = pin;
    }
    else if ([annotation isKindOfClass:[MKPointAnnotation class]] == YES) {
        static NSString *PinIdentifier = @"Pin";
        MKPinAnnotationView *pin = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:PinIdentifier];
        if (!pin) {
            pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:PinIdentifier];
        }
        
        annotationView = pin;
    }
    
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    if ([view isKindOfClass:[MatchPercentAnnotationView class]] == YES) {
        MatchPercentAnnotationView *pin = (MatchPercentAnnotationView*) view;
        
        if (pin.isHighlighted == NO) {
            [pin setHighlighted:YES];
            
            if (self.mode == SHModeBeer || self.mode == SHModeCocktail || self.mode == SHModeWine) {
                SpotAnnotationCallout *callout = [SpotAnnotationCallout viewFromNib];
                [callout setMatchPercentAnnotationView:pin];
                [callout setDelegate:self];
                [callout setFrame:CGRectMake(0.0f, -CGRectGetHeight(callout.frame), CGRectGetWidth(callout.frame), CGRectGetHeight(callout.frame))];
                
                [pin setCalloutView:callout];
                
                [pin setUserInteractionEnabled:YES];
                [pin addSubview:callout];
            }
            
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
        
        [pin.calloutView removeFromSuperview];
        [pin setCalloutView:nil];
    }
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    if (self.mapView.hidden || _isRepositioningMap) {
        return;
    }
    
    _btnUpdateSearchResults.alpha = 0.0;
    [_btnUpdateSearchResults setHidden:NO];
    
    UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState;
    [UIView animateWithDuration:0.25 delay:0.0 options:options animations:^{
        _btnUpdateSearchResults.alpha = 1.0;
    } completion:^(BOOL finished) {
    }];
}

@end
