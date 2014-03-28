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
    
}

- (IBAction)onClickShareFacebook:(id)sender {
}

- (IBAction)onClickShareTWitter:(id)sender {
}

- (IBAction)onClickShareText:(id)sender {
}

- (IBAction)onClickShare:(id)sender {
}

#pragma mark - Private

- (void)updateView {
    if (ShareViewControllerShareCheckin == _shareType) {
        [_lblTite setText:kTitleCheckin];
    } else if (ShareViewControllerShareCheckin == _shareType) {
    [_lblTite setText:kTitleSpecial];
    }
}

@end
