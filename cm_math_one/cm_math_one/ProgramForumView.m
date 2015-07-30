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
@synthesize program;

#pragma mark - Interface

- (void)viewDidLoad {
    [super viewDidLoad];

    forumArray = [[NSMutableArray alloc] init];
    self.forumTable.tableFooterView = [[UIView alloc] init];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.forumTable.estimatedRowHeight = 120.0;
    self.forumTable.rowHeight = UITableViewAutomaticDimension;
    
    //styling
    self.inputBackgroundView.backgroundColor = [UIColor whiteColor];
    
    //data
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *eventid = [defaults objectForKey:@"currentEventId"];
    PFObject *event = [PFObject objectWithoutDataWithClassName:@"Event" objectId:eventid];
    [self getForum:self forProgram:program];
    
    
}

- (void)viewDidLayoutSubviews
{
    if ([self.forumTable respondsToSelector:@selector(layoutMargins)]) {
        self.forumTable.layoutMargins = UIEdgeInsetsZero;
    }
}

- (IBAction)sendButtonTap:(UIButton *)sender {
    
}

- (IBAction)refreshButtonTap:(UIBarButtonItem *)sender {
    [self getForum:self forProgram:program];
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
}

- (void)postForumSuccessCallback
{
    [self getForum:self forProgram:program];
}

@end
