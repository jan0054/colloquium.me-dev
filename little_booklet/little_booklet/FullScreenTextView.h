//
//  FullScreenTextView.h
//  cm_math_one
//
//  Created by csjan on 7/29/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FullScreenTextView : UIViewController
@property (strong, nonatomic) IBOutlet UITextView *contentTextView;
- (IBAction)textFieldTapped:(UITapGestureRecognizer *)sender;
@property (strong, nonatomic) IBOutlet UIView *controlBar;
@property (strong, nonatomic) IBOutlet UIButton *exitButton;
- (IBAction)exitButtonTap:(UIButton *)sender;
@property (strong, nonatomic) IBOutlet UIButton *whiteTextButton;
- (IBAction)whiteTextButtonTap:(UIButton *)sender;
@property (strong, nonatomic) IBOutlet UIButton *blackTextButton;
- (IBAction)blackTextButtonTap:(UIButton *)sender;

@property NSString *content;

@end
