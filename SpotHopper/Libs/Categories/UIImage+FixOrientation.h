//
//  UIImage+FixOrientation.h
//  Mobicratic
//
//  Created by Josh Holtz on 5/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (FixOrientation)

- (UIImage*)fixOrientation;
- (NSData*)scaleToMaxSizeInKB:(NSInteger)sizeInKB;

@end
