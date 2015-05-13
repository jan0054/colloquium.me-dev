//
//  FeedbackTabViewController.h
//  SQuInt2014
//
//  Created by csjan on 4/17/14.
//  Copyright (c) 2014 tapgo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <Parse/Parse.h>
#import "SettingLoginCellTableViewCell.h"
#import "SettingPushCellTableViewCell.h"
#import "GeneralSettingCellTableViewCell.h"
#import "CustomLogInViewController.h"
#import "CustomSignUpViewController.h"
#import "UserPreferenceTableViewCell.h"

@interface FeedbackTabViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITableView *settingstable;
- (IBAction)login_button_tap:(UIButton *)sender;
- (IBAction)preference_change_button_tap:(UIButton *)sender;
- (IBAction)notification_switch_action:(UISwitch *)sender;

@end
