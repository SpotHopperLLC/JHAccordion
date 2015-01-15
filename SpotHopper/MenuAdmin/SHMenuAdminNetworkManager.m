//
//  NetworkManager.m
//  SpotHopperMenuAdmin
//
//  Created by Tracee Pettigrew on 8/26/14.
//  Copyright (c) 2014 com.SpotHopper.admin. All rights reserved.
//

//#import <Crashlytics/Crashlytics.h>

#import "SHMenuAdminNetworkManager.h"
#import "ClientSessionManager.h"

#import "MenuModel.h"
#import "MenuItemModel.h"
#import "PriceModel.h"
#import "SpotModel.h"
#import "UserModel.h"
#import "DrinkModel.h"
#import "SizeModel.h"


#define kParamPriceSizeID @"size_id"
#define kParamPriceCents @"cents"

#define kUpdatePriceQueryString @"/api/menu_items/%ld/prices?replace=true"
#define kCreatePriceQueryString @"/api/menu_items/%ld/prices"

@interface SHMenuAdminNetworkManager()

@end

@implementation SHMenuAdminNetworkManager

+ (SHMenuAdminNetworkManager *)sharedInstance {
    static SHMenuAdminNetworkManager *constantInstance = nil;
    
    if (constantInstance == nil){
        constantInstance = [[[self class]alloc]init];
    }
    
    return constantInstance;
}

#pragma mark - User
#pragma mark -

- (void)loginUser:(NSString *)email password:(NSString *)password success:(void(^)(UserModel *user))successBlock failure:(void(^)(ErrorModel *error))failureBlock {
    
    NSDictionary *params = @{
                            kUserModelParamEmail : email,
                            kUserModelParamPassword : password
                            };
    
    
    [UserModel loginUser:params success:^(UserModel *userModel, NSHTTPURLResponse *response) {
        
#ifdef NDEBUG
        [Crashlytics setUserIdentifier:userModel.ID];
        [Crashlytics setUserName:userModel.name];
#endif
        if (successBlock) {
            successBlock(userModel);
        }
        
    } failure:^(ErrorModel *errorModel) {
    
        if (failureBlock) {
            failureBlock(errorModel);
        }

    }];

}

- (void)fetchUserSpots:(UserModel *)user queryParam:(NSString *)query page:(NSNumber *)page pageSize:(NSNumber *)pageSize success:(void(^)(NSArray *spots))successBlock failure:(void(^)(ErrorModel *error))failureBlock {
  
    if (!page) {
        NSAssert(page, @"page number must be specified");
    }
    
    if (!pageSize) {
        NSAssert(pageSize, @"page size must be specified");
    }
    
    [UserModel fetchSpotsForUser:user query:query page:page pageSize:page success:successBlock failure:failureBlock];
    
//    NSMutableDictionary *paramsSpots = @{
//                                         kSpotModelParamPage : page, //@1,
//                                         kSpotModelParamsPageSize : pageSize
//                                         }.mutableCopy;
//    
//    if (query) {
//        [paramsSpots setObject:query forKey:kSpotModelParamQuery];
//    }
//    
//    
//    // /api/users/:id/spots
//    [[ClientSessionManager sharedClient] GET:[NSString stringWithFormat:@"api/users/%@/spots", user.ID] parameters:paramsSpots success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        
//        // Parses response with JSONAPI
//        JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:responseObject];
//        
//        // Parses response with JSONAPI
//        if (operation.response.statusCode == 200) {
//            if (successBlock) {
//                NSArray *spots = [jsonApi resourcesForKey:@"spots"];
//                successBlock(spots);
//            }
//        }
//        else {
//            if (failureBlock) {
//                ErrorModel *error = [jsonApi resourceForKey:@"errors"];
//                failureBlock(error);
//            }
//        }
//    }];
    
}

#pragma mark - Menu Item
#pragma mark -

