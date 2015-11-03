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

@implementation SignUpView
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor dark_primary];
    //self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
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
    
    UILabel *notice_label = [[UILabel alloc] initWithFrame:CGRectMake(20, 95, 280, 90)];
    [notice_label setBackgroundColor:[UIColor clearColor]];
    [notice_label setTextColor:[UIColor whiteColor]];
    [notice_label setText:NSLocalizedString(@"signup_welcome", nil)];
    [notice_label setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:15.0]];
    [notice_label setLineBreakMode:NSLineBreakByWordWrapping];
    notice_label.numberOfLines = 0;
    [self.view addSubview:notice_label];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    float signupy = self.signUpView.signUpButton.frame.origin.y;
    float signupx = self.signUpView.signUpButton.frame.origin.x;
    float signuph = self.signUpView.signUpButton.frame.size.height;
    float signupw = self.signUpView.signUpButton.frame.size.width;
    
    [self.signUpView.dismissButton setFrame:CGRectMake(signupx+signupw*0.25, signupy+signuph+40, signupw*0.5, signuph*0.75)];
    
    [self.signUpView.signUpButton setTitle:NSLocalizedString(@"signup_button", nil) forState:UIControlStateNormal];
    [self.signUpView.signUpButton setTitle:NSLocalizedString(@"signup_button", nil) forState:UIControlStateHighlighted];

    
    
}

@end
