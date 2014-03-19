//
//  ReviewCell.h
//  SpotHopper
//
//  Created by Josh Holtz on 1/15/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "SHTableViewCell.h"

#import "ReviewModel.h"

@interface ReviewCell : SHTableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblRating;

- (void)setReview:(ReviewModel*)review;

@end
