//
//  SHButton.h
//  SpotHopper
//
//  Created by Brennan Stehling on 9/22/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SHStyleKit+Additions.h"

// Xcode 6 is not ready for custom views
//IB_DESIGNABLE
@interface SHDrawnButton : UIButton

// IBInspectable
@property (assign, nonatomic) CGSize drawingSize;

@property (assign, nonatomic) SHStyleKitDrawing drawing;

@property (assign, nonatomic) SHStyleKitColor normalColor;

@property (assign, nonatomic) SHStyleKitColor highlightedColor;

- (void)setButtonDrawing:(SHStyleKitDrawing)drawing normalColor:(SHStyleKitColor)normalColor highlightedColor:(SHStyleKitColor)highlightedColor;

- (void)setButtonDrawing:(SHStyleKitDrawing)drawing normalColor:(SHStyleKitColor)normalColor highlightedColor:(SHStyleKitColor)highlightedColor drawingSize:(CGSize)drawingSize;

@end
