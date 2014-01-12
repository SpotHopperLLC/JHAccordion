//
//  DrinkModel.h
//  SpotHopper
//
//  Created by Josh Holtz on 1/7/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

//{
//    "id": 1,
//    "name": "Boobs and Billiards Scotch",
//    "type": "spirit",
//    "subtype": "scotch",
//    "description": "Super premium breasts and pool balls scotch which reeks of upper crust.",
//    "alcohol_by_volume": 0.9,
//    "style": "IPA",
//    "vintage": 1984,
//    "region": "Your mom's butt",
//    "recipe": "1 part boobs\n1part billiards"
//    "spot_id": 1
//}

#import "SHJSONAPIResource.h"

@class SpotModel;

@interface DrinkModel : SHJSONAPIResource

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *subtype;
@property (nonatomic, strong) NSString *descriptionOfDrink;
@property (nonatomic, strong) NSNumber *alcoholByVolume;
@property (nonatomic, strong) NSString *style;
@property (nonatomic, strong) NSNumber *vintage;
@property (nonatomic, strong) NSString *region;
@property (nonatomic, strong) NSString *recipe;
@property (nonatomic, strong) SpotModel *spot;
@property (nonatomic, strong) NSNumber *spotId;

@end
