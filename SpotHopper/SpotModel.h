//
//  SpotModel.h
//  SpotHopper
//
//  Created by Josh Holtz on 1/7/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

//{
//    "id": 1,
//    "name": "Oatmeal Junction",
//    "type": "Restaurant",
//    "address": "229 E Wisconsin Ave\nSuite #1102\nMilwaukee, WI 53202",
//    "phone_number": "715-539-8911",
//    "hours_of_operation":[
//                          ["8:30-0500","16:00-0500"],
//                          ["8:00-0500","20:00-0500"],
//                          ["8:00-0500","20:00-0500"],
//                          ["8:00-0500","20:00-0500"],
//                          ["8:00-0500","20:00-0500"],
//                          ["8:00-0500","20:00-0500"],
//                          ["8:30-0500","18:00-0500"]
//                          ],
//    "latitude": "43.038513",
//    "longitude": "-87.908913",
//    "sliders":[{
//        {"id": "radness", "name": "Radness", "min": "UnRad", "max": "Super Rad!", "value": 10}
//    }]
//}

#import "SHJSONAPIResource.h"

@interface SpotModel : SHJSONAPIResource

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *phoneNumber;
@property (nonatomic, strong) NSArray *hoursOfOperation;
@property (nonatomic, strong) NSNumber *latitude;
@property (nonatomic, strong) NSNumber *longitude;
@property (nonatomic, strong) NSDictionary *sliders;

@end
