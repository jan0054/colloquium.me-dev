//
//  CustomSignUpViewController.m
//  SQuInt2014
//
//  Created by csjan on 9/1/14.
//  Copyright (c) 2014 tapgo. All rights reserved.
//

#import "CustomSignUpViewController.h"
#import "UIColor+ProjectColors.h"

@interface CustomSignUpViewController ()

@end

@implementation CustomSignUpViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    //self.view.backgroundColor = [UIColor main_blue];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
    
    //[self.signUpView setLogo:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"squint_logo_blue"]]];
    [self.signUpView setLogo:[[UIImageView alloc] initWithImage:nil]];
    
    [self.signUpView.dismissButton setImage:[UIImage imageNamed:@"cancelwhite.png"] forState:UIControlStateNormal];
    [self.signUpView.dismissButton setImage:[UIImage imageNamed:@"cancelwhite.png"] forState:UIControlStateHighlighted];
    
    [self.signUpView.signUpButton setBackgroundColor:[UIColor shade_blue]];
    [self.signUpView.signUpButton setBackgroundImage:nil forState:UIControlStateNormal];
    [self.signUpView.signUpButton setBackgroundImage:nil forState:UIControlStateHighlighted];
    [self.signUpView.signUpButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:15.0]];
    //[self.signUpView.signUpButton setTitle:@"Sign Up" forState:UIControlStateNormal];
    //[self.signUpView.signUpButton setTitle:@"Sign Up" forState:UIControlStateHighlighted];
    
    // Remove text shadow
    CALayer *layer = self.signUpView.usernameField.layer;
    layer.shadowOpacity = 0.0;
    layer = self.signUpView.passwordField.layer;
    layer.shadowOpacity = 0.0;
    layer = self.signUpView.emailField.layer;
    layer.shadowOpacity = 0.0;
    
    [self.signUpView.usernameField setBackgroundColor:[UIColor whiteColor]];
    [self.signUpView.passwordField setBackgroundColor:[UIColor whiteColor]];
    [self.signUpView.emailField setBackgroundColor:[UIColor whiteColor]];
    
    [self.signUpView.usernameField setTextColor:[UIColor darkGrayColor]];
    [self.signUpView.passwordField setTextColor:[UIColor darkGrayColor]];
    [self.signUpView.emailField setTextColor:[UIColor darkGrayColor]];
    
    //self.signUpView.usernameField.placeholder= @"Username";
    //self.signUpView.passwordField.placeholder=@"Password";
    [self.signUpView.usernameField setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14.0]];
    [self.signUpView.passwordField setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14.0]];
    [self.signUpView.emailField setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14.0]];
    
    UILabel *notice_label = [[UILabel alloc] initWithFrame:CGRectMake(20, 95, 280, 60)];
    [notice_label setBackgroundColor:[UIColor clearColor]];
    [notice_label setTextColor:[UIColor whiteColor]];
    [notice_label setText:@"Please enter all fields correctly."];
    [notice_label setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:15.0]];
    [notice_label setLineBreakMode:NSLineBreakByWordWrapping];
    notice_label.numberOfLines = 0;
    [self.view addSubview:notice_label];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    
}
@end
