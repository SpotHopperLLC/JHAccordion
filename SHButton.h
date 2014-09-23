//
//  SHButton.h
//  SpotHopper
//
//  Created by Brennan Stehling on 9/22/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SHStyleKit+Additions.h"

IB_DESIGNABLE
@interface SHButton : UIButton

@property (assign, nonatomic) IBInspectable CGSize drawingSize;

@property (assign, nonatomic) SHStyleKitDrawing drawing;

@property (assign, nonatomic) SHStyleKitColor normalColor;

@property (assign, nonatomic) SHStyleKitColor highlightedColor;

@end
