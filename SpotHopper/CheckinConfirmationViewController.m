//
//  CheckinConfirmationViewController.m
//  SpotHopper
//
//  Created by Josh Holtz on 3/28/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "CheckinConfirmationViewController.h"

#import "NSArray+DailySpecials.h"

#import "SpotModel.h"
#import "LiveSpecialModel.h"

@interface CheckinConfirmationViewController ()

@property (weak, nonatomic) IBOutlet UILabel *lblCheckedInAt;
@property (weak, nonatomic) IBOutlet UILabel *lblSpecialTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblSpecials;

@end

@implementation CheckinConfirmationViewController

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

    [_lblSpecialTitle setFont:[UIFont fontWithName:@"Avenir-Book" size:_lblSpecialTitle.font.pointSize]];
    
    [self updateView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Public

- (void)setSpot:(SpotModel *)spot {
    _spot = spot;
    [self updateView];
}

#pragma mark - Actions

- (IBAction)onClickClose:(id)sender {
    if ([_delegate respondsToSelector:@selector(checkinConfirmationViewControllerClickedClose:)]) {
        [_delegate checkinConfirmationViewControllerClickedClose:self];
    }
}

- (IBAction)onClickDrinkList:(id)sender {
    if ([_delegate respondsToSelector:@selector(checkinConfirmationViewControllerClickedDrinkList:)]) {
        [_delegate checkinConfirmationViewControllerClickedDrinkList:self];
    }
}

- (IBAction)onClickFullMenu:(id)sender {
    if ([_delegate respondsToSelector:@selector(checkinConfirmationViewControllerClickedFullMenu:)]) {
        [_delegate checkinConfirmationViewControllerClickedFullMenu:self];
    }
}

#pragma mark - Private

- (void)updateView {
    [_lblCheckedInAt setText:[NSString stringWithFormat:@"You're checked-in at %@!", _spot.name]];
    
    // Sets share text
    NSString *specialTitle = @"No Current\nSpecials";
    NSString *specialText = nil;
    LiveSpecialModel *liveSpecial = [_spot currentLiveSpecial];
    NSString *dailySpecial = [[_spot dailySpecials] specialsForToday];
    if (liveSpecial != nil) {
        specialTitle = @"Live\nSpecials!";
        specialText = liveSpecial.text;
    } else if (dailySpecial != nil) {
        specialTitle = @"Current\nSpecials!";
        specialText = dailySpecial;
    }
    [_lblSpecialTitle setText:specialTitle];
    [_lblSpecials setText:specialText];
}

@end
