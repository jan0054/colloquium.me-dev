//
//  PositionPostViewController.m
//  SQuInT2015
//
//  Created by csjan on 2/5/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import "PositionPostViewController.h"
#import "UIColor+ProjectColors.h"

@interface PositionPostViewController ()

@end

BOOL kb_is_shown;
UITextField *active_input;
PFObject *self_person;

@implementation PositionPostViewController
@synthesize career_post_type;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self get_self_person];
    
    //config keyboard stuff
    self.background_scroll_view.delegate = self;
    CGSize scrollContentSize = CGSizeMake(320, 505);
    self.background_scroll_view.contentSize = scrollContentSize;
    kb_is_shown = NO;
    self.contact_name_tf.delegate = self;
    self.contact_email_tf.delegate = self;
    self.institution_tf.delegate = self;
    self.position_tf.delegate = self;
    self.time_duration_tf.delegate = self;
    self.description_tf.delegate = self;
    self.link_tf.delegate = self;
    
    //styling
    self.view.backgroundColor = [UIColor background];
    
    //adjust label text according to post type
    if ( self.career_post_type == 1)
    {
        self.contact_name_label.text = @"Name:";
        self.contact_email_label.text = @"Contact email:";
        self.position_label.text = @"Seeking position:";
        self.institution_label.text = @"Education (degree/institution):";
        self.time_duration_label.text = @"(Expected) Date of degree:";
        self.description_label.text = @"Short self description:";
        self.link_label.text = @"Web page: (optional)";
    }
}

- (void) post_data
{
    PFObject *new_career = [PFObject objectWithClassName:@"career"];
    new_career[@"offer_seek"] = [NSNumber numberWithInt:self.career_post_type];
    new_career[@"contact_name"] = self.contact_name_tf.text;
    new_career[@"contact_email"] = self.contact_email_tf.text;
    new_career[@"position"] = self.position_tf.text;
    new_career[@"institution"] = self.institution_tf.text;
    new_career[@"time_duration"] = self.time_duration_tf.text;
    new_career[@"description"] = self.description_tf.text;
    new_career[@"link"] = self.link_tf.text;
    new_career[@"posted_by"] = self_person;
    [new_career saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded)
        {
            //post success
            NSLog(@"career posted successfully");
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }];
    
}

- (BOOL) check_fields_done
{
    if (self.contact_name_tf.text.length <= 1)
    {
        return NO;
    }
    else if (self.contact_email_tf.text.length <=1)
    {
        return NO;
    }
    else if (self.position_tf.text.length <=1)
    {
        return NO;
    }
    else if (self.institution_tf.text.length <=1)
    {
        return NO;
    }
    else if (self.time_duration_tf.text.length <=1)
    {
        return NO;
    }
    else if (self.description_tf.text.length <=1)
    {
        return NO;
    }
    else
    {
        return YES;
    }
}

- (IBAction)confirm_post_button_tap:(UIBarButtonItem *)sender {
    if ([self check_fields_done])
    {
        [self post_data];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Please fill in all fields"
                                                       delegate:self
                                              cancelButtonTitle:@"Done"
                                              otherButtonTitles:nil];
        [alert show];

    }
}

- (IBAction)cancel_post_button_tap:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardDidHideNotification object:nil];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
}

//grab the current active input field
- (void) textFieldDidBeginEditing:(UITextField *)textField
{
    active_input = textField;
    NSLog(@"TEXTFIELD:%@", active_input);
}
- (void) textFieldDidEndEditing:(UITextField *)textField
{
    active_input = nil;
}

- (void)keyboardWillShow:(NSNotification *)notification {

    if (!kb_is_shown)
    {
        NSDictionary* info = [notification userInfo];
        CGRect keyPadFrame=[[UIApplication sharedApplication].keyWindow convertRect:[[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue] fromView:self.view];
        CGSize kbSize =keyPadFrame.size;
        CGRect activeRect=[self.view convertRect:active_input.frame fromView:active_input.superview];
        CGRect aRect = self.view.bounds;
        aRect.size.height -= (kbSize.height);
        
        CGPoint origin =  activeRect.origin;
        origin.y -= self.background_scroll_view.contentOffset.y;
        if (!CGRectContainsPoint(aRect, origin)) {
            CGPoint scrollPoint = CGPointMake(0.0,CGRectGetMaxY(activeRect)-(aRect.size.height));
            [self.background_scroll_view setContentOffset:scrollPoint animated:YES];
        }
        kb_is_shown = YES;
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary* info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    NSLog(@"keyboard will hide");
    
    // resize the scrollView
    CGRect viewFrame = self.background_scroll_view.frame;
    viewFrame.size.height += kbSize.height;
    [self.background_scroll_view setFrame:viewFrame];
    
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.background_scroll_view.contentInset = contentInsets;
    self.background_scroll_view.scrollIndicatorInsets = contentInsets;
    kb_is_shown = NO;
}

- (void) get_self_person
{
    if ([PFUser currentUser])
    {
        //ok, there's someone logged in, check if it's a registered attendee
        NSNumber *isperson = [PFUser currentUser][@"isperson"];
        int isperson_int = [isperson intValue];
        if (isperson_int == 1)
        {
            //ok, its a registered attendee, get the person
            self_person = [PFUser currentUser][@"person"];
        }
    }
}


@end
