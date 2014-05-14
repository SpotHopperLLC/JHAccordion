//
//  SHStyleKit.m
//  SpotHopper
//
//  Created by SpotHopper on 5/13/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//
//  Generated by PaintCode (www.paintcodeapp.com)
//

#import "SHStyleKit.h"


@implementation SHStyleKit

#pragma mark Cache

static UIColor* _mainColor = nil;
static UIColor* _mainColorTransparent = nil;
static UIColor* _mainTextColor = nil;

static UIImage* _imageOfWineIcon = nil;
static UIImage* _imageOfSpecialsIcon = nil;
static UIImage* _imageOfSpotIcon = nil;
static UIImage* _imageOfCocktailIcon = nil;
static UIImage* _imageOfBeerIcon = nil;

#pragma mark Initialization

+ (void)initialize
{
    // Colors Initialization
    _mainColor = [UIColor colorWithRed: 0.878 green: 0.399 blue: 0.148 alpha: 1];
    _mainColorTransparent = [SHStyleKit.mainColor colorWithAlphaComponent: 0.8];
    _mainTextColor = [UIColor colorWithRed: 0.4 green: 0.4 blue: 0.4 alpha: 1];

}

#pragma mark Colors

+ (UIColor*)mainColor { return _mainColor; }
+ (UIColor*)mainColorTransparent { return _mainColorTransparent; }
+ (UIColor*)mainTextColor { return _mainTextColor; }

#pragma mark Drawing Methods

+ (void)drawWineIcon;
{

    //// Group
    {
        //// Group 2
        {
            //// Bezier Drawing
            UIBezierPath* bezierPath = UIBezierPath.bezierPath;
            [bezierPath moveToPoint: CGPointMake(654.9, 1024)];
            [bezierPath addLineToPoint: CGPointMake(382.2, 1024)];
            [bezierPath addCurveToPoint: CGPointMake(349.8, 996.8) controlPoint1: CGPointMake(366.2, 1024) controlPoint2: CGPointMake(352.6, 1012.6)];
            [bezierPath addCurveToPoint: CGPointMake(371, 960.2) controlPoint1: CGPointMake(347, 981) controlPoint2: CGPointMake(356, 965.6)];
            [bezierPath addCurveToPoint: CGPointMake(499.1, 860.4) controlPoint1: CGPointMake(433.4, 937.7) controlPoint2: CGPointMake(475.4, 905)];
            [bezierPath addLineToPoint: CGPointMake(499.1, 521)];
            [bezierPath addCurveToPoint: CGPointMake(241.9, 28.3) controlPoint1: CGPointMake(341.7, 501.1) controlPoint2: CGPointMake(255.2, 335.5)];
            [bezierPath addLineToPoint: CGPointMake(240.7, 0)];
            [bezierPath addLineToPoint: CGPointMake(786.1, 0)];
            [bezierPath addLineToPoint: CGPointMake(786.5, 26.7)];
            [bezierPath addCurveToPoint: CGPointMake(679.4, 464) controlPoint1: CGPointMake(789.8, 245.9) controlPoint2: CGPointMake(754.8, 388.9)];
            [bezierPath addCurveToPoint: CGPointMake(553.3, 522.1) controlPoint1: CGPointMake(645.1, 498.1) controlPoint2: CGPointMake(602.8, 517.6)];
            [bezierPath addLineToPoint: CGPointMake(553.3, 861.9)];
            [bezierPath addCurveToPoint: CGPointMake(666.6, 958) controlPoint1: CGPointMake(570.3, 904.6) controlPoint2: CGPointMake(607.4, 936.1)];
            [bezierPath addCurveToPoint: CGPointMake(688.4, 996) controlPoint1: CGPointMake(682.1, 963.8) controlPoint2: CGPointMake(691.3, 979.8)];
            [bezierPath addCurveToPoint: CGPointMake(654.9, 1024) controlPoint1: CGPointMake(685.5, 1012.2) controlPoint2: CGPointMake(671.4, 1024)];
            [bezierPath closePath];
            [bezierPath moveToPoint: CGPointMake(471.3, 969.7)];
            [bezierPath addLineToPoint: CGPointMake(572.9, 969.7)];
            [bezierPath addCurveToPoint: CGPointMake(524, 920.7) controlPoint1: CGPointMake(553.2, 955.4) controlPoint2: CGPointMake(536.9, 939)];
            [bezierPath addCurveToPoint: CGPointMake(471.3, 969.7) controlPoint1: CGPointMake(509.4, 939) controlPoint2: CGPointMake(491.8, 955.4)];
            [bezierPath closePath];
            [bezierPath moveToPoint: CGPointMake(526.8, 468.8)];
            [bezierPath addCurveToPoint: CGPointMake(641.2, 425.6) controlPoint1: CGPointMake(573.6, 469.8) controlPoint2: CGPointMake(611.1, 455.5)];
            [bezierPath addCurveToPoint: CGPointMake(732.5, 54.3) controlPoint1: CGPointMake(701.8, 365.2) controlPoint2: CGPointMake(732.5, 240.3)];
            [bezierPath addLineToPoint: CGPointMake(297.5, 54.3)];
            [bezierPath addCurveToPoint: CGPointMake(526.8, 468.8) controlPoint1: CGPointMake(313.8, 326) controlPoint2: CGPointMake(390.9, 465.4)];
            [bezierPath closePath];
            bezierPath.miterLimit = 4;

            [SHStyleKit.mainColor setFill];
            [bezierPath fill];
        }


        //// Group 3
        {
            //// Bezier 2 Drawing
            UIBezierPath* bezier2Path = UIBezierPath.bezierPath;
            [bezier2Path moveToPoint: CGPointMake(285.6, 207.6)];
            [bezier2Path addLineToPoint: CGPointMake(759.6, 207.6)];
            bezier2Path.miterLimit = 4;

            [SHStyleKit.mainColor setFill];
            [bezier2Path fill];


            //// Bezier 3 Drawing
            UIBezierPath* bezier3Path = UIBezierPath.bezierPath;
            [bezier3Path moveToPoint: CGPointMake(285.6, 194)];
            [bezier3Path addLineToPoint: CGPointMake(759.6, 194)];
            [bezier3Path addLineToPoint: CGPointMake(759.6, 221.1)];
            [bezier3Path addLineToPoint: CGPointMake(285.6, 221.1)];
            [bezier3Path addLineToPoint: CGPointMake(285.6, 194)];
            [bezier3Path closePath];
            bezier3Path.miterLimit = 4;

            [SHStyleKit.mainColor setFill];
            [bezier3Path fill];
        }
    }
}

