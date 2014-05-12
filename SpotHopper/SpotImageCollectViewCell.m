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

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setImage:(ImageModel *)imageModel withPlaceholder:(UIImage*)placeholderImage {
    [_btnFoursquare setHidden:( imageModel.foursquareId.length == 0 )];
    
    if (imageModel == nil) {
        [_imgSpot setImage:placeholderImage];
    } else {
        [NetworkHelper loadImage:imageModel placeholderImage:placeholderImage withThumbImageBlock:^(UIImage *thumbImage) {
            _imgSpot.image = thumbImage;
        } withFullImageBlock:^(UIImage *fullImage) {
            _imgSpot.image = fullImage;
        } withErrorBlock:^(NSError *error) {
            // do nothing
        }];
    }
}

@end
