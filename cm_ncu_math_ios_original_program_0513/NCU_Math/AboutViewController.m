//
//  AboutViewController.m
//  SQuInt2014
//
//  Created by csjan on 9/17/14.
//  Copyright (c) 2014 tapgo. All rights reserved.
//

#import "AboutViewController.h"
#import "UIColor+ProjectColors.h"

@interface AboutViewController ()

@end

@implementation AboutViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    //styling
    self.view.backgroundColor = [UIColor background];
    [self.email_us_button setTitleColor:[UIColor dark_button_txt] forState:UIControlStateNormal];
    [self.email_us_button setTitleColor:[UIColor dark_button_txt] forState:UIControlStateHighlighted];
    self.company_background_view.backgroundColor = [UIColor light_bg];
    self.company_background_view.alpha = 1;
    self.company_title_label.textColor = [UIColor dark_txt];
    self.company_description_label.textColor = [UIColor dark_txt];
    self.company_description_two_label.textColor = [UIColor dark_txt];
    self.company_trim_view.backgroundColor = [UIColor clearColor];
    self.company_background_view.layer.cornerRadius = 2;
    
    //add shadow to views
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:self.company_background_view.bounds];
    self.company_background_view.layer.masksToBounds = NO;
    self.company_background_view.layer.shadowColor = [UIColor blackColor].CGColor;
    self.company_background_view.layer.shadowOffset = CGSizeMake(0.0f, 3.0f);
    self.company_background_view.layer.shadowOpacity = 0.3f;
    self.company_background_view.layer.shadowPath = shadowPath.CGPath;

    //set text description
    self.company_description_label.text = @"Colloquium.me is a conference platform designed to help event organizers and attendees stay up-to-date and connect with each other. We offer a variety of features and customizations to fit the needs of each conference.";
    self.company_description_two_label.text = @"If you host an academic conference or workshop and think this app is useful, contact us below to see how we can help you roll out your own solution.";
}


- (IBAction)email_us_tap:(UIButton *)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto://jan0054@gmail.com"]];
}

@end
