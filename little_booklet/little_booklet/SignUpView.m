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
UIImageView *bgView1;

@implementation SignUpView


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    bgView1 = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 50, 50)];
    [self.view addSubview:bgView1];
    [self.view sendSubviewToBack:bgView1];

    [self.signUpView setLogo:[[UIImageView alloc] initWithImage:nil]];
    
    [self.signUpView.dismissButton setTintColor:[UIColor whiteColor]];
    [self.signUpView.dismissButton setTitle:NSLocalizedString(@"signup_back", nil) forState:UIControlStateNormal];
    [self.signUpView.dismissButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.signUpView.dismissButton setBackgroundColor:[UIColor setup_button_background]] ;
    [self.signUpView.dismissButton setImage:nil forState:UIControlStateNormal];
    [self.signUpView.dismissButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:15.0]];
    
    [self.signUpView.signUpButton setBackgroundColor:[UIColor setup_button_background]];
    [self.signUpView.signUpButton setBackgroundImage:nil forState:UIControlStateNormal];
    [self.signUpView.signUpButton setBackgroundImage:nil forState:UIControlStateHighlighted];
    [self.signUpView.signUpButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:15.0]];
    
    [self.signUpView.usernameField setBackgroundColor:[UIColor whiteColor]];
    [self.signUpView.passwordField setBackgroundColor:[UIColor whiteColor]];
    [self.signUpView.emailField setBackgroundColor:[UIColor whiteColor]];
    
    [self.signUpView.usernameField setTextColor:[UIColor darkGrayColor]];
    [self.signUpView.passwordField setTextColor:[UIColor darkGrayColor]];
    [self.signUpView.emailField setTextColor:[UIColor darkGrayColor]];
    
    self.signUpView.emailField.placeholder = NSLocalizedString(@"email", nil);
    self.signUpView.passwordField.placeholder = NSLocalizedString(@"signup_pass_hint", nil);
    
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
    
    //background image stuff
    [bgView1 setFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height)];
    UIImage *bgRaw = [UIImage imageNamed:@"launchSplashEvent"];
    UIImage *bgImage = [self imageWithImage:bgRaw convertToSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height)];
    NSLog(@"BG SIZE:%f, %f", self.view.frame.size.width, self.view.frame.size.height);
    bgView1.image = bgImage;
    [bgView1 setContentMode:UIViewContentModeScaleToFill];
    
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
    
    float gap = signupy - upy - uph;

    [self.signUpView.dismissButton setFrame:CGRectMake(signupx, signupy+signuph+gap, signupw, signuph)];
    [noticeLabel setFrame:CGRectMake(unx, uny-90-gap, unw, 90)];
    
    [self.signUpView.signUpButton setTitle:NSLocalizedString(@"signup_button", nil) forState:UIControlStateNormal];
    [self.signUpView.signUpButton setTitle:NSLocalizedString(@"signup_button", nil) forState:UIControlStateHighlighted];
    
}

//helper method to resize background image
- (UIImage *)imageWithImage:(UIImage *)image convertToSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return destImage;
}

@end