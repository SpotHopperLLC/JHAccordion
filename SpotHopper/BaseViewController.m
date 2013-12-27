//
//  BaseViewController.m
//  SpotHopper
//
//  Created by Josh Holtz on 12/9/13.
//  Copyright (c) 2013 Josh Holtz. All rights reserved.
//

#import "BaseViewController.h"

#import "MBProgressHUD.h"

typedef void(^AlertBlock)();

@interface BaseViewController ()<UINavigationControllerDelegate>

@property (nonatomic, strong) UIAlertView *alertView;
@property (nonatomic, copy) AlertBlock alertBlock;

@property (nonatomic, strong) UIBarButtonItem *backButtonItem;
@property (nonatomic, strong) UIBarButtonItem *rightRevealButtonItem;

@property (nonatomic, assign) BOOL loaded;

@end

@implementation BaseViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [self viewDidLoad:YES];
}

- (void)viewDidLoad:(BOOL)adjustForIOS6 {
    [super viewDidLoad];
	[self.view setBackgroundColor:[UIColor clearColor]];
    
    if (adjustForIOS6 == YES && SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(@"7.0")) {
        [self adjustIOS6Crap];
    }
}

- (void)adjustIOS6Crap {
    for (UIView *view in self.view.subviews) {
        CGRect frame = view.frame;
        frame.origin.y -= 64.0f;
        [view setFrame:frame];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    _HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
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
    
    _HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
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
-(void)setViewMovedUp:(BOOL)movedUp keyboardFrame:(CGRect)keyboardFrame
{
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

@end