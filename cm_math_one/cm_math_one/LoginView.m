//
//  LoginView.m
//  cm_math_one
//
//  Created by csjan on 6/17/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import "LoginView.h"
#import <Parse/Parse.h>
#import <ParseUI.h>
#import "UIColor+ProjectColors.h"

@implementation LoginView
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
    self.view.backgroundColor = [UIColor dark_primary];
    [self.logInView setLogo:[[UIImageView alloc] initWithImage:nil]];
    
    UIImage *img = [UIImage imageNamed:@"cancel48"];
    img = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.logInView.dismissButton setTintColor:[UIColor whiteColor]];
    [self.logInView.dismissButton setTitle:@"Skip" forState:UIControlStateNormal];
    [self.logInView.dismissButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.logInView.dismissButton setBackgroundColor:[UIColor accent_color]] ;
    [self.logInView.dismissButton setImage:nil forState:UIControlStateNormal];
    [self.logInView.dismissButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:15.0]];
    
    [self.logInView.signUpButton setBackgroundColor:[UIColor accent_color]];
    [self.logInView.signUpButton setBackgroundImage:nil forState:UIControlStateNormal];
    [self.logInView.signUpButton setBackgroundImage:nil forState:UIControlStateHighlighted];
    [self.logInView.signUpButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:15.0]];
    [self.logInView.logInButton setBackgroundColor:[UIColor accent_color]];
    [self.logInView.logInButton setBackgroundImage:nil forState:UIControlStateNormal];
    [self.logInView.logInButton setBackgroundImage:nil forState:UIControlStateHighlighted];
    [self.logInView.logInButton setImage:nil forState:UIControlStateNormal];
    [self.logInView.logInButton setImage:nil forState:UIControlStateHighlighted];
    [self.logInView.logInButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:15.0]];
    
    // Remove text shadow
    CALayer *layer = self.logInView.usernameField.layer;
    layer.shadowOpacity = 0.0;
    layer = self.logInView.passwordField.layer;
    layer.shadowOpacity = 0.0;
    layer = self.logInView.signUpButton.layer;
    layer.shadowOpacity = 0.0;
    self.logInView.signUpButton.titleLabel.shadowColor = [UIColor clearColor];
    self.logInView.signUpButton.layer.shadowOpacity=0.0;
    
    // Set field text color
    [self.logInView.usernameField setBackgroundColor:[UIColor whiteColor]];
    [self.logInView.passwordField setBackgroundColor:[UIColor whiteColor]];
    [self.logInView.usernameField setTextColor:[UIColor darkGrayColor]];
    [self.logInView.passwordField setTextColor:[UIColor darkGrayColor]];
    [self.logInView.usernameField setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14.0]];
    [self.logInView.passwordField setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14.0]];
    
    UILabel *notice_label = [[UILabel alloc] initWithFrame:CGRectMake(40, 95, 280, 60)];
    [notice_label setBackgroundColor:[UIColor clearColor]];
    [notice_label setTextColor:[UIColor whiteColor]];
    [notice_label setText:@"Welcome to Colloquium.me for Mathematics! Please sign up or log in below to start customizing your events."];
    [notice_label setFont:[UIFont fontWithName:@"HelveticaNeue" size:15.0]];
    [notice_label setLineBreakMode:NSLineBreakByWordWrapping];
    notice_label.numberOfLines = 0;
    [self.view addSubview:notice_label];
    
    //[self.logInView setLogo:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"squint_logo_blue"]]];
    //self.logInView.signUpLabel.text = @"Sign up if you don't have an account";
    //self.logInView.externalLogInLabel.text = @"使用Facebook帳號登入";
    //[self.logInView.facebookButton setBackgroundColor:[UIColor colorWithRed:0.23 green:0.35 blue:0.59 alpha:1]];
    //[self.logInView.facebookButton setBackgroundImage:nil forState:UIControlStateNormal];
    //[self.logInView.facebookButton setBackgroundImage:nil forState:UIControlStateHighlighted];
    //[self.logInView.signUpButton setTitle:@"Sign Up" forState:UIControlStateNormal];
    //[self.logInView.signUpButton setTitle:@"Sign Up" forState:UIControlStateHighlighted];
    //[self.logInView.passwordForgottenButton setBackgroundImage:[UIImage imageNamed:@"noreply.png"] forState:UIControlStateNormal];
    //[self.logInView.passwordForgottenButton setBackgroundImage:[UIImage imageNamed:@"noreply.png"] forState:UIControlStateHighlighted];
    //[self.logInView.passwordForgottenButton setBackgroundColor:[UIColor clearColor]];
    self.logInView.usernameField.placeholder=@"Email";
    //self.logInView.passwordField.placeholder=@"密碼";
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    // Set frame for elements
    float loginy = self.logInView.logInButton.frame.origin.y;
    float loginx = self.logInView.logInButton.frame.origin.x;
    float loginh = self.logInView.logInButton.frame.size.height;
    float loginw = self.logInView.logInButton.frame.size.width;
    
    float signupy = self.logInView.signUpButton.frame.origin.y;
    float signupx = self.logInView.signUpButton.frame.origin.x;
    float signuph = self.logInView.signUpButton.frame.size.height;
    float signupw = self.logInView.signUpButton.frame.size.width;
    
    [self.logInView.dismissButton setFrame:CGRectMake(signupx, signupy-signuph-16, signupw, signuph)];
    //[self.logInView.logo setFrame:CGRectMake(140, 70, 40, 40)];
    //[self.logInView.passwordForgottenButton setFrame:CGRectMake(288, 263, 24, 24)];
    //[self.logInView.facebookButton setFrame:CGRectMake(35.0f, 287.0f, 120.0f, 40.0f)];
    //[self.logInView.twitterButton setFrame:CGRectMake(35.0f+130.0f, 287.0f, 120.0f, 40.0f)];
    //[self.logInView.signUpButton setFrame:CGRectMake(35.0f, 385.0f, 250.0f, 40.0f)];
    //[self.logInView.usernameField setFrame:CGRectMake(35.0f, 145.0f, 250.0f, 50.0f)];
    //[self.logInView.passwordField setFrame:CGRectMake(35.0f, 195.0f, 250.0f, 50.0f)];
    //[self.fieldsBackground setFrame:CGRectMake(35.0f, 145.0f, 250.0f, 100.0f)];
    
    //[self.logInView.logInButton setTitle:@"登入" forState:UIControlStateNormal];
    //[self.logInView.logInButton setTitle:@"登入" forState:UIControlStateHighlighted];
    //[self.logInView.logInButton setFrame:CGRectMake(35.0f, 240.0f, 250.0f, 40.0f)];
    
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

@end
