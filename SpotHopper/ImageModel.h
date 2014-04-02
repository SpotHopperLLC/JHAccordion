//
//  ImageModel.h
//  SpotHopper
//
//  Created by Josh Holtz on 3/26/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "SHJSONAPIResource.h"

@interface ImageModel : SHJSONAPIResource

@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *foursquareId;

@end
