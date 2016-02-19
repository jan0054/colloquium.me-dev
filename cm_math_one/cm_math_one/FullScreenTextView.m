//
//  FullScreenTextView.m
//  cm_math_one
//
//  Created by csjan on 7/29/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import "FullScreenTextView.h"

@interface FullScreenTextView ()

@end

BOOL barIsVisible;

@implementation FullScreenTextView
@synthesize content;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //initial state of the bottom control bar
    barIsVisible = YES;
    self.controlBar.hidden = NO;
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 8;
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue" size:17.0];
    self.contentTextView.attributedText = [[NSAttributedString alloc]
                               initWithString:@"Predefined Text"
                                           attributes:@{NSParagraphStyleAttributeName : style,
                                                        NSFontAttributeName : font }];
    self.contentTextView.text = self.content;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL preferBlack = [defaults boolForKey:@"preferblack"];
    if (preferBlack)
    {
        self.contentTextView.textColor = [UIColor blackColor];
        self.contentTextView.backgroundColor = [UIColor whiteColor];
        self.view.backgroundColor = [UIColor whiteColor];
    }
    else
    {
        self.contentTextView.textColor = [UIColor whiteColor];
        self.contentTextView.backgroundColor = [UIColor blackColor];
        self.view.backgroundColor = [UIColor blackColor];
    }
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)exitOut
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)textFieldTapped:(UITapGestureRecognizer *)sender {
    if (barIsVisible)
    {
        self.controlBar.hidden = YES;
        barIsVisible = NO;
    }
    else
    {
        self.controlBar.hidden = NO;
        barIsVisible = YES;
    }
}

- (IBAction)exitButtonTap:(UIButton *)sender {
    [self exitOut];
}

- (IBAction)whiteTextButtonTap:(UIButton *)sender {
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 8;
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue" size:17.0];
    self.contentTextView.attributedText = [[NSAttributedString alloc]
                                           initWithString:@"Predefined Text"
                                           attributes:@{NSParagraphStyleAttributeName : style,
                                                        NSFontAttributeName : font }];
    self.contentTextView.text = self.content;

    [self.contentTextView setTextColor:[UIColor whiteColor]];
    self.contentTextView.backgroundColor = [UIColor blackColor];
    self.view.backgroundColor = [UIColor blackColor];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:NO forKey:@"preferblack"];
    [defaults synchronize];
}

- (IBAction)blackTextButtonTap:(UIButton *)sender {
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 8;
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue" size:17.0];
    self.contentTextView.attributedText = [[NSAttributedString alloc]
                                           initWithString:@"Predefined Text"
                                           attributes:@{NSParagraphStyleAttributeName : style,
                                                        NSFontAttributeName : font }];
    self.contentTextView.text = self.content;

    [self.contentTextView setTextColor:[UIColor blackColor]];
    self.contentTextView.backgroundColor = [UIColor whiteColor];
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:YES forKey:@"preferblack"];
    [defaults synchronize];
}

@end
