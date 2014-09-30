//
//  BaseViewController.m
//  SpotHopper
//
//  Created by Josh Holtz on 12/9/13.
//  Copyright (c) 2013 Josh Holtz. All rights reserved.
//

#import "BaseViewController.h"

#import "SHAppConfiguration.h"
#import "SHAppUtil.h"

#import "MBProgressHUD.h"

#import "UIViewController+Navigator.h"
#import "UIAlertView+Block.h"

#import "AccountSettingsViewController.h"
//#import "FooterViewController.h"
//#import "SidebarViewController.h"
//#import "SearchViewController.h"
#import "ShareViewController.h"

#import "LaunchViewController.h"
//#import "DrinkProfileViewController.h"
//#import "SpotProfileViewController.h"

#import "SpotModel.h"
#import "DrinkModel.h"
#import "LiveSpecialModel.h"

#import "SHNotifications.h"

#import "AppDelegate.h"
#import "ClientSessionManager.h"
#import "JTSReachabilityResponder.h"

#import "TellMeMyLocation.h"
#import "SSTURLShortener.h"
#import "UIAlertView+Block.h"

#import "Tracker.h"
#import "ErrorModel.h"

#import <JHSidebar/JHSidebarViewController.h>
#import <FacebookSDK/FacebookSDK.h>

#define kTagHUD 1025

typedef void(^AlertBlock)();

@interface BaseViewController () <UINavigationControllerDelegate, ShareViewControllerDelegate>

@property (nonatomic, strong) UIAlertView *alertView;
@property (nonatomic, copy) AlertBlock alertBlock;

//@property (nonatomic, strong) UIBarButtonItem *backButtonItem;
@property (nonatomic, strong) UIBarButtonItem *rightSidebarButtonItem;

@property (nonatomic, strong) UIImageView *backgroundImage;
@property (nonatomic, strong) FooterViewController *footerViewController;

@property (nonatomic, strong) ShareViewController *shareViewController;

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
    [super viewDidLoad];
    
    NSArray *options = [self viewOptions];
    
    if (![options containsObject:kDidLoadOptionsNoBackground]) {
        _backgroundImage = [[UIImageView alloc] initWithFrame:self.view.frame];
        [_backgroundImage setImage:[UIImage imageNamed:( [options containsObject:kDidLoadOptionsFocusedBackground] ? @"app_background" : @"app_background_blurred" )]];
        [_backgroundImage setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
        [_backgroundImage setContentMode:UIViewContentModeBottom];
        
        [self.view insertSubview:_backgroundImage atIndex:0];
    }
}

- (NSArray *)viewOptions {
    return @[kDidLoadOptionsBlurredBackground];
}

- (void)viewDidLoad:(NSArray*)options {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushNotificationReceived:) name:kNotificationPushReceived object:nil];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSURL *openedURL = [appDelegate openedURL];
    if (openedURL) {
        [self handleOpenedURL:openedURL];
        appDelegate.openedURL = nil;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationPushReceived object:nil];
    [super viewWillDisappear:animated];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Push notification 

- (void)pushNotificationReceived:(NSNotification*)notification {
    NSLog(@"Handling push on - %@", self);
    
    //NSNumber *spotId = [notification.userInfo objectForKey:@"s_id"];
    NSNumber *liveSpecialId = [notification.userInfo objectForKey:@"ls_id"];
    
    if (liveSpecialId != nil) {
        LiveSpecialModel *liveSpecial = [[LiveSpecialModel alloc] init];
        [liveSpecial setID:liveSpecialId];
        // TODO: replace
        //[self showLiveSpecialViewController:liveSpecial needToFetch:YES];
    }
    
}

#pragma mark - URL Scheme Support

