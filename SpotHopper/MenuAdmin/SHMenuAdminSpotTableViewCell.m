//
//  SpotTableViewCell.m
//  SpotHopperMenuAdmin
//
//  Created by Tracee Pettigrew on 7/23/14.
//  Copyright (c) 2014 com.SpotHopper.admin. All rights reserved.
//

#import "SHMenuAdminSpotTableViewCell.h"
#import "SpotTypeModel.h"
#import "SHMenuAdminStyleSupport.h"
#import "ImageUtil.h"
#import "Haneke.h"

@implementation SHMenuAdminSpotTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
    [self styleCell];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setSpot:(SpotModel *)spot {
    NSDictionary *underlineAttribute = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
    self.lblSpotName.attributedText = [[NSAttributedString alloc] initWithString:spot.name
                                                                      attributes:underlineAttribute];
    self.lblSpotType.text = spot.spotType.name;
    self.lblSpotAddress.text = spot.addressCityState;
    
    if (spot.images.count) {
        ImageModel *image = spot.images[0];
        [self.imgIcon hnk_setImageFromURL:[NSURL URLWithString:image.thumbUrl]];
    }
    else {
        self.imgIcon.image = [UIImage imageNamed:@"placeholderSpot.png"];
    }
}

- (void)styleCell {
    self.lblSpotName.textColor = [SHMenuAdminStyleSupport sharedInstance].ORANGE;
    self.lblSpotName.font = [UIFont fontWithName:@"Lato-Bold" size:18.0f];
    
    self.lblSpotType.font = [UIFont fontWithName:@"Lato-Regular" size:14.0f];
    self.lblSpotAddress.font = [UIFont fontWithName:@"Lato-Italic" size:14.0f];
}

@end
