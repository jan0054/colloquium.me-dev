//
//  UserOptionsViewController.m
//  SQuInT2015
//
//  Created by Chi-sheng Jan on 1/18/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import "UserOptionsViewController.h"

@interface UserOptionsViewController ()

@end

BOOL keyboard_is_up;
UITextField *activefield;

@implementation UserOptionsViewController
@synthesize person_obj;
@synthesize isnew;
@synthesize background_scroll_view;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    keyboard_is_up = NO;
    //self.webpage_input_textview.delegate = self;
    self.background_scroll_view.delegate = self;
    CGSize scrollContentSize = CGSizeMake(320, 504);
    self.background_scroll_view.contentSize = scrollContentSize;
    [self hide_all];
    
    //styling
    self.view.backgroundColor = [UIColor dark_primary];
    self.email_label.textColor = [UIColor whiteColor];
    self.chat_label.textColor = [UIColor whiteColor];
    self.email_current_label.textColor = [UIColor lightGrayColor];
    self.chat_current_label.textColor = [UIColor lightGrayColor];
    self.user_status_label.textColor = [UIColor whiteColor];
    self.webpage_content_label.textColor = [UIColor whiteColor];
    self.webpage_title_label.textColor = [UIColor whiteColor];
    self.webpage_input_textview.tintColor = [UIColor whiteColor];
    [self.confirm_attendee_button setTitleColor:[UIColor light_button_txt] forState:UIControlStateNormal];
    [self.confirm_attendee_button setTitleColor:[UIColor light_button_txt] forState:UIControlStateHighlighted];
    [self.confirm_attendee_button setBackgroundColor:[UIColor accent_color]];
    self.confirm_attendee_button.layer.cornerRadius = 2;
    [self.not_attendee_button setTitleColor:[UIColor light_button_txt] forState:UIControlStateNormal];
    [self.not_attendee_button setTitleColor:[UIColor light_button_txt] forState:UIControlStateHighlighted];
    [self.not_attendee_button setBackgroundColor:[UIColor accent_color]];
    self.not_attendee_button.layer.cornerRadius = 2;
    self.or_label.textColor = [UIColor whiteColor];

    //add shadow to views
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:self.confirm_attendee_button.bounds];
    self.confirm_attendee_button.layer.masksToBounds = NO;
    self.confirm_attendee_button.layer.shadowColor = [UIColor blackColor].CGColor;
    self.confirm_attendee_button.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
    self.confirm_attendee_button.layer.shadowOpacity = 0.3f;
    self.confirm_attendee_button.layer.shadowPath = shadowPath.CGPath;
    UIBezierPath *shadowPath1 = [UIBezierPath bezierPathWithRect:self.confirm_attendee_button.bounds];
    self.not_attendee_button.layer.masksToBounds = NO;
    self.not_attendee_button.layer.shadowColor = [UIColor blackColor].CGColor;
    self.not_attendee_button.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
    self.not_attendee_button.layer.shadowOpacity = 0.3f;
    self.not_attendee_button.layer.shadowPath = shadowPath1.CGPath;
    
    [self process_info];
}

