//
//  SwipeableDrinkCellTableViewCell.m
//  SpotHopperMenuAdmin
//
//  Created by Tracee Pettigrew on 6/20/14.
//  Copyright (c) 2014 com.SpotHopper.admin. All rights reserved.
//

#import "SHMenuAdminSwipeableDrinkTableViewCell.h"
#import "SHStyleKit+Additions.h"
#import "UIButton+FilterStyling.h"

static CGFloat const kBounceValue = 40.0f;

@interface SHMenuAdminSwipeableDrinkTableViewCell() <UIGestureRecognizerDelegate>

#pragma mark - Menu Button Properties
#pragma mark -
@property (weak, nonatomic) IBOutlet UIView *upperLayerContainer;

@property (weak, nonatomic) IBOutlet UIButton *btnPhoto;
@property (weak, nonatomic) IBOutlet UIButton *btnFlavorProfile;
@property (weak, nonatomic) IBOutlet UIButton *btnEdit;
@property (weak, nonatomic) IBOutlet UIButton *btnDelete;

#pragma mark - Pan Gesture Properties
#pragma mark -
@property (nonatomic, strong) UIPanGestureRecognizer *panRecognizer;
@property (nonatomic, assign) CGPoint panStartPoint;
@property (nonatomic, assign) CGFloat startingRightLayoutConstraintConstant;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *contentViewRightConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *contentViewLeftConstraint;

@end

@implementation SHMenuAdminSwipeableDrinkTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showDrinkDetails)];
    self.lblDrinkName.userInteractionEnabled = TRUE;
    [self.lblDrinkName addGestureRecognizer:tap];
    
    self.panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panThisCell:)];
    self.panRecognizer.delegate = self;
    [self.upperLayerContainer addGestureRecognizer:self.panRecognizer];
    
    [self styleCell];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self resetConstraintConstantsToZero:NO notifyDelegateDidClose:NO];
}


#pragma mark - Actions
#pragma mark -

- (IBAction)menuButtonTapped:(id)sender {
    
    if (sender == self.btnPhoto) {
        if ([self.delegate respondsToSelector:@selector(photoButtonTapped:)]) {
            [self.delegate photoButtonTapped:self];
        }
    }else if (sender == self.btnFlavorProfile) {
        if ([self.delegate respondsToSelector:@selector(flavorProfileButtonTapped:)]) {
            [self.delegate flavorProfileButtonTapped:self];
        }
    }else if (sender == self.btnEdit) {
        if ([self.delegate respondsToSelector:@selector(editButtonTapped:)]) {
            [self.delegate editButtonTapped:self];
        }
    }else if (sender == self.btnDelete) {
        if ([self.delegate respondsToSelector:@selector(deleteButtonTapped:)]) {
            [self.delegate deleteButtonTapped:self];
        }
    }
    
}

- (void)showDrinkDetails {
    if ([self.delegate respondsToSelector:@selector(drinkLabelTapped:)]) {
        [self.delegate drinkLabelTapped:self];
    }
}


#pragma mark - Enable/Disable Gestures
#pragma mark -
- (void)toggleSwipeGesture:(BOOL)enable {
    self.panRecognizer.enabled = enable;
}


