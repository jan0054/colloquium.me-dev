//
//  UserPreferenceView.m
//  cm_math_one
//
//  Created by csjan on 6/24/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import "UserPreferenceView.h"

@implementation UserPreferenceView

- (IBAction)savePreferenceButtonTap:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cancelPreferenceButtonTap:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
