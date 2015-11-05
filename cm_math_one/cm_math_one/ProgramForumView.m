//
//  ProgramForumView.m
//  cm_math_one
//
//  Created by csjan on 6/29/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import "ProgramForumView.h"
#import "UIColor+ProjectColors.h"
#import "UIViewController+ParseQueries.h"
#import "ProgramForumCell.h"

NSMutableArray *forumArray;

@implementation ProgramForumView
@synthesize sourceProgram;
@synthesize pullrefresh;
#pragma mark - Interface

- (void)viewDidLoad {
    [super viewDidLoad];

    forumArray = [[NSMutableArray alloc] init];
    self.forumTable.tableFooterView = [[UIView alloc] init];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.forumTable.estimatedRowHeight = 160.0;
    self.forumTable.rowHeight = UITableViewAutomaticDimension;
    self.noForumLabel.hidden = YES;
    self.inputTextField.delegate = self;
    
    //styling
    self.inputBackgroundView.backgroundColor = [UIColor whiteColor];
    self.noForumLabel.textColor = [UIColor dark_primary];
    [self.sendButton setTitleColor:[UIColor dark_accent] forState:UIControlStateNormal];
    
    //data
    [self getForum:self forProgram:sourceProgram];
    
    self.pullrefresh = [[UIRefreshControl alloc] init];
    [pullrefresh addTarget:self action:@selector(refreshctrl:) forControlEvents:UIControlEventValueChanged];
    [self.forumTable addSubview:pullrefresh];
}

- (void)refreshctrl:(id)sender
{
    [self getForum:self forProgram:sourceProgram];
    [(UIRefreshControl *)sender endRefreshing];
}

- (void)viewDidLayoutSubviews
{
    if ([self.forumTable respondsToSelector:@selector(layoutMargins)]) {
        self.forumTable.layoutMargins = UIEdgeInsetsZero;
    }
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


- (IBAction)sendButtonTap:(UIButton *)sender {
    if (self.inputTextField.text.length >0)
    {
        [self postForum:self forProgram:sourceProgram withContent:self.inputTextField.text withAuthor:[PFUser currentUser]];
        [self.inputTextField resignFirstResponder];
    }
}

- (IBAction)refreshButtonTap:(UIBarButtonItem *)sender {
    [self getForum:self forProgram:sourceProgram];
}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return [forumArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ProgramForumCell *cell = [tableView dequeueReusableCellWithIdentifier:@"programforumcell"];
    
    //styling
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.timeLabel.textColor = [UIColor dark_primary];
    
    //data
    PFObject *forum = [forumArray objectAtIndex:indexPath.row];
    
    PFUser *author = forum[@"author"];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateStyle:NSDateFormatterMediumStyle];
    [dateFormat setTimeZone:[NSTimeZone systemTimeZone]];
    [dateFormat setDateFormat: @"MMM-d HH:mm"];
    NSDate *date = forum.createdAt;
    NSString *dateStr = [dateFormat stringFromDate:date];

    cell.timeLabel.text = dateStr;
    cell.authorLabel.text = [NSString stringWithFormat:@"%@ %@", author[@"first_name"], author[@"last_name"]];
    cell.contentLabel.text = forum[@"content"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - Data

- (void)processData: (NSArray *) results;
{
    [forumArray removeAllObjects];
    forumArray = [results mutableCopy];
    [self.forumTable reloadData];
    
    if (forumArray.count >0)
    {
        self.noForumLabel.hidden = YES;
    }
    else
    {
        self.noForumLabel.hidden = NO;
    }
}

- (void)postForumSuccessCallback
{
    self.inputTextField.text = @"";
    [self getForum:self forProgram:sourceProgram];
}

#pragma mark - Keyboard

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    NSValue *kbFrame = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect keyboardFrame = [kbFrame CGRectValue];
    
    CGFloat height = keyboardFrame.size.height;
    
    NSLog(@"Updating constraints: keyboard coming up");
    self.inputbarBottom.constant = height -49;
    
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    NSLog(@"Updating constraints: keyboard coming down");
    self.inputbarBottom.constant = 0;
    
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
}

@end
