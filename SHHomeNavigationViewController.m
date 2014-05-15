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
    
    CGSize iconSize = CGSizeMake(50.0f, 50.0f);
    
    UIImage *spotIcon = [SHStyleKit spotIconWithColor:SHStyleKitColorMyTintColor size:iconSize];
    UIImage *specialsIcon = [SHStyleKit specialsIconWithColor:SHStyleKitColorMyTintColor size:iconSize];
    UIImage *beerIcon = [SHStyleKit beerIconWithColor:SHStyleKitColorMyTintColor size:iconSize];
    UIImage *cocktailsIcon = [SHStyleKit cocktailIconWithColor:SHStyleKitColorMyTintColor size:iconSize];
    UIImage *wineIcon = [SHStyleKit wineIconWithColor:SHStyleKitColorMyTintColor size:iconSize];
    
    [self.btnSpots setImage:spotIcon forState:UIControlStateNormal];
    [self.btnSpecials setImage:specialsIcon forState:UIControlStateNormal];
    [self.btnBeer setImage:beerIcon forState:UIControlStateNormal];
    [self.btnCocktails setImage:cocktailsIcon forState:UIControlStateNormal];
    [self.btnWine setImage:wineIcon forState:UIControlStateNormal];
    
    self.lblSpots.textColor = [SHStyleKit myTintColor];
    self.lblSpecials.textColor = [SHStyleKit myTintColor];
    self.lblBeer.textColor = [SHStyleKit myTintColor];
    self.lblCocktails.textColor = [SHStyleKit myTintColor];
    self.lblWine.textColor = [SHStyleKit myTintColor];
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