- (void)createMenuItem:(MenuItemModel *)menuItem spot:(SpotModel *)spot menuType:(id)menuTypeID success:(void(^)(MenuItemModel *created))successBlock failure:(void(^)(ErrorModel *error))failureBlock {
    
    /**
     {
     "drink_id": "684",
     "menu_type_id": "8",
     "spot_id": "1"
     }
     */
    
    //create params and post new menu item
    NSMutableDictionary *params = @{}.mutableCopy;
    [params setObject:menuItem.drink.ID forKey:@"drink_id"];
    [params setObject:menuTypeID forKey:@"menu_type_id"];
    [params setObject:spot.ID forKey:@"spot_id"];
    
    //POST /api/spots/:spot_id/menu_items
    [[ClientSessionManager sharedClient] POST:[NSString stringWithFormat:@"/api/spots/%ld/menu_items", (long)[spot.ID integerValue]] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // Parses response with JSONAPI
        JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:responseObject];
        
        if (operation.response.statusCode == 200) {
            
            if (successBlock) {
                MenuItemModel *created = [jsonApi resourceForKey:@"menu_items"];
                successBlock(created);
            }
            
        }
        else {
            
            if (failureBlock) {
                ErrorModel *error = [jsonApi resourceForKey:@"errors"];
                failureBlock(error);
            }
        }
    }];
}

- (void)fetchMenuItems:(SpotModel *)spot success:(void(^)(NSArray *menuItems))successBlock failure:(void(^)(ErrorModel *error))failureBlock {
    if (!successBlock || !failureBlock) {
        return;
    }
    
    [spot fetchMenu:^(MenuModel *menu) {
        if (successBlock) {
            successBlock(menu.items);
        }
    } failure:^(ErrorModel *errorModel) {
        if (failureBlock) {
            failureBlock(errorModel);
        }
    }];
}

- (void)deleteMenuItem:(MenuItemModel *)menuItem spot:(SpotModel *)spot success:(void(^)())successBlock failure:(void(^)(ErrorModel *error))failureBlock {
    //DELETE /api/spots/:spot_id/menu_items/:id
    [[ClientSessionManager sharedClient] DELETE:[NSString stringWithFormat:@"/api/spots/%ld/menu_items/%ld", (long)[spot.ID integerValue], (long)[menuItem.ID integerValue]] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:responseObject];
        
        if (operation.response.statusCode == 204) {
            if (successBlock) {
                successBlock();
            }
        }
        else {
            if (failureBlock) {
                ErrorModel *error = [jsonApi resourceForKey:@"errors"];
                failureBlock(error);
            }
        }
    }];
}

#pragma mark - Drinks
#pragma mark -

- (void)fetchDrinks:(id)drinkTypeID queryParam:(NSString *)query page:(NSNumber *)page pageSize:(NSNumber *)pageSize extraParams:(NSDictionary *)extraParams success:(void(^)(NSArray *drinks))successBlock failure:(void(^)(ErrorModel *error))failureBlock {
  
    if (!drinkTypeID) {
        NSAssert(drinkTypeID, @"drink type ID must be specified");
    }
    
    if (!page) {
        NSAssert(page, @"page number must be specified");
    }
    
    if (!pageSize) {
        NSAssert(pageSize, @"page size must be specified");
    }
    
    NSMutableDictionary *paramsDrinks = [@{
                                           kDrinkModelParamPage : page,
                                           kDrinkModelParamsPageSize : pageSize,
                                           kDrinkModelParamDrinkTypeId : drinkTypeID
                                           } mutableCopy];
    
    if (query) {
        [paramsDrinks setObject:query forKey:kDrinkModelParamQuery];
    }
    
    //any extra drink params that may be added to the search are found
    //in the extraParams dictionary
    if (extraParams) {
        for (id key in extraParams) {
            [paramsDrinks setObject:[extraParams valueForKey:key] forKey:key];
        }
    }
    
    [DrinkModel getDrinks:paramsDrinks success:^(NSArray *drinkModels, JSONAPI *jsonApi) {
        if (successBlock) {
            successBlock(drinkModels);
        }
    } failure:^(ErrorModel *errorModel) {
        if (failureBlock) {
            failureBlock(errorModel);
        }
    }];
}

#pragma mark - Prices
#pragma mark -

- (void)postPricesWithQueryString:(NSString *)query menuItem:(MenuItemModel *)menuItem success:(void(^)(NSArray *prices))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    NSMutableArray *priceParams = [NSMutableArray array];
    NSMutableDictionary *indivParms = nil;
    
    for (PriceModel *price in menuItem.prices) {
        indivParms = [NSMutableDictionary dictionary];
        
        if (price.cents) {
            [indivParms setObject:price.cents forKey:kParamPriceCents];
        }
        
        if (price.size.ID) {
            [indivParms setObject:price.size.ID forKey:kParamPriceSizeID];
        }
        
        [priceParams addObject:indivParms];
    }
    
    [params setObject:priceParams forKey:@"prices"];
    
    //POST /api/menu_items/:menu_item_id/prices
    [[ClientSessionManager sharedClient] POST:[NSString stringWithFormat:query, (long)[menuItem.ID integerValue]] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // Parses response with JSONAPI
        NSDictionary *response = (NSDictionary*) responseObject;
        JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:response];

        if (operation.response.statusCode == 200) {
            NSArray *prices = [jsonApi resourcesForKey:@"prices"];
            
            if (successBlock) {
                successBlock(prices);
            }
        }
        else {
            if (failureBlock) {
                ErrorModel *error = [jsonApi resourceForKey:@"errors"];
                failureBlock(error);
            }
        }
    }];
}

