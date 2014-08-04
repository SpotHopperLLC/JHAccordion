//
//  MenuModel.m
//  SpotHopper
//
//  Created by Brennan Stehling on 6/23/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "MenuModel.h"

#import "DrinkModel.h"
#import "DrinkTypeModel.h"
#import "MenuTypeModel.h"
#import "PriceModel.h"

#import "Tracker.h"

@implementation MenuModel

- (NSArray *)menuItemsForDrink:(DrinkModel *)drink {
    NSMutableArray *menuItems = @[].mutableCopy;
    
    for (MenuItemModel *menuItem in self.items) {
        if ([menuItem.drink isEqual:drink]) {
            [menuItems addObject:menuItem];
        }
    }
    
    return menuItems;
}

- (MenuItemModel *)menuItemForDrink:(DrinkModel *)drink {
    for (MenuItemModel *menuItem in self.items) {
        if ([menuItem.drink isEqual:drink]) {
            return menuItem;
        }
    }

    NSDictionary *properties = @{@"Drink Name" : drink.name.length ? drink.name : @"Unknown",
                                 @"Spot Name" : self.spot.name.length ? self.spot.name : @"Unknown",
                                 @"Drink ID" : drink.ID ? drink.ID : [NSNull null],
                                 @"Spot ID" : self.spot.ID ? self.spot.ID : [NSNull null]};
    DebugLog(@"Unable to find menu item for drink: %@", properties);
    [Tracker track:@"Missing Menu Item" properties:properties];
    
    return nil;
}

- (BOOL)isBeerOnTap:(MenuItemModel *)menuItem {
    // TODO: verify this logic since an item may appear more than once on the menu as bottle or draft
    
    if ([menuItem.drink isBeer]) {
        for (MenuItemModel *aMenuItem in self.items) {
            if ([aMenuItem.drink isEqual:menuItem.drink]) {
                if ([@"Draft" isEqualToString:aMenuItem.menuType.name]) {
                    return TRUE;
                }
            }
        }
    }
    
    return FALSE;
}

- (BOOL)isBeerInBottle:(MenuItemModel *)menuItem {
    // TODO: verify this logic since an item may appear more than once on the menu as bottle or draft
    
    if ([menuItem.drink isBeer]) {
        for (MenuItemModel *aMenuItem in self.items) {
            if ([aMenuItem.drink isEqual:menuItem.drink]) {
                if ([@"Cans/Bottles" isEqualToString:aMenuItem.menuType.name]) {
                    return TRUE;
                }
            }
        }
    }
    
    return FALSE;
}

- (BOOL)isCocktail:(MenuItemModel *)menuItem {
    return [menuItem.drink isCocktail];
}

- (BOOL)isWine:(MenuItemModel *)menuItem {
    return [menuItem.drink isWine];
}

- (NSArray *)pricesForDrink:(DrinkModel *)drink {
    NSMutableArray *prices = @[].mutableCopy;

    NSArray *menuItems = [self menuItemsForDrink:drink];
    for (MenuItemModel *menuItem in menuItems) {
        for (PriceModel *price in menuItem.prices) {
            NSString *priceAndSize = [price priceAndSize];
            
            NSAssert(menuItem.menuType.name.length, @"Menu Type and Name is required");
            
            if (priceAndSize.length) {
                if ([menuItem.drink isBeer]) {
                    BOOL isOnTap = [@"Draft" isEqualToString:menuItem.menuType.name];
                    NSString *fullName = [NSString stringWithFormat:@"%@ (%@)", priceAndSize, isOnTap ? @"Tap" : @"Bottle"];
                    [prices addObject:fullName];
                }
                else {
                    [prices addObject:priceAndSize];
                }
            }
            else if ([menuItem.drink isCocktail] || [menuItem.drink isWine]) {
                [prices addObject:@"Available"];
            }
        }
    }
    
    if (!prices.count) {
        BOOL isBeerOnTap = FALSE;
        BOOL isBeerInBottle = FALSE;
        BOOL isAvailable = FALSE;
        for (MenuItemModel *menuItem in menuItems) {
            if ([menuItem.drink isBeer]) {
                isBeerOnTap = [self isBeerOnTap:menuItem];
                isBeerInBottle = [self isBeerInBottle:menuItem];
            }
            else if ([menuItem.drink isCocktail] || [menuItem.drink isWine]) {
                isAvailable = TRUE;
            }
        }
        
        if (isBeerOnTap && isBeerInBottle) {
            [prices addObject:@"Available on Tap"];
            [prices addObject:@"Available by the bottle"];
        }
        else if (isBeerOnTap && !isBeerInBottle) {
            [prices addObject:@"Available on Tap"];
        }
        else if (isBeerInBottle && !isBeerOnTap) {
            [prices addObject:@"Available by the bottle"];
        }
        else if (isAvailable) {
            [prices addObject:@"Available"];
        }
    }
    
    //[prices addObject:@"$3 / Bottle"];
    
    return prices;
}

@end
