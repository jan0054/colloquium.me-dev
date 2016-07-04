//
//  PasswordResetView.m
//  cm_math_one
//
//  Created by csjan on 11/2/15.
//  Copyright © 2015 tapgo. All rights reserved.
//

#import "PasswordResetView.h"
#import "UIColor+ProjectColors.h"
#import <Parse/Parse.h>

UIImageView *bgImageView;

@implementation PasswordResetView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 50, 50)];
    [self.view addSubview:bgImageView];
    [self.view sendSubviewToBack:bgImageView];
    [bgImageView setFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height)];
    UIImage *bgRaw = [UIImage imageNamed:@"launchSplashEvent"];
    UIImage *bgImage = [self imageWithImage:bgRaw convertToSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height)];
    NSLog(@"BG SIZE:%f, %f", self.view.frame.size.width, self.view.frame.size.height);
    bgImageView.image = bgImage;
    [bgImageView setContentMode:UIViewContentModeScaleToFill];

    
    //styling
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"launchSplashEvent"]];
    self.welcomeLabel.textColor = [UIColor whiteColor];
    [self.resetButton setBackgroundColor:[UIColor setup_button_background]];
    [self.cancelButton setBackgroundColor:[UIColor setup_button_background]];
    [self.resetButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.resetButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [self.cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    self.welcomeLabel.text = NSLocalizedString(@"reset_welcome", nil);
    [self.resetButton setTitle:NSLocalizedString(@"reset_button", nil) forState:UIControlStateNormal];
    [self.resetButton setTitle:NSLocalizedString(@"reset_button", nil) forState:UIControlStateHighlighted];
    [self.cancelButton setTitle:NSLocalizedString(@"reset_cancel", nil) forState:UIControlStateNormal];
    [self.cancelButton setTitle:NSLocalizedString(@"reset_cancel", nil) forState:UIControlStateHighlighted];
    self.emailTextField.layer.cornerRadius = 0;
    self.emailTextField.backgroundColor = [UIColor whiteColor];
    //change keyboard type for the email field
    self.emailTextField.keyboardType = UIKeyboardTypeEmailAddress;
    
    //small hack to get a text inset on the borderless textfield
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, self.emailTextField.frame.size.height)];
    leftView.backgroundColor = self.emailTextField.backgroundColor;
    self.emailTextField.leftView = leftView;
    self.emailTextField.leftViewMode = UITextFieldViewModeAlways;
}

- (IBAction)resetButtonTap:(UIButton *)sender {
    NSString *emailString = self.emailTextField.text;
    if (emailString.length >3)
    {
        [PFUser requestPasswordResetForEmailInBackground:emailString];
        [[[UIAlertView alloc] initWithTitle:@""
                                    message:NSLocalizedString(@"alert_reset_done", nil)
                                   delegate:nil
                          cancelButtonTitle:NSLocalizedString(@"alert_done", nil)
                          otherButtonTitles:nil] show];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)cancelButtonTap:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UIImage *)imageWithImage:(UIImage *)image convertToSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return destImage;
}



@end
