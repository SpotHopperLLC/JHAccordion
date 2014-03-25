//
//  UIView+RelativityLaws.m
//  LayoutOfRelativity
//
//  Created by Josh Holtz on 6/6/13.
//
//

#import "UIView+RelativityLaws.h"

@implementation UIView (RelativityLaws)

- (void)alignBelow:(UIView*)otherView withSpacing:(NSInteger)spacing {
    
    CGRect newViewFrame = CGRectMake(self.frame.origin.x, otherView.frame.origin.y + otherView.frame.size.height + spacing, self.frame.size.width, self.frame.size.height);
    
    [self setFrame:newViewFrame];
}

- (void)alignAbove:(UIView*)otherView withSpacing:(NSInteger)spacing {
    
    CGRect newViewFrame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, (otherView.frame.origin.y - self.frame.origin.y) - spacing);
    
    [self setFrame:newViewFrame];
}

- (void)alignToChildBottom:(UIView*)otherView withSpacing:(NSInteger)spacing {
    
    CGRect newViewFrame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, otherView.frame.origin.y + otherView.frame.size.height + spacing);

    [self setFrame:newViewFrame];
}

- (void)fitLabelHeight {
    [self fitLabelHeightWithMinHeight:0];
}

- (void)fitLabelHeightWithMinHeight:(float)minHeight {
    [self fitLabelHeightWithMinHeight:minHeight withMaxWidth:self.frame.size.width];
}

- (void)fitLabelHeightWithMinHeight:(float)minHeight withMaxWidth:(float)maxWidth {
    if ([self isKindOfClass:[UILabel class]]) {
        CGSize maximumLabelSize = CGSizeMake(maxWidth,9999);
        
        UILabel *label = (UILabel*) self;
        NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
        
        NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        [style setLineBreakMode:NSLineBreakByWordWrapping];
        
        CGSize expectedLabelSize = [label.text boundingRectWithSize:maximumLabelSize
                                                            options:NSStringDrawingUsesLineFragmentOrigin
                                                         attributes:@{
                                                                      NSFontAttributeName : label.font,
                                                                      NSParagraphStyleAttributeName : style
                                                                      }
                                                            context:context].size;
        
        NSLog(@"Expected label height - %f", expectedLabelSize.height);
        
        if (expectedLabelSize.height < minHeight) {
            expectedLabelSize.height = minHeight;
        }
        
        CGRect newViewFrame = CGRectMake(self.frame.origin.x, self.frame.origin.y, maximumLabelSize.width, expectedLabelSize.height);
        
        self.frame = newViewFrame;
    }
}

@end
