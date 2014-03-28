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

#import "NSArray+DailySpecials.h"

#import "LiveSpecialModel.h"
#import "SpotModel.h"

@interface ShareViewController ()

@property (weak, nonatomic) IBOutlet UILabel *lblTite;
@property (weak, nonatomic) IBOutlet UITextView *txtShare;
@property (weak, nonatomic) IBOutlet UIButton *btnFacebook;
@property (weak, nonatomic) IBOutlet UIButton *btnTwitter;
@property (weak, nonatomic) IBOutlet UIButton *btnText;

@end

@implementation ShareViewController

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
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)onClickClose:(id)sender {
    if ([_delegate respondsToSelector:@selector(shareViewControllerClickedClose:)]) {
        [_delegate shareViewControllerClickedClose:self];
    }
}

- (IBAction)onClickShareFacebook:(id)sender {
    
}

- (IBAction)onClickShareTWitter:(id)sender {
    
}

- (IBAction)onClickShareText:(id)sender {
    
}

- (IBAction)onClickShare:(id)sender {
    if ([_delegate respondsToSelector:@selector(shareViewControllerDidFinish:)]) {
        [_delegate shareViewControllerDidFinish:self];
    }
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

@end
