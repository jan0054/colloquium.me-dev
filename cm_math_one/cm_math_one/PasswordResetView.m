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

@implementation PasswordResetView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //styling
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"launchSplashEvent"]];
    self.welcomeLabel.textColor = [UIColor whiteColor];
    [self.resetButton setBackgroundColor:[UIColor accent_color]];
    [self.cancelButton setBackgroundColor:[UIColor accent_color]];
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


@end
