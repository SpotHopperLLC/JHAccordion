//
//  SpotCardCollectionViewCell.m
//  SpotHopper
//
//  Created by Josh Holtz on 3/5/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "SpotCardCollectionViewCell.h"

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
    
    [_imgSpot setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:spot.imageUrl]] placeholderImage:Nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        [_imgSpot setImage:image];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        [_imgSpot setImage:nil];
    }];
    
    [_lblName setText:spot.name];
    [_lblType setText:spot.spotType.name];
    
    [_lblWhere setText:spot.cityState];
    [_lblHowFar setText:@""];
    
}

@end
