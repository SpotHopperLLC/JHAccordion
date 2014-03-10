//
//  SpotAnnotationCallout.h
//  SpotHopper
//
//  Created by Josh Holtz on 3/10/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MatchPercentAnnotationView;

@protocol SpotAnnotationCalloutDelegate;

@interface SpotAnnotationCallout : UIView

+ (instancetype)viewFromNib;

@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblType;
@property (weak, nonatomic) IBOutlet UILabel *lblDistanceAway;

@property (nonatomic, strong) MatchPercentAnnotationView *matchPercentAnnotationView;
@property (nonatomic, assign) id<SpotAnnotationCalloutDelegate> delegate;

@end

@protocol SpotAnnotationCalloutDelegate <NSObject>

- (void)spotAnnotationCallout:(SpotAnnotationCallout*)spotAnnotationCallout clicked:(MatchPercentAnnotationView*)matchPercentAnnotationView;

@end