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

@implementation MenuModel

- (MenuItemModel *)menuItemForDrink:(DrinkModel *)drink {
    for (MenuItemModel *menuItem in self.items) {
        if ([menuItem.drink isEqual:drink]) {
            return menuItem;
        }
    }
    
    DebugLog(@"Unable to find menu item for drink: %@", drink.name);
    
    return nil;
}

- (BOOL)isBeerOnTap:(MenuItemModel *)menuItem {
    // TODO: verify this logic since an item may appear more than once on the menu as bottle or draft
    
    if ([menuItem.drink isBeer]) {
        for (MenuItemModel *aMenuItem in self.items) {
            if ([aMenuItem isEqual:menuItem]) {
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
            if ([aMenuItem isEqual:menuItem]) {
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

- (NSArray *)pricesForMenuItem:(MenuItemModel *)menuItem {
    NSArray *sorted = [menuItem.prices sortedArrayUsingComparator:^NSComparisonResult(PriceModel *obj1, PriceModel *obj2) {
        NSNumber *price1 = (obj1.cents ?: @0);
        NSNumber *price2 = (obj2.cents ?: @0);
        
        return [price1 compare:price2];
    }];
    
    NSMutableArray *prices = @[].mutableCopy;
    for (PriceModel *price in sorted) {
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
    
    if (!prices.count) {
        if ([menuItem.drink isBeer]) {
            // TODO: iterate over all menu items to find a matching drink and check if it is available on tap and bottle
            
            BOOL isBeerOnTap = FALSE;
            BOOL isBeerInBottle = FALSE;
            
            for (MenuItemModel *aMenuItem in self.items) {
                if ([menuItem.drink isEqual:aMenuItem.drink]) {
                    if ([@"Draft" isEqualToString:aMenuItem.menuType.name]) {
                        isBeerOnTap = TRUE;
                    }
                    if ([@"Cans/Bottles" isEqualToString:aMenuItem.menuType.name]) {
                        isBeerInBottle = TRUE;
                    }
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
        }
        else if ([menuItem.drink isWine]) {
            [prices addObject:@"Available on Tap"];
        }
    }
    
    //[prices addObject:@"$3 / Bottle"];
    
    return prices;
}

@end
