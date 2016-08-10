//
//  PasswordResetView.h
//  cm_math_one
//
//  Created by csjan on 11/2/15.
//  Copyright © 2015 tapgo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PasswordResetView : UIViewController
@property (strong, nonatomic) IBOutlet UILabel *welcomeLabel;
@property (strong, nonatomic) IBOutlet UITextField *emailTextField;
@property (strong, nonatomic) IBOutlet UIButton *resetButton;
@property (strong, nonatomic) IBOutlet UIButton *cancelButton;
- (IBAction)resetButtonTap:(UIButton *)sender;
- (IBAction)cancelButtonTap:(UIButton *)sender;

@end
