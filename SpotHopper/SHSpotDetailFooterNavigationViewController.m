//
//  SHMapFooterNavigationViewController.m
//  SpotHopper
//
//  Created by Brennan Stehling on 5/16/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "SHSpotDetailFooterNavigationViewController.h"

#import "SHStyleKit+Additions.h"

static NSString* const kButtonLabelTitleFindSimilar = @"Find Similar";
static NSString* const kButtonLabelTitleReviewIt = @"  Review It"; //cheap fix for the odd spacing in between btn image and text
static NSString* const kButtonLabelTitleDrinkMenu = @"Drink Menu";

@interface SHSpotDetailFooterNavigationViewController ()

@property (weak, nonatomic) IBOutlet UIButton *btnFindSimilar;
@property (weak, nonatomic) IBOutlet UIButton *btnReview;
@property (weak, nonatomic) IBOutlet UIButton *btnDrinkMenu;

@end

@implementation SHSpotDetailFooterNavigationViewController

#pragma mark - View Lifecyle
#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad:@[kDidLoadOptionsNoBackground]];
    
    [self setButtonStyles];

}

#pragma mark - User Actions
#pragma mark -
- (IBAction)findSimilarButtonTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(footerNavigationViewController:findSimilarButtonTapped:)]) {
        [self.delegate footerNavigationViewController:self findSimilarButtonTapped:sender];
    }
}

//todo: need to change these so they push view controllers
//todo: create segues on IB for transition
- (IBAction)reviewButtonTapped:(id)sender {
    //todo: push review view
    
    if ([self.delegate respondsToSelector:@selector(footerNavigationViewController:spotReviewButtonTapped:)]) {
        [self.delegate footerNavigationViewController:self spotReviewButtonTapped:sender];
    }
}

- (IBAction)drinkMenuButtonTapped:(id)sender {
    //todo: push menu view
    if ([self.delegate respondsToSelector:@selector(footerNavigationViewController:drinkMenuButtonTapped:)]) {
        [self.delegate footerNavigationViewController:self drinkMenuButtonTapped:sender];
    }
}

#pragma mark - Private
#pragma mark -

- (void)setButtonStyles {
    [SHStyleKit setButton:self.btnFindSimilar withDrawing:SHStyleKitDrawingSearchIcon text:kButtonLabelTitleFindSimilar normalColor:SHStyleKitColorMyTextColor highlightedColor:SHStyleKitColorMyWhiteColor];
    [SHStyleKit setButton:self.btnReview withDrawing:SHStyleKitDrawingReviewsIcon text:kButtonLabelTitleReviewIt normalColor:SHStyleKitColorMyTextColor highlightedColor:SHStyleKitColorMyWhiteColor];
    [SHStyleKit setButton:self.btnDrinkMenu withDrawing:SHStyleKitDrawingDrinkMenuIcon text:kButtonLabelTitleDrinkMenu normalColor:SHStyleKitColorMyTextColor highlightedColor:SHStyleKitColorMyWhiteColor];
    
    self.btnFindSimilar.titleLabel.font = [UIFont fontWithName:@"Lato-Light" size:12.0f];
    [self.btnFindSimilar setTitleColor:SHStyleKit.myTextColor forState:UIControlStateNormal];
    
    self.btnReview.titleLabel.font = [UIFont fontWithName:@"Lato-Light" size:12.0f];
    [self.btnReview setTitleColor:SHStyleKit.myTextColor forState:UIControlStateNormal];
    
    self.btnDrinkMenu.titleLabel.font = [UIFont fontWithName:@"Lato-Light" size:12.0f];
    [self.btnDrinkMenu setTitleColor:SHStyleKit.myTextColor forState:UIControlStateNormal];
}

@end
