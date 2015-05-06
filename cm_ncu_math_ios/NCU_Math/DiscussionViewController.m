//
//  DiscussionViewController.m
//  SQuInT2015
//
//  Created by Chi-sheng Jan on 1/30/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import "DiscussionViewController.h"
#import "DiscussionTableViewCell.h"
#import "UIColor+ProjectColors.h"

@interface DiscussionViewController ()

@end

NSMutableArray *discussion_array;
PFObject *current_person;
BOOL keyboard_up;

@implementation DiscussionViewController
@synthesize pullrefresh;
@synthesize send_button_bottom;
@synthesize table_bottom;
@synthesize textfield_bottom;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
    self.discussion_table.tableFooterView = [[UIView alloc] init];
    discussion_array = [[NSMutableArray alloc] init];
    //Pull To Refresh Controls
    self.pullrefresh = [[UIRefreshControl alloc] init];
    [pullrefresh addTarget:self action:@selector(refreshctrl:) forControlEvents:UIControlEventValueChanged];
    [self.discussion_table addSubview:pullrefresh];
    self.discussion_table.rowHeight = UITableViewAutomaticDimension;
    self.discussion_table.estimatedRowHeight = 60;
    [self.discussion_send_button setTitleColor:[UIColor nu_bright_orange] forState:UIControlStateNormal];
    [self.discussion_send_button setTitleColor:[UIColor nu_bright_orange] forState:UIControlStateHighlighted];
    self.empty_label.hidden = YES;
    
    //if someone is logged in, get the associated person
    if ([PFUser currentUser])
    {
        current_person = [self get_person_with_user:[PFUser currentUser]];
    }
    
    [self get_discussion_data];
    
    keyboard_up = NO;
    
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [self.discussion_table reloadData];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void) viewDidLayoutSubviews
{
    
    if ([self.discussion_table respondsToSelector:@selector(layoutMargins)]) {
        self.discussion_table.layoutMargins = UIEdgeInsetsZero;
    }
}

- (void)refreshctrl:(id)sender
{
    //refresh code here
    [self get_discussion_data];
    
    // End Refreshing
    [(UIRefreshControl *)sender endRefreshing];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    NSValue *kbFrame = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect keyboardFrame = [kbFrame CGRectValue];
    
    CGFloat height = keyboardFrame.size.height;
    
    NSLog(@"Updating constraints: keyboard coming up");
    
    self.textfield_bottom.constant = height -49;
    self.send_button_bottom.constant = height -49;
    self.table_bottom.constant = height -49 + 40;
    
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];

}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    NSLog(@"Updating constraints: keyboard coming down");
    
    self.textfield_bottom.constant = 14;
    self.send_button_bottom.constant = 14;
    self.table_bottom.constant = 57;
    
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [discussion_array count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DiscussionTableViewCell *discussioncell = [tableView dequeueReusableCellWithIdentifier:@"discussioncell"];
    //styling
    discussioncell.selectionStyle = UITableViewCellSelectionStyleNone;
    if ([discussioncell respondsToSelector:@selector(layoutMargins)]) {
        discussioncell.layoutMargins = UIEdgeInsetsZero;
    }
    discussioncell.author_label.textColor = [UIColor light_blue];
    discussioncell.content_label.textColor = [UIColor whiteColor];
    discussioncell.content_label.numberOfLines = 0;
    
    //data
    PFObject *post = [discussion_array objectAtIndex:indexPath.row];
    PFObject *author_person = post[@"author_person"];
    NSString *content = post[@"content"];
    NSString *fname = author_person[@"first_name"];
    NSString *lname = author_person[@"last_name"];
    discussioncell.author_label.text = [NSString stringWithFormat:@"%@ %@", fname, lname];
    discussioncell.content_label.text = content;
    NSLog(@"cell content: %@, %@, %@", fname, lname, content);

    return discussioncell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //dismiss keyboard when tapping
    [self.discussion_input resignFirstResponder];
}

- (IBAction)discussion_send_button_tap:(UIButton *)sender {
    if (self.discussion_input.text.length >1)
    {
        [self send_discussion_post];
        [self.discussion_input resignFirstResponder];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Text field is empty."
                                                       delegate:self
                                              cancelButtonTitle:@"Done"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (void) get_discussion_data
{
    PFQuery *discussion_query = [PFQuery queryWithClassName:@"forum"];
    [discussion_query orderByAscending:@"createdAt"];
    switch (self.event_type) {
        case 0:
            [discussion_query includeKey:@"source_talk"];
            [discussion_query whereKey:@"source_talk" equalTo:self.event_obj];
            break;
        case 1:
            [discussion_query includeKey:@"source_poster"];
            [discussion_query whereKey:@"source_poster" equalTo:self.event_obj];
            break;
        case 2:
            [discussion_query includeKey:@"source_abstract"];
            [discussion_query whereKey:@"source_abstract" equalTo:self.event_obj];
        default:
            [discussion_query includeKey:@"source_talk"];
            [discussion_query whereKey:@"source_talk" equalTo:self.event_obj];
            break;
    }
    [discussion_query includeKey:@"author_person"];
    [discussion_query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"forum query complete with count: %lu", (unsigned long)[objects count]);
        if ([objects count] == 0)
        {
            self.empty_label.hidden = NO;
        }
        [discussion_array removeAllObjects];
        discussion_array = [objects mutableCopy];
        [self.discussion_table reloadData];
    }];
}

- (void) send_discussion_post
{
    PFObject *new_post = [PFObject objectWithClassName:@"forum"];
    if ([PFUser currentUser])
    {
        new_post[@"author_user"] = [PFUser currentUser];
    }
    if (current_person != nil)
    {
        new_post[@"author_person"] = current_person;
    }
    new_post[@"content"] = self.discussion_input.text;
    switch (self.event_type) {
        case 0:
            new_post[@"source_talk"] = self.event_obj;
            break;
        case 1:
            new_post[@"source_poster"] = self.event_obj;
            break;
        case 2:
            new_post[@"source_abstract"] = self.event_obj;
        default:
            new_post[@"source_talk"] = self.event_obj;
            break;
    }
    [new_post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded)
        {
            NSLog(@"new forum post saved successfully");
            [self get_discussion_data];
            [self.discussion_input setText:@""];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:@"Please check network settings or try again later."
                                                           delegate:self
                                                  cancelButtonTitle:@"Done"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }];
}

- (PFObject *) get_person_with_user: (PFUser *) user
{
    // get the associated person *synchronously*
    PFQuery *person_query = [PFQuery queryWithClassName:@"person"];
    [person_query includeKey:@"user"];
    [person_query whereKey:@"user" equalTo:user];
    PFObject *person = [person_query getFirstObject];
    return person;
}


@end
