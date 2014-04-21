//
//  BaseViewController.m
//  SpotHopper
//
//  Created by Josh Holtz on 12/9/13.
//  Copyright (c) 2013 Josh Holtz. All rights reserved.
//

#import "BaseViewController.h"

#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"

#import "MBProgressHUD.h"

#import "UIViewController+Navigator.h"

#import "AccountSettingsViewController.h"
#import "FooterViewController.h"
#import "LiveSpecialViewController.h"
#import "SidebarViewController.h"
#import "SearchViewController.h"

#import "DrinkProfileViewController.h"
#import "SpotProfileViewController.h"

#import "LiveSpecialModel.h"

#import <JHSidebar/JHSidebarViewController.h>
#import <FacebookSDK/FacebookSDK.h>

typedef void(^AlertBlock)();

@interface BaseViewController ()<UINavigationControllerDelegate, SidebarViewControllerDelegate, LiveSpecialViewControllerDelegate, SearchViewControllerDelegate>

@property (nonatomic, strong) UIAlertView *alertView;
@property (nonatomic, copy) AlertBlock alertBlock;

@property (nonatomic, strong) UIBarButtonItem *backButtonItem;
@property (nonatomic, strong) UIBarButtonItem *rightSidebarButtonItem;

@property (nonatomic, strong) UIImageView *backgroundImage;
@property (nonatomic, strong) FooterViewController *footerViewController;

@property (nonatomic, assign) BOOL loaded;

@end

@implementation BaseViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [self viewDidLoad:@[kDidLoadOptionsBlurredBackground]];
}

