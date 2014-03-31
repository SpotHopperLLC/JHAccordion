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

#import <AFNetworking/UIImageView+AFNetworking.h>

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
    ImageModel *image = spot.images.firstObject;
    if (image != nil) {
        [_imgSpot setImageWithURL:[NSURL URLWithString:image.url] placeholderImage:spot.placeholderImage];
    } else {
        [_imgSpot setImage:spot.placeholderImage];
    }
    
    [_lblName setText:spot.name];
    [_lblType setText:spot.spotType.name];
    
    [_lblWhere setText:spot.cityState];
    [_lblHowFar setText:@""];
    
}

@end
