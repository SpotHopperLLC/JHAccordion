//
//  SpotImageCollectViewCell.m
//  SpotHopper
//
//  Created by Josh Holtz on 2/20/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "SpotImageCollectViewCell.h"

#import "ImageModel.h"

#import "NetworkHelper.h"

@implementation SpotImageCollectViewCell

- (void)setImage:(ImageModel *)imageModel withPlaceholder:(UIImage*)placeholderImage {
    [self.btnFoursquare setHidden:(!imageModel.foursquareId.length)];
    
    if (imageModel == nil) {
        [self.imgSpot setImage:placeholderImage];
    }
    else {
        [NetworkHelper loadImage:imageModel placeholderImage:placeholderImage withThumbImageBlock:^(UIImage *thumbImage) {
            self.imgSpot.image = thumbImage;
        } withFullImageBlock:^(UIImage *fullImage) {
            self.imgSpot.image = fullImage;
        } withErrorBlock:^(NSError *error) {
            // do nothing
        }];
    }
}

@end