- (void)viewDidLoad:(NSArray*)options {
    [super viewDidLoad];
    
    if ([options containsObject:kDidLoadOptionsDontAdjustForIOS6] == NO && SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        [self adjustIOS6Crap];
    }
    
    if (![options containsObject:kDidLoadOptionsNoBackground]) {
        
        _backgroundImage = [[UIImageView alloc] initWithFrame:self.view.frame];
        [_backgroundImage setImage:[UIImage imageNamed:( [options containsObject:kDidLoadOptionsFocusedBackground] ? @"app_background" : @"app_background_blurred" )]];
        [_backgroundImage setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
        [_backgroundImage setContentMode:UIViewContentModeBottom];
        
        [self.view insertSubview:_backgroundImage atIndex:0];
    }
    
    _backButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_nav_back"] style:UIBarButtonItemStylePlain target:self action:@selector(onClickBack:)];
    [_backButtonItem setBackgroundImage:[[UIImage alloc] init] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    if ([self.navigationController.viewControllers count] > 1) {
        [self.navigationItem setBackBarButtonItem:nil];
        [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:@selector(onClickBack:)]];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([self.navigationController.viewControllers count] > 1) {
        [self.navigationItem setBackBarButtonItem:nil];
        [self.navigationItem setLeftBarButtonItem:_backButtonItem];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushNotificationReceived:) name:kNotificationPushReceived object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(urlNotificationReceived:) name:kUrlPushReceived object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (kAnalyticsEnabled) {
        // tracking with Google Analytics (override screenName)
        id tracker = [[GAI sharedInstance] defaultTracker];
        [tracker set:kGAIScreenName value:self.screenName];
        [tracker send:[[GAIDictionaryBuilder createAppView] build]];
    }
    
    SidebarViewController *sidebar = (SidebarViewController*)self.navigationController.sidebarViewController.rightViewController;
    [sidebar setDelegate:self];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kUrlPushReceived object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationPushReceived object:nil];
    [super viewWillDisappear:animated];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (void)adjustIOS6Crap {
    for (UIView *view in self.view.subviews) {
        CGRect frame = view.frame;
        frame.origin.y -= 64.0f;
        [view setFrame:frame];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Push notification 

- (void)pushNotificationReceived:(NSNotification*)notification {
    NSLog(@"Handling push on - %@", self);
    
    NSNumber *spotId = [notification.userInfo objectForKey:@"s_id"];
    NSNumber *liveSpecialId = [notification.userInfo objectForKey:@"ls_id"];
    
    if (liveSpecialId != nil) {
        LiveSpecialModel *liveSpecial = [[LiveSpecialModel alloc] init];
        [liveSpecial setID:liveSpecialId];
        [self showLiveSpecialViewController:liveSpecial needToFetch:YES];
    }
    
}

#pragma mark - URL Notification

- (void)urlNotificationReceived:(NSNotification*)notification {
    // handle /spots/:id, /drinks/:id, /specials/:id
    
    NSString *fullURLString = [notification.userInfo objectForKey:@"full_url_string"];
    if ([fullURLString rangeOfString:@"//spots/" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        NSInteger modelId = [self extractNumberFromString:fullURLString withPrefix:@"//spots/"];
        if (modelId != NSNotFound) {
            SpotModel *spot = [[SpotModel alloc] init];
            [spot setID:[NSNumber numberWithInt:modelId]];
            [self goToSpotProfile:spot];
        }
        else {
            [self goToSpotListMenu];
        }
    }
    else if ([fullURLString rangeOfString:@"//drinks/" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        NSInteger modelId = [self extractNumberFromString:fullURLString withPrefix:@"//drinks/"];
        if (modelId != NSNotFound) {
            // TODO go to specific drink
        }
        else {
            [self goToDrinkListMenu];
        }
    }
    else if ([fullURLString rangeOfString:@"//specials/" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        NSInteger modelId = [self extractNumberFromString:fullURLString withPrefix:@"//specials/"];
        if (modelId != NSNotFound) {
            // TODO go to specific spot
        }
        else {
            [self goToTonightsSpecials];
        }
    }
}

#pragma mark - Tracking

- (NSString *)screenName {
    return self.title;
}

#pragma mark - SidebarViewControllerDelegate

- (void)sidebarViewControllerClickedSearch:(SidebarViewController *)sidebarViewController {
    SearchViewController *viewController = [[SearchViewController alloc] initWithNibName:@"SearchViewController" bundle:[NSBundle mainBundle]];
    [viewController setDelegate:self];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)sidebarViewControllerClickedSpots:(SidebarViewController *)sidebarViewController {
    [self goToSpotListMenu];
}

- (void)sidebarViewControllerClickedDrinks:(SidebarViewController *)sidebarViewController {
    [self goToDrinksNearBy];
}

- (void)sidebarViewControllerClickedSpecials:(SidebarViewController *)sidebarViewController {
    [self goToTonightsSpecials];
}

- (void)sidebarViewControllerClickedReview:(SidebarViewController *)sidebarViewController {
    [self goToReviewMenu];
}

- (void)sidebarViewControllerClickedCheckin:(SidebarViewController *)sidebarViewController {
    [self goToCheckin:nil];
}

- (void)sidebarViewControllerClickedAccount:(SidebarViewController *)sidebarViewController {
    AccountSettingsViewController *viewController = [[self userStoryboard] instantiateViewControllerWithIdentifier:@"AccountSettingsViewController"];
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - HUD

- (void)showHUDCompleted:(NSString*)text {
    [self showHUDCompleted:text block:nil];
}

- (void)showHUDCompleted:(NSString*)text block:(dispatch_block_t)block {
    [self showHUDCompleted:text time:2.5 block:block];
}

- (void)showHUDCompleted:(NSString *)text time:(NSInteger)time block:(dispatch_block_t)block {
    [self showHUD:text time:time image:@"37x-Checkmark.png" block:block];
}

- (void)showHUD:(NSString *)text time:(NSInteger)time image:(NSString*)image block:(dispatch_block_t)block {
    [_HUD hide:YES];
    [_HUD removeFromSuperview];
    _HUD = nil;
    
    _HUD = [MBProgressHUD showHUDAddedTo:[[[UIApplication sharedApplication] delegate] window] animated:YES];
    _HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:image]];
    [_HUD setLabelText:text];
	_HUD.mode = MBProgressHUDModeCustomView;
    [_HUD setDimBackground:YES];
    
	[_HUD hide:YES afterDelay:time];
    
    if (block != nil) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, time * NSEC_PER_SEC), dispatch_get_main_queue(), block);
    }
}

- (void)showHUD {
    [self showHUD:@"Loading"];
}

- (void)showHUD:(NSString*)label {
    [_HUD hide:YES];
    [_HUD removeFromSuperview];
    _HUD = nil;
    
    _HUD = [MBProgressHUD showHUDAddedTo:[[[UIApplication sharedApplication] delegate] window] animated:YES];
    [_HUD setMode:MBProgressHUDModeIndeterminate];
    [_HUD setDimBackground:YES];
    [_HUD setLabelText:label];
}

- (void)hideHUD {
    [_HUD hide:YES];
    _HUD = nil;
}

- (UIAlertView *)showAlert:(NSString *)title message:(NSString *)message {
    return [self showAlert:title message:message block:nil];
}

- (UIAlertView *)showAlert:(NSString *)title message:(NSString *)message block:(void(^)())alertBlock {
    [_alertView dismissWithClickedButtonIndex:0 animated:NO];
    _alertView = nil;
    
    _alertBlock = nil;
    _alertBlock = alertBlock;
    
    _alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
    [_alertView show];
    return _alertView;
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (_alertBlock != nil) {
        _alertBlock();
    }
}

#pragma mark - Touches Hide Keyboard

- (NSArray*)textfieldToHideKeyboard {
    return @[];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    
    
    BOOL hide = NO;
    for (UITextField *textfield in [self textfieldToHideKeyboard]) {
        if ([textfield isFirstResponder] && [touch view] != textfield) {
            hide  = YES;
        }
    }
    
    if (hide == YES) {
        [self.view endEditing:YES];
    }
    [super touchesBegan:touches withEvent:event];
}

#pragma mark - Keyboard

#define kOFFSET_FOR_KEYBOARD 80.0

- (float)offsetForKeyboard {
    return kOFFSET_FOR_KEYBOARD;
}

-(void)keyboardWillShow:(NSNotification*)notification {
    CGRect keyboardFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    // Animate the current view out of the way
    if (self.view.frame.origin.y >= 0)
    {
        [self setViewMovedUp:YES keyboardFrame:keyboardFrame];
    }
    else if (self.view.frame.origin.y < 0)
    {
        [self setViewMovedUp:NO keyboardFrame:keyboardFrame];
    }
}

-(void)keyboardWillHide:(NSNotification*)notification {
    CGRect keyboardFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    if (self.view.frame.origin.y >= 0)
    {
        [self setViewMovedUp:YES keyboardFrame:keyboardFrame];
    }
    else if (self.view.frame.origin.y < 0)
    {
        [self setViewMovedUp:NO keyboardFrame:keyboardFrame];
    }
}

//method to move the view up/down whenever the keyboard is shown/dismissed
-(void)setViewMovedUp:(BOOL)movedUp keyboardFrame:(CGRect)keyboardFrame {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    
    CGRect rect = self.view.frame;
    if (movedUp)
    {
        // 1. move the view's origin up so that the text field that will be hidden come above the keyboard
        // 2. increase the size of the view so that the area behind the keyboard is covered up.
        rect.origin.y -= [self offsetForKeyboard];
        rect.size.height += [self offsetForKeyboard];
    }
    else
    {
        // revert back to the normal state.
        rect.origin.y += [self offsetForKeyboard];
        rect.size.height -= [self offsetForKeyboard];
    }
    self.view.frame = rect;
    
    [UIView commitAnimations];
}

#pragma mark - Text

- (CGFloat)heightForAttributedString:(NSAttributedString *)text maxWidth:(CGFloat)maxWidth {
    if ([text isKindOfClass:[NSString class]] && !text.length) {
        // no text means no height
        return 0;
    }
    
    NSStringDrawingOptions options = NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
    CGSize size = [text boundingRectWithSize:CGSizeMake(maxWidth, CGFLOAT_MAX) options:options context:nil].size;
    
    CGFloat height = ceilf(size.height) + 1; // add 1 point as padding
    
    return height;
}

- (CGFloat)heightForString:(NSString *)text font:(UIFont *)font maxWidth:(CGFloat)maxWidth {
    if (![text isKindOfClass:[NSString class]] || !text.length) {
        // no text means no height
        return 0;
    }
    
    NSStringDrawingOptions options = NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
    NSDictionary *attributes = @{ NSFontAttributeName : font };
    CGSize size = [text boundingRectWithSize:CGSizeMake(maxWidth, CGFLOAT_MAX) options:options attributes:attributes context:nil].size;
    CGFloat height = ceilf(size.height) + 1; // add 1 point as padding
    
    return height;
}

- (CGFloat)widthForAttributedString:(NSAttributedString *)text maxWidth:(CGFloat)maxHeight {
    if ([text isKindOfClass:[NSString class]] && !text.length) {
        // no text means no height
        return 0;
    }
    
    NSStringDrawingOptions options = NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
    CGSize size = [text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, maxHeight) options:options context:nil].size;
    
    CGFloat width = ceilf(size.width) + 1; // add 1 point as padding
    
    return width;
}

- (CGFloat)widthForString:(NSString *)text font:(UIFont *)font maxWidth:(CGFloat)maxHeight {
    if (![text isKindOfClass:[NSString class]] || !text.length) {
        // no text means no height
        return 0;
    }
    
    NSStringDrawingOptions options = NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
    NSDictionary *attributes = @{ NSFontAttributeName : font };
    CGSize size = [text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, maxHeight) options:options attributes:attributes context:nil].size;
    CGFloat width = ceilf(size.width) + 1; // add 1 point as padding
    
    return width;
}

- (void)changeLabelToLatoLight:(UIView *)view {
    [self changeLabelToLatoLight:view withBoldText:nil];
}

- (void)changeLabelToLatoLight:(UIView *)view withBoldText:(NSString *)boldText {
    if (view && [view isKindOfClass:[TTTAttributedLabel class]]) {
        TTTAttributedLabel *label = (TTTAttributedLabel *)view;
        [label setFont:[UIFont fontWithName:@"Lato-Light" size:label.font.pointSize]];
        
        // change label height to fit text
        CGRect frame = label.frame;
        frame.size.height = [self heightForString:label.text font:label.font maxWidth:CGRectGetWidth(label.frame)];
        label.frame = frame;
        
        if (boldText.length) {
            [label setText:label.text withFont:[UIFont fontWithName:@"Lato-Bold" size:label.font.pointSize] onString:boldText];
        }
    }
}

#pragma mark - Images

- (UIImage *)whiteScreenImageForFrame:(CGRect)frame {
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(frame.size.width, frame.size.height), NO, 0.0f);
    
    CGFloat width = CGRectGetWidth(frame);
    CGFloat height = CGRectGetHeight(frame);
    
    //// General Declarations
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //// Color Declarations
    UIColor* myWhite1 = [[UIColor whiteColor] colorWithAlphaComponent:0.1];
    UIColor* myWhite2 = [[UIColor whiteColor] colorWithAlphaComponent:0.9];
    UIColor* middleColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
    
    //// Gradient Declarations
    NSArray* myWhiteGradientColors = [NSArray arrayWithObjects:
                                      (id)myWhite1.CGColor,
                                      (id)middleColor.CGColor,
                                      (id)myWhite2.CGColor, nil];
    CGFloat myWhiteGradientLocations[] = {0, 0.86, 1};
    CGGradientRef myWhiteGradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef)myWhiteGradientColors, myWhiteGradientLocations);
    
    //// Rectangle Drawing
    UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRect: CGRectMake(0, 0, width, height)];
    CGContextSaveGState(context);
    [rectanglePath addClip];
    CGContextDrawLinearGradient(context, myWhiteGradient, CGPointMake(width/2, 0), CGPointMake(width/2, height), 0);
    CGContextRestoreGState(context);
    
    //// Cleanup
    CGGradientRelease(myWhiteGradient);
    CGColorSpaceRelease(colorSpace);

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
        
    return image;
}

