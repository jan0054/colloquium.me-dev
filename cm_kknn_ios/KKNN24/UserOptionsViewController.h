//
//  UserOptionsViewController.h
//  SQuInT2015
//
//  Created by Chi-sheng Jan on 1/18/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

#import "UIColor+ProjectColors.h"

@interface UserOptionsViewController : UIViewController<UITextFieldDelegate, UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *user_status_label;
@property (weak, nonatomic) IBOutlet UILabel *email_label;
@property (weak, nonatomic) IBOutlet UILabel *chat_label;
@property (weak, nonatomic) IBOutlet UISwitch *email_switch;
@property (weak, nonatomic) IBOutlet UISwitch *chat_switch;
@property (weak, nonatomic) IBOutlet UILabel *email_current_label;
@property (weak, nonatomic) IBOutlet UILabel *chat_current_label;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *setup_done_button;
- (IBAction)setup_done_button_tap:(UIBarButtonItem *)sender;
- (IBAction)email_changed:(UISwitch *)sender;
- (IBAction)chat_changed:(UISwitch *)sender;

@property PFObject *person_obj;
@property int isnew;

@property (strong, nonatomic) IBOutlet UILabel *webpage_title_label;
@property (strong, nonatomic) IBOutlet UILabel *webpage_content_label;
@property (strong, nonatomic) IBOutlet UITextField *webpage_input_textview;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *textfieldbottom;
@property (strong, nonatomic) IBOutlet UIScrollView *background_scroll_view;
@property (weak, nonatomic) IBOutlet UIButton *confirm_attendee_button;

- (IBAction)confirm_attendee_button_tap:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UITextField *first_name_input;
@property (weak, nonatomic) IBOutlet UITextField *last_name_input;
@property (weak, nonatomic) IBOutlet UITextField *institution_input;

@property (weak, nonatomic) IBOutlet UILabel *or_label;
@property (weak, nonatomic) IBOutlet UIButton *not_attendee_button;
- (IBAction)not_attendee_button_tap:(UIButton *)sender;


@end