+ (void)drawSpecialsIcon;
{
    //// General Declarations
    CGContextRef context = UIGraphicsGetCurrentContext();

    //// Group
    {
        //// Group 2
        {
            //// Bezier Drawing
            UIBezierPath* bezierPath = UIBezierPath.bezierPath;
            [bezierPath moveToPoint: CGPointMake(499.1, 1021.2)];
            [bezierPath addCurveToPoint: CGPointMake(450.1, 991.7) controlPoint1: CGPointMake(478.5, 1021.2) controlPoint2: CGPointMake(459.7, 1009.9)];
            [bezierPath addLineToPoint: CGPointMake(339.5, 782.7)];
            [bezierPath addLineToPoint: CGPointMake(103.4, 768.3)];
            [bezierPath addCurveToPoint: CGPointMake(57.4, 738) controlPoint1: CGPointMake(83.6, 767) controlPoint2: CGPointMake(66.4, 755.7)];
            [bezierPath addCurveToPoint: CGPointMake(60.3, 682.9) controlPoint1: CGPointMake(48.4, 720.2) controlPoint2: CGPointMake(49.5, 699.7)];
            [bezierPath addLineToPoint: CGPointMake(465, 55.2)];
            [bezierPath addCurveToPoint: CGPointMake(515.9, 24.7) controlPoint1: CGPointMake(476.2, 37.8) controlPoint2: CGPointMake(495.3, 26.4)];
            [bezierPath addLineToPoint: CGPointMake(794.2, 2.4)];
            [bezierPath addCurveToPoint: CGPointMake(862.5, 46.5) controlPoint1: CGPointMake(824.3, 0) controlPoint2: CGPointMake(852.4, 18.3)];
            [bezierPath addLineToPoint: CGPointMake(957, 309.3)];
            [bezierPath addCurveToPoint: CGPointMake(950.3, 368.2) controlPoint1: CGPointMake(964, 328.8) controlPoint2: CGPointMake(961.5, 350.8)];
            [bezierPath addLineToPoint: CGPointMake(545.7, 995.8)];
            [bezierPath addCurveToPoint: CGPointMake(499.1, 1021.2) controlPoint1: CGPointMake(535.4, 1011.7) controlPoint2: CGPointMake(518, 1021.2)];
            [bezierPath closePath];
            [bezierPath moveToPoint: CGPointMake(799.6, 49.1)];
            [bezierPath addCurveToPoint: CGPointMake(798, 49.2) controlPoint1: CGPointMake(799.1, 49.1) controlPoint2: CGPointMake(798.5, 49.1)];
            [bezierPath addLineToPoint: CGPointMake(519.6, 71.5)];
            [bezierPath addCurveToPoint: CGPointMake(504.3, 80.6) controlPoint1: CGPointMake(513.4, 72) controlPoint2: CGPointMake(507.7, 75.4)];
            [bezierPath addLineToPoint: CGPointMake(99.7, 708.3)];
            [bezierPath addCurveToPoint: CGPointMake(99.3, 716.8) controlPoint1: CGPointMake(97.4, 711.9) controlPoint2: CGPointMake(98.4, 715.2)];
            [bezierPath addCurveToPoint: CGPointMake(106.4, 721.5) controlPoint1: CGPointMake(100.1, 718.4) controlPoint2: CGPointMake(102.1, 721.2)];
            [bezierPath addLineToPoint: CGPointMake(368.7, 737.5)];
            [bezierPath addLineToPoint: CGPointMake(491.6, 969.8)];
            [bezierPath addCurveToPoint: CGPointMake(499.2, 974.3) controlPoint1: CGPointMake(493.8, 973.9) controlPoint2: CGPointMake(497.6, 974.3)];
            [bezierPath addCurveToPoint: CGPointMake(506.4, 970.4) controlPoint1: CGPointMake(500.9, 974.3) controlPoint2: CGPointMake(504.2, 973.8)];
            [bezierPath addLineToPoint: CGPointMake(911, 342.8)];
            [bezierPath addCurveToPoint: CGPointMake(913, 325.1) controlPoint1: CGPointMake(914.4, 337.6) controlPoint2: CGPointMake(915.1, 331)];
            [bezierPath addLineToPoint: CGPointMake(818.5, 62.3)];
            [bezierPath addCurveToPoint: CGPointMake(799.6, 49.1) controlPoint1: CGPointMake(815.6, 54.4) controlPoint2: CGPointMake(808, 49.1)];
            [bezierPath closePath];
            bezierPath.miterLimit = 4;

            [SHStyleKit.mainColor setFill];
            [bezierPath fill];
        }


        //// Group 3
        {
            //// Bezier 2 Drawing
            UIBezierPath* bezier2Path = UIBezierPath.bezierPath;
            [bezier2Path moveToPoint: CGPointMake(714.7, 254.6)];
            [bezier2Path addCurveToPoint: CGPointMake(685.5, 246) controlPoint1: CGPointMake(704.3, 254.6) controlPoint2: CGPointMake(694.2, 251.6)];
            [bezier2Path addCurveToPoint: CGPointMake(662, 212.1) controlPoint1: CGPointMake(673.4, 238.2) controlPoint2: CGPointMake(665, 226.1)];
            [bezier2Path addCurveToPoint: CGPointMake(669.4, 171.5) controlPoint1: CGPointMake(659, 198) controlPoint2: CGPointMake(661.6, 183.6)];
            [bezier2Path addCurveToPoint: CGPointMake(714.8, 146.8) controlPoint1: CGPointMake(679.4, 156) controlPoint2: CGPointMake(696.3, 146.8)];
            [bezier2Path addCurveToPoint: CGPointMake(744, 155.4) controlPoint1: CGPointMake(725.2, 146.8) controlPoint2: CGPointMake(735.3, 149.8)];
            [bezier2Path addCurveToPoint: CGPointMake(760.1, 230) controlPoint1: CGPointMake(769, 171.5) controlPoint2: CGPointMake(776.2, 205)];
            [bezier2Path addCurveToPoint: CGPointMake(714.7, 254.6) controlPoint1: CGPointMake(750.1, 245.4) controlPoint2: CGPointMake(733.2, 254.6)];
            [bezier2Path closePath];
            [bezier2Path moveToPoint: CGPointMake(714.8, 170.1)];
            [bezier2Path addCurveToPoint: CGPointMake(689.1, 184.1) controlPoint1: CGPointMake(704.4, 170.1) controlPoint2: CGPointMake(694.8, 175.3)];
            [bezier2Path addCurveToPoint: CGPointMake(684.9, 207.1) controlPoint1: CGPointMake(684.7, 191) controlPoint2: CGPointMake(683.2, 199.1)];
            [bezier2Path addCurveToPoint: CGPointMake(698.2, 226.3) controlPoint1: CGPointMake(686.6, 215.1) controlPoint2: CGPointMake(691.3, 221.9)];
            [bezier2Path addCurveToPoint: CGPointMake(740.4, 217.2) controlPoint1: CGPointMake(712, 235.2) controlPoint2: CGPointMake(731.6, 230.8)];
            [bezier2Path addCurveToPoint: CGPointMake(731.3, 175) controlPoint1: CGPointMake(749.5, 203.1) controlPoint2: CGPointMake(745.4, 184.1)];
            [bezier2Path addCurveToPoint: CGPointMake(714.8, 170.1) controlPoint1: CGPointMake(726.4, 171.8) controlPoint2: CGPointMake(720.7, 170.1)];
            [bezier2Path closePath];
            bezier2Path.miterLimit = 4;

            [SHStyleKit.mainColor setFill];
            [bezier2Path fill];
        }


        //// Rectangle Drawing
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, 515.98, 480.88);
        CGContextRotateCTM(context, 35.99 * M_PI / 180);

        CGRect rectangleRect = CGRectMake(-117.02, -189.62, 234.04, 379.25);
        NSMutableParagraphStyle* rectangleStyle = NSMutableParagraphStyle.defaultParagraphStyle.mutableCopy;
        rectangleStyle.alignment = NSTextAlignmentLeft;

        NSDictionary* rectangleFontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"MyriadPro-Bold" size: 408.65], NSForegroundColorAttributeName: SHStyleKit.mainColor, NSParagraphStyleAttributeName: rectangleStyle};

        [@"$" drawInRect: rectangleRect withAttributes: rectangleFontAttributes];

        CGContextRestoreGState(context);
    }
}

