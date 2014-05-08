//
//  SpotImageCollectViewCell.h
//  SpotHopper
//
//  Created by Josh Holtz on 2/20/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ImageModel;

@interface SpotImageCollectViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imgSpot;
@property (weak, nonatomic) IBOutlet UIButton *btnFoursquare;

- (void)setImage:(ImageModel *)imageModel withPlaceholder:(UIImage*)placeholderImage;

@end
