//
//  NetworkManager.h
//  SpotHopperMenuAdmin
//
//  Created by Tracee Pettigrew on 8/26/14.
//  Copyright (c) 2014 com.SpotHopper.admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SpotModel, UserModel, MenuItemModel, ErrorModel, PriceModel;

@interface SHMenuAdminNetworkManager : NSObject

+ (SHMenuAdminNetworkManager *)sharedInstance;

//user based network calls
- (void)loginUser:(NSString *)email password:(NSString *)password success:(void(^)(UserModel *user))successBlock failure:(void(^)(ErrorModel *error))failureBlock;

- (void)fetchUserSpots:(UserModel *)user queryParam:(NSString *)query page:(NSNumber*)page pageSize:(NSNumber*)pageSize success:(void(^)(NSArray *spots))successBlock failure:(void(^)(ErrorModel *error))failureBlock __deprecated;

//menu item based network calls
- (void)createMenuItem:(MenuItemModel *)menuItem spot:(SpotModel*)spot menuType:(id)menuTypeID success:(void(^)(MenuItemModel *created))successBlock failure:(void(^)(ErrorModel *error))failureBlock __deprecated;

- (void)fetchMenuItems:(SpotModel *)spot success:(void(^)(NSArray *menuItems))successBlock failure:(void(^)(ErrorModel *error))failureBlock;

- (void)deleteMenuItem:(MenuItemModel *)menuItem spot:(SpotModel *)spot success:(void(^)())successBlock failure:(void(^)(ErrorModel *error))failureBlock __deprecated;

//price based network calls
- (void)createPrices:(MenuItemModel *)menuItem success:(void(^)(NSArray *prices))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock;

- (void)updatePrices:(MenuItemModel *)menuItem success:(void(^)(NSArray *prices))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock;

- (void)deletePrice:(PriceModel *)price menuItem:(MenuItemModel *)menuItem success:(void(^)())successBlock failure:(void(^)(ErrorModel *error))failureBlock;

//drinks
- (void)fetchDrinks:(id)drinkTypeID queryParam:(NSString *)query page:(NSNumber *)page pageSize:(NSNumber *)pageSize extraParams:(NSDictionary *)extraParams success:(void(^)(NSArray *drinks))successBlock failure:(void(^)(ErrorModel *error))failureBlock __deprecated;

//misc.
- (void)fetchDrinkSizes:(SpotModel *)spot success:(void(^)(NSArray *sizes))successBlock failure:(void(^)(ErrorModel *error))failureBlock;

- (void)fetchMenuTypes:(SpotModel *)spot success:(void(^)(NSArray *menuTypes))successBlock failure:(void(^)(ErrorModel *error))failureBlock;

- (void)fetchDrinkTypes:(void(^)(NSArray *drinkTypes))successBlock failure:(void(^)(ErrorModel *error))failureBlock;

@end
