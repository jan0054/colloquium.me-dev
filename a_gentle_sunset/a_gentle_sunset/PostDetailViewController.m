//
//  PostDetailViewController.m
//  a_gentle_sunset
//
//  Created by csjan on 4/8/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import "PostDetailViewController.h"
#import "PostCommentCell.h"

@interface PostDetailViewController ()

@end

NSMutableArray *comment_array;

@implementation PostDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    comment_array = [[NSMutableArray alloc] init];
    
    [self fillData];
    [self getCommentData];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [comment_array count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PostCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"postcommentcell"];
    
    PFObject *object = [comment_array objectAtIndex:indexPath.row];
    cell.comment_content.text = [object objectForKey:@"content"];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat: @"yyyy-MM-dd HH:mm"];
    NSDate *created = [object objectForKey:@"createdAt"];
    NSString *dateString = [dateFormat stringFromDate:created];
    cell.comment_time.text = dateString;
    cell.comment_author.text = [object objectForKey:@"author_name"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void) fillData {
    self.post_content.text = self.timeline_content;
    self.post_elder_name.text = self.timeline_elder;
    self.post_author_name.text = self.timeline_author;
    self.post_time.text = self.timeline_time;
    self.post_image.image = [UIImage imageNamed:@"placeholder_image"];
    self.post_image.file = [self.timeline_post objectForKey:@"image"];
    [self.post_image loadInBackground];
}

- (void) getCommentData {
    PFQuery *query = [PFQuery queryWithClassName:@"comment"];
    [query orderByDescending:@"createdAt"];
    [query setLimit:100];
    [query includeKey:@"post"];
    [query whereKey:@"post" equalTo:self.timeline_post];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [comment_array removeAllObjects];
        comment_array = [objects mutableCopy];
        [self.comment_table reloadData];
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
