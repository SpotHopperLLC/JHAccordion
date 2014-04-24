//
//  SpotCardCollectionViewCell.m
//  SpotHopper
//
//  Created by Josh Holtz on 3/5/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "SpotCardCollectionViewCell.h"

#import "ImageModel.h"
#import "SpotTypeModel.h"

#import "NetworkHelper.h"

@implementation SpotCardCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSpot:(SpotModel *)spot {
    
    // Sets image
    ImageModel *imageModel = spot.images.firstObject;
    if (imageModel != nil) {
        [NetworkHelper loadImageProgressively:imageModel imageView:_imgSpot placeholderImage:spot.placeholderImage];
    } else {
        [_imgSpot setImage:spot.placeholderImage];
    }
    
    [_lblName setText:spot.name];
    [_lblType setText:spot.spotType.name];
    
    [_lblWhere setText:spot.cityState];
    [_lblHowFar setText:@""];
    
}

@end
