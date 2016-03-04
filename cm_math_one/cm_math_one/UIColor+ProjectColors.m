//
//  UIColor+ProjectColors.m
//  cm_math_one
//
//  Created by csjan on 6/16/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import "UIColor+ProjectColors.h"

@implementation UIColor (ProjectColors)

+ (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

//main colors

+ (UIColor*) accent_color
{
    //return [self in500];
    return [self burgandy];
}
+ (UIColor*) light_accent
{
    //return [self in200];
    return [self test_ye];
}
+ (UIColor*) dark_accent
{
    //return [self in700];
    return [self darkGrey];
}
+ (UIColor*) primary_color
{
    //return [self do500];
    return [self blugGrey];
}
+ (UIColor*) primary_color_icon
{
    //return [self do700];
    return [self test_lr];
}
+ (UIColor*) unselected_icon
{
    return [self gr600];
}
+ (UIColor*) primary_text
{
    return [self gr900];
}
+ (UIColor*) secondary_text
{
    return [self gr700];
}
+ (UIColor*) divider_color
{
    return [self gr400];
}
+ (UIColor*) light_bg
{
    return [self gr300];
}
+ (UIColor*) dark_bg
{
    return [self gr800];
}
+ (UIColor*) light_button_txt
{
    return [UIColor whiteColor];
}
+ (UIColor*) light_grey_background
{
    return [self gr300];
}
+ (UIColor*) shadow_color
{
    return [self gr500];
}
+ (UIColor*) setup_button_background
{
    //return [self do800];
    return [self burgandy];
}
+ (UIColor*) setup_button_text
{
    return [UIColor whiteColor];
}
+ (UIColor*) drawer_background
{
    return [self gr900];
}
+ (UIColor*) drawer_icon_primary
{
    return [self gr500];
}
+ (UIColor*) drawer_icon_secondary
{
    //return [self do500];
    return [self test_br];
}
+ (UIColor*) tab_background
{
    return [self blackColor];
}

//original colors

//grey
+ (UIColor*) gr100
{
    return [self colorFromHexString:@"#F5F5F5"];
}
+ (UIColor*) gr200
{
    return [self colorFromHexString:@"#EEEEEE"];
}
+ (UIColor*) gr300
{
    return [self colorFromHexString:@"#E0E0E0"];
}
+ (UIColor*) gr400
{
    return [self colorFromHexString:@"#BDBDBD"];
}
+ (UIColor*) gr500
{
    return [self colorFromHexString:@"#9E9E9E"];
}
+ (UIColor*) gr600
{
    return [self colorFromHexString:@"#757575"];
}
+ (UIColor*) gr700
{
    return [self colorFromHexString:@"#616161"];
}
+ (UIColor*) gr800
{
    return [self colorFromHexString:@"#424242"];
}
+ (UIColor*) gr900
{
    return [self colorFromHexString:@"#212121"];
}

//deep orange
+ (UIColor*) do200
{
    return [self colorFromHexString:@"#FFAB91"];
}
+ (UIColor*) do300
{
    return [self colorFromHexString:@"#FF8A65"];
}
+ (UIColor*) do400
{
    return [self colorFromHexString:@"#FF7043"];
}
+ (UIColor*) do500
{
    return [self colorFromHexString:@"#FF5722"];
}
+ (UIColor*) do700
{
    return [self colorFromHexString:@"#E64A19"];
}
+ (UIColor*) do800
{
    return [self colorFromHexString:@"#D84315"];
}
+ (UIColor*) do900
{
    return [self colorFromHexString:@"#BF360C"];
}
+ (UIColor*) doa100
{
    return [self colorFromHexString:@"#FF9E80"];
}
+ (UIColor*) doa200
{
    return [self colorFromHexString:@"#FF6E40"];
}

//indigo
+ (UIColor*) in200
{
    return [self colorFromHexString:@"#9FA8DA"];
}
+ (UIColor*) in500
{
    return [self colorFromHexString:@"#3F51B5"];
}
+ (UIColor*) in700
{
    return [self colorFromHexString:@"#303F9F"];
}
+ (UIColor*) in900
{
    return [self colorFromHexString:@"#1A237E"];
}
+ (UIColor*) ina100
{
    return [self colorFromHexString:@"#8C9EFF"];
}
+ (UIColor*) ina200
{
    return [self colorFromHexString:@"#536DFE"];
}

//test1
+ (UIColor*) darkGrey
{
    return [self colorFromHexString:@"#505160"];
}
+ (UIColor*) blugGrey
{
    return [self colorFromHexString:@"#68829E"];
}
+ (UIColor*) test_ye
{
    return [self colorFromHexString:@"#AEBD38"];
}
+ (UIColor*) test_gr
{
    return [self colorFromHexString:@"#598234"];
}
+ (UIColor*) burgandy
{
    return [self colorFromHexString:@"#882426"];
}
+ (UIColor*) test_lr
{
    return [self colorFromHexString:@"#E29930"];
}
+ (UIColor*) test_br
{
    return [self colorFromHexString:@"#E8A735"];
    //return [self colorFromHexString:@"#D97072"];
}

@end