- (void) process_info
{
    //isnew=1 is new account creation, isnew=0 is change preference from settings menu
    if (self.isnew == 1)
    {
        PFUser *self_user = [PFUser currentUser];
        NSString *user_email_str = self_user.email;
        PFQuery *person_query = [PFQuery queryWithClassName:@"Person"];
        [person_query whereKey:@"email" equalTo:user_email_str];
        [person_query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            if (object != nil)
            {
                NSLog(@"FOUND A MATCH");
                //we have a matching person, this is a registered attendee
                NSString *welcometext = [NSString stringWithFormat:@"Hello %@ %@, please set your preferences and info below, you can change these anytime.", object[@"first_name"], object[@"last_name"]];
                self.user_status_label.text = welcometext;
                self_user[@"is_person"] = @1;
                self_user[@"chat_status"] = @1;
                self_user[@"email_status"] = @0;
                self_user[@"person"] = object;
                [self_user saveInBackground];
                person_obj = object;
                person_obj[@"chat_status"] = @1;
                person_obj[@"email_status"] = @0;
                person_obj[@"user"] = self_user;
                person_obj[@"is_user"] = @1;
                [person_obj saveInBackground];
                
                [self show_web_hide_attendence];
                
                NSString *linkstr = person_obj[@"link"];
                if ( linkstr == (id)[NSNull null] ||linkstr.length == 0 )
                {
                    //no webpage, do nothing
                }
                else
                {
                    //already has webpage, display it
                    self.webpage_input_textview.text = linkstr;
                }
            }
            else
            {
                NSLog(@"NO MATCHES FOUND");
                // no matches for email, this is not an attendee
                self.user_status_label.text = @"Hello, if you are an event attendee, please confirm using the button below. You can then connect with other attendees.";
                //set "user is not a person"
                self_user[@"is_person"] = @0;
                [self_user saveInBackground];
                
                [self hide_web_show_attendence];
            }
        }];
    }
    else if (self.isnew != 1)
    {
        PFUser *self_user = [PFUser currentUser];
        NSString *user_email_str = self_user.email;
        PFQuery *person_query = [PFQuery queryWithClassName:@"Person"];
        [person_query whereKey:@"email" equalTo:user_email_str];
        [person_query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            if (object != nil)
            {
                NSLog(@"FOUND A MATCH");
                //we have a matching person, this is a registered attendee
                NSString *welcometext = [NSString stringWithFormat:@"Hello %@ %@, please set your preferences and info below, then tap Done to leave this page.", object[@"first_name"], object[@"last_name"]];
                self.user_status_label.text = welcometext;
                person_obj = object;
                NSNumber *per_email_num = person_obj[@"email_status"];
                NSNumber *per_chat_num = person_obj[@"chat_status"];
                int per_email = [per_email_num intValue];
                int per_chat = [per_chat_num intValue];
                
                if (per_email == 1)
                {
                    //email was set to on
                    [self.email_switch setOn:YES animated:FALSE];
                    self.email_current_label.text = @"Current: On";
                }
                else
                {
                    //email was set to off
                    [self.email_switch setOn:FALSE animated:FALSE];
                    self.email_current_label.text = @"Current: Off";
                }
                
                if (per_chat == 1)
                {
                    //chat was set to on
                    [self.chat_switch setOn:YES animated:FALSE];
                    self.chat_current_label.text = @"Current: On";
                }
                else
                {
                    //chat was set to off
                    [self.chat_switch setOn:FALSE animated:FALSE];
                    self.chat_current_label.text = @"Current: Off";
                }
                
                [self show_web_hide_attendence];
                
                NSString *linkstr = person_obj[@"link"];
                if ( linkstr == (id)[NSNull null] ||linkstr.length == 0 )
                {
                    //no webpage, do nothing
                }
                else
                {
                    //already has webpage, display it
                    self.webpage_input_textview.text = linkstr;
                }
            }
            else
            {
                NSLog(@"NO MATCHES FOUND");
                // no matches for email, this is not an attendee
                self.user_status_label.text = @"Hello, if you are an event attendee, please confirm using the button below. You can then connect with other attendees.";
                //set "user is not a person"
                self_user[@"is_person"] = @0;
                [self_user saveInBackground];
                
                [self hide_web_show_attendence];
            }
        }];
    }

}

#pragma mark - User Interface

- (void) hide_web_show_attendence {
    //hide webpage controls
    self.webpage_content_label.hidden = YES;
    self.webpage_input_textview.hidden = YES;
    self.webpage_title_label.hidden = YES;
    self.chat_switch.hidden = YES;
    self.chat_label.hidden = YES;
    self.chat_current_label.hidden = YES;
    self.email_switch.hidden = YES;
    self.email_label.hidden = YES;
    self.email_current_label.hidden = YES;
    self.setup_done_button.enabled = NO;
    //display attendence controls
    self.confirm_attendee_button.hidden = NO;
    self.confirm_attendee_button.userInteractionEnabled = YES;
    self.first_name_input.hidden = NO;
    self.last_name_input.hidden = NO;
    self.institution_input.hidden = NO;
    self.not_attendee_button.hidden = NO;
    self.not_attendee_button.userInteractionEnabled = YES;
    self.or_label.hidden = NO;
}

