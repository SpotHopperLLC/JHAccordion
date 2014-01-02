//
//  BaseViewController.h
//  SpotHopper
//
//  Created by Josh Holtz on 12/9/13.
//  Copyright (c) 2013 Josh Holtz. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MBProgressHUD.h"

#import "JHPullRefreshViewController.h"

@interface BaseViewController : JHPullRefreshViewController

@property (nonatomic, strong) MBProgressHUD *HUD;

- (void)viewDidLoad:(BOOL)adjustForIOS6;

- (void)showHUDCompleted:(NSString*)text;
- (void)showHUDCompleted:(NSString*)text block:(dispatch_block_t)block;
- (void)showHUDCompleted:(NSString*)text time:(NSInteger)time block:(dispatch_block_t)block;
- (void)showHUD:(NSString *)text time:(NSInteger)time image:(NSString*)image block:(dispatch_block_t)block;

- (void)showHUD;
- (void)showHUD:(NSString*)label;
- (void)hideHUD;

- (UIAlertView*)showAlert:(NSString*)title message:(NSString*)message;
- (UIAlertView *)showAlert:(NSString *)title message:(NSString *)message block:(void(^)())alertBlock;

- (NSArray*)textfieldToHideKeyboard;

- (float)offsetForKeyboard;
-(void)keyboardWillShow:(NSNotification*)notification;
-(void)keyboardWillHide:(NSNotification*)notification;
-(void)setViewMovedUp:(BOOL)movedUp keyboardFrame:(CGRect)keyboardFrame;

- (void)onClickBack:(id)sender;

@end
