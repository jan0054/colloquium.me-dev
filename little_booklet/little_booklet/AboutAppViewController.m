//
//  AboutAppViewController.m
//  Little Booklet
//
//  Created by Chi-sheng Jan on 8/12/16.
//  Copyright © 2016 tapgo. All rights reserved.
//

#import "AboutAppViewController.h"
#import "UIColor+ProjectColors.h"

@interface AboutAppViewController ()

@end

@implementation AboutAppViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //styling
    [self.doneButton setTitleColor:[UIColor accent_color] forState:UIControlStateNormal];
    [self.contactButton setTitleColor:[UIColor accent_color] forState:UIControlStateNormal];
    [self.doneButton setTitle:NSLocalizedString(@"about_done_button", nil) forState:UIControlStateNormal];
    [self.contactButton setTitle:NSLocalizedString(@"about_contact_button", nil) forState:UIControlStateNormal];
    self.titleLabel.text = NSLocalizedString(@"about_title", nil);
    self.contentLabel.text = NSLocalizedString(@"about_content", nil);
}

- (IBAction)contactButtonTap:(UIButton *)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto://csjan@tapgo.cc"]];
}

- (IBAction)doneButtonTap:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
