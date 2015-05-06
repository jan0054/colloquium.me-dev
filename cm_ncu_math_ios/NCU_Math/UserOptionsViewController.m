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
    
    //styling
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
    self.email_label.textColor = [UIColor whiteColor];
    self.chat_label.textColor = [UIColor whiteColor];
    self.email_current_label.textColor = [UIColor lightGrayColor];
    self.chat_current_label.textColor = [UIColor lightGrayColor];
    self.user_status_label.textColor = [UIColor whiteColor];
    self.webpage_content_label.textColor = [UIColor whiteColor];
    self.webpage_title_label.textColor = [UIColor whiteColor];
    self.webpage_input_textview.tintColor = [UIColor whiteColor];
    
    //isnew=1 is new account creation, isnew=0 is change preference from settings menu
    if (self.isnew == 1)
    {
        PFUser *self_user = [PFUser currentUser];
        NSString *user_email_str = self_user.email;
        PFQuery *person_query = [PFQuery queryWithClassName:@"person"];
        [person_query whereKey:@"email" equalTo:user_email_str];
        [person_query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            if (object != nil)
            {
                NSLog(@"FOUND A MATCH");
                //we have a matching person, this is a registered attendee
                NSString *welcometext = [NSString stringWithFormat:@"Hello %@ %@, please set your email and chat preferences below, you can change these preferences anytime.", object[@"first_name"], object[@"last_name"]];
                self.user_status_label.text = welcometext;
                self_user[@"isperson"] = @1;
                self_user[@"chat_on"] = @1;
                self_user[@"email_on"] = @0;
                [self_user saveEventually];
                person_obj = object;
                person_obj[@"chat_on"] = @1;
                person_obj[@"email_on"] = @0;
                [person_obj saveEventually];
                
                //display webpage controls
                self.webpage_content_label.hidden = FALSE;
                self.webpage_input_textview.hidden = FALSE;
                self.webpage_title_label.hidden = FALSE;
                
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
                self.user_status_label.text = @"Sorry, you do not seem to be a registered attendee. Email and chat functions will not be available. Remember, you must use the same email address you used to register for the workshop.";
                //set "user is not a person"
                self_user[@"isperson"] = @0;
                [self_user saveEventually];
                //gray out and disable controls on this page
                [self.chat_switch setOn:FALSE animated:FALSE];
                self.email_switch.enabled = FALSE;
                self.chat_switch.enabled = FALSE;
                self.email_label.textColor = [UIColor grayColor];
                self.chat_label.textColor = [UIColor grayColor];
                self.email_current_label.textColor = [UIColor grayColor];
                self.chat_current_label.textColor = [UIColor grayColor];
                
                //hide webpage controls
                self.webpage_content_label.hidden = YES;
                self.webpage_input_textview.hidden = YES;
                self.webpage_title_label.hidden = YES;
            }
        }];
    }
    else if (self.isnew == 0)
    {
        PFUser *self_user = [PFUser currentUser];
        NSString *user_email_str = self_user.email;
        PFQuery *person_query = [PFQuery queryWithClassName:@"person"];
        [person_query whereKey:@"email" equalTo:user_email_str];
        [person_query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            if (object != nil)
            {
                NSLog(@"FOUND A MATCH");
                //we have a matching person, this is a registered attendee
                NSString *welcometext = [NSString stringWithFormat:@"Hello %@ %@, please set your email and chat preferences below, then tap Done to leave this page.", object[@"first_name"], object[@"last_name"]];
                self.user_status_label.text = welcometext;
                person_obj = object;
                NSNumber *per_email_num = person_obj[@"email_on"];
                NSNumber *per_chat_num = person_obj[@"chat_on"];
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
                
                //display webpage controls
                self.webpage_content_label.hidden = FALSE;
                self.webpage_input_textview.hidden = FALSE;
                self.webpage_title_label.hidden = FALSE;
                
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
                self.user_status_label.text = @"Sorry, you do not seem to be a registered attendee. Email and chat functions will not be available. Remember, you must use the same email address you used to register for the workshop.";
                //set "user is not a person"
                self_user[@"isperson"] = @0;
                [self_user saveEventually];
                //gray out and disable controls on this page
                [self.chat_switch setOn:FALSE animated:FALSE];
                self.email_switch.enabled = FALSE;
                self.chat_switch.enabled = FALSE;
                self.email_label.textColor = [UIColor grayColor];
                self.chat_label.textColor = [UIColor grayColor];
                self.email_current_label.textColor = [UIColor grayColor];
                self.chat_current_label.textColor = [UIColor grayColor];
                
                //hide webpage controls
                self.webpage_content_label.hidden = YES;
                self.webpage_input_textview.hidden = YES;
                self.webpage_title_label.hidden = YES;
            }
        }];
    }
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
        person_obj[@"email_on"] = @1;
        self_user[@"email_on"] = @1;
        [person_obj saveEventually];
        [self_user saveEventually];
        self.email_current_label.text = @"Current: On";
    }
    else
    {
        NSLog(@"EMAIL SWITCH OFF");
        //switched email sharing to off
        person_obj[@"email_on"] = @0;
        self_user[@"email_on"] = @0;
        [person_obj saveEventually];
        [self_user saveEventually];
        self.email_current_label.text = @"Current: Off";
    }
}

- (IBAction)chat_changed:(UISwitch *)sender {
    PFUser *self_user = [PFUser currentUser];
    if (self.chat_switch.on)
    {
        NSLog(@"CHAT SWITCH ON");
        //switched email sharing to on
        person_obj[@"chat_on"] = @1;
        self_user[@"chat_on"] = @1;
        [person_obj saveEventually];
        [self_user saveEventually];
        self.chat_current_label.text = @"Current On";
        
        // Associate the device with a user
        PFInstallation *installation = [PFInstallation currentInstallation];
        installation[@"user"] = [PFUser currentUser];
        [installation saveInBackground];
        NSLog(@"USER INSTALLATION ASSOCIATED");
        //turn on notifications (push)  ***currently not in use
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setInteger:1 forKey:@"notifications"];
        [defaults synchronize];
    }
    else
    {
        NSLog(@"CHAT SWITCH OFF");
        //switched email sharing to off
        person_obj[@"chat_on"] = @0;
        self_user[@"chat_on"] = @0;
        [person_obj saveEventually];
        [self_user saveEventually];
        self.chat_current_label.text = @"Current Off";
        
        //turn off notifications (push)  ***currently not in use
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setInteger:0 forKey:@"notifications"];
        [defaults synchronize];
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

@end