- (void) show_web_hide_attendence {
    //display webpage controls
    self.webpage_content_label.hidden = FALSE;
    self.webpage_input_textview.hidden = FALSE;
    self.webpage_title_label.hidden = FALSE;
    self.chat_switch.hidden = NO;
    self.chat_label.hidden = NO;
    self.chat_current_label.hidden = NO;
    self.email_switch.hidden = NO;
    self.email_label.hidden = NO;
    self.email_current_label.hidden = NO;
    self.setup_done_button.enabled = YES;
    //hide attendence controls
    self.confirm_attendee_button.hidden = YES;
    self.confirm_attendee_button.userInteractionEnabled = NO;
    self.first_name_input.hidden = YES;
    self.last_name_input.hidden = YES;
    self.institution_input.hidden = YES;
    self.not_attendee_button.hidden = YES;
    self.not_attendee_button.userInteractionEnabled = NO;
    self.or_label.hidden = YES;
}

- (void) hide_all
{
    //hide webpage controls
    self.webpage_content_label.hidden = YES;
    self.webpage_input_textview.hidden = YES;
    self.webpage_title_label.hidden = YES;
    self.chat_switch.hidden = YES;
    self.chat_label.hidden = YES;
    self.chat_current_label.hidden = YES;
    self.email_switch.hidden = YES;
    self.email_label.hidden = YES;
    self.email_current_label.hidden = YES;
    //hide attendence controls
    self.confirm_attendee_button.hidden = YES;
    self.confirm_attendee_button.userInteractionEnabled = NO;
    self.first_name_input.hidden = YES;
    self.last_name_input.hidden = YES;
    self.institution_input.hidden = YES;
    self.not_attendee_button.hidden = YES;
    self.not_attendee_button.userInteractionEnabled = NO;
    self.or_label.hidden = YES;
}