+ (void)drawSpotIcon;
{

    //// Group
    {
        //// Group 2
        {
            //// Bezier Drawing


            //// Bezier 2 Drawing
            UIBezierPath* bezier2Path = UIBezierPath.bezierPath;
            [bezier2Path moveToPoint: CGPointMake(510.2, 1024.1)];
            [bezier2Path addLineToPoint: CGPointMake(239.5, 492.3)];
            [bezier2Path addCurveToPoint: CGPointMake(190.4, 321.7) controlPoint1: CGPointMake(207.4, 441.2) controlPoint2: CGPointMake(190.4, 382.2)];
            [bezier2Path addCurveToPoint: CGPointMake(511.5, 0.6) controlPoint1: CGPointMake(190.4, 144.6) controlPoint2: CGPointMake(334.5, 0.6)];
            [bezier2Path addCurveToPoint: CGPointMake(832.6, 321.7) controlPoint1: CGPointMake(688.5, 0.6) controlPoint2: CGPointMake(832.6, 144.7)];
            [bezier2Path addCurveToPoint: CGPointMake(783.7, 492) controlPoint1: CGPointMake(832.6, 382.1) controlPoint2: CGPointMake(815.7, 441)];
            [bezier2Path addLineToPoint: CGPointMake(510.2, 1024.1)];
            [bezier2Path closePath];
            [bezier2Path moveToPoint: CGPointMake(511.5, 47.3)];
            [bezier2Path addCurveToPoint: CGPointMake(237.1, 321.7) controlPoint1: CGPointMake(360.2, 47.3) controlPoint2: CGPointMake(237.1, 170.4)];
            [bezier2Path addCurveToPoint: CGPointMake(279.6, 468.2) controlPoint1: CGPointMake(237.1, 373.7) controlPoint2: CGPointMake(251.8, 424.4)];
            [bezier2Path addLineToPoint: CGPointMake(280.7, 470.1)];
            [bezier2Path addLineToPoint: CGPointMake(510.5, 921.4)];
            [bezier2Path addLineToPoint: CGPointMake(743.6, 467.9)];
            [bezier2Path addCurveToPoint: CGPointMake(785.9, 321.7) controlPoint1: CGPointMake(771.3, 424.1) controlPoint2: CGPointMake(785.9, 373.5)];
            [bezier2Path addCurveToPoint: CGPointMake(511.5, 47.3) controlPoint1: CGPointMake(785.8, 170.4) controlPoint2: CGPointMake(662.8, 47.3)];
            [bezier2Path closePath];
            bezier2Path.miterLimit = 4;

            [SHStyleKit.mainColor setFill];
            [bezier2Path fill];
        }


        //// Group 3
        {
            //// Bezier 3 Drawing


            //// Bezier 4 Drawing
            UIBezierPath* bezier4Path = UIBezierPath.bezierPath;
            [bezier4Path moveToPoint: CGPointMake(516.5, 459.7)];
            [bezier4Path addCurveToPoint: CGPointMake(402.6, 345.8) controlPoint1: CGPointMake(453.7, 459.7) controlPoint2: CGPointMake(402.6, 408.6)];
            [bezier4Path addCurveToPoint: CGPointMake(516.5, 231.8) controlPoint1: CGPointMake(402.6, 283) controlPoint2: CGPointMake(453.7, 231.8)];
            [bezier4Path addCurveToPoint: CGPointMake(630.4, 345.8) controlPoint1: CGPointMake(579.3, 231.8) controlPoint2: CGPointMake(630.4, 282.9)];
            [bezier4Path addCurveToPoint: CGPointMake(516.5, 459.7) controlPoint1: CGPointMake(630.4, 408.7) controlPoint2: CGPointMake(579.3, 459.7)];
            [bezier4Path closePath];
            [bezier4Path moveToPoint: CGPointMake(516.5, 266.8)];
            [bezier4Path addCurveToPoint: CGPointMake(437.6, 345.7) controlPoint1: CGPointMake(473, 266.8) controlPoint2: CGPointMake(437.6, 302.2)];
            [bezier4Path addCurveToPoint: CGPointMake(516.5, 424.6) controlPoint1: CGPointMake(437.6, 389.2) controlPoint2: CGPointMake(473, 424.6)];
            [bezier4Path addCurveToPoint: CGPointMake(595.4, 345.7) controlPoint1: CGPointMake(560, 424.6) controlPoint2: CGPointMake(595.4, 389.2)];
            [bezier4Path addCurveToPoint: CGPointMake(516.5, 266.8) controlPoint1: CGPointMake(595.4, 302.2) controlPoint2: CGPointMake(560, 266.8)];
            [bezier4Path closePath];
            bezier4Path.miterLimit = 4;

            [SHStyleKit.mainColor setFill];
            [bezier4Path fill];
        }
    }
}

