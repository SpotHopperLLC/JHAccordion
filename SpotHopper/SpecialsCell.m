//
//  SpecialsCell.m
//  SpotHopper
//
//  Created by Josh Holtz on 3/26/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "SpecialsCell.h"

#import "ImageModel.h"

#import <AFNetworking/UIImageView+AFNetworking.h>

@implementation SpecialsCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSpot:(SpotModel *)spot {
    
    ImageModel *image = spot.images.firstObject;
    if (image != nil) {
        [_imgSpotCover setImageWithURL:[NSURL URLWithString:image.url] placeholderImage:spot.placeholderImage];
    } else {
        [_imgSpotCover setImage:spot.placeholderImage];
    }
    
    [_lblSpotName setText:spot.name];
    
}

- (IBAction)onClickShare:(id)sender {
    if ([_delegate respondsToSelector:@selector(specialsCellClickedShare:)]) {
        [_delegate specialsCellClickedShare:self];
    }

}

@end