- (void)handleOpenedURL:(NSURL *)openedURL {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.openedURL = nil;
    
    NSString *fullURLString = openedURL.absoluteString;
    
    if ([fullURLString rangeOfString:@"/spots/" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        NSInteger modelId = [self extractNumberFromString:fullURLString withPrefix:@"/spots/"];
        if (modelId != NSNotFound) {
            SpotModel *spot = [[SpotModel alloc] init];
            spot.ID = [NSNumber numberWithInteger:modelId];
            [[spot fetchSpot] then:^(SpotModel *fetchedSpot) {
                [SHNotifications displaySpot:fetchedSpot];
            } fail:^(ErrorModel *errorModel) {
                [self oops:errorModel caller:_cmd message:@"Failure to fetch spot. Please try again."];
            } always:nil];
        }
    }
    else if ([fullURLString rangeOfString:@"/drinks/" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        NSInteger modelId = [self extractNumberFromString:fullURLString withPrefix:@"/drinks/"];
        if (modelId != NSNotFound) {
            DrinkModel *drink = [[DrinkModel alloc] init];
            drink.ID = [NSNumber numberWithInteger:modelId];
            
            [[drink fetchDrink] then:^(DrinkModel *fetchedDrink) {
                [SHNotifications displayDrink:fetchedDrink];
            } fail:^(ErrorModel *errorModel) {
                [self oops:errorModel caller:_cmd message:@"Failure to fetch drink. Please try again."];
            } always:nil];
        }
    }
    else if ([fullURLString rangeOfString:@"/live_specials/" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        NSInteger modelId = [self extractNumberFromString:fullURLString withPrefix:@"/live_specials/"];
        if (modelId != NSNotFound) {
            LiveSpecialModel *liveSpecial =[[LiveSpecialModel alloc] init];
            [liveSpecial setID:[NSNumber numberWithInteger:modelId]];
            // TODO: replace
            //[self showLiveSpecialViewController:liveSpecial needToFetch:YES];
        }
        // TODO: reimplement
//        else {
//            [self goToTonightsSpecials];
//        }
    }
}

#pragma mark - Tracking

- (NSString *)screenName {
    return self.title;
}

#pragma mark - Errors

- (void)oops:(ErrorModel *)errorModel caller:(SEL)caller {
    [self oops:errorModel caller:caller message:nil];
}

- (void)oops:(ErrorModel *)errorModel caller:(SEL)caller message:(NSString *)message {
    [Tracker logError:errorModel class:[self class] trace:NSStringFromSelector(caller)];
    
    if (![[JTSReachabilityResponder sharedInstance] isReachable]) {
        [self showAlert:@"Oops" message:@"Sorry, the network is currently not accessible. Please try again later."];
    }
    else if (message.length) {
        [self showAlert:@"Oops" message:message];
    }
    else if (errorModel.human.length && !message.length) {
        [self showAlert:@"Oops" message:errorModel.human];
    }
    else {
        [self showAlert:@"Oops" message:@"Something went wrong. Please try again."];
    }
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
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[[[UIApplication sharedApplication] delegate] window] animated:YES];
    hud.tag = kTagHUD;
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:image]];
    [hud setLabelText:text];
	hud.mode = MBProgressHUDModeCustomView;
    [hud setDimBackground:YES];
    [hud removeFromSuperViewOnHide];
    
	[hud hide:YES afterDelay:time];
    
    if (block != nil) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, time * NSEC_PER_SEC), dispatch_get_main_queue(), block);
    }
}

- (void)showHUD {
    [self showHUD:@"Loading"];
}

- (void)showHUD:(NSString*)label {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[[[UIApplication sharedApplication] delegate] window] animated:YES];
    hud.tag = kTagHUD;
    [hud setMode:MBProgressHUDModeIndeterminate];
    [hud setDimBackground:YES];
    [hud setLabelText:label];
    [hud removeFromSuperViewOnHide];
}

