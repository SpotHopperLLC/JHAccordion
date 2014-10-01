//
//  SHCheckinViewController.m
//  SpotHopper
//
//  Created by Brennan Stehling on 10/1/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "SHCheckinViewController.h"

#import "SHStyleKit+Additions.h"

@interface SHCheckinViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (nonatomic, weak) IBOutlet UITableView *tableView;

@end

@implementation SHCheckinViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    DebugLog(@"%@", NSStringFromSelector(_cmd));
    
    self.headerView.backgroundColor = [SHStyleKit color:SHStyleKitColorMyTintTransparentColor];
    
    [self.cancelButton setTitleColor:[SHStyleKit color:SHStyleKitColorMyWhiteColor] forState:UIControlStateNormal];
    
}

- (NSArray *)viewOptions {
    return @[kDidLoadOptionsNoBackground];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.tableView flashScrollIndicators];
}

#pragma mark - User Actions
#pragma mark -

- (IBAction)cancelButtonTapped:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(checkInViewControllerCancelButtonTapped:)]) {
        [self.delegate checkInViewControllerCancelButtonTapped:self];
    }
}

#pragma mark - UITableViewDataSource
#pragma mark -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"SpotCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    UIView *selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    selectedBackgroundView.backgroundColor = [SHStyleKit color:SHStyleKitColorMyTintTransparentColor];
    cell.selectedBackgroundView = selectedBackgroundView;
    
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:1];
    
    imageView.image = [UIImage imageNamed:@"spot_placeholder"];
    
    return cell;
}

#pragma mark - UITableViewDelegate
#pragma mark -

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DebugLog(@"%@", NSStringFromSelector(_cmd));
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [tableView deselectRowAtIndexPath:indexPath animated:TRUE];
    });
}

@end
