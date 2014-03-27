//
//  SpecialsCell.m
//  SpotHopper
//
//  Created by Josh Holtz on 3/26/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "SpecialsCell.h"

#import "NSArray+DailySpecials.h"
#import "UIView+RelativityLaws.h"

#import "ImageModel.h"
#import "LiveSpecialModel.h"

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
    
    // Reset label height (to align with image bottom) - need to do this when we shrink label
    CGRect frameSpecial = _lblSpecial.frame;
    CGFloat maxHeight = CGRectGetMaxY(_imgSpotCover.frame) - CGRectGetMinY(frameSpecial);
    frameSpecial.size.height = maxHeight;
    [_lblSpecial setFrame:frameSpecial];
    
    // Sets name
    LiveSpecialModel *liveSpecial = [spot currentLiveSpecial];
    if (liveSpecial != nil) {
        [_lblSpotName setText:[NSString stringWithFormat:@"LIVE - %@", spot.name]];
    } else {
        [_lblSpotName setText:spot.name];
    }
    
    // Sets special
    if (liveSpecial != nil) {
        [_lblSpecial setText:[liveSpecial text]];
    } else {
        [_lblSpecial setText:[spot.dailySpecials specialsForToday]];
    }
    
    // Shrinking label so it aligns top
    [_lblSpecial fitLabelHeight];
    
    // Setting label to max height incase special is super duper long
    if (CGRectGetHeight(_lblSpecial.frame) > maxHeight) {
        frameSpecial.size.height = maxHeight;
        [_lblSpecial setFrame:frameSpecial];
    }
    
}

- (IBAction)onClickShare:(id)sender {
    if ([_delegate respondsToSelector:@selector(specialsCellClickedShare:)]) {
        [_delegate specialsCellClickedShare:self];
    }

}

@end
