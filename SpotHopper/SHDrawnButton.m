//
//  SHButton.m
//  SpotHopper
//
//  Created by Brennan Stehling on 9/22/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "SHDrawnButton.h"

@implementation SHDrawnButton

//- (void)awakeFromNib {
//    [super awakeFromNib];
//}

//- (void)drawRect:(CGRect)rect {
//}

- (void)drawButtonImage {
    self.contentMode = UIViewContentModeCenter;
    self.backgroundColor = [UIColor clearColor];
    
    if (SHStyleKitDrawingNone != _drawing && SHStyleKitColorNone != _normalColor && SHStyleKitColorNone != _highlightedColor) {
        [SHStyleKit setButton:self withDrawing:_drawing normalColor:_normalColor highlightedColor:_highlightedColor size:CGSizeEqualToSize(_drawingSize, CGSizeZero) ? self.frame.size : _drawingSize];
    }
}

- (void)setButtonDrawing:(SHStyleKitDrawing)drawing normalColor:(SHStyleKitColor)normalColor highlightedColor:(SHStyleKitColor)highlightedColor {
    [self setButtonDrawing:drawing normalColor:normalColor highlightedColor:highlightedColor drawingSize:CGSizeZero];
}

- (void)setButtonDrawing:(SHStyleKitDrawing)drawing normalColor:(SHStyleKitColor)normalColor highlightedColor:(SHStyleKitColor)highlightedColor drawingSize:(CGSize)drawingSize {
    
    _drawing = drawing;
    _normalColor = normalColor;
    _highlightedColor = highlightedColor;
    _drawingSize = drawingSize;
    
    [self drawButtonImage];
}

#if !TARGET_INTERFACE_BUILDER

//- (void)setDrawing:(SHStyleKitDrawing)drawing {
//    _drawing = drawing;
//    [self setNeedsDisplay];
//}
//
//- (void)setDrawingSize:(CGSize)drawingSize {
//    _drawingSize = drawingSize;
//    [self setNeedsDisplay];
//}
//
//- (void)setNormalColor:(SHStyleKitColor)normalColor {
//    _normalColor = normalColor;
//    [self prepareView];
//}
//
//- (void)setHighlightedColor:(SHStyleKitColor)highlightedColor {
//    _highlightedColor = highlightedColor;
//    [self prepareView];
//}

#endif

@end
