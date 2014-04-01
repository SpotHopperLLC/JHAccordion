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
#import "NSDate+Util.h"

#define kNumberOfCells      4

@interface TutorialViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (weak, nonatomic) IBOutlet UIButton *btnStep1;
@property (weak, nonatomic) IBOutlet UIButton *btnStep2;
@property (weak, nonatomic) IBOutlet UIButton *btnStep3;
@property (weak, nonatomic) IBOutlet UIButton *btnStep4;

@property (weak, nonatomic) IBOutlet UIView *viewAgeVerification;
@property (weak, nonatomic) IBOutlet UIDatePicker *ageVerificationDatePicker;

@property (strong, nonatomic) NSArray *buttons;
@property (strong, nonatomic) NSDate *minumumAgeRequirement;

@end

@implementation TutorialViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSArray *buttons = @[_btnStep1, _btnStep2, _btnStep3, _btnStep4];
    for (UIButton *button in buttons) {
        [button addTarget:self action:@selector(onStep:) forControlEvents:UIControlEventTouchUpInside];
        [button setBackgroundImage:[self dotFilledImage] forState:UIControlStateNormal];
        [button setBackgroundImage:[self dotOutlinedImage] forState:UIControlStateSelected];
        button.selected = button.tag == 1;
    }
    
    NSCAssert(_viewAgeVerification, @"Outlet is required");
    NSDate *manyYearsAgo = [[NSDate date] addMonths:12*120*-1];
    NSDate *just18YearsAgo = [[NSDate date] addMonths:12*18*-1];
    
    _viewAgeVerification.hidden = TRUE;
    _ageVerificationDatePicker.maximumDate = [NSDate date];
    _ageVerificationDatePicker.minimumDate = manyYearsAgo;
    _ageVerificationDatePicker.date = just18YearsAgo;
    
    self.minumumAgeRequirement = just18YearsAgo;
    
    self.buttons = buttons;
}

#pragma mark - UICollectionViewDelegate

// nothing to implement for this delegate

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return kNumberOfCells;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *cellName = [NSString stringWithFormat:@"WelcomeCell%li", indexPath.item + 1];
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
            
            UIButton *btnContinue = (UIButton *)[cell viewWithTag:4];
            [btnContinue addTarget:self action:@selector(onContinue:) forControlEvents:UIControlEventTouchUpInside];
            
            btnContinue.alpha = 0.0;

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

- (IBAction)onContinue:(UIButton *)button {
    [self showAgeVerification:TRUE];
}

- (IBAction)onCancelAgeVerification:(UIButton *)button {
    [self hideAgeVerification:TRUE];
}

- (IBAction)onEnterAgeVerification:(UIButton *)button {
    // verify the age is over 18 to procede or alert the user they cannot continue
    
    NSDate* now = [NSDate date];
    NSDateComponents* ageComponents = [[NSCalendar currentCalendar] components:NSYearCalendarUnit
                                                                      fromDate:_ageVerificationDatePicker.date
                                                                        toDate:now
                                                                       options:0];
    NSInteger age = [ageComponents year];
    
    if (age >= 18) {
        [self hideAgeVerification:FALSE];
        
        // go immediately to the launch screen after age verification
        UIViewController *presentingVC = self.presentingViewController;
        [self dismissViewControllerAnimated:NO completion:^{
            [presentingVC goToLaunch:NO];
        }];
    }
    else {
        [self showAlert:@"Age Verification" message:@"You must be 18 or older to use this app."];
    }
}

#pragma mark - Private

- (void)selectCell:(NSUInteger)item {
    
//    btnContinue.alpha
    for (UIButton *button in _buttons) {
        button.selected = button.tag == (item+1);
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        // for the last cell fade in the continue button to get the user's attention
        if (item == kNumberOfCells - 1) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:3 inSection:0];
            UICollectionViewCell *cell = [_collectionView cellForItemAtIndexPath:indexPath];
            UIView *view = [cell viewWithTag:4];
            UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction;
            [UIView animateWithDuration:0.5 delay:0.0 options:options animations:^{
                view.alpha = 1.0;
            } completion:^(BOOL finished) {
            }];
        }
    });
}

- (void)changeLabelToLatoLight:(UIView *)view {
    [self changeLabelToLatoLight:view withBoldText:nil];
}

- (void)changeLabelToLatoLight:(UIView *)view withBoldText:(NSString *)boldText {
    if (view && [view isKindOfClass:[TTTAttributedLabel class]]) {
        TTTAttributedLabel *label = (TTTAttributedLabel *)view;
        [label setFont:[UIFont fontWithName:@"Lato-Light" size:label.font.pointSize]];
        
        // change label height to fit text
        CGRect frame = label.frame;
        frame.size.height = [self heightForString:label.text font:label.font maxWidth:CGRectGetWidth(label.frame)];
        label.frame = frame;
        
        if (boldText.length) {
            [label setText:label.text withFont:[UIFont fontWithName:@"Lato-Bold" size:label.font.pointSize] onString:boldText];
        }
    }
}

- (void)showAgeVerification:(BOOL)animated {
    _viewAgeVerification.alpha = 0.0f;
    _viewAgeVerification.hidden = FALSE;

    CGFloat duration = animated ? 0.5f : 0.0f;
    UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction;
    [UIView animateWithDuration:duration delay:0.0 options:options animations:^{
        _viewAgeVerification.alpha = 1.0f;
    } completion:^(BOOL finished) {
    }];
}

- (void)hideAgeVerification:(BOOL)animated {
    CGFloat duration = animated ? 0.5f : 0.0f;
    UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction;
    [UIView animateWithDuration:duration delay:0.0 options:options animations:^{
        _viewAgeVerification.alpha = 0.0f;
    } completion:^(BOOL finished) {
        _viewAgeVerification.hidden = TRUE;
    }];
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
