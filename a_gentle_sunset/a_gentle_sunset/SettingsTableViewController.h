//
//  SettingsTableViewController.h
//  a_gentle_sunset
//
//  Created by csjan on 3/24/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI.h>

@interface SettingsTableViewController : UITableViewController
@property (strong, nonatomic) IBOutlet UIButton *login_button;
- (IBAction)login_button_tap:(UIButton *)sender;
@property (strong, nonatomic) IBOutlet UIButton *push_button;
- (IBAction)push_button_tap:(UIButton *)sender;

@end
