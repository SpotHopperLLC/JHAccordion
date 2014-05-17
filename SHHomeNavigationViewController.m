//
//  SHHomeNavigationViewController.m
//  SpotHopper
//
//  Created by Brennan Stehling on 5/13/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "SHHomeNavigationViewController.h"

#import "SHStyleKit.h"
#import "SHStyleKit+Additions.h"

@interface SHHomeNavigationViewController ()

@property (weak, nonatomic) IBOutlet UILabel *lblHeader;

@property (weak, nonatomic) IBOutlet UIButton *btnSpots;
@property (weak, nonatomic) IBOutlet UIButton *btnSpecials;
@property (weak, nonatomic) IBOutlet UIButton *btnBeer;
@property (weak, nonatomic) IBOutlet UIButton *btnCocktails;
@property (weak, nonatomic) IBOutlet UIButton *btnWine;

@property (weak, nonatomic) IBOutlet UILabel *lblSpots;
@property (weak, nonatomic) IBOutlet UILabel *lblSpecials;
@property (weak, nonatomic) IBOutlet UILabel *lblBeer;
@property (weak, nonatomic) IBOutlet UILabel *lblCocktails;
@property (weak, nonatomic) IBOutlet UILabel *lblWine;

@end

@implementation SHHomeNavigationViewController

#pragma mark - View Lifecyle
#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad:@[kDidLoadOptionsNoBackground]];

    self.lblHeader.textColor = [SHStyleKit myTextColor];
    
    NSCAssert(self.btnSpots.frame.size.width > 0, @"Width must already be set");
    NSCAssert(self.btnSpots.frame.size.height > 0, @"Height must already be set");
    
    [SHStyleKit setButton:self.btnSpots withDrawing:SHStyleKitDrawingSpotIcon normalColor:SHStyleKitColorMyTintColor highlightedColor:SHStyleKitColorMyTextColor];
    [SHStyleKit setButton:self.btnSpecials withDrawing:SHStyleKitDrawingSpecialsIcon normalColor:SHStyleKitColorMyTintColor highlightedColor:SHStyleKitColorMyTextColor];
    [SHStyleKit setButton:self.btnBeer withDrawing:SHStyleKitDrawingBeerIcon normalColor:SHStyleKitColorMyTintColor highlightedColor:SHStyleKitColorMyTextColor];
    [SHStyleKit setButton:self.btnCocktails withDrawing:SHStyleKitDrawingCocktailIcon normalColor:SHStyleKitColorMyTintColor highlightedColor:SHStyleKitColorMyTextColor];
    [SHStyleKit setButton:self.btnWine withDrawing:SHStyleKitDrawingWineIcon normalColor:SHStyleKitColorMyTintColor highlightedColor:SHStyleKitColorMyTextColor];
    
    [SHStyleKit setLabel:self.lblSpots textColor:SHStyleKitColorMyTintColor];
    [SHStyleKit setLabel:self.lblSpecials textColor:SHStyleKitColorMyTintColor];
    [SHStyleKit setLabel:self.lblBeer textColor:SHStyleKitColorMyTintColor];
    [SHStyleKit setLabel:self.lblCocktails textColor:SHStyleKitColorMyTintColor];
    [SHStyleKit setLabel:self.lblWine textColor:SHStyleKitColorMyTintColor];
}

#pragma mark - User Actions
#pragma mark -

- (IBAction)spotsButtonTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(homeNavigationViewControllerDidRequestSpots:)]) {
        [self.delegate homeNavigationViewControllerDidRequestSpots:self];
    }
}

- (IBAction)specialsButtonTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(homeNavigationViewControllerDidRequestSpecials:)]) {
        [self.delegate homeNavigationViewControllerDidRequestSpecials:self];
    }
}

- (IBAction)beerButtonTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(homeNavigationViewControllerDidRequestBeers:)]) {
        [self.delegate homeNavigationViewControllerDidRequestBeers:self];
    }
}

- (IBAction)cocktailsButtonTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(homeNavigationViewControllerDidRequestCocktails:)]) {
        [self.delegate homeNavigationViewControllerDidRequestCocktails:self];
    }
}

- (IBAction)wineButtonTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(homeNavigationViewControllerDidRequestWines:)]) {
        [self.delegate homeNavigationViewControllerDidRequestWines:self];
    }
}

@end