+ (void)drawCocktailIcon;
{

    //// Group
    {
        //// Bezier Drawing
        UIBezierPath* bezierPath = UIBezierPath.bezierPath;
        [bezierPath moveToPoint: CGPointMake(548.5, 589.5)];
        [bezierPath addLineToPoint: CGPointMake(919, 202.8)];
        [bezierPath addLineToPoint: CGPointMake(716.2, 202.8)];
        [bezierPath addLineToPoint: CGPointMake(769.6, 147.1)];
        [bezierPath addCurveToPoint: CGPointMake(821.8, 132.3) controlPoint1: CGPointMake(786.6, 152) controlPoint2: CGPointMake(807, 147)];
        [bezierPath addCurveToPoint: CGPointMake(836.1, 77.6) controlPoint1: CGPointMake(837.2, 116.8) controlPoint2: CGPointMake(842.2, 95.2)];
        [bezierPath addLineToPoint: CGPointMake(889.3, 22)];
        [bezierPath addLineToPoint: CGPointMake(866.1, 0)];
        [bezierPath addLineToPoint: CGPointMake(814.6, 53.8)];
        [bezierPath addCurveToPoint: CGPointMake(755.5, 65.9) controlPoint1: CGPointMake(796.4, 44.9) controlPoint2: CGPointMake(772.4, 49)];
        [bezierPath addCurveToPoint: CGPointMake(744.3, 127.2) controlPoint1: CGPointMake(738, 83.5) controlPoint2: CGPointMake(734.1, 108.8)];
        [bezierPath addLineToPoint: CGPointMake(672, 202.8)];
        [bezierPath addLineToPoint: CGPointMake(130, 202.8)];
        [bezierPath addLineToPoint: CGPointMake(500.6, 589.5)];
        [bezierPath addLineToPoint: CGPointMake(500.6, 915.2)];
        [bezierPath addLineToPoint: CGPointMake(321.6, 992.9)];
        [bezierPath addCurveToPoint: CGPointMake(727.6, 992.9) controlPoint1: CGPointMake(321.6, 992.9) controlPoint2: CGPointMake(523.5, 1064.8)];
        [bezierPath addLineToPoint: CGPointMake(548.6, 915.2)];
        [bezierPath addLineToPoint: CGPointMake(548.6, 589.5)];
        [bezierPath addLineToPoint: CGPointMake(548.5, 589.5)];
        [bezierPath closePath];
        [bezierPath moveToPoint: CGPointMake(578.1, 300.7)];
        [bezierPath addLineToPoint: CGPointMake(498.8, 383.6)];
        [bezierPath addLineToPoint: CGPointMake(521.8, 405.7)];
        [bezierPath addLineToPoint: CGPointMake(622.4, 300.8)];
        [bezierPath addLineToPoint: CGPointMake(764.1, 300.8)];
        [bezierPath addLineToPoint: CGPointMake(524.6, 550.6)];
        [bezierPath addLineToPoint: CGPointMake(285.1, 300.7)];
        [bezierPath addLineToPoint: CGPointMake(578.1, 300.7)];
        [bezierPath closePath];
        bezierPath.miterLimit = 4;

        [SHStyleKit.mainColor setFill];
        [bezierPath fill];
    }
}

