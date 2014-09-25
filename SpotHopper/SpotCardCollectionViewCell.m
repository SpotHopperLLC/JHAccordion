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

#import "ImageUtil.h"

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
    if (spot.images.count) {
        ImageModel *imageModel = spot.images[0];
        [ImageUtil loadImage:imageModel placeholderImage:spot.placeholderImage withThumbImageBlock:^(UIImage *thumbImage) {
            self.imgSpot.image = thumbImage;
        } withFullImageBlock:^(UIImage *fullImage) {
            self.imgSpot.image = fullImage;
        } withErrorBlock:^(NSError *error) {
            [self.imgSpot setImage:spot.placeholderImage];
        }];
    } else {
        [self.imgSpot setImage:spot.placeholderImage];
    }
    
    [_lblName setText:spot.name];
    [_lblType setText:spot.spotType.name];
    
    [_lblWhere setText:spot.cityState];
    [_lblHowFar setText:@""];
}

@end
