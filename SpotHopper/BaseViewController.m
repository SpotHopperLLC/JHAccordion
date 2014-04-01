//
//  BaseViewController.m
//  SpotHopper
//
//  Created by Josh Holtz on 12/9/13.
//  Copyright (c) 2013 Josh Holtz. All rights reserved.
//

#import "BaseViewController.h"

#import "MBProgressHUD.h"

#import "UIViewController+Navigator.h"

#import "AccountSettingsViewController.h"
#import "FooterViewController.h"
#import "LiveSpecialViewController.h"
#import "SidebarViewController.h"

#import "LiveSpecialModel.h"

#import <JHSidebar/JHSidebarViewController.h>
#import <FacebookSDK/FacebookSDK.h>

typedef void(^AlertBlock)();

@interface BaseViewController ()<UINavigationControllerDelegate, SidebarViewControllerDelegate, LiveSpecialViewControllerDelegate>

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
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    SidebarViewController *sidebar = (SidebarViewController*)self.navigationController.sidebarViewController.rightViewController;
    [sidebar setDelegate:self];
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

#pragma mark - SidebarViewControllerDelegate

- (void)sidebarViewControllerClickedReview:(SidebarViewController *)sidebarViewController {
    [self goToReviewMenu];
}

- (void)sidebarViewControllerClickedCheckin:(SidebarViewController *)sidebarViewController {
    [self goToCheckin];
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
    CGFloat maxContentOffset = MAX(0, tableView.contentSize.height - tableView.frame.size.height);
    
    // adjust bottom for offset to compare with midway point
    CGFloat adjustedBottom = cellBottom - tableView.contentOffset.y;
    CGFloat midway = tableView.frame.size.height/2;
    
    if (adjustedBottom > midway) {
        CGFloat newOffset = MIN(maxContentOffset, cellBottom - midway);
        CGPoint offset = CGPointMake(0.0, newOffset);
        [tableView setContentOffset:offset animated:TRUE];
    }
}

#pragma mark - LiveSpecialViewController

- (void)showLiveSpecialViewController:(LiveSpecialModel *)liveSpecial {
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

@end