//
//  UIButton+UIButton_FilterStyling.m
//  
//
//  Created by Tracee Pettigrew on 8/11/14.
//
//

#import "UIButton+FilterStyling.h"
#import "SHMenuAdminStyleSupport.h"

@implementation UIButton (FilterStyling)

- (void)styleAsFilterButtonWithTopImage:(UIImage*)image text:(NSString*)text{
    //{top, left, bottom, right}
    [self setBaseFilterButtonProperties:false image:image text:text];
    
    // the space between the image and text
    CGFloat spacing = 6.0;
    
    // lower the text and push it left so it appears centered
    //  below the image
    CGSize imageSize = self.imageView.frame.size;
    self.titleEdgeInsets = UIEdgeInsetsMake(0.0, - imageSize.width, - (imageSize.height + spacing), 0.0);
    
    // raise the image and push it right so it appears centered
    //  above the text
    CGSize titleSize = self.titleLabel.frame.size;
    self.imageEdgeInsets = UIEdgeInsetsMake(- (titleSize.height + spacing), 0.0,-8.0, - titleSize.width);
}

- (void)styleAsFilterButtonWithSideImage:(UIImage*)image text:(NSString*)text{
    //{top, left, bottom, right}
    [self setBaseFilterButtonProperties:true image:image text:text];

    // the space between the image and text
    CGFloat spacing = 8.0;

    CGSize imageSize = self.imageView.frame.size;
    self.imageEdgeInsets = UIEdgeInsetsMake(0.0, 8.0, 0.0, 10.0);
    self.titleEdgeInsets = UIEdgeInsetsMake(0.0, imageSize.width + spacing, 0.0, 8.0);
}

- (void)setBaseFilterButtonProperties:(BOOL)isSideButton image:(UIImage*)image text:(NSString*)text {
    
    CGFloat size = 12.0f;
    if (isSideButton) {
        size = 16.0f;
    }
    
    self.backgroundColor = [SHMenuAdminStyleSupport sharedInstance].LIGHT_ORANGE;
    self.titleLabel.font = [UIFont fontWithName:@"Lato-Regular" size:size];
    self.titleLabel.numberOfLines = 0;
    
    [self setTitle:text forState:UIControlStateNormal];
    [self setImage:image forState:UIControlStateNormal];
}

- (void)styleAsEditButton:(UIImage*)image text:(NSString*)text {
    [self setTitle:text forState:UIControlStateNormal];
    [self setImage:image forState:UIControlStateNormal];

    self.backgroundColor = [SHMenuAdminStyleSupport sharedInstance].GRAY;
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.font = [UIFont fontWithName:@"Lato-Bold" size:10.0];

    CGFloat spacing = 6.0;

    CGSize imageSize = self.imageView.frame.size;
    self.titleEdgeInsets = UIEdgeInsetsMake(0.0, - imageSize.width, - (imageSize.height + spacing), 0.0);
    
    CGSize titleSize = self.titleLabel.frame.size;
    self.imageEdgeInsets = UIEdgeInsetsMake(- (titleSize.height + spacing), 0.0,-8.0, - titleSize.width);
    
}

- (void)addBottomBorder{
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0.0f, (self.frame.size.height - 0.5f), self.frame.size.width, 0.5f);
    bottomBorder.backgroundColor = [UIColor whiteColor].CGColor;
    [self.layer addSublayer:bottomBorder];
}

- (void)addTopBorder{
    CALayer *topBorder = [CALayer layer];
    topBorder.frame = CGRectMake(0.0f, 0.0f, self.frame.size.width, 0.5f);
    topBorder.backgroundColor = [UIColor whiteColor].CGColor;
    [self.layer addSublayer:topBorder];
}

- (void)addLeftBorder {
    CALayer *leftBorder = [CALayer layer];
    leftBorder.frame = CGRectMake(0.0f, 0.0f, 0.5f, self.frame.size.height);
    leftBorder.backgroundColor = [UIColor whiteColor].CGColor;
    [self.layer addSublayer:leftBorder];
}

- (void)addRightBorder{
    CALayer *rightBorder = [CALayer layer];
    rightBorder.frame = CGRectMake(-1,-1, 1.0f, self.frame.size.height);
    rightBorder.backgroundColor = [UIColor whiteColor].CGColor;
    [self.layer addSublayer:rightBorder];
}

@end
