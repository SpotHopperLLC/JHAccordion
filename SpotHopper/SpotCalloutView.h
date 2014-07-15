//
//  SpotCalloutView.h
//  SpotHopper
//
//  Created by Brennan Stehling on 6/25/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <MapKit/MapKit.h>

typedef enum {
    SpotCalloutIconNone = 0,
    SpotCalloutIconBeerOnTap,
    SpotCalloutIconBeerInBottle,
    SpotCalloutIconBeerOnTapAndInBottle,
    SpotCalloutIconCocktail,
    SpotCalloutIconWine
} SpotCalloutIcon;

extern NSString * const SpotCalloutViewIdentifier;

@protocol SpotCalloutViewDelegate;

@interface SpotCalloutView : UIView

@property (weak, nonatomic) id<SpotCalloutViewDelegate> delegate;
@property (weak, nonatomic, readonly) UIView *containerView;

- (void)setIcon:(SpotCalloutIcon)icon spotNameText:(NSString *)spotNameText drink1Text:(NSString *)drink1Text drink2Text:(NSString *)drink2Text;

- (void)placeInMapView:(MKMapView *)mapView insideAnnotationView:(MKAnnotationView *)annotationView;

@end

@protocol SpotCalloutViewDelegate <NSObject>

@optional

- (void)spotCalloutView:(SpotCalloutView *)spotCalloutView didSelectAnnotationView:(MKAnnotationView *)annotationView;

@end
