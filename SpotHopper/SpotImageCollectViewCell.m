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

- (void)setImage:(ImageModel *)image withPlaceholder:(UIImage*)placeholderImage {
    [_btnFoursquare setHidden:( image.foursquareId.length == 0 )];
    
    if (image == nil) {
        [_imgSpot setImage:placeholderImage];
    } else {
        [NetworkHelper loadImageProgressively:image imageView:_imgSpot placeholderImage:placeholderImage];
    }
}

@end