#pragma mark - UIGestureRecognizerDelegate
#pragma mark -

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer*)panGestureRecognizer {
    //if the velocity of the gesture is more vertical than horizontal
        //return no
    if ([panGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        UIPanGestureRecognizer *panGesture = (UIPanGestureRecognizer*)panGestureRecognizer;
        CGPoint velocity = [panGesture velocityInView:self];
        return fabs(velocity.y) < fabs(velocity.x);
    }
    
    return FALSE;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

#pragma mark - Public
#pragma mark -
- (void)openCell {
    [self setConstraintsToShowAllButtons:NO notifyDelegateDidOpen:NO];
}

-(void)closeCell {
    [self resetConstraintConstantsToZero:YES notifyDelegateDidClose:NO];
}


#pragma mark - Private
#pragma mark -

- (void)panThisCell:(UIPanGestureRecognizer*)recognizer {

    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:{
            self.panStartPoint = [recognizer translationInView:self.upperLayerContainer];
            self.startingRightLayoutConstraintConstant = self.contentViewRightConstraint.constant;
        }
        break;
        case UIGestureRecognizerStateChanged: {
            CGPoint currentPoint = [recognizer translationInView:self.upperLayerContainer];
            CGFloat deltaX = currentPoint.x - self.panStartPoint.x;
            
            BOOL panningLeft = NO;
            if (currentPoint.x < self.panStartPoint.x) {
                panningLeft = YES;
            }
            
            if (self.startingRightLayoutConstraintConstant == 0) {
                if (!panningLeft) {
                    CGFloat constant = MAX(-deltaX, 0);
                    if (constant == 0) {
                        [self resetConstraintConstantsToZero:TRUE notifyDelegateDidClose:FALSE];
                    }else {
                        self.contentViewRightConstraint.constant = constant;
                    }
                }else {
                    CGFloat constant = MIN(-deltaX, [self buttonTotalWidth]);
                    if (constant == [self buttonTotalWidth]) {
                        [self setConstraintsToShowAllButtons:TRUE notifyDelegateDidOpen:FALSE];
                    }else {
                        self.contentViewRightConstraint.constant = constant;
                    }
                }
            }else {
                
                CGFloat adjustment = self.startingRightLayoutConstraintConstant - deltaX;
                if (!panningLeft) {
                    CGFloat constant = MAX(adjustment, 0);
                    if (constant == 0) {
                        [self resetConstraintConstantsToZero:TRUE notifyDelegateDidClose:FALSE];
                    }else {
                        self.contentViewRightConstraint.constant = constant;
                    }
                }else {
                    CGFloat constant = MIN(adjustment, [self buttonTotalWidth]);
                    if (constant == [self buttonTotalWidth]) {
                        [self setConstraintsToShowAllButtons:TRUE notifyDelegateDidOpen:FALSE];
                    }else {
                        self.contentViewRightConstraint.constant = constant;
                    }
                }
            }
            
            self.contentViewLeftConstraint.constant = -self.contentViewRightConstraint.constant;
        }
        break;
        case UIGestureRecognizerStateEnded:{
            if (self.startingRightLayoutConstraintConstant == 0) {
                CGFloat halfOfDeleteButton = CGRectGetWidth(self.btnDelete.frame) / 2;
                if (self.contentViewRightConstraint.constant >= halfOfDeleteButton) {
                    [self setConstraintsToShowAllButtons:TRUE notifyDelegateDidOpen:TRUE];
                }else {
                    [self resetConstraintConstantsToZero:TRUE notifyDelegateDidClose:TRUE];
                }
                
            }else {
                CGFloat photoButtonPlusHalfOfFlavorProfile = CGRectGetWidth(self.btnPhoto.frame) + (CGRectGetWidth(self.btnFlavorProfile.frame)/2);
                
                if (self.contentViewRightConstraint.constant >= photoButtonPlusHalfOfFlavorProfile) {
                    [self setConstraintsToShowAllButtons:TRUE notifyDelegateDidOpen:TRUE];
                }else {
                    [self resetConstraintConstantsToZero:TRUE notifyDelegateDidClose:TRUE];
                }
                
            }
        }
        break;
        case UIGestureRecognizerStateCancelled:
            if (self.startingRightLayoutConstraintConstant == 0) {
                //Cell was closed - reset everything to 0
                [self resetConstraintConstantsToZero:YES notifyDelegateDidClose:YES];
            } else {
                //Cell was open - reset to the open state
                [self setConstraintsToShowAllButtons:YES notifyDelegateDidOpen:YES];
            }
            break;
        default:
            break;
    }
    
}

- (void)updateConstraintsIfNeeded:(BOOL)animated completion:(void (^)(BOOL finished))completion {
    float duration = 0;
    if (animated) {
        duration = 0.3;
    }
    
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self layoutIfNeeded];
    }completion:^(BOOL finished) {
        if (completion) {
            completion(finished);
        }
    }];
    
}

