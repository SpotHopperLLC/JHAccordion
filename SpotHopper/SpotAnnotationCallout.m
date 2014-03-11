//
//  SpotAnnotationCallout.m
//  SpotHopper
//
//  Created by Josh Holtz on 3/10/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "SpotAnnotationCallout.h"

#import "SpotModel.h"
#import "SpotTypeModel.h"

@interface SpotAnnotationCallout()

@property (nonatomic, strong) UITapGestureRecognizer *tgr;

@end

@implementation SpotAnnotationCallout

+ (instancetype)viewFromNib
{
    NSArray *xib = [[NSBundle mainBundle] loadNibNamed:@"SpotAnnotationCalloutView" owner:self options:nil];
    SpotAnnotationCallout *view = [xib objectAtIndex:0];
    [view setup];
    
    return view;
}

- (void)setup {
    [self setUserInteractionEnabled:YES];
    
    _tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickCallout:)];
    [self addGestureRecognizer:_tgr];
}

#pragma mark - Actions

- (IBAction)onClickCallout:(id)sender {
    if ([_delegate respondsToSelector:@selector(spotAnnotationCallout:clicked:)]) {
        [_delegate spotAnnotationCallout:self clicked:_matchPercentAnnotationView];
    }
}

@end
