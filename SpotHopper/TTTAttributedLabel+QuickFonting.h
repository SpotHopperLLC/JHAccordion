//
//  TTTAttributedLabel+QuickFonting.h
//  SpotHopper
//
//  Created by Josh Holtz on 3/4/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "TTTAttributedLabel.h"

@interface TTTAttributedLabel (QuickFonting)

- (void)setText:(NSString*)text withFont:(UIFont *)font onString:(NSString*)stringToFont;

@end
