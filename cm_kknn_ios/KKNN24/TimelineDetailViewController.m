//
//  TimelineDetailViewController.m
//  KKNN24
//
//  Created by csjan on 5/19/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import "TimelineDetailViewController.h"
#import "CommentCellTableViewCell.h"
#import "CommentParentCellTableViewCell.h"

@interface TimelineDetailViewController ()

@end

NSMutableArray *comment_array;
BOOL image_set;
BOOL is_person;

@implementation TimelineDetailViewController
@synthesize post;
@synthesize post_author_name;
@synthesize post_content;
@synthesize post_time;
@synthesize image;

#pragma mark - Interface

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //init
    comment_array = [[NSMutableArray alloc] init];
    if (image == nil)
    {
        image_set = NO;
    }
    else
    {
        image_set = YES;
    }
    self.comment_table.rowHeight = UITableViewAutomaticDimension;
    self.comment_table.estimatedRowHeight = 320.0;
    self.bottom_screen_spacing.active = NO;
    is_person = [self check_is_person];
    
    //styling
    self.comment_table.backgroundColor = [UIColor clearColor];
    self.view.backgroundColor = [UIColor dark_primary];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.comment_table.tableFooterView = [[UIView alloc] init];
    self.post_background.backgroundColor = [UIColor light_bg];
    self.author_label.textColor = [UIColor dark_txt];
    self.time_label.textColor = [UIColor secondary_text];
    self.content_label.textColor = [UIColor dark_txt];
    self.content_label.backgroundColor = [UIColor clearColor];
    self.input_background.backgroundColor = [UIColor light_bg];
    [self.post_comment_button setTitleColor:[UIColor dark_button_txt] forState:UIControlStateNormal];
    [self.post_comment_button setTitleColor:[UIColor accent_color] forState:UIControlStateHighlighted];
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:self.input_background.bounds];
    self.input_background.layer.masksToBounds = NO;
    self.input_background.layer.shadowColor = [UIColor blackColor].CGColor;
    self.input_background.layer.shadowOffset = CGSizeMake(0.0f, -2.0f);
    self.input_background.layer.shadowOpacity = 0.3f;
    self.input_background.layer.shadowPath = shadowPath.CGPath;

}

- (void) viewDidAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [super viewDidAppear:animated];
    [self fill_post_data];
    [self get_comment_data];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void) viewDidLayoutSubviews
{
    //styling
    if ([self.comment_table respondsToSelector:@selector(layoutMargins)]) {
        self.comment_table.layoutMargins = UIEdgeInsetsZero;
    }
}


- (IBAction)post_comment_button_tap:(UIButton *)sender {
    if (is_person)
    {
        if (self.comment_input.text.length >= 1)
        {
            [self send_new_comment];
            [self.comment_input resignFirstResponder];
        }
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Sorry, You need to be an event attendee to comment on posts."
                                                       delegate:self
                                              cancelButtonTitle:@"Done"
                                              otherButtonTitles:nil];
        [alert show];
    }
    
}

#pragma mark - Data

- (void) fill_post_data {
    self.author_label.text = [NSString stringWithFormat:@"%@:", post_author_name];
    self.content_label.text = post_content;
    self.time_label.text = post_time;
}

- (void) get_comment_data {
    PFQuery *query = [PFQuery queryWithClassName:@"Comment"];
    [query whereKey:@"post" equalTo:post];
    [query orderByDescending:@"createdAt"];
    [query setLimit:500];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error)
        {
            [comment_array removeAllObjects];
            NSLog(@"Successfully retrieved %lu comments for the post.", (unsigned long)objects.count);
            comment_array = [objects mutableCopy];
            [self.comment_table reloadData];
        }
        else
        {
            // Log details of the failure if there's an error
            NSLog(@"Error fetching comments: %@ %@", error, [error userInfo]);
        }
    }];
}

- (void) send_new_comment {
    NSString *content = self.comment_input.text;
    PFObject *comment = [PFObject objectWithClassName:@"Comment"];
    comment[@"content"] = content;
    PFUser *user = [PFUser currentUser];
    comment[@"author"] = user;
    comment[@"author_name"] = user[@"username"];
    comment[@"post"] = post;
    [comment saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded)
        {
            NSLog(@"Successfully published new comment");
            self.comment_input.text = @"";
            [self get_comment_data];
        }
        else
        {
            NSLog(@"Error posting comment: %@ %@", error, [error userInfo]);
        }
    }];
}

- (BOOL) check_is_person {
    if ([PFUser currentUser]) {
        PFUser *user = [PFUser currentUser];
        NSNumber *is_person = user[@"is_person"];
        int is_person_int = [is_person intValue];
        if (is_person_int == 1) {
            return YES;
        }
        else
        {
            return NO;
        }
    }
    else {
        return NO;
    }
}

#pragma mark - Tableview

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (image_set == NO)
    {
        return comment_array.count;
    }
    else
    {
        return comment_array.count+1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CommentCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"commentcell"];
    CommentParentCellTableViewCell *imagecell = [tableView dequeueReusableCellWithIdentifier:@"commentparentcell"];
    
    if (image_set == YES && indexPath.row == 0)
    {
        imagecell.post_image.image = image;
        imagecell.post_image.clipsToBounds = YES;
        return imagecell;
    }
    
    //data source
    PFObject *comment = [PFObject alloc];
    if (image_set == NO)
    {
        comment = [comment_array objectAtIndex:indexPath.row];
    }
    else
    {
        comment = [comment_array objectAtIndex:indexPath.row-1];
    }
    NSString *authorname = comment[@"author_name"];
    NSString *content = comment[@"content"];
    NSDate *time = comment.createdAt;
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat: @"MM-dd HH:mm"];
    NSString *timeString = [dateFormat stringFromDate:time];
    NSLog(@"TIME:%@",timeString);
    cell.comment_author_label.text = [NSString stringWithFormat:@"%@:",authorname];
    cell.comment_content_label.text = content;
    cell.comment_time_label.text = timeString;
    
    //styling
    if ([cell respondsToSelector:@selector(layoutMargins)]) {
        cell.layoutMargins = UIEdgeInsetsZero;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    cell.comment_author_label.textColor = [UIColor light_txt];
    cell.comment_content_label.textColor = [UIColor light_txt];
    cell.comment_time_label.textColor = [UIColor light_txt];
    
    return cell;
}

#pragma mark - Keyboard

- (void)keyboardWillShow:(NSNotification *)notification {
    NSLog(@"keyboard will show");
    //self.dismiss_keyboard_button.hidden = NO;
    NSDictionary *info = [notification userInfo];
    NSValue *kbFrame = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect keyboardFrame = [kbFrame CGRectValue];
    CGFloat height = keyboardFrame.size.height;
    self.bottom_tabbar_spacing.active = NO;
    self.bottom_screen_spacing.active = YES;
    self.bottom_screen_spacing.constant = height;
    
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSLog(@"keyboard will hide");
    //self.dismiss_keyboard_button.hidden = YES;
    NSDictionary *info = [notification userInfo];
    NSValue *kbFrame = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect keyboardFrame = [kbFrame CGRectValue];
    CGFloat height = keyboardFrame.size.height;
    self.bottom_screen_spacing.active = NO;
    self.bottom_tabbar_spacing.active = YES;
    
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
}

@end
