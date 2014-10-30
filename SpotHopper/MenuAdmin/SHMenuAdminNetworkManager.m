//
//  NetworkManager.m
//  SpotHopperMenuAdmin
//
//  Created by Tracee Pettigrew on 8/26/14.
//  Copyright (c) 2014 com.SpotHopper.admin. All rights reserved.
//

#import <Crashlytics/Crashlytics.h>

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

- (void)loginUser:(NSString*)email password:(NSString*)password success:(void(^)(UserModel* user))success failure:(void(^)(ErrorModel *error))failure{
    
    NSDictionary *params = @{
                            kUserModelParamEmail : email,
                            kUserModelParamPassword : password
                            };
    
    
    [UserModel loginUser:params success:^(UserModel *userModel, NSHTTPURLResponse *response) {
        
#ifdef NDEBUG
        [Crashlytics setUserIdentifier:userModel.ID];
        [Crashlytics setUserName:userModel.name];
#endif
        if (success) {
            success(userModel);
        }
        
    } failure:^(ErrorModel *errorModel) {
    
        if (failure) {
            failure(errorModel);
        }

    }];

}

- (void)fetchUserSpots:(UserModel*)user queryParam:(NSString*)query page:(NSNumber*)page pageSize:(NSNumber*)pageSize success:(void(^)(NSArray* spots))success failure:(void(^)(ErrorModel *error))failure{
  
    if (!page) {
        NSAssert(page, @"page number must be specified");
    }
    
    if (!pageSize) {
        NSAssert(pageSize, @"page size must be specified");
    }
    
    NSMutableDictionary *paramsSpots = @{
                                         kSpotModelParamPage : page, //@1,
                                         kSpotModelParamsPageSize : pageSize
                                         }.mutableCopy;
    
    if (query) {
        [paramsSpots setObject:query forKey:kSpotModelParamQuery];
    }
    
    
    // /api/users/:id/spots
    [[ClientSessionManager sharedClient] GET:[NSString stringWithFormat:@"api/users/%@/spots", user.ID] parameters:paramsSpots success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // Parses response with JSONAPI
        JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:responseObject];
        
        // Parses response with JSONAPI
        if (operation.response.statusCode == 200) {
            
            if (success) {
                NSArray *spots = [jsonApi resourcesForKey:@"spots"];
                success(spots);
            }

        }
        else {
            if (failure) {
                ErrorModel *error = [jsonApi resourceForKey:@"errors"];
                failure(error);
            }

        }
    }];
    
}


#pragma mark - Menu Item
#pragma mark -

- (void)createMenuItem:(MenuItemModel*)menuItem spot:(SpotModel*)spot menuType:(id)menuTypeID success:(void(^)(MenuItemModel* created))success failure:(void(^)(ErrorModel*error))failure{
    
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
        NSLog(@"adding menu item finished with status: %ld",(long)operation.response.statusCode);
        JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:responseObject];
        
        if (operation.response.statusCode == 200) {
            
            if (success) {
                MenuItemModel *created = [jsonApi resourceForKey:@"menu_items"];
                success(created);
            }
            
        }
        else {
            
            if (failure) {
                ErrorModel *error = [jsonApi resourceForKey:@"errors"];
                failure(error);
            }
        }
        
    }];

}

- (void)fetchMenuItems:(SpotModel*)spot success:(void(^)(NSArray* menuItems))success failure:(void(^)(ErrorModel* error))failure{
    if (!success || !failure) {
        return;
    }
    
    [spot fetchMenu:^(MenuModel *menu) {
        if (success) {
            success(menu.items);
        }
    } failure:^(ErrorModel *errorModel) {
        if (failure) {
            failure(errorModel);
        }
    }];
}

- (void)deleteMenuItem:(MenuItemModel*)menuItem spot:(SpotModel*)spot success:(void(^)())success failure:(void(^)(ErrorModel* error))failure{
  
    //DELETE /api/spots/:spot_id/menu_items/:id
    [[ClientSessionManager sharedClient] DELETE:[NSString stringWithFormat:@"/api/spots/%ld/menu_items/%ld", (long)[spot.ID integerValue], (long)[menuItem.ID integerValue]] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        CLS_LOG(@"%li", (long)operation.response.statusCode);
        JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:responseObject];
        
        if (operation.response.statusCode == 204) {
            if (success) {
                success();
            }
        }
        else {
            if (failure) {
                ErrorModel *error = [jsonApi resourceForKey:@"errors"];
                failure(error);
            }
        }
        
    }];
    
}

#pragma mark - Drinks
#pragma mark -
- (void)fetchDrinks:(id)drinkTypeID queryParam:(NSString*)query page:(NSNumber*)page pageSize:(NSNumber*)pageSize extraParams:(NSDictionary*)extraParams success:(void(^)(NSArray* drinks))success failure:(void(^)(ErrorModel *error))failure{
  
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
                                           kDrinkModelParamQuery : query,
                                           kDrinkModelParamPage : page,
                                           kDrinkModelParamsPageSize : pageSize,
                                           kDrinkModelParamDrinkTypeId : drinkTypeID
                                           } mutableCopy];
    
    if (query) {
        [paramsDrinks setObject:query forKey:kSpotModelParamQuery];
    }
    
    //any extra drink params that may be added to the search are found
    //in the extraParams dictionary
    if (extraParams) {
        for (id key in extraParams) {
            [paramsDrinks setObject:[extraParams valueForKey:key] forKey:key];
        }
    }
    
    [DrinkModel getDrinks:paramsDrinks success:^(NSArray *drinkModels, JSONAPI *jsonApi) {
        if (success) {
            success(drinkModels);
        }
    } failure:^(ErrorModel *errorModel) {
        if (failure) {
            failure(errorModel);
        }
    }];
    
}

