//
//  TimelineViewController.m
//  KKNN24
//
//  Created by csjan on 5/19/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import "TimelineViewController.h"
#import "UIColor+ProjectColors.h"
#import <Parse/Parse.h>
#import "PostCellTableViewCell.h"

@interface TimelineViewController ()

@end

NSMutableArray *post_array;

@implementation TimelineViewController
@synthesize pullrefresh;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //init elements
    post_array = [[NSMutableArray alloc] init];
    self.pullrefresh = [[UIRefreshControl alloc] init];
    [pullrefresh addTarget:self action:@selector(refreshctrl:) forControlEvents:UIControlEventValueChanged];
    [self.timeline_table addSubview:pullrefresh];
    
    //styling
    self.timeline_table.backgroundColor = [UIColor clearColor];
    self.view.backgroundColor = [UIColor background];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.timeline_table.tableFooterView = [[UIView alloc] init];


}

- (void) viewDidLayoutSubviews
{
    //styling
    if ([self.timeline_table respondsToSelector:@selector(layoutMargins)]) {
        self.timeline_table.layoutMargins = UIEdgeInsetsZero;
    }
}

- (void)refreshctrl:(id)sender
{
    [self get_post_data];
    [(UIRefreshControl *)sender endRefreshing];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    [self get_post_data];
}

- (void) get_post_data {
    PFQuery *query = [PFQuery queryWithClassName:@"Post"];
    [query orderByAscending:@"content"];
    [query setLimit:500];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"Post query success: %lu", (unsigned long)[objects count]);
        [post_array removeAllObjects];
        for (PFObject *post_obj in objects)
        {
            [post_array addObject:post_obj];
        }
        [self.timeline_table reloadData];
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return post_array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSString *cellIdentifier = [NSString stringWithFormat:@"cell%d",indexPath.row];
    PostCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"postcell"];
    
    //data source
    PFObject *post = [post_array objectAtIndex:indexPath.row];
    NSString *authorname = post[@"author_name"];
    NSString *content = post[@"content"];
    NSDate *time = post.createdAt;
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat: @"MM-dd HH:mm"];
    NSString *timeString = [dateFormat stringFromDate:time];
    NSLog(@"TIME:%@",timeString);
    cell.author_label.text = authorname;
    cell.content_label.text = content;
    cell.time_label.text = timeString;
    cell.timeline_image.clipsToBounds = YES;
    cell.timeline_image.image = nil;
    cell.timeline_image.file = [post objectForKey:@"image"];
    [cell.timeline_image loadInBackground];
    
    //styling
    if ([cell respondsToSelector:@selector(layoutMargins)]) {
        cell.layoutMargins = UIEdgeInsetsZero;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.timeline_trim.backgroundColor = [UIColor accent_color];
    cell.timeline_background.backgroundColor = [UIColor light_bg];
    cell.author_label.textColor = [UIColor dark_txt];
    cell.time_label.textColor = [UIColor secondary_text];
    cell.content_label.textColor = [UIColor dark_txt];
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:cell.timeline_background.bounds];
    cell.timeline_background.layer.masksToBounds = NO;
    cell.timeline_background.layer.shadowColor = [UIColor blackColor].CGColor;
    cell.timeline_background.layer.shadowOffset = CGSizeMake(0.0f, 3.0f);
    cell.timeline_background.layer.shadowOpacity = 0.3f;
    cell.timeline_background.layer.shadowPath = shadowPath.CGPath;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


- (IBAction)addpost_button_tap:(UIBarButtonItem *)sender {
    [self performSegueWithIdentifier:@"newpostsegue" sender:self];
    
}

@end