+ (void)drawBeerIcon;
{

    //// Group
    {
        //// Group 2
        {
            //// Bezier Drawing


            //// Bezier 2 Drawing
            UIBezierPath* bezier2Path = UIBezierPath.bezierPath;
            [bezier2Path moveToPoint: CGPointMake(712.2, 1020.5)];
            [bezier2Path addLineToPoint: CGPointMake(323.2, 1020.5)];
            [bezier2Path addLineToPoint: CGPointMake(328.3, 995.2)];
            [bezier2Path addCurveToPoint: CGPointMake(283, 450) controlPoint1: CGPointMake(386.5, 702) controlPoint2: CGPointMake(331.5, 568.1)];
            [bezier2Path addCurveToPoint: CGPointMake(267.3, 14.2) controlPoint1: CGPointMake(236.4, 336.5) controlPoint2: CGPointMake(192.4, 229.4)];
            [bezier2Path addLineToPoint: CGPointMake(272.3, 0)];
            [bezier2Path addLineToPoint: CGPointMake(758.7, 0)];
            [bezier2Path addLineToPoint: CGPointMake(763, 15.6)];
            [bezier2Path addCurveToPoint: CGPointMake(739.9, 436.5) controlPoint1: CGPointMake(819.8, 223.5) controlPoint2: CGPointMake(781, 327)];
            [bezier2Path addCurveToPoint: CGPointMake(707.1, 995.1) controlPoint1: CGPointMake(695.5, 554.9) controlPoint2: CGPointMake(645.1, 689.1)];
            [bezier2Path addLineToPoint: CGPointMake(712.2, 1020.5)];
            [bezier2Path closePath];
            [bezier2Path moveToPoint: CGPointMake(374.6, 978.1)];
            [bezier2Path addLineToPoint: CGPointMake(660.5, 978.1)];
            [bezier2Path addCurveToPoint: CGPointMake(700.1, 421.6) controlPoint1: CGPointMake(603.9, 678) controlPoint2: CGPointMake(655, 542)];
            [bezier2Path addCurveToPoint: CGPointMake(726.1, 42.4) controlPoint1: CGPointMake(739.3, 317.2) controlPoint2: CGPointMake(773.3, 226.6)];
            [bezier2Path addLineToPoint: CGPointMake(302.5, 42.4)];
            [bezier2Path addCurveToPoint: CGPointMake(322.2, 433.9) controlPoint1: CGPointMake(239.5, 232.5) controlPoint2: CGPointMake(276.1, 321.7)];
            [bezier2Path addCurveToPoint: CGPointMake(374.6, 978.1) controlPoint1: CGPointMake(371.5, 554.1) controlPoint2: CGPointMake(427.3, 689.8)];
            [bezier2Path closePath];
            bezier2Path.miterLimit = 4;

            [SHStyleKit.mainColor setFill];
            [bezier2Path fill];
        }


        //// Group 3
        {
            //// Bezier 3 Drawing
            UIBezierPath* bezier3Path = UIBezierPath.bezierPath;
            [bezier3Path moveToPoint: CGPointMake(259, 188.5)];
            [bezier3Path addLineToPoint: CGPointMake(258.8, 146.1)];
            [bezier3Path addLineToPoint: CGPointMake(770.2, 142.4)];
            [bezier3Path addLineToPoint: CGPointMake(770.5, 184.8)];
            [bezier3Path addLineToPoint: CGPointMake(259, 188.5)];
            [bezier3Path closePath];
            bezier3Path.miterLimit = 4;

            [SHStyleKit.mainColor setFill];
            [bezier3Path fill];
        }


        //// Group 4
        {
            //// Bezier 4 Drawing
            UIBezierPath* bezier4Path = UIBezierPath.bezierPath;
            [bezier4Path moveToPoint: CGPointMake(579.72, 716.18)];
            [bezier4Path addCurveToPoint: CGPointMake(579.72, 736.82) controlPoint1: CGPointMake(585.43, 721.88) controlPoint2: CGPointMake(585.43, 731.12)];
            [bezier4Path addCurveToPoint: CGPointMake(559.08, 736.82) controlPoint1: CGPointMake(574.02, 742.53) controlPoint2: CGPointMake(564.78, 742.53)];
            [bezier4Path addCurveToPoint: CGPointMake(559.08, 716.18) controlPoint1: CGPointMake(553.37, 731.12) controlPoint2: CGPointMake(553.37, 721.88)];
            [bezier4Path addCurveToPoint: CGPointMake(579.72, 716.18) controlPoint1: CGPointMake(564.78, 710.47) controlPoint2: CGPointMake(574.02, 710.47)];
            [bezier4Path closePath];
            bezier4Path.miterLimit = 4;

            [SHStyleKit.mainColor setFill];
            [bezier4Path fill];
        }


        //// Group 5
        {
            //// Bezier 5 Drawing
            UIBezierPath* bezier5Path = UIBezierPath.bezierPath;
            [bezier5Path moveToPoint: CGPointMake(620.13, 569.67)];
            [bezier5Path addCurveToPoint: CGPointMake(620.13, 589.33) controlPoint1: CGPointMake(625.56, 575.1) controlPoint2: CGPointMake(625.56, 583.9)];
            [bezier5Path addCurveToPoint: CGPointMake(600.47, 589.33) controlPoint1: CGPointMake(614.7, 594.76) controlPoint2: CGPointMake(605.9, 594.76)];
            [bezier5Path addCurveToPoint: CGPointMake(600.47, 569.67) controlPoint1: CGPointMake(595.04, 583.9) controlPoint2: CGPointMake(595.04, 575.1)];
            [bezier5Path addCurveToPoint: CGPointMake(620.13, 569.67) controlPoint1: CGPointMake(605.9, 564.24) controlPoint2: CGPointMake(614.7, 564.24)];
            [bezier5Path closePath];
            bezier5Path.miterLimit = 4;

            [SHStyleKit.mainColor setFill];
            [bezier5Path fill];
        }


        //// Group 6
        {
            //// Bezier 6 Drawing
            UIBezierPath* bezier6Path = UIBezierPath.bezierPath;
            [bezier6Path moveToPoint: CGPointMake(557.9, 448.5)];
            [bezier6Path addCurveToPoint: CGPointMake(557.9, 464.9) controlPoint1: CGPointMake(562.43, 453.03) controlPoint2: CGPointMake(562.43, 460.37)];
            [bezier6Path addCurveToPoint: CGPointMake(541.5, 464.9) controlPoint1: CGPointMake(553.37, 469.43) controlPoint2: CGPointMake(546.03, 469.43)];
            [bezier6Path addCurveToPoint: CGPointMake(541.5, 448.5) controlPoint1: CGPointMake(536.97, 460.37) controlPoint2: CGPointMake(536.97, 453.03)];
            [bezier6Path addCurveToPoint: CGPointMake(557.9, 448.5) controlPoint1: CGPointMake(546.03, 443.97) controlPoint2: CGPointMake(553.37, 443.97)];
            [bezier6Path closePath];
            bezier6Path.miterLimit = 4;

            [SHStyleKit.mainColor setFill];
            [bezier6Path fill];
        }


        //// Group 7
        {
            //// Bezier 7 Drawing
            UIBezierPath* bezier7Path = UIBezierPath.bezierPath;
            [bezier7Path moveToPoint: CGPointMake(611.61, 280.09)];
            [bezier7Path addCurveToPoint: CGPointMake(611.61, 309.51) controlPoint1: CGPointMake(619.73, 288.22) controlPoint2: CGPointMake(619.73, 301.38)];
            [bezier7Path addCurveToPoint: CGPointMake(582.19, 309.51) controlPoint1: CGPointMake(603.48, 317.63) controlPoint2: CGPointMake(590.32, 317.63)];
            [bezier7Path addCurveToPoint: CGPointMake(582.19, 280.09) controlPoint1: CGPointMake(574.07, 301.38) controlPoint2: CGPointMake(574.07, 288.22)];
            [bezier7Path addCurveToPoint: CGPointMake(611.61, 280.09) controlPoint1: CGPointMake(590.32, 271.97) controlPoint2: CGPointMake(603.48, 271.97)];
            [bezier7Path closePath];
            bezier7Path.miterLimit = 4;

            [SHStyleKit.mainColor setFill];
            [bezier7Path fill];
        }
    }
}