#pragma mark - Prices
#pragma mark -

- (void)postPricesWithQueryString:(NSString*)query menuItem:(MenuItemModel*)menuItem success:(void(^)(NSArray* prices))success failure:(void(^)(ErrorModel *errorModel))failure{
    
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

        
        NSLog(@"%ld", (long)operation.response.statusCode);
        
        if (operation.response.statusCode == 200) {
            
            NSArray *prices = [jsonApi resourcesForKey:@"prices"];
            
//            for (JSONAPIResource *price in prices) {
//                NSLog(@"%@", price);
//            }
            
            if (success) {
                success(prices);
            }
            
        }
        else {
            if (failure) {
                ErrorModel *error = [jsonApi resourceForKey:@"errors"];
                failure(error);
            }
            
        }
    }];

    
}


- (void)createPrices:(MenuItemModel*)menuItem success:(void(^)(NSArray* prices))success failure:(void(^)(ErrorModel *errorModel))failure{
    
    [self postPricesWithQueryString:kCreatePriceQueryString menuItem:menuItem success:success failure:failure];
}

- (void)updatePrices:(MenuItemModel*)menuItem success:(void(^)(NSArray* prices))success failure:(void(^)(ErrorModel *errorModel))failure{
    
    [self postPricesWithQueryString:kUpdatePriceQueryString menuItem:menuItem success:success failure:failure];
    
}

- (void)deletePrice:(PriceModel*)price menuItem:(MenuItemModel*)menuItem success:(void(^)())success failure:(void(^)(ErrorModel* error))failure{
    
    //DELETE /api/menu_items/:menu_item_id/prices/:id
    [[ClientSessionManager sharedClient] DELETE:[NSString stringWithFormat:@"/api/menu_items/%ld/prices/%ld", (long)[menuItem.ID integerValue], (long)[price.ID integerValue]] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"deleting price finished w/ status code of %li", (long)operation.response.statusCode);
        JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:responseObject];

        if (operation.response.statusCode == 204) {
            
            if (success) {
                success();
            }
            
        }
        else {
            if (failure) {
                ErrorModel *error = [jsonApi resourceForKey:@"errors"];
                failure(error);
            }
        }
    }];
    
}

#pragma mark - Menu Sizes
#pragma mark -

- (void)fetchDrinkSizes:(SpotModel*)spot success:(void(^)(NSArray* sizes))success failure:(void(^)(ErrorModel* error))failure{
   
    [[ClientSessionManager sharedClient] GET:@"/api/sizes" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:responseObject];
        
        if (operation.response.statusCode == 200) {
            
            if (success) {
                NSArray *sizes = [jsonApi resourcesForKey:@"sizes"];
                success (sizes);
            }
            
        }
        else {
            if (failure) {
                ErrorModel *error = [jsonApi resourceForKey:@"errors"];
                failure(error);
            }
        }
    }];
    
}

#pragma mark - Menu Types
#pragma mark -

- (void)fetchMenuTypes:(SpotModel*)spot success:(void(^)(NSArray* menuTypes))success failure:(void(^)(ErrorModel* error))failure{
    
    NSString *path = [NSString stringWithFormat:@"/api/spots/%@/menu_items?page_size=0", spot ? spot.ID : @47];
    DebugLog(@"path: %@", path);
    [[ClientSessionManager sharedClient] GET:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *response = (NSDictionary*) responseObject;
        NSDictionary *form = [response objectForKey:@"form"];
        
        JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:form];
        
        DebugLog(@"status code: %li", (long)operation.response.statusCode);
        
        if (operation.response.statusCode == 200) {
            NSArray *menuTypes = [jsonApi resourcesForKey:@"menu_types"];
            
            if (success) {
                success(menuTypes);
            }
       
        }
        else {
            if (failure) {
                ErrorModel *error = [jsonApi resourceForKey:@"errors"];
                failure(error);
            }
        }
    }];
    
}

#pragma mark - Drink Types
#pragma mark -

- (void)fetchDrinkTypes:(void(^)(NSArray* drinkTypes))success failure:(void(^)(ErrorModel* error))failure{
    [[ClientSessionManager sharedClient] GET:@"/api/drinks?page_size=0" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *response = (NSDictionary*) responseObject;
        NSDictionary *form = [response objectForKey:@"form"];
        
        JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:form];
        
        if (operation.response.statusCode == 200) {
            NSArray *drinkTypes = [jsonApi resourcesForKey:@"drink_types"];
            
            if (success) {
                success(drinkTypes);
            }
           
        }
        else {
            if (failure) {
                ErrorModel *error = [jsonApi resourceForKey:@"errors"];
                failure(error);
            }
        }
    }];

}


@end