#pragma mark - Navigation

- (void)onClickBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)onClickShowSidebar:(id)sender {
    [self.navigationController.sidebarViewController showRightSidebar:YES];
}

#pragma mark - Sidebar

- (void)showSidebarButton:(BOOL)show animated:(BOOL)animated {
    [self showSidebarButton:show animated:animated navigationItem:self.navigationItem];
}

- (void)showSidebarButton:(BOOL)show animated:(BOOL)animated navigationItem:(UINavigationItem*)navigationItem {
    
    // Shows sidebar menu
//    JHSidebarViewController *sidebarViewController = [self.navigationController sidebarViewController];
    _rightSidebarButtonItem = nil;
    if (_rightSidebarButtonItem == nil) {
        UIImage *image;
        image = [UIImage imageNamed:@"btn_nav_sidebar"];
        _rightSidebarButtonItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(onClickShowSidebar:)];
        [_rightSidebarButtonItem setTintColor:kColorOrange];
        [_rightSidebarButtonItem setBackgroundImage:[[UIImage alloc] init] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    }
    
    if (show == YES) {
        [navigationItem setRightBarButtonItem:_rightSidebarButtonItem animated:animated];
    } else {
        [navigationItem setRightBarButtonItem:nil animated:animated];
    }
    
}

#pragma mark - FooterViewController