#pragma mark Generated Images

+ (UIImage*)imageOfWineIcon;
{
    if (_imageOfWineIcon)
        return _imageOfWineIcon;

    UIGraphicsBeginImageContextWithOptions(CGSizeMake(1024, 1024), NO, 0.0f);
    [SHStyleKit drawWineIcon];
    _imageOfWineIcon = [UIGraphicsGetImageFromCurrentImageContext() imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal];
    UIGraphicsEndImageContext();

    return _imageOfWineIcon;
}

+ (UIImage*)imageOfSpecialsIcon;
{
    if (_imageOfSpecialsIcon)
        return _imageOfSpecialsIcon;

    UIGraphicsBeginImageContextWithOptions(CGSizeMake(1024, 1024), NO, 0.0f);
    [SHStyleKit drawSpecialsIcon];
    _imageOfSpecialsIcon = [UIGraphicsGetImageFromCurrentImageContext() imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal];
    UIGraphicsEndImageContext();

    return _imageOfSpecialsIcon;
}

+ (UIImage*)imageOfSpotIcon;
{
    if (_imageOfSpotIcon)
        return _imageOfSpotIcon;

    UIGraphicsBeginImageContextWithOptions(CGSizeMake(1024, 1024), NO, 0.0f);
    [SHStyleKit drawSpotIcon];
    _imageOfSpotIcon = [UIGraphicsGetImageFromCurrentImageContext() imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal];
    UIGraphicsEndImageContext();

    return _imageOfSpotIcon;
}

