//
//  NetworkManager.h
//  SpotHopperMenuAdmin
//
//  Created by Tracee Pettigrew on 8/26/14.
//  Copyright (c) 2014 com.SpotHopper.admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SpotModel;
@class UserModel;
@class MenuItemModel;
@class ErrorModel;
@class PriceModel;

@interface SHMenuAdminNetworkManager : NSObject

+ (SHMenuAdminNetworkManager*)sharedInstance;

//user based network calls
- (void)loginUser:(NSString*)email password:(NSString*)password success:(void(^)(UserModel *user))success failure:(void(^)(ErrorModel *error))failure;

- (void)fetchUserSpots:(UserModel*)user queryParam:(NSString*)query page:(NSNumber*)page pageSize:(NSNumber*)pageSize success:(void(^)(NSArray* spots))success failure:(void(^)(ErrorModel *error))failure;

//menu item based network calls
- (void)createMenuItem:(MenuItemModel*)menuItem spot:(SpotModel*)spot menuType:(id)menuTypeID success:(void(^)(MenuItemModel* created))success failure:(void(^)(ErrorModel*error))failure;

- (void)fetchMenuItems:(SpotModel*)spot success:(void(^)(NSArray* menuItems))success failure:(void(^)(ErrorModel* error))failure;

- (void)deleteMenuItem:(MenuItemModel*)menuItem spot:(SpotModel*)spot success:(void(^)())success failure:(void(^)(ErrorModel* error))failure;

//price based network calls
- (void)createPrices:(MenuItemModel*)menuItem success:(void(^)(NSArray* prices))success failure:(void(^)(ErrorModel *errorModel))failure;

- (void)updatePrices:(MenuItemModel*)menuItem success:(void(^)(NSArray* prices))success failure:(void(^)(ErrorModel *errorModel))failure;

- (void)deletePrice:(PriceModel*)price menuItem:(MenuItemModel*)menuItem success:(void(^)())success failure:(void(^)(ErrorModel* error))failure;

//drinks
- (void)fetchDrinks:(id)drinkTypeID queryParam:(NSString*)query page:(NSNumber*)page pageSize:(NSNumber*)pageSize extraParams:(NSDictionary*)extraParams success:(void(^)(NSArray* drinks))success failure:(void(^)(ErrorModel *error))failure;


//misc.
- (void)fetchDrinkSizes:(SpotModel*)spot success:(void(^)(NSArray* sizes))success failure:(void(^)(ErrorModel *error))failure;

- (void)fetchMenuTypes:(SpotModel*)spot success:(void(^)(NSArray* menuTypes))success failure:(void(^)(ErrorModel* error))failure;

- (void)fetchDrinkTypes:(void(^)(NSArray* drinkTypes))success failure:(void(^)(ErrorModel* error))failure;

@end
