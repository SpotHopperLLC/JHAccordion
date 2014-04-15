//
//  ShareViewController.m
//  SpotHopper
//
//  Created by Josh Holtz on 3/28/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#define kTitleCheckin @"Share Check-in!"
#define kTitleSpecial @"Share this Special!"

#import "ShareViewController.h"

#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"

#import "NSArray+DailySpecials.h"

#import "AppDelegate.h"

#import "LiveSpecialModel.h"
#import "SpotModel.h"

#import "MBProgressHUD.h"

#import <Promises/Promise.h>

#import <MessageUI/MessageUI.h>
#import <Social/Social.h>

#import "Tracker.h"
#import "TellMeMyLocation.h"

@interface ShareViewController ()<MFMessageComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *lblTite;
@property (weak, nonatomic) IBOutlet UITextView *txtShare;
@property (weak, nonatomic) IBOutlet UIButton *btnFacebook;
@property (weak, nonatomic) IBOutlet UIButton *btnTwitter;
@property (weak, nonatomic) IBOutlet UIButton *btnText;

@property (nonatomic, assign) BOOL sendToFacebook;
@property (nonatomic, assign) BOOL sendToTwitter;
@property (nonatomic, assign) BOOL sendToText;

@property (nonatomic, strong) ACAccount *selectedTwitterAccount;

@property (nonatomic, strong) UIAlertView *alertView;
@property (nonatomic, strong) MBProgressHUD *HUD;

@end

@implementation ShareViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self updateView];
    [self updateSocialViews];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_txtShare becomeFirstResponder];
    
    // tracking with Google Analytics (override screenName)
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:self.screenName];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Tracking

- (NSString *)screenName {
    return @"Share";
}

#pragma mark - MFMessageComposeViewControllerDelegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [controller dismissViewControllerAnimated:YES completion:^{
        if ([_delegate respondsToSelector:@selector(shareViewControllerDidFinish:)]) {
            [_delegate shareViewControllerDidFinish:self];
        }
    }];
}

#pragma mark - Actions

- (IBAction)onClickClose:(id)sender {
    if ([_delegate respondsToSelector:@selector(shareViewControllerClickedClose:)]) {
        [_delegate shareViewControllerClickedClose:self];
    }
}

- (IBAction)onClickShareFacebook:(id)sender {
    [Tracker track:@"Sharing" properties:@{@"Service" : @"Facebook", @"Location" : [TellMeMyLocation lastLocationNameShort]}];
    
    if ([[FBSession activeSession] isOpen] == YES) {
        _sendToFacebook = !_sendToFacebook;
        [self updateSocialViews];
        return;
    }
    
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate facebookAuth:YES success:^(FBSession *session) {
        _sendToFacebook = YES;
        [self updateSocialViews];
    } failure:^(FBSessionState state, NSError *error) {
        _sendToFacebook = NO;
        [self updateSocialViews];
    }];
    
}

- (IBAction)onClickShareTWitter:(id)sender {
    [Tracker track:@"Sharing" properties:@{@"Service" : @"Twitter", @"Location" : [TellMeMyLocation lastLocationNameShort]}];
    
    if (_sendToTwitter == YES) {
        _selectedTwitterAccount = nil;
        _sendToTwitter = NO;
        [self updateSocialViews];
    } else {
    
        AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        [appDelegate twitterChooseAccount:self.view success:^(ACAccount *account) {
            _selectedTwitterAccount = account;
            
            _sendToTwitter = YES;
            [self updateSocialViews];
        } cancel:^{
            
        } noAccounts:^{
            [self showAlert:@"No Accounts Found" message:@"No Twitter accounts were found logged in to this device..\n\nPlease connect Twitter account in the Settings app if you would like to use Twitter in SpotHopper"];
        } permissionDenied:^{
            [self showAlert:@"Permission Denied" message:@"SpotHopper does not have permission to use Twitter.\n\nPlease adjust the permissions in the Settings app if you would like to use Twitter in SpotHopper"];
        }];
        
    }
}

- (IBAction)onClickShareText:(id)sender {
    [Tracker track:@"Sharing" properties:@{@"Service" : @"Text", @"Location" : [TellMeMyLocation lastLocationNameShort]}];
    
    _sendToText = !_sendToText;
    [self updateSocialViews];
}

- (IBAction)onClickShare:(id)sender {
    [self doShare];
}

#pragma mark - Public

- (void)setSpot:(SpotModel *)spot {
    _spot = spot;
    [self updateView];
}

- (void)setShareType:(ShareViewControllerShareType)shareType {
    _shareType = shareType;
    [self updateView];
}

#pragma mark - Private