+ (UIImage*)imageOfCocktailIcon;
{
    if (_imageOfCocktailIcon)
        return _imageOfCocktailIcon;

    UIGraphicsBeginImageContextWithOptions(CGSizeMake(1024, 1024), NO, 0.0f);
    [SHStyleKit drawCocktailIcon];
    _imageOfCocktailIcon = [UIGraphicsGetImageFromCurrentImageContext() imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal];
    UIGraphicsEndImageContext();

    return _imageOfCocktailIcon;
}

+ (UIImage*)imageOfBeerIcon;
{
    if (_imageOfBeerIcon)
        return _imageOfBeerIcon;

    UIGraphicsBeginImageContextWithOptions(CGSizeMake(1024, 1024), NO, 0.0f);
    [SHStyleKit drawBeerIcon];
    _imageOfBeerIcon = [UIGraphicsGetImageFromCurrentImageContext() imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal];
    UIGraphicsEndImageContext();

    return _imageOfBeerIcon;
}

#pragma mark Customization Infrastructure

- (void)setWineIconTargets: (NSArray*)wineIconTargets
{
    _wineIconTargets = wineIconTargets;

    for (id target in self.wineIconTargets)
        [target setImage: SHStyleKit.imageOfWineIcon];
}

- (void)setSpecialsIconTargets: (NSArray*)specialsIconTargets
{
    _specialsIconTargets = specialsIconTargets;

    for (id target in self.specialsIconTargets)
        [target setImage: SHStyleKit.imageOfSpecialsIcon];
}

- (void)setSpotIconTargets: (NSArray*)spotIconTargets
{
    _spotIconTargets = spotIconTargets;

    for (id target in self.spotIconTargets)
        [target setImage: SHStyleKit.imageOfSpotIcon];
}

- (void)setCocktailIconTargets: (NSArray*)cocktailIconTargets
{
    _cocktailIconTargets = cocktailIconTargets;

    for (id target in self.cocktailIconTargets)
        [target setImage: SHStyleKit.imageOfCocktailIcon];
}

- (void)setBeerIconTargets: (NSArray*)beerIconTargets
{
    _beerIconTargets = beerIconTargets;

    for (id target in self.beerIconTargets)
        [target setImage: SHStyleKit.imageOfBeerIcon];
}


@end
