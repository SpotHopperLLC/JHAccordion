//
//  SHMapFooterNavigationViewController.m
//  SpotHopper
//
//  Created by Brennan Stehling on 5/16/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "SHSpotDetailFooterNavigationViewController.h"

#import "SHStyleKit+Additions.h"

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
    
    //todo: change button images?
    [SHStyleKit setButton:self.btnFindSimilar withDrawing:SHStyleKitDrawingSpotIcon normalColor:SHStyleKitColorMyTextColor highlightedColor:SHStyleKitColorMyWhiteColor];
    [SHStyleKit setButton:self.btnReview withDrawing:SHStyleKitDrawingSpotIcon normalColor:SHStyleKitColorMyTextColor highlightedColor:SHStyleKitColorMyWhiteColor];
    [SHStyleKit setButton:self.btnDrinkMenu withDrawing:SHStyleKitDrawingSpotIcon normalColor:SHStyleKitColorMyTextColor highlightedColor:SHStyleKitColorMyWhiteColor];
}

#pragma mark - User Actions
#pragma mark -


- (IBAction)findSimilarButtonTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(footerNavigationViewController:findSimilarButtonTapped:)]) {
        [self.delegate footerNavigationViewController:self findSimilarButtonTapped:sender];
    }
}

- (IBAction)reviewButtonTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(footerNavigationViewController:reviewItButtonTapped:)]) {
        [self.delegate footerNavigationViewController:self reviewItButtonTapped:sender];
    }
}

- (IBAction)drinkMenuButtonTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(footerNavigationViewController:drinkMenuButtonTapped:)]) {
        [self.delegate footerNavigationViewController:self drinkMenuButtonTapped:sender];
    }
}



@end
