//
//  UIColor+ProjectColors.m
//  cm_math_one
//
//  Created by csjan on 6/16/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import "UIColor+ProjectColors.h"

@implementation UIColor (ProjectColors)
//main palette

+ (UIColor*) accent_color
{
    return [UIColor colorWithRed:83.0/255.0 green:109.0/255.0 blue:254.0/255.0 alpha:1];
}
+ (UIColor*) primary_text
{
    return [UIColor colorWithRed:33.0/255.0 green:33.0/255.0 blue:33.0/255.0 alpha:1];
}
+ (UIColor*) secondary_text
{
    return [UIColor colorWithRed:114.0/255.0 green:114.0/255.0 blue:114.0/255.0 alpha:1];
}
+ (UIColor*) divider_color
{
    return [UIColor colorWithRed:182.0/255.0 green:182.0/255.0 blue:182.0/255.0 alpha:1];
}
+ (UIColor*) primary_color
{
    return [UIColor colorWithRed:158.0/255.0 green:158.0/255.0 blue:158.0/255.0 alpha:1];
}
+ (UIColor*) dark_primary
{
    return [UIColor colorWithRed:97.0/255.0 green:97.0/255.0 blue:97.0/255.0 alpha:1];
}
+ (UIColor*) light_primary
{
    return [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1];
}
+ (UIColor*) dark_accent
{
    return [UIColor colorWithRed:48.0/255.0 green:63.0/255.0 blue:159.0/255.0 alpha:1];
}
+ (UIColor*) light_accent
{
    return [UIColor colorWithRed:197.0/255.0 green:202.0/255.0 blue:233.0/255.0 alpha:1];
}

//ui elements

+ (UIColor*) background
{
    return [UIColor colorWithRed:158.0/255.0 green:158.0/255.0 blue:158.0/255.0 alpha:1];
}
+ (UIColor*) nav_bar
{
    return [UIColor colorWithRed:63.0/255.0 green:81.0/255.0 blue:181.0/255.0 alpha:1];
}
+ (UIColor*) tab_bar
{
    return [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1];
}
+ (UIColor*) light_button_txt
{
    return [UIColor whiteColor];
}
+ (UIColor*) dark_button_txt
{
    return [UIColor colorWithRed:48.0/255.0 green:63.0/255.0 blue:159.0/255.0 alpha:1];
}
+ (UIColor*) light_bg
{
    return [UIColor whiteColor];
}
+ (UIColor*) light_txt
{
    return [UIColor whiteColor];
}
+ (UIColor*) dark_bg
{
    return [UIColor colorWithRed:97.0/255.0 green:97.0/255.0 blue:97.0/255.0 alpha:1];
}
+ (UIColor*) dark_txt
{
    return [UIColor colorWithRed:33.0/255.0 green:33.0/255.0 blue:33.0/255.0 alpha:1];
}

@end