- (FooterViewController *)addFooterViewController:(void(^)(FooterViewController *footerViewController))initializeBlock {
    if (_footerViewController != nil) return _footerViewController;
    
    _footerViewController = [[FooterViewController alloc] initWithNibName:@"FooterViewController" bundle:[NSBundle mainBundle]];
    [_footerViewController setDelegate:self];
    [_footerViewController.view setAutoresizingMask:UIViewAutoresizingNone];
    [self addChildViewController:_footerViewController];
    
    CGFloat offset = 0.0f;
    if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        offset = -20.f;
        if ([self.navigationController isNavigationBarHidden] == NO) {
            offset -= 44.0f;
        }
    }
    
    // Place on bottom
    CGRect frame = _footerViewController.view.frame;
    frame.size.height = 65.0f;
    frame.origin.y = CGRectGetMaxY(self.navigationController.view.frame) - CGRectGetHeight(frame) + offset;
    [_footerViewController.view setFrame:frame];
    
    [self.view addSubview:_footerViewController.view];
    
    if (initializeBlock) {
        initializeBlock(_footerViewController);
    }
    
    return _footerViewController;
}

- (FooterViewController *)footerViewController {
    return _footerViewController;
}

#pragma mark - Table Helper

- (void)slideCell:(UITableViewCell *)cell aboveTableViewMidwayPoint:(UITableView *)tableView {
    NSIndexPath *indexPath = [tableView indexPathForCell:cell];
    CGRect cellFrame = [tableView rectForRowAtIndexPath:indexPath];
    CGFloat cellBottom = cellFrame.origin.y + cellFrame.size.height;
    
    // do not set offset beyond the max content offset
    CGFloat maxContentOffset = MAX(0, tableView.contentSize.height - tableView.frame.size.height + tableView.contentInset.bottom);
    
    // adjust bottom for offset to compare with midway point
    CGFloat adjustedBottom = cellBottom - tableView.contentOffset.y;
    CGFloat midway = CGRectGetHeight(tableView.frame)/2;

    if (adjustedBottom > midway) {
        CGFloat newOffset = MIN(maxContentOffset, cellBottom - midway);
        CGPoint offset = CGPointMake(0.0, newOffset);
        [tableView setContentOffset:offset animated:TRUE];
    }
}

