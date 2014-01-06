//
//  UIButton+Block.m
//  BoothTag
//
//  Created by Josh Holtz on 4/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIButton+Block.h"

#import <objc/runtime.h>

@implementation UIButton (Block)

static char overviewKey;
static char returnButtonKey;
static char objectKey;

@dynamic actions;

- (void) setActionWithBlock:(void(^)())block {
    
    if ([self actions] == nil) {
        [self setActions:[[NSMutableDictionary alloc] init]];
    }
    
    [[self actions] setObject:[block copy] forKey:kUIButtonBlockTouchUpInside];
    [self addTarget:self action:@selector(doTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setActions:(NSMutableDictionary*)actions {
    objc_setAssociatedObject (self, &overviewKey,actions,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableDictionary*)actions {
    return objc_getAssociatedObject(self, &overviewKey);
}

- (void)setReturnButton:(BOOL)returnButton {
    objc_setAssociatedObject (self, &returnButtonKey,(returnButton ? @"Return" : nil),OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)returnButton {
    return (objc_getAssociatedObject(self, &returnButtonKey) != nil);
}

- (void)setObject:(id)object {
    objc_setAssociatedObject (self, &objectKey,object,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)object {
    return objc_getAssociatedObject(self, &objectKey);
}

- (void)doTouchUpInside:(id)sender {
    if ([self returnButton]) {
        void(^block)(id button);
        block = [[self actions] objectForKey:kUIButtonBlockTouchUpInside];
        block(self);
    } else {
        void(^block)();
        block = [[self actions] objectForKey:kUIButtonBlockTouchUpInside];
        block();
    }
}


@end
