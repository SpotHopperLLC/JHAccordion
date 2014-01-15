//
//  ReviewCell.h
//  SpotHopper
//
//  Created by Josh Holtz on 1/15/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ReviewModel.h"

@interface ReviewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblRating;

- (void)setReview:(ReviewModel*)review;

@end
