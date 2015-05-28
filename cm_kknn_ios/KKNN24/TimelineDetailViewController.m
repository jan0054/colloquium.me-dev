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
    
    //styling
    self.comment_table.backgroundColor = [UIColor clearColor];
    self.view.backgroundColor = [UIColor background];
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
    [super viewDidAppear:YES];
    [self fill_post_data];
    [self get_comment_data];
}

- (void) viewDidLayoutSubviews
{
    //styling
    if ([self.comment_table respondsToSelector:@selector(layoutMargins)]) {
        self.comment_table.layoutMargins = UIEdgeInsetsZero;
    }
}


- (IBAction)post_comment_button_tap:(UIButton *)sender {
    if (self.comment_input.text.length >= 1)
    {
        [self send_new_comment];
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

@end