- (void)createPrices:(MenuItemModel *)menuItem success:(void(^)(NSArray *prices))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock {
    [self postPricesWithQueryString:kCreatePriceQueryString menuItem:menuItem success:successBlock failure:failureBlock];
}

- (void)updatePrices:(MenuItemModel *)menuItem success:(void(^)(NSArray *prices))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock {
    [self postPricesWithQueryString:kUpdatePriceQueryString menuItem:menuItem success:successBlock failure:failureBlock];
}

- (void)deletePrice:(PriceModel *)price menuItem:(MenuItemModel *)menuItem success:(void(^)())successBlock failure:(void(^)(ErrorModel *error))failureBlock {
    //DELETE /api/menu_items/:menu_item_id/prices/:id
    [[ClientSessionManager sharedClient] DELETE:[NSString stringWithFormat:@"/api/menu_items/%ld/prices/%ld", (long)[menuItem.ID integerValue], (long)[price.ID integerValue]] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:responseObject];

        if (operation.response.statusCode == 204) {
            if (successBlock) {
                successBlock();
            }
        }
        else {
            if (failureBlock) {
                ErrorModel *error = [jsonApi resourceForKey:@"errors"];
                failureBlock(error);
            }
        }
    }];
}

#pragma mark - Menu Sizes
#pragma mark -

- (void)fetchDrinkSizes:(SpotModel *)spot success:(void(^)(NSArray *sizes))successBlock failure:(void(^)(ErrorModel *error))failureBlock {
    [[ClientSessionManager sharedClient] GET:@"/api/sizes" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:responseObject];
        
        if (operation.response.statusCode == 200) {
            if (successBlock) {
                NSArray *sizes = [jsonApi resourcesForKey:@"sizes"];
                successBlock(sizes);
            }
        }
        else {
            if (failureBlock) {
                ErrorModel *error = [jsonApi resourceForKey:@"errors"];
                failureBlock(error);
            }
        }
    }];
}

#pragma mark - Menu Types
#pragma mark -

- (void)fetchMenuTypes:(SpotModel *)spot success:(void(^)(NSArray *menuTypes))successBlock failure:(void(^)(ErrorModel *error))failureBlock {
    NSString *path = [NSString stringWithFormat:@"/api/spots/%@/menu_items?page_size=0", spot ? spot.ID : @47];
    [[ClientSessionManager sharedClient] GET:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *response = (NSDictionary*) responseObject;
        NSDictionary *form = [response objectForKey:@"form"];
        
        JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:form];
        
        if (operation.response.statusCode == 200) {
            NSArray *menuTypes = [jsonApi resourcesForKey:@"menu_types"];
            
            if (successBlock) {
                successBlock(menuTypes);
            }
       
        }
        else {
            if (failureBlock) {
                ErrorModel *error = [jsonApi resourceForKey:@"errors"];
                failureBlock(error);
            }
        }
    }];
}

#pragma mark - Drink Types
#pragma mark -

- (void)fetchDrinkTypes:(void(^)(NSArray *drinkTypes))successBlock failure:(void(^)(ErrorModel *error))failureBlock {
    [[ClientSessionManager sharedClient] GET:@"/api/drinks?page_size=0" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *response = (NSDictionary*) responseObject;
        NSDictionary *form = [response objectForKey:@"form"];
        
        JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:form];
        
        if (operation.response.statusCode == 200) {
            NSArray *drinkTypes = [jsonApi resourcesForKey:@"drink_types"];
            
            if (successBlock) {
                successBlock(drinkTypes);
            }
           
        }
        else {
            if (failureBlock) {
                ErrorModel *error = [jsonApi resourceForKey:@"errors"];
                failureBlock(error);
            }
        }
    }];
}

@end