- (IBAction)setup_done_button_tap:(UIBarButtonItem *)sender {
    if (self.webpage_input_textview.text == (id)[NSNull null] || self.webpage_input_textview.text.length == 0)
    {
        //url empty, delete the field
        NSLog(@"URL EMPTY");
        if (self.webpage_input_textview.hidden == FALSE)
        {
            person_obj[@"link"] = @"";
            [person_obj saveInBackground];
        }
    }
    else
    {
        person_obj[@"link"] = self.webpage_input_textview.text;
        [person_obj saveInBackground];
        NSLog(@"URL UPDATED");
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)email_changed:(UISwitch *)sender {
    PFUser *self_user = [PFUser currentUser];
    if (self.email_switch.on)
    {
        NSLog(@"EMAIL SWITCH ON");
        //switched email sharing to on
        person_obj[@"email_status"] = @1;
        self_user[@"email_status"] = @1;
        [person_obj saveInBackground];
        [self_user saveInBackground];
        self.email_current_label.text = @"Current: On";
    }
    else
    {
        NSLog(@"EMAIL SWITCH OFF");
        //switched email sharing to off
        person_obj[@"email_status"] = @0;
        self_user[@"email_status"] = @0;
        [person_obj saveInBackground];
        [self_user saveInBackground];
        self.email_current_label.text = @"Current: Off";
    }
}

- (IBAction)chat_changed:(UISwitch *)sender {
    PFUser *self_user = [PFUser currentUser];
    if (self.chat_switch.on)
    {
        NSLog(@"CHAT SWITCH ON");
        //switched email sharing to on
        person_obj[@"chat_status"] = @1;
        self_user[@"chat_status"] = @1;
        [person_obj saveInBackground];
        [self_user saveInBackground];
        self.chat_current_label.text = @"Current On";
        
        // Associate the device with a user
        PFInstallation *installation = [PFInstallation currentInstallation];
        installation[@"user"] = [PFUser currentUser];
        [installation saveInBackground];
        NSLog(@"USER INSTALLATION ASSOCIATED");
    }
    else
    {
        NSLog(@"CHAT SWITCH OFF");
        //switched email sharing to off
        person_obj[@"chat_status"] = @0;
        self_user[@"chat_status"] = @0;
        [person_obj saveInBackground];
        [self_user saveInBackground];
        self.chat_current_label.text = @"Current Off";
        
        // Disassociate the device
        PFInstallation *installation = [PFInstallation currentInstallation];
        [installation removeObjectForKey:@"user"];
        [installation saveInBackground];
        NSLog(@"USER INSTALLATION DIS-ASSOCIATED: %@", installation.objectId);
    }
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}
- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary* info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    if (!keyboard_is_up)
    {
        NSLog(@"keyboard up");
        // resize the scrollView
        CGRect viewFrame = self.background_scroll_view.frame;
        viewFrame.size.height -= kbSize.height;
        [self.background_scroll_view setFrame:viewFrame];
        float kh = kbSize.height;
        NSLog(@"KEYBOARD:%f", kh);
        float view_height = self.view.frame.size.height;
        float text_height = self.webpage_input_textview.frame.size.height;
        float text_y = self.webpage_input_textview.frame.origin.y;
        float move_distance = text_y - (view_height - (kbSize.height+text_height));
        if (move_distance > 0)
        {
            UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, move_distance, 0.0);
            self.background_scroll_view.contentInset = contentInsets;
            self.background_scroll_view.scrollIndicatorInsets = contentInsets;
        }
        keyboard_is_up = YES;
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary* info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    if (keyboard_is_up)
    {
        NSLog(@"keyboard down");
        
        // resize the scrollView
        CGRect viewFrame = self.background_scroll_view.frame;
        viewFrame.size.height += kbSize.height;
        [self.background_scroll_view setFrame:viewFrame];
        
        UIEdgeInsets contentInsets = UIEdgeInsetsZero;
        self.background_scroll_view.contentInset = contentInsets;
        self.background_scroll_view.scrollIndicatorInsets = contentInsets;
        
        keyboard_is_up = NO;
    }
}

- (IBAction)confirm_attendee_button_tap:(UIButton *)sender {
    if (self.first_name_input.text.length>0 && self.last_name_input.text.length>0 && self.institution_input.text.length>0)
    {
        self.confirm_attendee_button.enabled = NO;
        self.confirm_attendee_button.userInteractionEnabled = NO;
        [self create_person];
    }
}

- (void) create_person
{
    PFUser *cur_user = [PFUser currentUser];
    NSString *email = cur_user[@"email"];
    cur_user[@"is_person"] = @1;
    cur_user[@"chat_status"] = @1;
    PFObject *person = [PFObject objectWithClassName:@"Person"];
    person[@"user"] = cur_user;
    person[@"is_user"] = @1;
    person[@"chat_status"] = @1;
    person[@"email"] = email;
    person[@"first_name"] = self.first_name_input.text;
    person[@"last_name"] = self.last_name_input.text;
    person[@"institution"] = self.institution_input.text;
    //after completion, call the method to close signup view and go to user options view
    [person saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded)
        {
            NSLog(@"new person created successfully");
            cur_user[@"person"] = person;
            [cur_user saveInBackground];
            [self process_info];
            self.confirm_attendee_button.enabled = YES;
            self.confirm_attendee_button.userInteractionEnabled = YES;
        }
        else
        {
            NSLog(@"new person creation error");
            self.confirm_attendee_button.enabled = YES;
            self.confirm_attendee_button.userInteractionEnabled = YES;
        }
    }];

}

- (IBAction)not_attendee_button_tap:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
