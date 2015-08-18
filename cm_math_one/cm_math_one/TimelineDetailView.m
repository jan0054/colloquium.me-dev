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
#import "TimelineCommentEmptyCell.h"

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
    self.commentTable.estimatedRowHeight = 120.0;
    self.commentTable.rowHeight = UITableViewAutomaticDimension;
    self.inputBackgroundView.backgroundColor = [UIColor whiteColor];
    [self.sendButton setTitleColor:[UIColor dark_accent] forState:UIControlStateNormal];
    
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
    [self.inputTextField resignFirstResponder];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
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
        if (commentArray.count>0)
        {
            return [commentArray count];
        }
        else
        {
            return 1;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TimelineCommentCell *commentcell = [tableView dequeueReusableCellWithIdentifier:@"timelinecommentcell"];
    TimelineDetailTextCell *textcell = [tableView dequeueReusableCellWithIdentifier:@"timelinedetailtextcell"];
    TimelineDetailImageCell *imagecell = [tableView dequeueReusableCellWithIdentifier:@"timelinedetailimagecell"];
    TimelineCommentEmptyCell *emptycell = [tableView dequeueReusableCellWithIdentifier:@"emptycell"];
    
    //styling
    commentcell.selectionStyle = UITableViewCellSelectionStyleNone;
    textcell.selectionStyle = UITableViewCellSelectionStyleNone;
    imagecell.selectionStyle = UITableViewCellSelectionStyleNone;
    if ([commentcell respondsToSelector:@selector(layoutMargins)]) {
        commentcell.layoutMargins = UIEdgeInsetsZero;
    }
    if ([textcell respondsToSelector:@selector(layoutMargins)]) {
        textcell.layoutMargins = UIEdgeInsetsZero;
    }
    if ([imagecell respondsToSelector:@selector(layoutMargins)]) {
        imagecell.layoutMargins = UIEdgeInsetsZero;
    }
    emptycell.contentLabel.textColor = [UIColor dark_primary];
    
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0)
        {
            textcell.timeLabel.textColor = [UIColor dark_primary];
            
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
        if (commentArray.count>0)
        {
            commentcell.timeLabel.textColor = [UIColor dark_primary];
            commentcell.authorLabel.textColor = [UIColor dark_primary];
            commentcell.contentLabel.textColor = [UIColor dark_primary];
            
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
        else
        {
            return emptycell;
        }
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

#pragma mark - Keyboard

- (void)keyboardWillShow:(NSNotification *)notification {
    NSLog(@"keyboard will show");
    NSDictionary *info = [notification userInfo];
    NSValue *kbFrame = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect keyboardFrame = [kbFrame CGRectValue];
    CGFloat height = keyboardFrame.size.height;
    
    self.inputBarToBottom.constant = height -49;
    
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSLog(@"keyboard will hide");
    NSDictionary *info = [notification userInfo];
    NSValue *kbFrame = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect keyboardFrame = [kbFrame CGRectValue];
    CGFloat height = keyboardFrame.size.height;
    
    self.inputBarToBottom.constant = 0;
    
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
    
}



@end
