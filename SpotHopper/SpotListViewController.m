//
//  SpotListViewController.m
//  SpotHopper
//
//  Created by Josh Holtz on 3/5/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "SpotListViewController.h"

#import "CardLayout.h"

#import "SpotCardCollectionViewCell.h"

@interface SpotListViewController ()<UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation SpotListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Sets title
    [self setTitle:[NSString stringWithFormat:@"Similar to %@", _spotList.name]];
    
    // Shows sidebar button in nav
    [self showSidebarButton:YES animated:YES];
    
    [self.collectionView setBackgroundColor:[UIColor clearColor]];
    [self.collectionView setCollectionViewLayout:[[CardLayout alloc] init]];
    
    [self fetchSpotList];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    
    // Adds contextual footer view
    [self addFooterViewController:^(FooterViewController *footerViewController) {
        [footerViewController showHome:YES];
        [footerViewController setRightButton:@"Info" image:[UIImage imageNamed:@"btn_context_info"]];
    }];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _spotList.spots.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    SpotModel *spot = [_spotList.spots objectAtIndex:indexPath.row];
    
    SpotCardCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SpotCardCollectionViewCell" forIndexPath:indexPath];
    [cell setSpot:spot];
    
    return cell;
}

#pragma mark - Private

- (void)fetchSpotList {
    
    [self showHUD:@"Getting spots"];
    [_spotList getSpotList:nil success:^(SpotListModel *spotListModel, JSONAPI *jsonAPi) {
        [self hideHUD];
        
        _spotList = spotListModel;
        [_collectionView reloadData];
    } failure:^(ErrorModel *errorModel) {
        [self hideHUD];
        [_collectionView reloadData];
    }];
    
}

@end
