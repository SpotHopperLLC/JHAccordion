//
//  SHMapFooterNavigationViewController.m
//  SpotHopper
//
//  Created by Brennan Stehling on 5/16/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "SHMapFooterNavigationViewController.h"

#import "SHStyleKit+Additions.h"

@interface SHMapFooterNavigationViewController ()

@property (weak, nonatomic) IBOutlet UIButton *btnSpots;
@property (weak, nonatomic) IBOutlet UIButton *btnSpecials;
@property (weak, nonatomic) IBOutlet UIButton *btnBeer;
@property (weak, nonatomic) IBOutlet UIButton *btnCocktail;
@property (weak, nonatomic) IBOutlet UIButton *btnWine;

@end

@implementation SHMapFooterNavigationViewController

#pragma mark - View Lifecyle
#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad:@[kDidLoadOptionsNoBackground]];
    
    [SHStyleKit setButton:self.btnSpots withDrawing:SHStyleKitDrawingSpotIcon normalColor:SHStyleKitColorMyTextColor highlightedColor:SHStyleKitColorMyWhiteColor];
    [SHStyleKit setButton:self.btnSpecials withDrawing:SHStyleKitDrawingSpecialsIcon normalColor:SHStyleKitColorMyTextColor highlightedColor:SHStyleKitColorMyWhiteColor];
    [SHStyleKit setButton:self.btnBeer withDrawing:SHStyleKitDrawingBeerIcon normalColor:SHStyleKitColorMyTextColor highlightedColor:SHStyleKitColorMyWhiteColor];
    [SHStyleKit setButton:self.btnCocktail withDrawing:SHStyleKitDrawingCocktailIcon normalColor:SHStyleKitColorMyTextColor highlightedColor:SHStyleKitColorMyWhiteColor];
    [SHStyleKit setButton:self.btnWine withDrawing:SHStyleKitDrawingWineIcon normalColor:SHStyleKitColorMyTextColor highlightedColor:SHStyleKitColorMyWhiteColor];
}

#pragma mark - User Actions
#pragma mark -

- (IBAction)spotsButtonTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(footerNavigationViewController:spotsButtonTapped:)]) {
        [self.delegate footerNavigationViewController:self spotsButtonTapped:sender];
    }
}

- (IBAction)specialsButtonTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(footerNavigationViewController:specialsButtonTapped:)]) {
        [self.delegate footerNavigationViewController:self specialsButtonTapped:sender];
    }
}

- (IBAction)beerButtonTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(footerNavigationViewController:beersButtonTapped:)]) {
        [self.delegate footerNavigationViewController:self beersButtonTapped:sender];
    }
}

- (IBAction)cocktailsButtonTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(footerNavigationViewController:cocktailsButtonTapped:)]) {
        [self.delegate footerNavigationViewController:self cocktailsButtonTapped:sender];
    }
}

- (IBAction)wineButtonTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(footerNavigationViewController:winesButtonTapped:)]) {
        [self.delegate footerNavigationViewController:self winesButtonTapped:sender];
    }
}

@end