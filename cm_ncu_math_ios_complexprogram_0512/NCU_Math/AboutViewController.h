//
//  AboutViewController.h
//  SQuInt2014
//
//  Created by csjan on 9/17/14.
//  Copyright (c) 2014 tapgo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AboutViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIButton *email_us_button;
- (IBAction)email_us_tap:(UIButton *)sender;
@property (strong, nonatomic) IBOutlet UILabel *company_title_label;
@property (strong, nonatomic) IBOutlet UILabel *company_description_label;
@property (strong, nonatomic) IBOutlet UIView *company_background_view;
@property (strong, nonatomic) IBOutlet UILabel *company_description_two_label;
@property (strong, nonatomic) IBOutlet UIView *company_trim_view;

@end