- (void)resetConstraintConstantsToZero:(BOOL)animated notifyDelegateDidClose:(BOOL)notifyDelegate {
    if (notifyDelegate && [self.delegate respondsToSelector:@selector(cellDidClose:)]) {
        [self.delegate cellDidClose:self];
    }
    
    if (self.startingRightLayoutConstraintConstant == 0 && self.contentViewRightConstraint.constant == 0) {
        return;
    }
    
    self.contentViewRightConstraint.constant = -kBounceValue;
    self.contentViewLeftConstraint.constant = kBounceValue;
    
    [self updateConstraintsIfNeeded:animated completion:^(BOOL finished) {
//        if (finished) {
            self.contentViewRightConstraint.constant = 0;
            self.contentViewLeftConstraint.constant = 0;
            
            [self updateConstraintsIfNeeded:animated completion:^(BOOL finished) {
//                if (finished) {
                    self.startingRightLayoutConstraintConstant = self.contentViewRightConstraint.constant;
//                }
            }];
//        }
    }];
}

- (void)setConstraintsToShowAllButtons:(BOOL)animated notifyDelegateDidOpen:(BOOL)notifyDelegate {
    if (notifyDelegate && [self.delegate respondsToSelector:@selector(cellDidOpen:)]) {
        [self.delegate cellDidOpen:self];
    }
    
    if (self.startingRightLayoutConstraintConstant == [self buttonTotalWidth] && self.contentViewRightConstraint.constant == [self buttonTotalWidth]) {
        return;
    }
    
    self.contentViewLeftConstraint.constant = -[self buttonTotalWidth] - kBounceValue;
    self.contentViewRightConstraint.constant = [self buttonTotalWidth] + kBounceValue;
    
    [self updateConstraintsIfNeeded:animated completion:^(BOOL finished) {
//        if (finished) {
            self.contentViewLeftConstraint.constant = -[self buttonTotalWidth];
            self.contentViewRightConstraint.constant = [self buttonTotalWidth];
            
            [self updateConstraintsIfNeeded:animated completion:^(BOOL finished) {
//                if (finished) {
                    self.startingRightLayoutConstraintConstant = self.contentViewRightConstraint.constant;
//                }
            }];
//        }
    }];
    
}



//returns the starting position of the leftmost button (photo)
//represents the amount the upper layer has to reposition
- (CGFloat)buttonTotalWidth {
    return CGRectGetWidth(self.frame) - CGRectGetMinX(self.btnEdit.frame);
    //    return CGRectGetWidth(self.frame) - CGRectGetMinX(self.btnPhoto.frame);
}

#pragma mark - Style
#pragma mark -

- (void)styleCell {

    UIFont *regLato = [UIFont fontWithName:@"Lato-Regular" size:12.0f];
 
    self.lblDrinkName.textColor = [SHStyleKit color:SHStyleKitColorMyTintColor];
    self.lblDrinkName.font = [UIFont fontWithName:@"Lato-Regular" size:18.0f];
    
    self.lblDrinkSpecifics.font = regLato;
    self.lblBrewSpot.font = regLato;

    self.lblPrice.font = [UIFont fontWithName:@"Lato-Italic" size:12.0f];
    self.lblPrice.textColor = [SHStyleKit color:SHStyleKitColorMyTextColor];

    self.lblSlidePrompt.font = [UIFont fontWithName:@"Lato-Regular" size:10.0f];
    self.lblSlidePrompt.textColor = [SHStyleKit color:SHStyleKitColorMyTextColor];
    
    
    [self.btnPhoto styleAsEditButton:[UIImage imageNamed:@"photoIcon.png"] text:@"Photo"];
    [self.btnFlavorProfile styleAsEditButton:[UIImage imageNamed:@"flavorProfileIcon.png"] text:@"Flavor Profile"];
    [self.btnEdit styleAsEditButton:[UIImage imageNamed:@"editIcon.png"] text:@"Edit"];
    [self.btnDelete styleAsEditButton:[UIImage imageNamed:@"trashIcon.png"] text:@"Delete"];
    
}


@end
