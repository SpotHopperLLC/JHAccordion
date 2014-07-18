//
//  MenuModel.h
//  SpotHopper
//
//  Created by Brennan Stehling on 6/23/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SpotModel.h"
#import "DrinkModel.h"
#import "MenuItemModel.h"

@interface MenuModel : NSObject

@property (strong, nonatomic) SpotModel *spot;
@property (strong, nonatomic) NSArray *items;
@property (strong, nonatomic) NSDictionary *types;

- (MenuItemModel *)menuItemForDrink:(DrinkModel *)drink;

- (BOOL)isBeerOnTap:(MenuItemModel *)menuItem;

- (BOOL)isBeerInBottle:(MenuItemModel *)menuItem;

- (BOOL)isCocktail:(MenuItemModel *)menuItem;

- (BOOL)isWine:(MenuItemModel *)menuItem;

- (NSArray *)pricesForMenuItem:(MenuItemModel *)menuItem;

@end
