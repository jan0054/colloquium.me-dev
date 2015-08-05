//
//  TimelineDetailView.m
//  cm_math_one
//
//  Created by csjan on 6/29/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import "TimelineDetailView.h"
#import "UIColor+ProjectColors.h"
#import "UIViewController+ParseQueries.h"
#import "TimelineCommentCell.h"
#import "TimelineDetailImageCell.h"
#import "TimelineDetailTextCell.h"

NSMutableArray *commentArray;

@implementation TimelineDetailView
@synthesize currentPost;
@synthesize currentImage;

#pragma mark - Interface

- (void)viewDidLoad {
    [super viewDidLoad];

    commentArray = [[NSMutableArray alloc] init];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.commentTable.tableFooterView = [[UIView alloc] init];
    
    //data
    [self getComments:self forPost:currentPost];
}

- (void) viewDidLayoutSubviews
{
    //styling
    if ([self.commentTable respondsToSelector:@selector(layoutMargins)]) {
        self.commentTable.layoutMargins = UIEdgeInsetsZero;
    }
}

- (IBAction)sendButtonTap:(UIButton *)sender {
    if (self.inputTextField.text.length >0 && [PFUser currentUser])
    {
        [self sendComment:self forPost:currentPost withContent:self.inputTextField.text withAuthor:[PFUser currentUser]];
    }
}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 2;
    }
    else
    {
        return [commentArray count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TimelineCommentCell *commentcell = [tableView dequeueReusableCellWithIdentifier:@"timelinecommentcell"];
    TimelineDetailTextCell *textcell = [tableView dequeueReusableCellWithIdentifier:@"timelinedetailtextcell"];
    TimelineDetailImageCell *imagecell = [tableView dequeueReusableCellWithIdentifier:@"timelinedetailimagecell"];
    
    //styling
    commentcell.selectionStyle = UITableViewCellSelectionStyleNone;
    textcell.selectionStyle = UITableViewCellSelectionStyleNone;
    imagecell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0)
        {
            PFUser *postAuthor = currentPost[@"author"];
            NSDate *date = currentPost.createdAt;
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat: @"MMM-d HH:mm"];
            NSString *dateString = [dateFormat stringFromDate:date];
            
            textcell.authorLabel.text = [NSString stringWithFormat:@"%@ %@", postAuthor[@"first_name"], postAuthor[@"last_name"]];
            textcell.contentLabel.text = currentPost[@"content"];
            textcell.timeLabel.text = dateString;
            
            return textcell;
        }
        else
        {
            imagecell.postImage.image = currentImage;
            return imagecell;
        }
    }
    else
    {
        PFObject *comment = [commentArray objectAtIndex:indexPath.row];
        PFUser *author = comment[@"author"];
        NSDate *date = comment.createdAt;
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat: @"MMM-d HH:mm"];
        NSString *dateString = [dateFormat stringFromDate:date];
        
        commentcell.authorLabel.text = [NSString stringWithFormat:@"%@ %@", author[@"first_name"], author[@"last_name"]];
        commentcell.contentLabel.text = comment[@"content"];
        commentcell.timeLabel.text =dateString;
        
        return commentcell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - Data

- (void)processData: (NSArray *) results
{
    [commentArray removeAllObjects];
    commentArray = [results mutableCopy];
    [self.commentTable reloadData];
}

- (void)commentPostedCallback
{
    self.inputTextField.text = @"";
    [self getComments:self forPost:currentPost];
}


@end
