//
//  SignUpView.m
//  cm_math_one
//
//  Created by csjan on 6/17/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import "SignUpView.h"
#import <Parse/Parse.h>
#import <ParseUI.h>
#import "UIColor+ProjectColors.h"

UILabel *noticeLabel;

@implementation SignUpView


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"launchSplashEvent"]];
    [self.signUpView setLogo:[[UIImageView alloc] initWithImage:nil]];
    
    [self.signUpView.dismissButton setTintColor:[UIColor whiteColor]];
    [self.signUpView.dismissButton setTitle:NSLocalizedString(@"signup_back", nil) forState:UIControlStateNormal];
    [self.signUpView.dismissButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.signUpView.dismissButton setBackgroundColor:[UIColor accent_color]] ;
    [self.signUpView.dismissButton setImage:nil forState:UIControlStateNormal];
    [self.signUpView.dismissButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:15.0]];
    
    [self.signUpView.signUpButton setBackgroundColor:[UIColor accent_color]];
    [self.signUpView.signUpButton setBackgroundImage:nil forState:UIControlStateNormal];
    [self.signUpView.signUpButton setBackgroundImage:nil forState:UIControlStateHighlighted];
    [self.signUpView.signUpButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:15.0]];
    
    // Remove text shadow
    //CALayer *layer = self.signUpView.usernameField.layer;
    //layer.shadowOpacity = 0.0;
    //layer = self.signUpView.passwordField.layer;
    //layer.shadowOpacity = 0.0;
    //layer = self.signUpView.emailField.layer;
    //layer.shadowOpacity = 0.0;
    
    [self.signUpView.usernameField setBackgroundColor:[UIColor whiteColor]];
    [self.signUpView.passwordField setBackgroundColor:[UIColor whiteColor]];
    [self.signUpView.emailField setBackgroundColor:[UIColor whiteColor]];
    
    [self.signUpView.usernameField setTextColor:[UIColor darkGrayColor]];
    [self.signUpView.passwordField setTextColor:[UIColor darkGrayColor]];
    [self.signUpView.emailField setTextColor:[UIColor darkGrayColor]];
    
    //self.signUpView.usernameField.placeholder= @"Username";
    self.signUpView.emailField.placeholder = NSLocalizedString(@"email", nil);
    self.signUpView.passwordField.placeholder = NSLocalizedString(@"signup_pass_hint", nil);
    //[self.signUpView.usernameField setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14.0]];
    //[self.signUpView.passwordField setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14.0]];
    //[self.signUpView.emailField setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14.0]];
    
    //change keyboard type for the email field
    self.signUpView.emailField.keyboardType = UIKeyboardTypeEmailAddress;
    

    
    noticeLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 90, 320-32, 90)];
    [noticeLabel setBackgroundColor:[UIColor clearColor]];
    [noticeLabel setTextColor:[UIColor whiteColor]];
    [noticeLabel setText:NSLocalizedString(@"signup_welcome", nil)];
    [noticeLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:15.0]];
    [noticeLabel setLineBreakMode:NSLineBreakByWordWrapping];
    noticeLabel.numberOfLines = 0;
    [self.view addSubview:noticeLabel];

    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    float signupy = self.signUpView.signUpButton.frame.origin.y;
    float signupx = self.signUpView.signUpButton.frame.origin.x;
    float signuph = self.signUpView.signUpButton.frame.size.height;
    float signupw = self.signUpView.signUpButton.frame.size.width;
    
    float uny = self.signUpView.usernameField.frame.origin.y;
    float unx = self.signUpView.usernameField.frame.origin.x;
    float unh = self.signUpView.usernameField.frame.size.height;
    float unw = self.signUpView.usernameField.frame.size.width;
    
    float upy = self.signUpView.passwordField.frame.origin.y;
    float upx = self.signUpView.passwordField.frame.origin.x;
    float uph = self.signUpView.passwordField.frame.size.height;
    float upw = self.signUpView.passwordField.frame.size.width;
    
    [self.signUpView.dismissButton setFrame:CGRectMake(16, signupy+44+(signupy-upy-uph), signupw-32, 44)];
    [self.signUpView.signUpButton setFrame:CGRectMake(16, signupy, signupw-32, 44)];
    [self.signUpView.usernameField setFrame:CGRectMake(16, uny, unw-32, unh)];
    [self.signUpView.passwordField setFrame:CGRectMake(16, upy, upw-32, uph)];
    
    [self.signUpView.signUpButton setTitle:NSLocalizedString(@"signup_button", nil) forState:UIControlStateNormal];
    [self.signUpView.signUpButton setTitle:NSLocalizedString(@"signup_button", nil) forState:UIControlStateHighlighted];
    
    [noticeLabel setFrame:CGRectMake(16, uny/2-45, unw-32, 90)];
    
}

@end