- (void)hideHUD {
    [MBProgressHUD hideHUDForView:[[[UIApplication sharedApplication] delegate] window] animated:YES];
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

- (NSTimeInterval)getKeyboardDuration:(NSNotification *)notification {
	NSDictionary *info = [notification userInfo];
	
	NSTimeInterval duration;
	
	NSValue *durationValue = [info objectForKey:UIKeyboardAnimationDurationUserInfoKey];
	[durationValue getValue:&duration];
	
	return duration;
}

- (CGFloat)getKeyboardHeight:(NSNotification *)notification forBeginning:(BOOL)forBeginning {
	NSDictionary *info = [notification userInfo];
	
	CGFloat keyboardHeight;
    
    NSValue *boundsValue = nil;
    if (forBeginning) {
        boundsValue = [info valueForKey:UIKeyboardFrameBeginUserInfoKey];
    }
    else {
        boundsValue = [info valueForKey:UIKeyboardFrameEndUserInfoKey];
    }
    
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    if (UIDeviceOrientationIsLandscape(orientation)) {
        keyboardHeight = [boundsValue CGRectValue].size.width;
    }
    else {
        keyboardHeight = [boundsValue CGRectValue].size.height;
    }
    
	return keyboardHeight;
}

- (UIViewAnimationOptions)getKeyboardAnimationCurve:(NSNotification *)notification {
	UIViewAnimationCurve curve = [[notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    switch (curve) {
        case UIViewAnimationCurveEaseInOut:
            return UIViewAnimationOptionCurveEaseInOut;
            break;
        case UIViewAnimationCurveEaseIn:
            return UIViewAnimationOptionCurveEaseIn;
            break;
        case UIViewAnimationCurveEaseOut:
            return UIViewAnimationOptionCurveEaseOut;
            break;
        case UIViewAnimationCurveLinear:
            return UIViewAnimationOptionCurveLinear;
            break;
    }
    
    return kNilOptions;
}

#pragma mark - Text

- (CGFloat)heightForAttributedString:(NSAttributedString *)text maxWidth:(CGFloat)maxWidth {
    return [[SHAppUtil defaultInstance] heightForAttributedString:text maxWidth:maxWidth];
}

- (CGFloat)heightForString:(NSString *)text font:(UIFont *)font maxWidth:(CGFloat)maxWidth {
    return [[SHAppUtil defaultInstance] heightForString:text font:font maxWidth:maxWidth];
}

- (CGFloat)widthForAttributedString:(NSAttributedString *)text maxWidth:(CGFloat)maxHeight {
    return [[SHAppUtil defaultInstance] widthForAttributedString:text maxWidth:maxHeight];
}

- (CGFloat)widthForString:(NSString *)text font:(UIFont *)font maxWidth:(CGFloat)maxHeight {
    return [[SHAppUtil defaultInstance] widthForString:text font:font maxWidth:maxHeight];
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
        frame.size.height = [[SHAppUtil defaultInstance] heightForString:label.text font:label.font maxWidth:CGRectGetWidth(label.frame)];
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

- (UIImage *)resizeImage:(UIImage *)image toMaximumSize:(CGSize)maxSize {
    CGFloat widthRatio = maxSize.width / image.size.width;
    CGFloat heightRatio = maxSize.height / image.size.height;
    CGFloat scaleRatio = widthRatio < heightRatio ? widthRatio : heightRatio;
    CGSize newSize = CGSizeMake(image.size.width * scaleRatio, image.size.height * scaleRatio);
    
    UIGraphicsBeginImageContextWithOptions(newSize, NO, image.scale);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resizedImage;
}

- (UIImage *)screenshotOfView:(UIView *)view excludingViews:(NSArray *)excludedViews {
    if (!floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        NSCAssert(FALSE, @"iOS 7 or later is required.");
    }
    
    // hide all excluded views before capturing screen and keep initial value
    NSMutableArray *hiddenValues = [@[] mutableCopy];
    for (NSUInteger index=0;index<excludedViews.count;index++) {
        [hiddenValues addObject:[NSNumber numberWithBool:((UIView *)excludedViews[index]).hidden]];
        ((UIView *)excludedViews[index]).hidden = TRUE;
    }
    
    UIImage *image = nil;
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:excludedViews.count > 0];
    
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // reset hidden values
    for (NSUInteger index=0;index<excludedViews.count;index++) {
        ((UIView *)excludedViews[index]).hidden = [[hiddenValues objectAtIndex:index] boolValue];
    }
    
    // clean up
    hiddenValues = nil;
    
    return image;
}

#pragma mark - Sharing

- (void)shortenLink:(NSString *)link withCompletionBlock:(void (^)(NSString *shortedLink, NSError *error))completionBlock {
    // go.spotapps.co -> www.spothopperapp.com
    
    [SSTURLShortener shortenURL:[NSURL URLWithString:link] username:[SHAppConfiguration bitlyUsername] apiKey:[SHAppConfiguration bitlyAPIKey] withCompletionBlock:^(NSURL *shortenedURL, NSError *error) {
        if (completionBlock) {
            completionBlock(shortenedURL.absoluteString, error);
        }
    }];
}

#pragma mark - Directions

#define kGoogleMapsURLScheme @"comgooglemaps://"
#define kAppleMapsURLScheme @"http://maps.apple.com"

- (void)promptForDirectionsForSpot:(SpotModel *)spot {
#if TARGET_IPHONE_SIMULATOR
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Simulator" message:@"Directions are not available in the iOS Simulator." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
#else
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Directions" message:@"Would you like to open directions for this spot?" delegate:nil cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    [alertView showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            if ([self isGoogleMapsAvailable]) {
                [self openGoogleMapsDirectionsForSpot:spot];
            }
            else {
                [self openAppleMapsDirectionsForSpot:spot];
            }
        }
    }];
