//
//  PriceSizeRowContainerView.m
//  SpotHopperMenuAdmin
//
//  Created by Tracee Pettigrew on 7/21/14.
//  Copyright (c) 2014 com.SpotHopper.admin. All rights reserved.
//

#import "SHMenuAdminPriceSizeRowContainerView.h"
#import "UIView+AutoLayout.h"

#define kPadding 3.0f
#define kMaxRowsShown 3

@interface SHMenuAdminPriceSizeRowContainerView()
@property (nonatomic, assign) BOOL didAddNewRow;
@property (nonatomic, assign) NSInteger indexOfRemovedRow;
@end

@implementation SHMenuAdminPriceSizeRowContainerView

- (id)init
{
    self = [super initWithFrame:CGRectMake(0, 0, kPriceSizeRowWidth, kPriceSizeRowHeight)];
    if (self) {
        _didAddNewRow = FALSE;
        self.indexOfRemovedRow = 0; // sentinal value since first row can never be removed
        
        SHMenuAdminPriceSizeRowView *row = [[SHMenuAdminPriceSizeRowView alloc]initWithFrame:CGRectMake(0, 0, kPriceSizeRowWidth, kPriceSizeRowHeight)];
        row.delegate = self;
        row.btnRemovePriceAndSize.enabled = FALSE;

        [self addSubview:row];
        self.height = 0;
    }
    
    return self;
}

#pragma mark - PriceSizeRowDelegate
#pragma mark -
- (void)addPriceAndSizeButtonTapped:(SHMenuAdminPriceSizeRowView*)row {
    if ([self.delegate respondsToSelector:@selector(addPriceAndSizeButtonTapped:)]) {
        [self addNewPriceSizeRow];
        [self.delegate addPriceAndSizeButtonTapped:self];
    }
}

- (void)removePriceAndSizeButtonTapped:(SHMenuAdminPriceSizeRowView*)row{
    if ([self.delegate respondsToSelector:@selector(removePriceAndSizeButtonTapped:indexOfRemoved:)]) {
        [self removePrizeSizeRow:row];
        
        if (self.indexOfRemovedRow != 0) {
            [self.delegate removePriceAndSizeButtonTapped:self indexOfRemoved:self.indexOfRemovedRow];
        }

    }
}

- (void)sizeLabelTapped:(SHMenuAdminPriceSizeRowView*)row {
    if ([self.delegate respondsToSelector:@selector(sizeLabelTapped:row:)]) {
        [self.delegate sizeLabelTapped:self row:row];
    }
}

//TODO: come back to when dealing with keyboard behavior
- (void)viewShouldScroll {
    if ([self.delegate respondsToSelector:@selector(viewShouldScroll)]) {
        [self.delegate viewShouldScroll];
    }
}

#pragma mark - Price/Size Add and Remove
#pragma mark -
- (SHMenuAdminPriceSizeRowView*)addNewPriceSizeRow {
    //if subviews that are PriceSizeContainers less than 5??
    //add new container to the subview
    self.didAddNewRow = TRUE;
    NSMutableArray *rows = [NSMutableArray array];
    
    //find # of rows in container already
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[SHMenuAdminPriceSizeRowView class]]) {
            [rows addObject:view];
        }
    }
    
    if (rows.count >=kMaxRowsShown) {
        self.didAddNewRow = FALSE;
        return nil;// define some failing behavior
    }
    
    SHMenuAdminPriceSizeRowView *newRow = nil;
    
    if (rows.count == 1) {
        SHMenuAdminPriceSizeRowView *first = [rows firstObject];
        newRow = [[SHMenuAdminPriceSizeRowView alloc]initWithFrame:CGRectMake(0, (first.frame.origin.y + kPriceSizeRowHeight +kPadding), kPriceSizeRowWidth, kPriceSizeRowHeight)];
    }
    else if(rows.count > 1 && rows.count < kMaxRowsShown){
        SHMenuAdminPriceSizeRowView *last = [rows lastObject];
        newRow = [[SHMenuAdminPriceSizeRowView alloc]initWithFrame:CGRectMake(0, (last.frame.origin.y + kPriceSizeRowHeight +kPadding), kPriceSizeRowWidth, kPriceSizeRowHeight)];
    }
    
    newRow.delegate = self;
    [self addSubview:newRow];
    
    //adjust height of container for row addition
    CGRect newFrameHeight = CGRectMake(0, 0, kPriceSizeRowWidth, (self.frame.size.height + kPriceSizeRowHeight +kPadding));
    self.frame = newFrameHeight;
    
    self.height = self.frame.size.height;
    
    return newRow;
}

- (BOOL)removePrizeSizeRow:(UIView*)container {
    NSInteger containerCount = 0;
    BOOL removed = TRUE;
    
    for (NSInteger i = 0; i < self.subviews.count; i++) {
        if ([self.subviews[i] isKindOfClass:[SHMenuAdminPriceSizeRowView class]]) {
            containerCount++;
        }
    }
    
    if (containerCount == 1) {
        return removed = FALSE;
        //no deletion of last price column
    }
    
    //find the index of the container to move
    //get it's y value
    //every container after that container move vertically up
    
    self.indexOfRemovedRow = [self.subviews indexOfObject:container];
    
    //start at next container
    for (NSInteger i = self.indexOfRemovedRow; i < self.subviews.count; i++) {
        SHMenuAdminPriceSizeRowView *rowToMove = self.subviews[i];
        NSInteger currentY = rowToMove.frame.origin.y;
        CGRect newLocation = CGRectMake(0, (currentY - kPriceSizeRowHeight), kPriceSizeRowWidth, kPriceSizeRowHeight);
        rowToMove.frame = newLocation;
    }
    
    [container removeFromSuperview];
    
    //adjust height of container for row removal
    CGRect newFrameHeight = CGRectMake(0, 0, kPriceSizeRowWidth, (self.frame.size.height - kPriceSizeRowHeight - kPadding));
    self.frame = newFrameHeight;
    
    self.height = self.frame.size.height;
    
    return removed;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
