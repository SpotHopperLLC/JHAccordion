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

#import "SSTURLShortener.h"

#import <Promises/Promise.h>

#import <MessageUI/MessageUI.h>
#import <Social/Social.h>

#import "Tracker.h"
#import "TellMeMyLocation.h"

#define kSpecialsHashtags @"#spothopper #barspecials"
#define kCheckinHashtags @"#spothopper #checkin"

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
            [_txtShare setText:[NSString stringWithFormat:@"%@ at %@ with check-in %@", specialText, _spot.name, kSpecialsHashtags]];
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

- (NSString *)linkToShareForSource:(NSString *)source {
    // TODO add user id, and special or spot id depending on the share type (check in or special)
    
    // Notes on Sharing with Links
    // These parameters will not be visible in the shorted URL and once the page is loaded it should immediately
    // captures these values to the session and redirect to the appropriate web page.
    
    // These details should be logged each time a link is used so that it will be possible to identify who
    // is sharing the link, which source (FB, Twitter, SMS) and the related spot or special if it is set.
    // We will want to log these details so that we can identify the users which share the most and create the
    // most activity from their sharing activities. On a higher level we want to know which locations are most
    // active as well as determine which check ins and drink specials are the most sharable so we can encourage
    // that sort of content being shared.
    
    // For a generic share it can just log the detail and return to the home page without any query string
    // parameters. If a spot is identified it should go there. For a special it should go to a specials page.
    // Initially these pages will not exist so the web site will just redirect to a page which will promote
    // the app and if the user is accessing the page from a mobile device with the app installed it will
    // open the app and pass the spot or special id to open the app in that context. The website should
    // log with analytics the action that it is able to take, such as viewing the page on iOS, Android or
    // the desktop and if the app was installed and could be opened. Opening the app will just include
    // the spot, drink or special id but later it could include the user id of the user who shared it
    // to close the loop on tracking that sharing activity.
    
    // TODO get the actual userId if they are logged in to give them credit for the share
    // (otherwise leave userId as NSNotFound so it is not used, defensive programming)
    NSInteger userId = NSNotFound;
    NSString *type = _shareType == ShareViewControllerShareCheckin ? @"checkin" : @"special";
    
    NSString *spotOrSpecialParams = @"";
    // TODO if the spot or special is defined then set these params which are appended at the end
    // Be sure to follow the query string format: &NAME=VALUE
    // Examples: &spot=123 or &special=456
    
    if (userId != NSNotFound) {
        return [NSString stringWithFormat:@"http://www.spothopperapp.com/?source=%@&user=%li&type=%@%@", source, (long)userId, type, spotOrSpecialParams];
    }
    else {
        return [NSString stringWithFormat:@"http://www.spothopperapp.com/?source=%@&type=%@%@", source, type, spotOrSpecialParams];
    }
}

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
            NSString *linkToShare = [self linkToShareForSource:@"SMS"];
            [self shortenLink:linkToShare withCompletionBlock:^(NSString *shortedLink, NSError *error) {
                if (!shortedLink) {
                    shortedLink = kBitlyShortURL;
                }
                
                NSString *message = [NSString stringWithFormat:@"%@ - %@", _txtShare.text, shortedLink];
                
                MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
                picker.messageComposeDelegate = self;
                picker.body = message;
                
                [self presentViewController:picker animated:YES completion:nil];
                
            }];
        } else if ([_delegate respondsToSelector:@selector(shareViewControllerDidFinish:)]) {
            [_delegate shareViewControllerDidFinish:self];
        }
        
    } fail:^(id error) {
        [self hideHUD];
        [self showAlert:@"Oops" message:@"Failed to share"];
    } always:^{
        
    }];
}

- (void)shortenLink:(NSString *)link withCompletionBlock:(void (^)(NSString *shortedLink, NSError *error))completionBlock {
    // go.spotapps.co -> www.spothopperapp.com
    
    [SSTURLShortener shortenURL:[NSURL URLWithString:link] username:kBitlyUsername apiKey:kBitlyAPIKey withCompletionBlock:^(NSURL *shortenedURL, NSError *error) {
        if (completionBlock) {
            if (error) {
                completionBlock(nil, error);
            }
            else {
                completionBlock(shortenedURL.absoluteString, nil);
            }
        }
    }];
}

#pragma mark - Private Share Facebook

- (Promise*)doShareToFacebook {
    // Creating deferred for promises
    Deferred *deferred = [Deferred deferred];
    
    NSString *linkToShare = [self linkToShareForSource:@"Facebook"];
    [self shortenLink:linkToShare withCompletionBlock:^(NSString *shortedLink, NSError *error) {
        
        if (!shortedLink) {
            shortedLink = kBitlyShortURL;
        }
        
        NSDictionary *params = @{ @"message" : _txtShare.text, @"link" : shortedLink, @"icon" : kSpotHopperIconURL, @"description" : kSpotHopperTagline };
        
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
    }];
    
    return deferred.promise;
}

#pragma mark - Private Share Twitter

- (Promise*)doShareToTwitter {
    // Creating deferred for promises
    Deferred *deferred = [Deferred deferred];
    
    NSString *linkToShare = [self linkToShareForSource:@"Twitter"];
    [self shortenLink:linkToShare withCompletionBlock:^(NSString *shortedLink, NSError *error) {
        
        if (!shortedLink) {
            shortedLink = kBitlyShortURL;
        }
        
        NSUInteger maxLength = 140 - (shortedLink.length + 4); // padding for 3 periods and 1 space
    
        NSString *caption = _txtShare.text;
        if (caption.length > maxLength) {
            caption = [caption substringToIndex:maxLength];
        }
        
        NSString *status = [NSString stringWithFormat:@"%@... %@", caption, shortedLink];;
        
        NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/update.json"];
        NSDictionary *params = @{@"status" : status};
        SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                requestMethod:SLRequestMethodPOST
                                                          URL:url
                                                   parameters:params];
        
        [request setAccount:_selectedTwitterAccount];
        
        [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"Twitter response, HTTP response: %ld", (long)[urlResponse statusCode]);
                
                if (error || [urlResponse statusCode] != 200) {
                    [deferred rejectWith:error];
                } else {
                    [deferred resolve];
                }
                
            });
        }];
        
    }];
        
    return deferred.promise;
}

@end