- (void)updateSocialViews {
    
    [_btnFacebook setSelected:_sendToFacebook];
    [_btnTwitter setSelected:_sendToTwitter];
    [_btnText setSelected:_sendToText];
    
}

- (void)updateView {
    // Sets stuff if checkin
    if (ShareViewControllerShareCheckin == _shareType) {
        
        // Sets title
        [_lblTite setText:kTitleCheckin];
        
        NSString *extraText = @"";
        LiveSpecialModel *liveSpecial = [_spot currentLiveSpecial];
        NSString *dailySpecial = [[_spot dailySpecials] specialsForToday];
        if (liveSpecial != nil) {
            extraText = [NSString stringWithFormat:@": %@", liveSpecial.text];
        } else if (dailySpecial != nil) {
            extraText = [NSString stringWithFormat:@": %@", dailySpecial];
        }
        
        // Sets share text
        [_txtShare setText:[NSString stringWithFormat:@"Checked into the %@ with SpotHopper%@", _spot.name, extraText]];
        
    }
    // Sets stuff if share live special
    else if (ShareViewControllerShareSpecial == _shareType) {
        
        // Sets title
        [_lblTite setText:kTitleSpecial];
        
        // Sets share text
        NSString *specialText = nil;
        LiveSpecialModel *liveSpecial = [_spot currentLiveSpecial];
        NSString *dailySpecial = [[_spot dailySpecials] specialsForToday];
        if (liveSpecial != nil) {
            specialText = liveSpecial.text;
        } else if (dailySpecial != nil) {
            specialText = dailySpecial;
        }
        
        if (specialText != nil) {
            [_txtShare setText:[NSString stringWithFormat:@"%@ at %@ with check-in #spothopper #barspecials", specialText, _spot.name]];
        } else {
            [_txtShare setText:@""];
        }
        
    }
    
}

- (UIAlertView *)showAlert:(NSString *)title message:(NSString *)message {
    return [self showAlert:title message:message block:nil];
}

- (UIAlertView *)showAlert:(NSString *)title message:(NSString *)message block:(void(^)())alertBlock {
    [_alertView dismissWithClickedButtonIndex:0 animated:NO];
    _alertView = nil;
    
    _alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
    [_alertView show];
    return _alertView;
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

#pragma mark - Private Share

- (void)doShare {
    
    NSMutableArray *promises = [NSMutableArray array];
    
    [self showHUD:@"Sharing"];
    if (_sendToFacebook == YES) {
        [promises addObject:[self doShareToFacebook]];
    }
    if (_sendToTwitter == YES && _selectedTwitterAccount != nil) {
        [promises addObject:[self doShareToTwitter]];
    }
    
    [When when:promises then:^{
        [self hideHUD];
        
        if (_sendToText == YES) {
            
            MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
            picker.messageComposeDelegate = self;
            picker.body = _txtShare.text;
            
            [self presentViewController:picker animated:YES completion:nil];
            
        } else if ([_delegate respondsToSelector:@selector(shareViewControllerDidFinish:)]) {
            [_delegate shareViewControllerDidFinish:self];
        }
        
    } fail:^(id error) {
        [self hideHUD];
        [self showAlert:@"Oops" message:@"Failed to share"];
    } always:^{
        
    }];
    
}

#pragma mark - Private Share Facebook

- (Promise*)doShareToFacebook {
    
    // Creating deferred for promises
    Deferred *deferred = [Deferred deferred];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            _txtShare.text, @"message",
                            nil];
    
    [FBRequestConnection
     startWithGraphPath:@"me/feed"
     parameters:params
     HTTPMethod:@"POST"
     completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        
         if (error) {
             [deferred rejectWith:error];
         } else {
             [deferred resolve];
         }
         
     }];
    
    return deferred.promise;
}

#pragma mark - Private Share Twitter

- (Promise*)doShareToTwitter {

    // Creating deferred for promises
    Deferred *deferred = [Deferred deferred];
    
    NSString *caption = [_txtShare text];
    int maxLength = 140;
    if (caption.length > maxLength) {
        caption = [caption substringToIndex:maxLength];
    }
    
    NSString *status = caption;
    
    
    NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/update.json"];
    NSDictionary *params = @{@"status" : status};
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                            requestMethod:SLRequestMethodPOST
                                                      URL:url
                                               parameters:params];
    
    [request setAccount:_selectedTwitterAccount];
    
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Twitter response, HTTP response: %ld", [urlResponse statusCode]);
            
            if (error || [urlResponse statusCode] != 200) {
                [deferred rejectWith:error];
            } else {
                [deferred resolve];
            }
            
        });
    }];
    
    return deferred.promise;
}

@end
