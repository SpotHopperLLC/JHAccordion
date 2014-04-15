//
//  JHPullRefreshViewController.m
//  JHTableViewPullRefresh
//
//  Created by Josh Holtz on 5/16/12.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "JHPullRefreshViewController.h"

#import "RefreshView.h"

@interface JHPullRefreshViewController ()

@property (nonatomic, assign) NSInteger refreshType;

@property (nonatomic, strong) RefreshView *refreshViewDown;
@property (nonatomic, strong) RefreshView *refreshViewUp;
@property (nonatomic, assign) BOOL refreshing;

@property (nonatomic, strong) UITableView *refreshTableView;

@end

@implementation JHPullRefreshViewController

@synthesize refreshType = _refreshType;

@synthesize refreshViewDown = _refreshViewDown;
@synthesize refreshViewUp = _refreshViewUp;
@synthesize refreshing = _refreshing;

@synthesize refreshTableView = _refreshTableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO;
}

#pragma mark - Scroll view delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    if (_refreshTableView == scrollView) {
        
        if (scrollView.isDragging) {
            
            if (_refreshType == kPullRefreshTypeDown || _refreshType == kPullRefreshTypeBoth) {
                
                float y = scrollView.contentOffset.y;
                
                if (y > -65.0f && y < 0.0f && !_refreshing) {
                    [_refreshViewDown setStatus:kRefreshViewPullDown];
                } else if (y < -65.0f && !_refreshing) {
                    [_refreshViewDown setStatus:kRefreshViewRefreshing];
                }
            }
            
            if (_refreshType == kPullRefreshTypeUp || _refreshType == kPullRefreshTypeBoth) {
                
                CGPoint offset = scrollView.contentOffset;
                CGRect bounds = scrollView.bounds;
                CGSize size = scrollView.contentSize;
                UIEdgeInsets inset = scrollView.contentInset;
                float y = offset.y + bounds.size.height - inset.bottom;
                float h = size.height;
                
                if (y > (65.0f + h) && !_refreshing) {
                    [_refreshViewUp setStatus:kRefreshViewRefreshing];
                } else if (y <= h && !_refreshing) {
                    [_refreshViewUp setStatus:kRefreshViewPullUp];
                }
            }
            
        }
        
    }
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    if (_refreshTableView == scrollView) {
        
        if (_refreshType == kPullRefreshTypeDown || _refreshType == kPullRefreshTypeBoth) {
            
            float y = scrollView.contentOffset.y;
            
            if (y < -65.0f && !_refreshing) {
                
                _refreshing = YES;
                
                [UIView beginAnimations:nil context:NULL];
                [UIView setAnimationDuration:0.2];
                _refreshTableView.contentInset = UIEdgeInsetsMake(60.0f, 0.0f, 0.0f, 0.0f);
                [UIView commitAnimations];
                
                [self reloadTableViewDataPullDown];
            }
        }
        
        if (_refreshType == kPullRefreshTypeUp || _refreshType == kPullRefreshTypeBoth) {
            
            CGPoint offset = scrollView.contentOffset;
            CGRect bounds = scrollView.bounds;
            CGSize size = scrollView.contentSize;
            UIEdgeInsets inset = scrollView.contentInset;
            float y = offset.y + bounds.size.height - inset.bottom;
            float h = size.height;
            
            if (_refreshTableView.contentSize.height < _refreshTableView.frame.size.height) {
                h = _refreshTableView.frame.size.height;
            }
            
            if (y > (65.0f + h) && !_refreshing) {
                
                _refreshing = YES;
                
                [UIView beginAnimations:nil context:NULL];
                [UIView setAnimationDuration:0.2];
                _refreshTableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 60.0f, 0.0f);
                [UIView commitAnimations];
                
                [self reloadTableViewDataPullUp];
            }
        }
        
    }
}

- (void)dataDidFinishRefreshing {
    [self dataDidFinishRefreshing:YES];
}

- (void)dataDidFinishRefreshing:(BOOL)reloadTable {
    
    if (_refreshTableView) {
        
        _refreshing = NO;
        
        [UIView animateWithDuration:0.3f animations:^{
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:.3];
            [_refreshTableView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
            [UIView commitAnimations];
        } completion:^(BOOL finished) {
            if (reloadTable == YES) {
                [_refreshTableView reloadData];
            }
            
            [_refreshViewUp removeFromSuperview];
            if (_refreshTableView.contentSize.height < _refreshTableView.frame.size.height) {
                _refreshViewUp.frame = CGRectMake(0, _refreshTableView.frame.size.height, _refreshTableView.frame.size.width, 60);
            } else {
                _refreshViewUp.frame = CGRectMake(0, _refreshTableView.contentSize.height, _refreshTableView.frame.size.width, 60);
            }
            
            [_refreshTableView addSubview:_refreshViewUp];
        }];
        
    }
    
}

#pragma mark - JHPullRefresh methods

- (void)registerRefreshTableView:(UITableView*)tableView withReloadType:(NSInteger)refreshType {
    _refreshType = refreshType;
    _refreshTableView = tableView;
    
    if (refreshType == kPullRefreshTypeDown || refreshType == kPullRefreshTypeBoth) {
        NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:@"RefreshView"
                                                          owner:self
                                                        options:nil];
        _refreshViewDown = [ nibViews objectAtIndex: 0];
        _refreshViewDown.frame = CGRectMake(0, -60, _refreshTableView.frame.size.width, 60);
        
        [_refreshTableView addSubview:_refreshViewDown];
    }
    if (refreshType == kPullRefreshTypeUp || refreshType == kPullRefreshTypeBoth) {
        NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:@"RefreshView"
                                                          owner:self
                                                        options:nil];
        _refreshViewUp = [ nibViews objectAtIndex: 0];
        _refreshViewUp.frame = CGRectMake(0, _refreshTableView.frame.size.height, _refreshTableView.frame.size.width, 60);
        
    }
}

- (void)unregisterRefreshTableView {
    _refreshType = -1;
    _refreshTableView = nil;

    [_refreshViewDown removeFromSuperview];
    [_refreshViewUp removeFromSuperview];
}

#pragma mark - JHPullRefresh methods for override

- (void)reloadTableViewDataPullUp {
    NSLog(@"Please override up");
}

- (void)reloadTableViewDataPullDown {
    NSLog(@"Please override down");
}

@end