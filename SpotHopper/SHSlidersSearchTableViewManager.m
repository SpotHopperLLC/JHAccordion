//
//  BaseSlidersSearchTableViewManager.m
//  SpotHopper
//
//  Created by Brennan Stehling on 5/23/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "SHSlidersSearchTableViewManager.h"

#import "SHStyleKit+Additions.h"

#pragma mark - Class Extension
#pragma mark -

@interface SHSlidersSearchTableViewManager ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet id<SHSlidersSearchTableViewDelegate> delegate;

@end

@implementation SHSlidersSearchTableViewManager

#pragma mark - UITableViewDataSource
#pragma mark -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"DemoCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    UILabel *label = (UILabel *)[cell viewWithTag:1];
    label.text = [NSString stringWithFormat:@"Row %li", (long)indexPath.row+1];
    [SHStyleKit setLabel:label textColor:SHStyleKitColorMyTextColor];
    label.font = [UIFont fontWithName:@"Lato-Bold" size:label.font.pointSize];
    
    return cell;
}

#pragma mark - UITableViewDelegate
#pragma mark -

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"selected: %li, %li", (long)indexPath.section, (long)indexPath.row);
    
    [tableView deselectRowAtIndexPath:indexPath animated:TRUE];
}

@end