#endif
}

- (BOOL)isGoogleMapsAvailable {
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:kGoogleMapsURLScheme]];
}

- (void)openGoogleMapsInAppStore {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/us/app/google-maps/id585027354?mt=8"]];
}

- (void)openGoogleMapsDirectionsForSpot:(SpotModel *)spot {
    if ([self isGoogleMapsAvailable]) {
        CLLocation *currentLocation = [TellMeMyLocation currentDeviceLocation];
        CLLocation *spotLocation = [[CLLocation alloc] initWithLatitude:[spot.latitude floatValue] longitude:[spot.longitude floatValue]];
        
        CLLocationDistance meters = [currentLocation distanceFromLocation:spotLocation];
        NSString *dirflg = meters < 500 ? @"w" : @"d"; // set to walking for under 500 meters
        
        // w = walking, d = driving, r = public transit
        
        NSString *saddr = [NSString stringWithFormat:@"%f,%f",
                           currentLocation.coordinate.latitude,
                           currentLocation.coordinate.longitude];
        NSString *daddr = [NSString stringWithFormat:@"%f,%f",
                           spotLocation.coordinate.latitude,
                           spotLocation.coordinate.longitude];

        NSString *urlString = [NSString stringWithFormat:@"%@?saddr=%@&daddr=%@&dirflg=%@", kGoogleMapsURLScheme, saddr, daddr, dirflg];
        NSURL *url = [NSURL URLWithString:urlString];
        
        [[UIApplication sharedApplication] openURL:url];
    }
}

- (void)openAppleMapsDirectionsForSpot:(SpotModel *)spot {
    CLLocation *currentLocation = [TellMeMyLocation currentDeviceLocation];
    CLLocation *spotLocation = [[CLLocation alloc] initWithLatitude:[spot.latitude floatValue] longitude:[spot.longitude floatValue]];
    
    CLLocationDistance meters = [currentLocation distanceFromLocation:spotLocation];
    NSString *dirflg = meters < 500 ? @"w" : @"d"; // default to walking
    
    // if the distance is not walking distance (1/8 mile) then use driving directions
    // w = walking, d = driving, r = public transit
    
    NSString *saddr = [NSString stringWithFormat:@"%f,%f",
                       currentLocation.coordinate.latitude,
                       currentLocation.coordinate.longitude];
    NSString *daddr = [NSString stringWithFormat:@"%f,%f",
                       spotLocation.coordinate.latitude,
                       spotLocation.coordinate.longitude];
    
    NSString *urlString = [NSString stringWithFormat:@"%@?saddr=%@&daddr=%@&dirflg=%@", kAppleMapsURLScheme, saddr, daddr, dirflg];
    NSURL *url = [NSURL URLWithString:urlString];
    
    [[UIApplication sharedApplication] openURL:url];
}

#pragma mark - Navigation

- (void)onClickBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)onClickShowSidebar:(id)sender {
    [self.navigationController.sidebarViewController showRightSidebar:YES];
}

#pragma mark - Embedding View Controllers

