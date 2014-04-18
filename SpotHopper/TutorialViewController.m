//
//  TutorialViewController.m
//  SpotHopper
//
//  Created by Brennan Stehling on 3/28/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "TutorialViewController.h"

#import "UIViewController+Navigator.h"
#import "TTTAttributedLabel+QuickFonting.h"

#import "ClientSessionManager.h"

#define kNumberOfCells      5

@interface TutorialViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (weak, nonatomic) IBOutlet UIButton *btnStep1;
@property (weak, nonatomic) IBOutlet UIButton *btnStep2;
@property (weak, nonatomic) IBOutlet UIButton *btnStep3;
@property (weak, nonatomic) IBOutlet UIButton *btnStep4;
@property (weak, nonatomic) IBOutlet UIButton *btnStep5;

@property (strong, nonatomic) NSArray *buttons;

@end

@implementation TutorialViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSArray *buttons = @[_btnStep1, _btnStep2, _btnStep3, _btnStep4, _btnStep5];
    for (UIButton *button in buttons) {
        [button addTarget:self action:@selector(onStep:) forControlEvents:UIControlEventTouchUpInside];
        [button setBackgroundImage:[self dotFilledImage] forState:UIControlStateNormal];
        [button setBackgroundImage:[self dotOutlinedImage] forState:UIControlStateSelected];
        button.selected = button.tag == 1;
    }
    
    self.buttons = buttons;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[ClientSessionManager sharedClient] setHasSeenWelcome:TRUE];
}

#pragma mark - Tracking

- (NSString *)screenName {
    return @"Tutorial";
}

#pragma mark - UICollectionViewDelegate

// nothing to implement for this delegate

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return kNumberOfCells;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *cellName = [NSString stringWithFormat:@"WelcomeCell%li", (long)indexPath.item + 1];
    UICollectionViewCell *cell = (UICollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellName forIndexPath:indexPath];
    
    switch (indexPath.item) {
        case 0: {
            [self changeLabelToLatoLight:[cell viewWithTag:2]];
            [self changeLabelToLatoLight:[cell viewWithTag:3]];
            
            break;
        }
        case 1: {
            [self changeLabelToLatoLight:[cell viewWithTag:2]];
            [self changeLabelToLatoLight:[cell viewWithTag:3] withBoldText:@"you"];
            
            break;
        }
        case 2: {
            [self changeLabelToLatoLight:[cell viewWithTag:2]];
            [self changeLabelToLatoLight:[cell viewWithTag:3]];

            break;
        }
        case 3: {
            [self changeLabelToLatoLight:[cell viewWithTag:2]];
            [self changeLabelToLatoLight:[cell viewWithTag:3]];
            
            break;
        }
            
        default:
            // do nothing
            break;
    }
    
    return  cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.view.frame.size;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    static NSInteger previousPage = 0;
    CGFloat pageWidth = CGRectGetWidth(scrollView.frame);
    float fractionalPage = scrollView.contentOffset.x / pageWidth;
    NSInteger page = lround(fractionalPage);
    if (previousPage != page) {
        // Page has changed
        // Do your thing!
        previousPage = page;
    }
    
    [self selectCell:page];
}

#pragma mark - Action

- (IBAction)onStep:(UIButton *)button {
    [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:(button.tag - 1) inSection:0]
                                               atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                                       animated:TRUE];
    [self selectCell:(button.tag-1)];
}

#pragma mark - Private

- (void)selectCell:(NSUInteger)item {
    for (UIButton *button in _buttons) {
        button.selected = button.tag == (item+1);
    }
    
    if (item == kNumberOfCells - 1) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.25 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self dismissViewControllerAnimated:TRUE completion:^{
                // do nothing
            }];
        });
    }
}

#pragma mark - Images

- (UIImage *)dotFilledImage {
    static UIImage *image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(20, 20), NO, 0.0f);
        
        UIBezierPath* dotPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(1.5, 1.5, 16, 16)];
        [[UIColor whiteColor] setFill];
        [dotPath fill];
        
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
    });
    return image;
}

- (UIImage *)dotOutlinedImage {
    static UIImage *image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(20, 20), NO, 0.0f);
        
        UIBezierPath* dotPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(1.5, 1.5, 16, 16)];
        [[UIColor whiteColor] setStroke];
        dotPath.lineWidth = 1;
        [dotPath stroke];
        
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
    });
    return image;
}

@end
