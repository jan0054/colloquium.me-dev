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
#import "PasswordResetView.h"

UIButton *resetButton;
UIImageView *bgView;

@implementation LoginView
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    bgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 50, 50)];
    [self.view addSubview:bgView];
    [self.view sendSubviewToBack:bgView];

    [self.logInView setLogo:[[UIImageView alloc] initWithImage:nil]];
    
    UIImage *img = [UIImage imageNamed:@"cancel48"];
    img = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.logInView.dismissButton setTintColor:[UIColor whiteColor]];
    [self.logInView.dismissButton setTitle:NSLocalizedString(@"skip_button", nil) forState:UIControlStateNormal];
    [self.logInView.dismissButton setTitle:NSLocalizedString(@"skip_button", nil) forState:UIControlStateHighlighted];
    [self.logInView.dismissButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.logInView.dismissButton setBackgroundColor:[UIColor clearColor]] ;
    [self.logInView.dismissButton setImage:nil forState:UIControlStateNormal];
    [self.logInView.dismissButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:13.0]];
    NSMutableAttributedString *attributeStringSkip = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"skip_button", nil)];
    [attributeStringSkip addAttribute:NSUnderlineStyleAttributeName
                            value:[NSNumber numberWithInt:1]
                            range:(NSRange){0,[attributeStringSkip length]}];
    [self.logInView.dismissButton.titleLabel setAttributedText:attributeStringSkip];
    self.logInView.dismissButton.titleLabel.textAlignment = NSTextAlignmentRight;
    
    [self.logInView.signUpButton setBackgroundColor:[UIColor setup_button_background]];
    [self.logInView.signUpButton setBackgroundImage:nil forState:UIControlStateNormal];
    [self.logInView.signUpButton setBackgroundImage:nil forState:UIControlStateHighlighted];
    [self.logInView.signUpButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:15.0]];
    [self.logInView.logInButton setBackgroundColor:[UIColor setup_button_background]];
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
    
    //welcome label (deprecated)
    /*
    UILabel *notice_label = [[UILabel alloc] initWithFrame:CGRectMake(40, 95, 280, 60)];
    [notice_label setBackgroundColor:[UIColor clearColor]];
    [notice_label setTextColor:[UIColor whiteColor]];
    [notice_label setText:NSLocalizedString(@"login_welcome", nil)];
    [notice_label setFont:[UIFont fontWithName:@"HelveticaNeue" size:15.0]];
    [notice_label setLineBreakMode:NSLineBreakByWordWrapping];
    notice_label.numberOfLines = 0;
    [self.view addSubview:notice_label];
    */
    
    //[self.logInView setLogo:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"squint_logo_blue"]]];
    //self.logInView.signUpLabel.text = @"Sign up if you don't have an account";
    //[self.logInView.facebookButton setBackgroundColor:[UIColor colorWithRed:0.23 green:0.35 blue:0.59 alpha:1]];
    //[self.logInView.facebookButton setBackgroundImage:nil forState:UIControlStateNormal];
    //[self.logInView.facebookButton setBackgroundImage:nil forState:UIControlStateHighlighted];
    

    //[self.logInView.passwordForgottenButton setBackgroundImage:[UIImage imageNamed:@"noreply.png"] forState:UIControlStateNormal];
    //[self.logInView.passwordForgottenButton setBackgroundImage:[UIImage imageNamed:@"noreply.png"] forState:UIControlStateHighlighted];
    //[self.logInView.passwordForgottenButton setBackgroundColor:[UIColor clearColor]];
    self.logInView.usernameField.placeholder=NSLocalizedString(@"email", nil);
    self.logInView.passwordField.placeholder=NSLocalizedString(@"login_pass_hint", nil);
    
    //change keyboard type for the email field
    self.logInView.usernameField.keyboardType = UIKeyboardTypeEmailAddress;
    
    //reset button
    resetButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [resetButton setBackgroundColor:[UIColor clearColor]];
    [resetButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [resetButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [resetButton addTarget:self action:@selector(goToResetView:) forControlEvents:UIControlEventTouchUpInside];
    [resetButton setTitle:NSLocalizedString(@"pass_reset", nil) forState:UIControlStateNormal];
    [resetButton setTitle:NSLocalizedString(@"pass_reset", nil) forState:UIControlStateHighlighted];
    
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"pass_reset", nil)];
    [attributeString addAttribute:NSUnderlineStyleAttributeName
                            value:[NSNumber numberWithInt:1]
                            range:(NSRange){0,[attributeString length]}];
    
    [resetButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:13.0]];
    [resetButton.titleLabel setAttributedText:attributeString];
    [resetButton.titleLabel setTextAlignment:NSTextAlignmentLeft];
    [resetButton setTitleEdgeInsets:UIEdgeInsetsZero];
    [self.view addSubview:resetButton];
    [self.view setNeedsLayout];
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [bgView setFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height)];
    UIImage *bgRaw = [UIImage imageNamed:@"launchSplashEvent"];
    UIImage *bgImage = [self imageWithImage:bgRaw convertToSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height)];
    NSLog(@"BG SIZE:%f, %f", self.view.frame.size.width, self.view.frame.size.height);
    bgView.image = bgImage;
    [bgView setContentMode:UIViewContentModeScaleToFill];
    
    // Set frame for elements
    float loginy = self.logInView.logInButton.frame.origin.y;
    float loginx = self.logInView.logInButton.frame.origin.x;
    float loginh = self.logInView.logInButton.frame.size.height;
    float loginw = self.logInView.logInButton.frame.size.width;
    
    float signupy = self.logInView.signUpButton.frame.origin.y;
    float signupx = self.logInView.signUpButton.frame.origin.x;
    float signuph = self.logInView.signUpButton.frame.size.height;
    float signupw = self.logInView.signUpButton.frame.size.width;
    
    float fby = self.logInView.facebookButton.frame.origin.y;
    float fbx = self.logInView.facebookButton.frame.origin.x;
    float fbh = self.logInView.facebookButton.frame.size.height;
    float fbw = self.logInView.facebookButton.frame.size.width;
    
    float uny = self.logInView.usernameField.frame.origin.y;
    float unx = self.logInView.usernameField.frame.origin.x;
    float unh = self.logInView.usernameField.frame.size.height;
    float unw = self.logInView.usernameField.frame.size.width;
    
    float upy = self.logInView.passwordField.frame.origin.y;
    float upx = self.logInView.passwordField.frame.origin.x;
    float uph = self.logInView.passwordField.frame.size.height;
    float upw = self.logInView.passwordField.frame.size.width;
    
    //optional layout with skip and reset password side by side
    //[self.logInView.dismissButton setFrame:CGRectMake(fbx+fbw-(loginw*1/4), (loginy+loginh+fby)/2-loginh*1/4, (loginw*1/4), (loginh*1/2))];
    //[resetButton setFrame:CGRectMake(fbx , (loginy+loginh+fby)/2-loginh*1/4, (loginw*1/3), (loginh*1/2))];
    
    [resetButton setFrame:CGRectMake(fbx+fbw/2-loginw/6 , (loginy+loginh+fby)/2-loginh*1/4, (loginw*1/3), (loginh*1/2))];
    [self.logInView.dismissButton setFrame:CGRectMake(unx+unw-loginw/5, uny-loginh/2-4, (loginw*1/5), (loginh*1/2))];
    [self.logInView.logInButton setFrame:CGRectMake(fbx, loginy, fbw, fbh)];
    [self.logInView.usernameField setFrame:CGRectMake(fbx, uny, fbw, unh)];
    [self.logInView.passwordField setFrame:CGRectMake(fbx, upy, fbw, uph)];
    
    //[self.logInView.logo setFrame:CGRectMake(140, 70, 40, 40)];
    //[self.logInView.passwordForgottenButton setFrame:CGRectMake(288, 263, 24, 24)];
    //[self.logInView.facebookButton setFrame:CGRectMake(35.0f, 287.0f, 120.0f, 40.0f)];
    //[self.logInView.twitterButton setFrame:CGRectMake(35.0f+130.0f, 287.0f, 120.0f, 40.0f)];
    //[self.logInView.signUpButton setFrame:CGRectMake(35.0f, 385.0f, 250.0f, 40.0f)];
    //[self.logInView.usernameField setFrame:CGRectMake(35.0f, 145.0f, 250.0f, 50.0f)];
    //[self.logInView.passwordField setFrame:CGRectMake(35.0f, 195.0f, 250.0f, 50.0f)];
    //[self.fieldsBackground setFrame:CGRectMake(35.0f, 145.0f, 250.0f, 100.0f)];
    
    [self.logInView.logInButton setTitle:NSLocalizedString(@"login_button", nil) forState:UIControlStateNormal];
    [self.logInView.logInButton setTitle:NSLocalizedString(@"login_button", nil) forState:UIControlStateHighlighted];
    [self.logInView.signUpButton setTitle:NSLocalizedString(@"to_signup", nil) forState:UIControlStateNormal];
    [self.logInView.signUpButton setTitle:NSLocalizedString(@"to_signup", nil) forState:UIControlStateHighlighted];
    [self.logInView.facebookButton setTitle:NSLocalizedString(@"fb_login", nil) forState:UIControlStateNormal];
    [self.logInView.facebookButton setTitle:NSLocalizedString(@"fb_login", nil) forState:UIControlStateHighlighted];
    //[self.logInView.logInButton setFrame:CGRectMake(35.0f, 240.0f, 250.0f, 40.0f)];
    
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)goToResetView: (id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PasswordResetView *controller = (PasswordResetView *)[storyboard instantiateViewControllerWithIdentifier:@"reset_vc"];
    [self presentViewController:controller animated:YES completion:nil];
}

- (UIImage *)imageWithImage:(UIImage *)image convertToSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return destImage;
}

@end