#pragma mark - LiveSpecialViewController

- (void)showLiveSpecialViewController:(LiveSpecialModel *)liveSpecial needToFetch:(BOOL)needToFetch {
    if (_liveSpecialViewController == nil) {
        
        // Create live special view controller
        _liveSpecialViewController = [[LiveSpecialViewController alloc] initWithNibName:@"LiveSpecialViewController" bundle:[NSBundle mainBundle]];
        [_liveSpecialViewController setDelegate:self];
        
        // Set alpha to zero so we can animate in
        [_liveSpecialViewController.view setAlpha:0.0f];
        [_liveSpecialViewController.view setFrame:self.navigationController.view.frame];
        
        // Adding to window
        [[[UIApplication sharedApplication] keyWindow]  addSubview:_liveSpecialViewController.view];
        
        // Animating in
        [UIView animateWithDuration:0.35 animations:^{
            [_liveSpecialViewController.view setAlpha:1.0f];
        }];
    }
    
    // Updating live special text
    [_liveSpecialViewController setNeedToFetch:needToFetch];
    [_liveSpecialViewController setLiveSpecial:liveSpecial];
}

- (void)hideLiveSpecialViewController:(void(^)(void))completion {
    
    // Animating live special out
    [UIView animateWithDuration:0.35 animations:^{
        [_liveSpecialViewController.view setAlpha:0.0f];
    } completion:^(BOOL finished) {
        
        // Removing live special from view
        [_liveSpecialViewController.view removeFromSuperview];
        _liveSpecialViewController = nil;

        if (completion != nil) {
            completion();
        }
    }];
}

