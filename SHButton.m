//
//  SHButton.m
//  SpotHopper
//
//  Created by Brennan Stehling on 9/22/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "SHButton.h"

@implementation SHButton

- (void)awakeFromNib {
    [super awakeFromNib];
    [self prepareView];
}

- (void)drawRect:(CGRect)rect {
    [self prepareView];
}

- (void)prepareView {
    self.contentMode = UIViewContentModeCenter;
    self.backgroundColor = [UIColor clearColor];
    
#if TARGET_INTERFACE_BUILDER
    _drawing = SHStyleKitDrawingBottleIcon;
    _normalColor = SHStyleKitColorMyTintColor;
    _highlightedColor = SHStyleKitColorMyTextColor;
#endif
    
    [SHStyleKit setButton:self withDrawing:_drawing normalColor:_normalColor highlightedColor:_highlightedColor size:CGSizeEqualToSize(_drawingSize, CGSizeZero) ? self.frame.size : _drawingSize];
}

#if !TARGET_INTERFACE_BUILDER

- (void)setDrawing:(SHStyleKitDrawing)drawing {
    _drawing = drawing;
    [self setNeedsDisplay];
}

- (void)setDrawingSize:(CGSize)drawingSize {
    _drawingSize = drawingSize;
    [self setNeedsDisplay];
}

- (void)setNormalColor:(SHStyleKitColor)normalColor {
    _normalColor = normalColor;
    [self setNeedsDisplay];
}

- (void)setHighlightedColor:(SHStyleKitColor)highlightedColor {
    _highlightedColor = highlightedColor;
    [self setNeedsDisplay];
}

#endif

@end
