//
//  AboutUsView.m
//  cm_math_one
//
//  Created by csjan on 7/7/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import "AboutUsView.h"
#import "UIColor+ProjectColors.h"

@interface AboutUsView ()

@end

@implementation AboutUsView

- (void)viewDidLoad {
    [super viewDidLoad];
    //styling
}

- (IBAction)contactButtonTap:(UIButton *)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto://jan0054@gmail.com"]];
}

- (IBAction)doneButtonTap:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
