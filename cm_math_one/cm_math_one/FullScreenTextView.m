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

@implementation FullScreenTextView
@synthesize content;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.contentTextView.text = self.content;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)exitOut
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)textFieldTapped:(UITapGestureRecognizer *)sender {
    [self exitOut];
}

@end