- (void)fillSubview:(UIView *)subview inSuperView:(UIView *)superview {
    NSDictionary *views = NSDictionaryOfVariableBindings(subview);
    [superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[subview]|" options:0 metrics:nil views:views]];
    [superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[subview]|" options:0 metrics:nil views:views]];
}

- (void)embedViewController:(UIViewController *)vc intoView:(UIView *)superview {
    [self embedViewController:vc intoView:superview placementBlock:nil];
}

- (void)embedViewController:(UIViewController *)vc intoView:(UIView *)superview placementBlock:(void (^)(UIView *view))placementBlock {
    NSAssert(vc, @"VC must be define");
    NSAssert(superview, @"Superview must be defined");
    
    vc.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self addChildViewController:vc];
    [superview addSubview:vc.view];
    
    if (placementBlock) {
        placementBlock(vc.view);
    }
    else {
        [self fillSubview:vc.view inSuperView:superview];
    }
    
    [vc didMoveToParentViewController:self];
}

- (void)removeEmbeddedViewController:(UIViewController *)vc {
    if (vc) {
        [vc willMoveToParentViewController:self];
        [vc.view removeFromSuperview];
        [vc removeFromParentViewController];
    }
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
    }
    else {
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

#pragma mark - ShareViewController

//- (void)showShareViewControllerWithCheckIn:(CheckInModel *)checkIn {
//    if (_shareViewController == nil) {
//        
//        // Create lshare view controller
//        _shareViewController = [[self shareStoryboard] instantiateViewControllerWithIdentifier:( IS_FOUR_INCH ? @"ShareViewController" : @"ShareViewControllerIPhone4" )];
//        [_shareViewController setDelegate:self];
//        
//        // Set alpha to zero so we can animate in
//        [_shareViewController.view setAlpha:0.0f];
//        [_shareViewController.view setFrame:self.navigationController.view.frame];
//        
//        // Adding to window
//        [[[UIApplication sharedApplication] keyWindow] addSubview:_shareViewController.view];
//        
//        // Animating in
//        [UIView animateWithDuration:0.35 animations:^{
//            [_shareViewController.view setAlpha:1.0f];
//        }];
//    }
//    
//    // Updating live special text
//    [_shareViewController setCheckIn:checkIn];
//    [_shareViewController setSpot:checkIn.spot];
//    [_shareViewController setShareType:ShareViewControllerShareCheckin];
//}

- (void)showShareViewControllerWithSpot:(SpotModel *)spot shareType:(ShareViewControllerShareType)shareType {
    if (_shareViewController == nil) {
        
        // Create lshare view controller
        _shareViewController = [[self shareStoryboard] instantiateViewControllerWithIdentifier:( IS_FOUR_INCH ? @"ShareViewController" : @"ShareViewControllerIPhone4" )];
        [_shareViewController setDelegate:self];
        
        // Set alpha to zero so we can animate in
        [_shareViewController.view setAlpha:0.0f];
        [_shareViewController.view setFrame:self.navigationController.view.frame];
        
        // Adding to window
        [[[UIApplication sharedApplication] keyWindow] addSubview:_shareViewController.view];
        
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

#pragma mark - Prompt Login Needed

// Returns YES if a login is needed
- (BOOL)promptLoginNeeded:(NSString*)message {
    BOOL isLoggedIn = [ClientSessionManager sharedClient].isLoggedIn;
    
    if (isLoggedIn == NO) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Do you want to login?" message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
        [alertView showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                [self.navigationController popToRootViewControllerAnimated:YES];
                [self goToLaunch:YES];
            }
        }];
    }
    
    return !isLoggedIn;
}

#pragma mark - Helper Methods

- (BOOL)hasFourInchDisplay {
    return ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone && [UIScreen mainScreen].bounds.size.height == 568.0);
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

#pragma mark - ShareViewControllerDelegate
#pragma mark -

- (void)shareViewControllerClickedClose:(ShareViewController*)viewController {
    [self hideShareViewController:nil];
}

- (void)shareViewControllerDidFinish:(ShareViewController*)viewController {
    [self hideShareViewController:nil];
}

@end