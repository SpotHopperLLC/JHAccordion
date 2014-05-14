//
//  SHHomeNavigationViewController.m
//  SpotHopper
//
//  Created by Brennan Stehling on 5/13/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "SHHomeNavigationViewController.h"

#import "SHStyleKit.h"

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

    self.lblHeader.textColor = [SHStyleKit mainTextColor];
    
    CGSize iconSize = CGSizeMake(50.0f, 50.0f);
    
    UIImage *spotIcon = [self resizeImage:[SHStyleKit imageOfSpotIcon] toMaximumSize:iconSize];
    UIImage *specialsIcon = [self resizeImage:[SHStyleKit imageOfSpecialsIcon] toMaximumSize:iconSize];
    UIImage *beerIcon = [self resizeImage:[SHStyleKit imageOfBeerIcon] toMaximumSize:iconSize];
    UIImage *cocktailsIcon = [self resizeImage:[SHStyleKit imageOfCocktailIcon] toMaximumSize:iconSize];
    UIImage *wineIcon = [self resizeImage:[SHStyleKit imageOfWineIcon] toMaximumSize:iconSize];
    
    self.btnSpots.tintColor = [SHStyleKit mainColor];
    self.btnSpecials.tintColor = [SHStyleKit mainColor];
    self.btnBeer.tintColor = [SHStyleKit mainColor];
    self.btnCocktails.tintColor = [SHStyleKit mainColor];
    self.btnWine.tintColor = [SHStyleKit mainColor];
    
    [self.btnSpots setImage:spotIcon forState:UIControlStateNormal];
    [self.btnSpecials setImage:specialsIcon forState:UIControlStateNormal];
    [self.btnBeer setImage:beerIcon forState:UIControlStateNormal];
    [self.btnCocktails setImage:cocktailsIcon forState:UIControlStateNormal];
    [self.btnWine setImage:wineIcon forState:UIControlStateNormal];
    
    self.lblSpots.textColor = [SHStyleKit mainColor];
    self.lblSpecials.textColor = [SHStyleKit mainColor];
    self.lblBeer.textColor = [SHStyleKit mainColor];
    self.lblCocktails.textColor = [SHStyleKit mainColor];
    self.lblWine.textColor = [SHStyleKit mainColor];
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
