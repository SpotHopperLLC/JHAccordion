//
//  BaseViewController.h
//  SpotHopper
//
//  Created by Josh Holtz on 12/9/13.
//  Copyright (c) 2013 Josh Holtz. All rights reserved.
//

#define kDidLoadOptionsDontAdjustForIOS6 @"DontAdjustForIOS6"
#define kDidLoadOptionsNoBackground @"NoBackground"
#define kDidLoadOptionsBlurredBackground @"BlurredBackground"
#define kDidLoadOptionsFocusedBackground @"FocusedBackground"

#import <UIKit/UIKit.h>

#import "FooterViewController.h"

#import "MBProgressHUD.h"

#import "JHPullRefreshViewController.h"

#import "TTTAttributedLabel+QuickFonting.h"

@class LiveSpecialModel, SpotModel, ErrorModel;

@interface BaseViewController : JHPullRefreshViewController<FooterViewControllerDelegate>

@property (nonatomic, readonly) NSString *screenName; // override

@property (readonly) BOOL hasFourInchDisplay;

- (void)viewDidLoad:(NSArray*)options;

- (void)showHUDCompleted:(NSString*)text;
- (void)showHUDCompleted:(NSString*)text block:(dispatch_block_t)block;
- (void)showHUDCompleted:(NSString*)text time:(NSInteger)time block:(dispatch_block_t)block;
- (void)showHUD:(NSString *)text time:(NSInteger)time image:(NSString*)image block:(dispatch_block_t)block;

- (void)showHUD;
- (void)showHUD:(NSString*)label;
- (void)hideHUD;

- (void)oops:(ErrorModel *)errorModel caller:(SEL)caller;
- (void)oops:(ErrorModel *)errorModel caller:(SEL)caller message:(NSString *)message;

- (UIAlertView*)showAlert:(NSString*)title message:(NSString*)message;
- (UIAlertView *)showAlert:(NSString *)title message:(NSString *)message block:(void(^)())alertBlock;

- (NSArray*)textfieldToHideKeyboard;

- (float)offsetForKeyboard;
-(void)keyboardWillShow:(NSNotification*)notification;
-(void)keyboardWillHide:(NSNotification*)notification;
-(void)setViewMovedUp:(BOOL)movedUp keyboardFrame:(CGRect)keyboardFrame;
- (NSTimeInterval)getKeyboardDuration:(NSNotification *)notification;
- (CGFloat)getKeyboardHeight:(NSNotification *)notification forBeginning:(BOOL)forBeginning;
- (UIViewAnimationOptions)getKeyboardAnimationCurve:(NSNotification *)notification;

- (CGFloat)heightForAttributedString:(NSAttributedString *)text maxWidth:(CGFloat)maxWidth;
- (CGFloat)heightForString:(NSString *)text font:(UIFont *)font maxWidth:(CGFloat)maxWidth;
- (CGFloat)widthForAttributedString:(NSAttributedString *)text maxWidth:(CGFloat)maxHeight;
- (CGFloat)widthForString:(NSString *)text font:(UIFont *)font maxWidth:(CGFloat)maxHeight;

- (void)changeLabelToLatoLight:(UIView *)view;
- (void)changeLabelToLatoLight:(UIView *)view withBoldText:(NSString *)boldText;

- (UIImage *)whiteScreenImageForFrame:(CGRect)frame;
- (UIImage *)resizeImage:(UIImage *)image toMaximumSize:(CGSize)maxSize;
- (UIImage *)screenshotOfView:(UIView *)view excludingViews:(NSArray *)excludedViews;

- (void)shortenLink:(NSString *)link withCompletionBlock:(void (^)(NSString *shortedLink, NSError *error))completionBlock;

- (void)promptForDirectionsForSpot:(SpotModel *)spot;
- (BOOL)isGoogleMapsAvailable;
- (void)openGoogleMapsInAppStore;
- (void)openGoogleMapsDirectionsForSpot:(SpotModel *)spot;
- (void)openAppleMapsDirectionsForSpot:(SpotModel *)spot;

- (void)onClickBack:(id)sender;
- (void)onClickShowSidebar:(id)sender;

- (void)fillSubview:(UIView *)subview inSuperView:(UIView *)superview;
- (void)embedViewController:(UIViewController *)vc intoView:(UIView *)superview placementBlock:(void (^)(UIView *view))placementBlock;
- (void)removeEmbeddedViewController:(UIViewController *)vc;

- (void)showSidebarButton:(BOOL)show animated:(BOOL)animated;
- (void)showSidebarButton:(BOOL)show animated:(BOOL)animated navigationItem:(UINavigationItem*)navigationItem;

- (FooterViewController*)addFooterViewController:(void(^)(FooterViewController *footerViewController))initializeBlock;
- (FooterViewController*)footerViewController;

- (void)slideCell:(UITableViewCell *)cell aboveTableViewMidwayPoint:(UITableView *)tableView;

// URL Scheme Support
- (void)handleOpenedURL:(NSURL *)openedURL;

// Prompt Login Needed
- (BOOL)promptLoginNeeded:(NSString*)message;

@end
