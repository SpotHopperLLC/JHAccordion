
//
//  PriceSizeContainerView.m
//  SpotHopperMenuAdmin
//
//  Created by Tracee Pettigrew on 7/10/14.
//  Copyright (c) 2014 com.SpotHopper.admin. All rights reserved.
//

#import "SHMenuAdminPriceSizeRowView.h"
#import "UIView+AutoLayout.h"
#import "SHMenuAdminStyleSupport.h"

@interface SHMenuAdminPriceSizeRowView() <UITextFieldDelegate>

@end

@implementation SHMenuAdminPriceSizeRowView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        // Initialization code
        self.txtfldPrice = [[UITextField alloc]initWithFrame:CGRectMake(0, 0, 80, 30)];
        self.txtfldPrice.borderStyle = UITextBorderStyleRoundedRect;
        self.txtfldPrice.placeholder = @"$0.00";
        self.txtfldPrice.keyboardType = UIKeyboardTypeDecimalPad;
        self.txtfldPrice.delegate = self;
        
        self.lblSize = [[UILabel alloc]initWithFrame:CGRectMake(88, 0, 67, 30)];
        self.lblSize.userInteractionEnabled = TRUE;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showSizePicker)];
        [self.lblSize addGestureRecognizer:tap];
        self.lblSize.text = @"per size ";
        self.lblSize.font = [UIFont systemFontOfSize:12.0f]; //todo: remove during styling
        
        self.btnRemovePriceAndSize = [[UIButton alloc]initWithFrame:CGRectMake(166, 0, 30, 30)];
        [self.btnRemovePriceAndSize addTarget:self action:@selector(removePriceAndSizeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.btnRemovePriceAndSize setTitle:@"-" forState:UIControlStateNormal];
        [self.btnRemovePriceAndSize setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        [self.btnRemovePriceAndSize setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];

        self.btnAddPriceAndSize = [[UIButton alloc]initWithFrame:CGRectMake(196, 0, 30, 30)];
        [self.btnAddPriceAndSize addTarget:self action:@selector(addPriceAndSizeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.btnAddPriceAndSize setTitle:@"+" forState:UIControlStateNormal];
        [self.btnAddPriceAndSize setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        [self.btnAddPriceAndSize setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];

       
        [self addSubview:self.txtfldPrice];
        [self addSubview:self.lblSize];
        [self addSubview:self.btnAddPriceAndSize];
        [self addSubview:self.btnRemovePriceAndSize];
    
        [self styleRow];
    }
    return self;
}


#pragma mark - User Actions
#pragma mark -

- (void)sizeLabelTapped:(SHMenuAdminPriceSizeRowView*)container {
    if ([self.delegate respondsToSelector:@selector(sizeLabelTapped:)]) {
        [self.delegate sizeLabelTapped:self];
    }
}

- (void)addPriceAndSizeButtonTapped:(SHMenuAdminPriceSizeRowView*)container {
    if ([self.delegate respondsToSelector:@selector(addPriceAndSizeButtonTapped:)]) {
        [self.delegate addPriceAndSizeButtonTapped:self];
    }
}
- (void)removePriceAndSizeButtonTapped:(SHMenuAdminPriceSizeRowView*)container {
    if ([self.delegate respondsToSelector:@selector(removePriceAndSizeButtonTapped:)]) {
        [self.delegate removePriceAndSizeButtonTapped:self];
    }
}

- (void)showSizePicker {
    if ([self.delegate respondsToSelector:@selector(sizeLabelTapped:)]) {
        NSLog(@"size lbl tapped");
        [self.delegate sizeLabelTapped:self];
    }
}


#pragma mark - UITextfieldDelegate
#pragma mark -
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    if ([self.delegate respondsToSelector:@selector(viewShouldScroll)]) {
        NSLog(@"size lbl tapped");
        [self.delegate viewShouldScroll];
    }
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    textField.placeholder = nil;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    textField.placeholder = @"$0.00";
}


#pragma mark - Helpers
#pragma mark -

- (NSString*)formatTextFieldForCurrency:(NSString*)oldText {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc]init];
    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [formatter setLocale: [NSLocale localeWithLocaleIdentifier:@"en_US"]];
    formatter.usesSignificantDigits = FALSE;
    formatter.maximumSignificantDigits = 4;
    formatter.minimumSignificantDigits = 2;
    
    NSNumber *price = [formatter numberFromString:oldText];
    return [NSString stringWithFormat:@"%@", price];
    
}

#pragma mark - Styling
#pragma mark -

- (void)styleRow {
    /**
     @property (nonatomic, strong) UITextField *txtfldPrice;
     @property (nonatomic, strong) UILabel *lblSize;
     @property (nonatomic, strong) UIButton *btnAddPriceAndSize;
     @property (nonatomic, strong) UIButton *btnRemovePriceAndSize;
     */
    UIFont *regLato = [UIFont fontWithName:@"Lato-Regular" size:12.0f];
    
    self.txtfldPrice.font = regLato;
    self.txtfldPrice.backgroundColor = [SHMenuAdminStyleSupport sharedInstance].GRAY;
    
    self.lblSize.font = regLato;
    self.lblSize.textColor = [SHMenuAdminStyleSupport sharedInstance].ORANGE;
    
}

@end