#pragma mark - LiveSpecialViewControllerDelegate

- (void)liveSpecialViewControllerClickedClose:(LiveSpecialViewController *)viewController {
    [self hideLiveSpecialViewController:nil];
}

- (void)liveSpecialViewControllerClickedShare:(LiveSpecialViewController *)viewController {
    LiveSpecialModel *liveSpecial = [viewController liveSpecial];
    
    [self hideLiveSpecialViewController:^{
        [self showShareViewController:liveSpecial.spot shareType:ShareViewControllerShareSpecial];
    }];
}

#pragma mark - ShareViewController

- (void)showShareViewController:(SpotModel *)spot shareType:(ShareViewControllerShareType)shareType {
    if (_shareViewController == nil) {
        
        // Create lshare view controller
        _shareViewController = [[self shareStoryboard] instantiateViewControllerWithIdentifier:( IS_FOUR_INCH ? @"ShareViewController" : @"ShareViewControllerIPhone4" )];
        [_shareViewController setDelegate:self];
        
        // Set alpha to zero so we can animate in
        [_shareViewController.view setAlpha:0.0f];
        [_shareViewController.view setFrame:self.navigationController.view.frame];
        
        // Adding to window
        [[[UIApplication sharedApplication] keyWindow]  addSubview:_shareViewController.view];
        
        // Animating in
        [UIView animateWithDuration:0.35 animations:^{
            [_shareViewController.view setAlpha:1.0f];
        }];
    }
    
    // Updating live special text
    [_shareViewController setSpot:spot];
    [_shareViewController setShareType:shareType];
}

- (void)hideShareViewController:(void (^)(void))completion {
    // Animating live special out
    [UIView animateWithDuration:0.35 animations:^{
        [_shareViewController.view setAlpha:0.0f];
    } completion:^(BOOL finished) {
        
        // Removing live special from view
        [_shareViewController.view removeFromSuperview];
        _shareViewController = nil;
        
        if (completion != nil) {
            completion();
        }
    }];
}

#pragma mark - ShareViewControllerDelegate

- (void)shareViewControllerClickedClose:(ShareViewController *)viewController {
    [self hideShareViewController:nil];
}

- (void)shareViewControllerDidFinish:(ShareViewController *)viewController {
    [self hideShareViewController:^{
        
    }];
}

#pragma mark - SearchViewControllerDelegate

- (void)searchViewController:(SearchViewController *)viewController selectedDrink:(DrinkModel *)drink {
    
    DrinkProfileViewController *drinkViewController = [[self drinksStoryboard] instantiateViewControllerWithIdentifier:@"DrinkProfileViewController"];
    [drinkViewController setDrink:drink];
    
    NSMutableArray *viewControllers = self.navigationController.viewControllers.mutableCopy;
    [viewControllers removeLastObject];
    [viewControllers addObject:drinkViewController];
    
    [self.navigationController setViewControllers:viewControllers animated:YES];
    
}

- (void)searchViewController:(SearchViewController *)viewController selectedSpot:(SpotModel *)spot {
 
    SpotProfileViewController *spotViewController = [[self spotsStoryboard] instantiateViewControllerWithIdentifier:@"SpotProfileViewController"];
    [spotViewController setSpot:spot];
    
    NSMutableArray *viewControllers = self.navigationController.viewControllers.mutableCopy;
    [viewControllers removeLastObject];
    [viewControllers addObject:spotViewController];
    
    [self.navigationController setViewControllers:viewControllers animated:YES];
    
}

#pragma mark - Private

- (NSInteger)extractNumberFromString:(NSString *)string withPrefix:(NSString *)prefix {
    NSString *pattern = [NSString stringWithFormat:@"%@(\\d+)", prefix];
    
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    if (!error) {
        NSArray *matches = [regex matchesInString:string options:0 range:NSMakeRange(0, [string length])];
        if (matches.count) {
            NSTextCheckingResult *match = matches[0];
            if (match.numberOfRanges > 1) {
                NSString *substring = [string substringWithRange:[match rangeAtIndex:1]];
                return [substring integerValue];
            }
        }
    }
    
    return NSNotFound;
}

@end